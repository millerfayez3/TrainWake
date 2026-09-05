import 'package:flutter_test/flutter_test.dart';
import 'package:train_wake/trip/trip_engine.dart';

void main() {
  group('TripEngine State Machine', () {
    late TripEngine engine;

    setUp(() {
      engine = TripEngine();
    });

    test('initial state is idle', () {
      expect(engine.currentState, equals(TripState.idle));
    });

    test('startTrip transitions to tracking', () {
      engine.startTrip(10000);
      expect(engine.currentState, equals(TripState.tracking));
      expect(engine.context.destinationProgressMeters, equals(10000));
    });

    test('updates progress monotonically', () {
      engine.startTrip(10000);
      engine.updateProgress(1000, 20, 5.0);
      expect(engine.context.currentProgressMeters, equals(1000));
      expect(engine.context.remainingRailwayDistance, equals(9000));
      
      // Simulate backward jump
      engine.updateProgress(900, 20, 5.0);
      // Should remain at 1000
      expect(engine.context.currentProgressMeters, equals(1000));
    });

    test('transitions to gpsUncertain on high inaccuracy', () {
      engine.startTrip(10000);
      engine.updateProgress(1000, 20, 5.0);
      expect(engine.currentState, equals(TripState.tracking));
      
      // Massive inaccuracy drops confidence
      engine.updateProgress(1500, 20, 150.0);
      engine.updateProgress(1500, 20, 150.0);
      engine.updateProgress(1500, 20, 150.0);
      
      expect(engine.currentState, equals(TripState.gpsUncertain));
    });

    test('transitions tracking -> approaching -> alarmArmed -> arrived', () {
      engine.startTrip(10000); // 10km total

      engine.updateProgress(4000, 20, 5.0); // 6km remaining
      expect(engine.currentState, equals(TripState.tracking));
      
      engine.updateProgress(6000, 20, 5.0); // 4km remaining
      expect(engine.currentState, equals(TripState.approaching));

      engine.updateProgress(8500, 20, 5.0); // 1.5km remaining
      expect(engine.currentState, equals(TripState.alarmArmed));
      
      engine.updateProgress(10000, 20, 5.0); // 0km remaining
      expect(engine.currentState, equals(TripState.arrived));
    });
  });
}
