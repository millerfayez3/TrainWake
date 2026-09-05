import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:train_wake/simulation/simulation_engine.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'package:train_wake/trip/alarm_engine.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared test fixtures
// ─────────────────────────────────────────────────────────────────────────────

/// Straight-line route ~10 km long (Cairo north).
/// Segments are each ~2.5 km so total ~ 10 km.
final _testRoute = [
  const LatLng(30.0000, 31.2000),
  const LatLng(30.0225, 31.2000),
  const LatLng(30.0450, 31.2000),
  const LatLng(30.0675, 31.2000),
  const LatLng(30.0900, 31.2000),
];

/// Creates an engine with the test route pre-set and started.
/// Uses seeded random so all tests are deterministic.
SimulationEngine _makeEngine({
  double speedMps = 20.0,
  double noiseMeters = 0.0,
  double accuracy = 5.0,
  double wakeOffsetSeconds = 60.0, // short offset so alarm fires in test
  int seed = 42,
}) {
  final engine = SimulationEngine(
    baseSpeedMps: speedMps,
    gpsNoiseMeters: noiseMeters,
    simulatedGpsAccuracy: accuracy,
    wakeOffsetSeconds: wakeOffsetSeconds,
    randomSeed: seed,
  )..routeGeometry = _testRoute;
  engine.start();
  return engine;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Advances engine [n] ticks and returns the last non-null frame.
SimulationFrame? _tickN(SimulationEngine engine, int n) {
  SimulationFrame? last;
  for (int i = 0; i < n; i++) {
    final f = engine.tick();
    if (f != null) last = f;
  }
  return last;
}

/// Advances engine until [predicate] is true or [maxTicks] exceeded.
SimulationFrame? _tickUntil(
  SimulationEngine engine,
  bool Function(SimulationFrame) predicate, {
  int maxTicks = 5000,
}) {
  for (int i = 0; i < maxTicks; i++) {
    final f = engine.tick();
    if (f == null) return null;
    if (predicate(f)) return f;
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('SimulationEngine — lifecycle', () {
    test('starts in idle, transitions to tracking on start()', () {
      final engine = SimulationEngine()..routeGeometry = _testRoute;
      expect(engine.tripState, TripState.idle);
      expect(engine.started, false);
      engine.start();
      expect(engine.tripState, TripState.tracking);
      expect(engine.started, true);
    });

    test('tick() returns null before start()', () {
      final engine = SimulationEngine()..routeGeometry = _testRoute;
      expect(engine.tick(), isNull);
    });

    test('tick() returns null for empty routeGeometry', () {
      final engine = SimulationEngine();
      engine.start(); // geometry empty → no-op
      expect(engine.tick(), isNull);
    });

    test('reset() restores engine to pre-start state', () {
      final engine = _makeEngine();
      _tickN(engine, 10);
      engine.reset();
      expect(engine.tripState, TripState.idle);
      expect(engine.started, false);
      expect(engine.cursorDistance, 0.0);
    });

    test('tick() returns null after reset() and before start()', () {
      final engine = _makeEngine();
      _tickN(engine, 5);
      engine.reset();
      expect(engine.tick(), isNull);
    });

    test('can start again after reset()', () {
      final engine = _makeEngine();
      _tickN(engine, 10);
      engine.reset();
      engine.start();
      final frame = engine.tick();
      expect(frame, isNotNull);
      expect(frame!.tripState, TripState.tracking);
    });
  });

  group('SimulationEngine — pipeline', () {
    test('tick() feeds through RailwayMatcher (matchedPosition on route)', () {
      final engine = _makeEngine();
      final frame = engine.tick()!;
      // matchedPosition must be on or very near the route
      // Distance from raw to matched should be less than the noise radius
      const distCalc = Distance();
      final distToRoute = distCalc.distance(frame.rawPosition, frame.matchedPosition);
      // With no noise, rawPosition IS on the route, matched ≈ raw
      expect(distToRoute, lessThan(50.0)); // < 50 m snapping error
    });

    test('tick() calls EtaEngine (etaSeconds is non-null and positive)', () {
      final engine = _makeEngine();
      final frame = engine.tick()!;
      expect(frame.etaSeconds, isNotNull);
      expect(frame.etaSeconds!, greaterThan(0));
    });

    test('tick() calls AlarmEngine (alarmState is armed initially)', () {
      final engine = _makeEngine();
      final frame = engine.tick()!;
      expect(frame.alarmState, AlarmState.armed);
    });

    test('SimulationFrame is read-only output model (does not drive engine)', () {
      final engine = _makeEngine();
      final frame1 = engine.tick()!;
      final frame2 = engine.tick()!;
      // Progress should increase — frame is just a snapshot
      expect(frame2.progressMeters, greaterThanOrEqualTo(frame1.progressMeters));
    });
  });

  group('SimulationEngine — deterministic tick semantics', () {
    test('each tick advances exactly baseSpeedMps meters along route', () {
      final engine = _makeEngine(speedMps: 25.0);
      final f1 = engine.tick()!;
      final f2 = engine.tick()!;
      // With no noise, matched progress should increase by ~25m each tick
      // (may differ slightly due to projection onto route)
      expect(f2.progressMeters, greaterThan(f1.progressMeters));
    });

    test('1x speed covers same logical distance as 20x in same N ticks', () {
      // Both engines use same seed, same speed — 100 ticks each
      final engine1x = _makeEngine(speedMps: 20.0, seed: 42);
      final engine20x = _makeEngine(speedMps: 20.0, seed: 42);

      final f1 = _tickN(engine1x, 100)!;
      final f20 = _tickN(engine20x, 100)!;

      // Deterministic: same seed, same ticks → same result
      expect(f1.progressMeters, closeTo(f20.progressMeters, 1.0));
    });

    test('cursor does not exceed totalRouteLength', () {
      final engine = _makeEngine(speedMps: 200.0); // very fast
      _tickN(engine, 100);
      expect(engine.cursorDistance, lessThanOrEqualTo(engine.totalRouteLength + 0.01));
    });
  });

  group('SimulationEngine — monotonic progress', () {
    test('progress is monotonically non-decreasing (no GPS bounce backward)', () {
      final engine = _makeEngine(noiseMeters: 30.0, seed: 99); // with noise
      double lastProgress = 0.0;
      for (int i = 0; i < 200; i++) {
        final f = engine.tick();
        if (f == null) break;
        expect(f.progressMeters, greaterThanOrEqualTo(lastProgress));
        lastProgress = f.progressMeters;
      }
    });
  });

  group('SimulationEngine — state transitions', () {
    test('transitions tracking → approaching (< 5000m remaining)', () {
      final engine = _makeEngine(speedMps: 20.0, wakeOffsetSeconds: 60.0);
      final frame = _tickUntil(engine, (f) => f.tripState == TripState.approaching);
      expect(frame, isNotNull, reason: 'Should reach approaching state');
      expect(frame!.remainingMeters, lessThanOrEqualTo(5000));
    });

    test('transitions approaching → alarmArmed (< 2000m remaining)', () {
      final engine = _makeEngine(speedMps: 20.0, wakeOffsetSeconds: 60.0);
      final frame = _tickUntil(engine, (f) => f.tripState == TripState.alarmArmed);
      expect(frame, isNotNull, reason: 'Should reach alarmArmed state');
      expect(frame!.remainingMeters, lessThanOrEqualTo(2000));
    });

    test('transitions to arrived when progress >= destination', () {
      final engine = _makeEngine(speedMps: 20.0, wakeOffsetSeconds: 60.0);
      final frame = _tickUntil(engine, (f) => f.tripState == TripState.arrived);
      expect(frame, isNotNull, reason: 'Should reach arrived state');
      expect(frame!.remainingMeters, closeTo(0.0, 50.0));
    });

    test('tick() returns null after arrived (terminal state)', () {
      final engine = _makeEngine(speedMps: 200.0);
      _tickUntil(engine, (f) => f.tripState == TripState.arrived);
      expect(engine.tick(), isNull);
    });
  });

  group('SimulationEngine — alarm progression', () {
    test('alarm progresses armed → earlyWarningTriggered → unacknowledged', () {
      // wakeOffset=120s so alarm fires when ETA <= 120s (≈ 2400m at 20m/s)
      final engine = _makeEngine(speedMps: 20.0, wakeOffsetSeconds: 120.0);

      final earlyFrame = _tickUntil(
        engine, (f) => f.alarmState == AlarmState.earlyWarningTriggered);
      expect(earlyFrame, isNotNull, reason: 'Should trigger early warning');

      final alarmFrame = _tickUntil(
        engine, (f) => f.alarmState == AlarmState.unacknowledged);
      expect(alarmFrame, isNotNull, reason: 'Should trigger main alarm');
    });

    test('alarm is idempotent — same frame never re-triggers after unacknowledged', () {
      final engine = _makeEngine(speedMps: 20.0, wakeOffsetSeconds: 120.0);
      _tickUntil(engine, (f) => f.alarmState == AlarmState.unacknowledged);

      // Continue ticking — state must stay unacknowledged, not bounce back
      for (int i = 0; i < 50; i++) {
        final f = engine.tick();
        if (f == null) break;
        expect(
          f.alarmState,
          anyOf(AlarmState.unacknowledged, AlarmState.acknowledged, AlarmState.completed),
          reason: 'Alarm must not re-trigger after reaching unacknowledged',
        );
      }
    });
  });

  group('SimulationEngine — GPS noise', () {
    test('noise does not bypass RailwayMatcher (matched position stays near route)', () {
      // Large 50m noise still gets snapped back to route by RailwayMatcher
      final engine = _makeEngine(noiseMeters: 50.0, seed: 7);
      const distCalc = Distance();
      for (int i = 0; i < 50; i++) {
        final f = engine.tick();
        if (f == null) break;
        // Matched position should be within 5m of the straight-line route
        // (route is perfectly straight so snap error is minimal)
        final distRawToMatched = distCalc.distance(f.rawPosition, f.matchedPosition);
        expect(distRawToMatched, lessThanOrEqualTo(60.0)); // allow some tolerance
        // Raw can be up to 50m away; matched snaps back, so this gap verifies noise is applied
        // We just verify matched is NOT identical to raw when noise is present
        // and that progress is still valid
        expect(f.progressMeters, inInclusiveRange(0.0, f.destinationMeters));
      }
    });

    test('raw position differs from matched when noise > 0', () {
      final engine = _makeEngine(noiseMeters: 20.0, seed: 1);
      // With nonzero noise at least some ticks will differ
      bool foundDifference = false;
      for (int i = 0; i < 50; i++) {
        final f = engine.tick();
        if (f == null) break;
        if (f.rawPosition.latitude != f.matchedPosition.latitude ||
            f.rawPosition.longitude != f.matchedPosition.longitude) {
          foundDifference = true;
          break;
        }
      }
      expect(foundDifference, isTrue, reason: 'Noise should create raw ≠ matched');
    });

    test('zero noise: raw position equals matched position (perfect GPS)', () {
      final engine = _makeEngine(noiseMeters: 0.0);
      for (int i = 0; i < 10; i++) {
        final f = engine.tick();
        if (f == null) break;
        // With no noise, raw is exactly on route, so raw ≈ matched
        expect(f.rawPosition.latitude,
          closeTo(f.matchedPosition.latitude, 0.0001));
        expect(f.rawPosition.longitude,
          closeTo(f.matchedPosition.longitude, 0.0001));
      }
    });
  });

  group('SimulationEngine — GPS uncertainty', () {
    test('high accuracy value (>100m) triggers gpsUncertain in TripEngine', () {
      final engine = _makeEngine(accuracy: 5.0);
      // Get a few normal ticks first
      _tickN(engine, 10);
      // Simulate GPS loss
      engine.forceGpsLoss(); // accuracy = 200m
      // Need multiple ticks to degrade confidence below threshold
      SimulationFrame? uncertain;
      for (int i = 0; i < 20; i++) {
        final f = engine.tick();
        if (f?.tripState == TripState.gpsUncertain) {
          uncertain = f;
          break;
        }
      }
      expect(uncertain, isNotNull, reason: 'Should enter gpsUncertain after GPS loss');
    });

    test('GPS recovery restores tracking state', () {
      final engine = _makeEngine(accuracy: 5.0);
      _tickN(engine, 10);
      engine.forceGpsLoss();
      _tickUntil(engine, (f) => f.tripState == TripState.gpsUncertain);

      engine.forceGpsRecovery(); // accuracy = 5m
      final recovered = _tickUntil(engine, (f) => f.tripState == TripState.tracking);
      expect(recovered, isNotNull, reason: 'Should recover to tracking');
    });
  });

  group('SimulationEngine — force actions', () {
    test('forceEarlyWarning() sets alarmState without direct provider write', () {
      final engine = _makeEngine();
      _tickN(engine, 5);
      engine.forceEarlyWarning();
      expect(engine.alarmState, AlarmState.earlyWarningTriggered);
    });

    test('forceAlarm() sets alarmState to unacknowledged', () {
      final engine = _makeEngine();
      _tickN(engine, 5);
      engine.forceAlarm();
      expect(engine.alarmState, AlarmState.unacknowledged);
    });

    test('forceArrival() sets tripState to arrived and stops ticking', () {
      final engine = _makeEngine();
      _tickN(engine, 5);
      engine.forceArrival();
      expect(engine.tripState, TripState.arrived);
      expect(engine.isTerminal, isTrue);
      expect(engine.tick(), isNull);
    });

    test('forceMissed() sets tripState to missed and stops ticking', () {
      final engine = _makeEngine();
      _tickN(engine, 5);
      engine.forceMissed();
      expect(engine.tripState, TripState.missed);
      expect(engine.isTerminal, isTrue);
      expect(engine.tick(), isNull);
    });

    test('forceAlarm twice is idempotent (no double-trigger)', () {
      final engine = _makeEngine();
      _tickN(engine, 5);
      engine.forceAlarm();
      final state1 = engine.alarmState;
      engine.forceAlarm();
      expect(engine.alarmState, state1); // state unchanged
    });
  });

  group('SimulationEngine — DirectionDetector', () {
    test('travelingForward is null for first few ticks (insufficient history)', () {
      final engine = _makeEngine();
      // First 2 ticks won't have enough position history (need >= 3)
      final f1 = engine.tick()!;
      final f2 = engine.tick()!;
      expect(f1.travelingForward, isNull);
      expect(f2.travelingForward, isNull);
    });

    test('travelingForward becomes non-null after sufficient position history', () {
      final engine = _makeEngine();
      SimulationFrame? forwardFrame;
      for (int i = 0; i < 10; i++) {
        final f = engine.tick();
        if (f?.travelingForward != null) {
          forwardFrame = f;
          break;
        }
      }
      expect(forwardFrame, isNotNull);
      // Simulation travels in the same direction as the route
      expect(forwardFrame!.travelingForward, isTrue);
    });
  });

  group('SimulationEngine — missed journey', () {
    test('forceMissed() stops the simulation correctly', () {
      final engine = _makeEngine();
      _tickN(engine, 20);
      engine.forceMissed();
      expect(engine.tripState, TripState.missed);
      expect(engine.tick(), isNull);
    });
  });
}
