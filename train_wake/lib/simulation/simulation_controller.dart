import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:train_wake/simulation/simulation_engine.dart';
import 'package:train_wake/features/active_trip/active_trip_screen.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'package:train_wake/trip/alarm_engine.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SimulationStatus
// ─────────────────────────────────────────────────────────────────────────────

enum SimulationStatus { idle, running, paused, terminal }

// ─────────────────────────────────────────────────────────────────────────────
// SimulationControllerState — the Notifier state
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable state exposed to the UI.
class SimulationControllerState {
  final SimulationStatus status;
  final double multiplier;
  final SimulationFrame? lastFrame;
  final String activeRouteName;

  const SimulationControllerState({
    this.status = SimulationStatus.idle,
    this.multiplier = 1.0,
    this.lastFrame,
    this.activeRouteName = 'Cairo ➔ Giza (Express Test)',
  });

  SimulationControllerState copyWith({
    SimulationStatus? status,
    double? multiplier,
    SimulationFrame? lastFrame,
    String? activeRouteName,
  }) {
    return SimulationControllerState(
      status: status ?? this.status,
      multiplier: multiplier ?? this.multiplier,
      lastFrame: lastFrame ?? this.lastFrame,
      activeRouteName: activeRouteName ?? this.activeRouteName,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SimulationController — Riverpod Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Owns the [SimulationEngine] and orchestrates the simulation loop.
class SimulationController extends Notifier<SimulationControllerState> {
  SimulationEngine? _engine;
  Timer? _timer;

  /// Real Egyptian Railway presets
  static final Map<String, List<LatLng>> presetRoutes = {
    'Cairo ➔ Giza (Express Test)': [
      const LatLng(30.0636, 31.2464), // Cairo Ramses
      const LatLng(30.0450, 31.2300),
      const LatLng(30.0300, 31.2150),
      const LatLng(30.0150, 31.2090),
      const LatLng(30.0055, 31.2052), // Giza
    ],
    'Cairo ➔ Alexandria (Misr Express)': [
      const LatLng(30.0636, 31.2464), // Cairo Ramses
      const LatLng(30.1830, 31.2057), // Qalyub
      const LatLng(30.4632, 31.1818), // Banha
      const LatLng(30.7871, 31.0011), // Tanta
      const LatLng(31.0375, 30.4694), // Damanhour
      const LatLng(31.2185, 29.9392), // Sidi Gaber
      const LatLng(31.1925, 29.9056), // Alex Misr
    ],
    'Cairo ➔ Asyut (Upper Egypt Line)': [
      const LatLng(30.0636, 31.2464), // Cairo Ramses
      const LatLng(30.0055, 31.2052), // Giza
      const LatLng(29.0734, 31.0978), // Beni Suef
      const LatLng(28.1130, 30.7495), // Minya
      const LatLng(27.7324, 30.8406), // Mallawi
      const LatLng(27.1824, 31.1843), // Asyut
    ],
  };

  static final List<LatLng> _demoRoute = presetRoutes['Cairo ➔ Giza (Express Test)']!;

  @override
  SimulationControllerState build() => const SimulationControllerState();

  // ── Lifecycle controls ───────────────────────────────────────────────────

  /// Switches active route
  void selectRoute(String routeName) {
    final route = presetRoutes[routeName] ?? _demoRoute;
    state = state.copyWith(activeRouteName: routeName);
    if (state.status == SimulationStatus.running || state.status == SimulationStatus.paused) {
      start(route: route);
    }
  }

  /// Starts a fresh simulation. Uses [route] if provided, otherwise active preset.
  void start({
    List<LatLng>? route,
    double speedMps = 25.0,
    double noiseMeters = 0.0,
    double gpsAccuracy = 5.0,
    double wakeOffsetSeconds = 600.0,
  }) {
    _cancelTimer();
    final chosenRoute = route ?? presetRoutes[state.activeRouteName] ?? _demoRoute;
    _engine = SimulationEngine(
      baseSpeedMps: speedMps,
      gpsNoiseMeters: noiseMeters,
      simulatedGpsAccuracy: gpsAccuracy,
      wakeOffsetSeconds: wakeOffsetSeconds,
    )..routeGeometry = chosenRoute;

    _engine!.start();

    // Update matchedPositionProvider with route start immediately
    ref.read(matchedPositionProvider.notifier).set(_engine!.routeGeometry.first);
    ref.read(routeGeometryProvider.notifier).set(_engine!.routeGeometry);

    state = state.copyWith(status: SimulationStatus.running);
    _startTimer();
  }

  /// Pauses the simulation loop. Engine state is preserved.
  void pause() {
    _cancelTimer();
    state = state.copyWith(status: SimulationStatus.paused);
  }

  /// Resumes a paused simulation.
  void resume() {
    if (state.status != SimulationStatus.paused) return;
    state = state.copyWith(status: SimulationStatus.running);
    _startTimer();
  }

  /// Resets everything to idle. Clears all production provider state.
  void reset() {
    _cancelTimer();
    _engine?.reset();
    _engine = null;
    // Reset production providers back to neutral defaults
    ref.read(tripStateProvider.notifier).set(TripState.tracking);
    ref.read(alarmStateProvider.notifier).set(AlarmState.armed);
    ref.read(matchedPositionProvider.notifier).set(null);
    state = const SimulationControllerState();
  }

  /// Changes the playback speed multiplier.
  /// If currently running, restarts the timer at the new interval.
  void setMultiplier(double multiplier) {
    state = state.copyWith(multiplier: multiplier);
    if (state.status == SimulationStatus.running) {
      _cancelTimer();
      _startTimer();
    }
  }

  // ── Developer force actions (routed through engine, NOT through providers) ──

  /// All force* methods delegate to SimulationEngine's engine-level hooks.
  /// They do NOT write to Riverpod providers directly from the UI.
  void forceEarlyWarning() {
    _engine?.forceEarlyWarning();
    _syncProvidersFromEngine();
  }

  void forceAlarm() {
    _engine?.forceAlarm();
    _syncProvidersFromEngine();
  }

  void forceArrival() {
    _engine?.forceArrival();
    _cancelTimer();
    _syncProvidersFromEngine();
    state = state.copyWith(status: SimulationStatus.terminal);
  }

  void forceMissed() {
    _engine?.forceMissed();
    _cancelTimer();
    _syncProvidersFromEngine();
    state = state.copyWith(status: SimulationStatus.terminal);
  }

  void forceGpsLoss() {
    _engine?.forceGpsLoss();
  }

  void forceGpsRecovery() {
    _engine?.forceGpsRecovery();
  }

  void forceStationStop() {
    _engine?.baseSpeedMps = 0.0;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  /// Timer interval: 1000ms ÷ multiplier.
  /// Each tick = exactly 1 simulated second (deterministic).
  void _startTimer() {
    final intervalMs = (1000.0 / state.multiplier).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) => _onTick());
  }

  void _cancelTimer() => _timer?.cancel();

  void _onTick() {
    final engine = _engine;
    if (engine == null) return;

    final frame = engine.tick();
    if (frame == null) {
      // Terminal or not started
      if (engine.isTerminal) {
        _cancelTimer();
        state = state.copyWith(status: SimulationStatus.terminal);
      }
      return;
    }

    // Sync production providers from the engine-computed frame.
    // This is the ONLY place production providers are updated by simulation.
    // It is the SimulationController's responsibility, not the DeveloperScreen.
    ref.read(tripStateProvider.notifier).set(frame.tripState);
    ref.read(alarmStateProvider.notifier).set(frame.alarmState);
    ref.read(matchedPositionProvider.notifier).set(frame.matchedPosition);

    state = state.copyWith(lastFrame: frame);

    if (engine.isTerminal) {
      _cancelTimer();
      state = state.copyWith(status: SimulationStatus.terminal);
    }
  }

  /// Syncs providers from current engine state (used after force actions).
  void _syncProvidersFromEngine() {
    final engine = _engine;
    if (engine == null) return;
    ref.read(tripStateProvider.notifier).set(engine.tripState);
    ref.read(alarmStateProvider.notifier).set(engine.alarmState);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final simulationControllerProvider =
    NotifierProvider<SimulationController, SimulationControllerState>(
  SimulationController.new,
);
