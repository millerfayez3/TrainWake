import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'package:train_wake/routing/railway_matcher.dart';
import 'package:train_wake/routing/direction_detector.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'package:train_wake/trip/eta_engine.dart';
import 'package:train_wake/trip/alarm_engine.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SimulationFrame — read-only snapshot (output model, not source of truth)
// ─────────────────────────────────────────────────────────────────────────────

/// A read-only snapshot of one simulation tick.
/// This is produced by [SimulationEngine] and consumed by [SimulationController]
/// to sync Riverpod providers and by [DeveloperScreen] to display diagnostics.
/// It is NOT the source of truth — the engines inside [SimulationEngine] are.
class SimulationFrame {
  final LatLng rawPosition;
  final LatLng matchedPosition;
  final double progressMeters;
  final double destinationMeters;
  final double remainingMeters;
  final double speedMps;
  final double? etaSeconds;
  final double routeConfidence;
  final double gpsAccuracy;
  final bool? travelingForward;
  final TripState tripState;
  final AlarmState alarmState;

  const SimulationFrame({
    required this.rawPosition,
    required this.matchedPosition,
    required this.progressMeters,
    required this.destinationMeters,
    required this.remainingMeters,
    required this.speedMps,
    required this.etaSeconds,
    required this.routeConfidence,
    required this.gpsAccuracy,
    required this.travelingForward,
    required this.tripState,
    required this.alarmState,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SimulationEngine — pure Dart, no Flutter/Riverpod dependency
// ─────────────────────────────────────────────────────────────────────────────

/// Drives the full production pipeline with synthesized GPS.
///
/// **Tick semantics (deterministic):**
/// Each call to [tick] advances exactly [baseSpeedMps] × 1 simulated-second
/// worth of distance — regardless of who calls it.
/// The timer interval in [SimulationController] controls playback speed:
///   - 1x  → timer fires every 1000 ms  → 1 sim-second per real-second
///   - 20x → timer fires every   50 ms  → 20 sim-seconds per real-second
/// Tests call tick() directly N times and are fully deterministic (no wall-clock).
///
/// **Full production pipeline per tick:**
///   synthesized LatLng
///   → [RailwayMatcher.matchToRoute]
///   → [DirectionDetector.isTravelingForward]
///   → [TripEngine.updateProgress]
///   → [EtaEngine.calculateEta]
///   → [AlarmEngine.evaluate]
///   → [SimulationFrame] (output snapshot)
///
/// Has NO Flutter or Riverpod dependency.
class SimulationEngine {
  // ── Production pipeline (these are the real engines, not fakes) ────────────
  final TripEngine _tripEngine = TripEngine();
  final EtaEngine _etaEngine = EtaEngine();
  final AlarmEngine _alarmEngine;
  final RailwayMatcher _matcher = RailwayMatcher();
  final DirectionDetector _directionDetector = DirectionDetector();

  // ── Route ─────────────────────────────────────────────────────────────────
  /// Waypoints the simulation travels along. Must be set before [start].
  List<LatLng> routeGeometry = [];
  double _totalRouteLength = 0.0;

  // ── Cursor ────────────────────────────────────────────────────────────────
  /// Current position in meters along the route.
  double _cursorDistance = 0.0;

  // ── Direction detection window ────────────────────────────────────────────
  final List<LatLng> _recentPositions = [];
  static const int _positionHistoryMax = 5;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _started = false;

  // ── Configuration ─────────────────────────────────────────────────────────
  /// Movement speed in m/s. Set by the DeveloperScreen speed slider.
  double baseSpeedMps;

  /// Noise radius in meters applied to the raw synthesized position BEFORE
  /// passing to RailwayMatcher. Zero = perfect GPS.
  double gpsNoiseMeters;

  /// The accuracy value reported to TripEngine (low value = good GPS).
  /// Values > 100 m trigger gpsUncertain in TripEngine.
  double simulatedGpsAccuracy;

  /// Seeded for reproducibility in tests. Defaults to unseeded (random).
  final math.Random _random;

  SimulationEngine({
    this.baseSpeedMps = 20.0,
    this.gpsNoiseMeters = 0.0,
    this.simulatedGpsAccuracy = 5.0,
    double wakeOffsetSeconds = 600.0,
    int? randomSeed,
  })  : _alarmEngine = AlarmEngine(wakeOffsetSeconds: wakeOffsetSeconds),
        _random = randomSeed != null ? math.Random(randomSeed) : math.Random();

  // ── Read-only state accessors ─────────────────────────────────────────────
  TripState get tripState => _tripEngine.currentState;
  AlarmState get alarmState => _alarmEngine.currentState;
  double get cursorDistance => _cursorDistance;
  double get totalRouteLength => _totalRouteLength;
  bool get started => _started;

  bool get isTerminal =>
      _tripEngine.currentState == TripState.arrived ||
      _tripEngine.currentState == TripState.missed ||
      _tripEngine.currentState == TripState.ended;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Starts the trip. Call once before the first [tick].
  /// No-op if routeGeometry has fewer than 2 points.
  void start() {
    if (routeGeometry.length < 2) return;
    _totalRouteLength = _computeRouteLength(routeGeometry);
    _cursorDistance = 0.0;
    _recentPositions.clear();
    _started = true;
    _tripEngine.startTrip(_totalRouteLength);
    _alarmEngine.restoreState(AlarmState.armed);
  }

  /// Resets all engines and internal state back to pre-start.
  /// Parameters optionally override configuration.
  void reset({
    double? speedMps,
    double? noiseMeters,
    double? accuracy,
  }) {
    if (speedMps != null) baseSpeedMps = speedMps;
    if (noiseMeters != null) gpsNoiseMeters = noiseMeters;
    if (accuracy != null) simulatedGpsAccuracy = accuracy;
    _cursorDistance = 0.0;
    _recentPositions.clear();
    _started = false;
    _tripEngine.reset();
    _etaEngine.reset();
    _alarmEngine.restoreState(AlarmState.notArmed);
  }

  // ── Core tick ─────────────────────────────────────────────────────────────

  /// Advances exactly one simulated second of travel.
  ///
  /// Returns a [SimulationFrame] snapshot, or null if:
  /// - not yet started, or
  /// - routeGeometry is too short, or
  /// - the engine is in a terminal state.
  ///
  /// **The returned frame is a read-only output model.**
  /// The authoritative state lives inside the production engines.
  SimulationFrame? tick() {
    if (!_started || isTerminal) return null;
    if (routeGeometry.length < 2) return null;

    // 1. Advance cursor by exactly 1 simulated second of travel.
    final distanceThisTick = baseSpeedMps; // meters = m/s * 1 simulated-second
    _cursorDistance = (_cursorDistance + distanceThisTick).clamp(0.0, _totalRouteLength);

    // 2. Synthesize ideal position, then apply noise BEFORE matching.
    //    noise → RailwayMatcher ensures production matcher sees realistic inputs.
    final idealPosition = _positionAtDistance(_cursorDistance, routeGeometry);
    final rawPosition = _applyNoise(idealPosition, gpsNoiseMeters);

    // 3. RailwayMatcher — snaps raw GPS to nearest route segment.
    final matched = _matcher.matchToRoute(
      currentPosition: rawPosition,
      routeGeometry: routeGeometry,
    );
    final matchedPosition = matched.snappedPoint;
    final progressMeters = matched.progressMeters;

    // 4. DirectionDetector — informational; confirms forward travel.
    _recentPositions.add(rawPosition);
    if (_recentPositions.length > _positionHistoryMax) {
      _recentPositions.removeAt(0);
    }
    final travelingForward = _directionDetector.isTravelingForward(
      recentLocations: _recentPositions,
      routeGeometry: routeGeometry,
    );

    // 5. TripEngine — production state machine.
    _tripEngine.updateProgress(progressMeters, baseSpeedMps, simulatedGpsAccuracy);
    
    // Read the monotonic progress verified and stored by TripEngine
    final monotonicProgress = _tripEngine.context.currentProgressMeters;

    final remaining = (_totalRouteLength - monotonicProgress).clamp(0.0, double.infinity);

    // 6. EtaEngine — production ETA calculation.
    final eta = _etaEngine.calculateEta(
      remainingDistanceMeters: remaining,
      currentSpeedMps: baseSpeedMps,
      confidence: _tripEngine.context.gpsConfidence,
    );

    // 7. AlarmEngine — production alarm evaluation.
    if (eta != null) {
      _alarmEngine.evaluate(
        etaSeconds: eta,
        confidence: _tripEngine.context.gpsConfidence,
        remainingDistanceMeters: remaining,
      );
    }

    // 8. Return read-only snapshot for consumers.
    return SimulationFrame(
      rawPosition: rawPosition,
      matchedPosition: matchedPosition,
      progressMeters: monotonicProgress,
      destinationMeters: _totalRouteLength,
      remainingMeters: remaining,
      speedMps: baseSpeedMps,
      etaSeconds: eta,
      routeConfidence: _tripEngine.context.routeConfidence,
      gpsAccuracy: simulatedGpsAccuracy,
      travelingForward: travelingForward,
      tripState: _tripEngine.currentState,
      alarmState: _alarmEngine.currentState,
    );
  }

  // ── Developer / test force actions ────────────────────────────────────────
  // These route through engine-level hooks, NOT through Riverpod providers.
  // They use the existing AlarmEngine.restoreState() and TripEngine.forceState()
  // developer hooks — they do not bypass idempotency or safety invariants.

  /// Forces early warning. Idempotent — same call twice is safe.
  void forceEarlyWarning() =>
      _alarmEngine.restoreState(AlarmState.earlyWarningTriggered);

  /// Forces main alarm to unacknowledged. Idempotent.
  void forceAlarm() => _alarmEngine.restoreState(AlarmState.unacknowledged);

  /// Forces TripState to arrived. Stops further ticking (isTerminal = true).
  void forceArrival() => _tripEngine.forceState(TripState.arrived);

  /// Forces TripState to missed. Stops further ticking (isTerminal = true).
  void forceMissed() => _tripEngine.forceState(TripState.missed);

  /// Simulates GPS loss — accuracy > 100m triggers gpsUncertain in TripEngine.
  void forceGpsLoss() => simulatedGpsAccuracy = 200.0;

  /// Restores simulated GPS quality.
  void forceGpsRecovery() => simulatedGpsAccuracy = 5.0;

  // ── Spatial helpers (static / pure functions) ─────────────────────────────

  static final _distCalc = const Distance();

  /// Sums segment lengths to get total route length in meters.
  static double _computeRouteLength(List<LatLng> geometry) {
    double total = 0.0;
    for (int i = 0; i < geometry.length - 1; i++) {
      total += _distCalc.distance(geometry[i], geometry[i + 1]);
    }
    return total;
  }

  /// Returns the LatLng at [distanceMeters] along [geometry] via linear
  /// interpolation between waypoints.
  static LatLng _positionAtDistance(double distanceMeters, List<LatLng> geometry) {
    double accumulated = 0.0;
    for (int i = 0; i < geometry.length - 1; i++) {
      final segLen = _distCalc.distance(geometry[i], geometry[i + 1]);
      if (accumulated + segLen >= distanceMeters) {
        final fraction = (distanceMeters - accumulated) / segLen;
        final lat = geometry[i].latitude +
            fraction * (geometry[i + 1].latitude - geometry[i].latitude);
        final lng = geometry[i].longitude +
            fraction * (geometry[i + 1].longitude - geometry[i].longitude);
        return LatLng(lat, lng);
      }
      accumulated += segLen;
    }
    return geometry.last;
  }

  /// Applies uniform random noise in meters to a LatLng position.
  /// Uses flat-earth approximation (valid for small noise values).
  LatLng _applyNoise(LatLng position, double noiseMeters) {
    if (noiseMeters <= 0) return position;
    const metersPerDegreeLat = 111320.0;
    final metersPerDegreeLng =
        metersPerDegreeLat * math.cos(position.latitude * math.pi / 180.0);
    final dLat = (_random.nextDouble() * 2 - 1) * noiseMeters / metersPerDegreeLat;
    final dLng = (_random.nextDouble() * 2 - 1) * noiseMeters / metersPerDegreeLng;
    return LatLng(position.latitude + dLat, position.longitude + dLng);
  }
}
