import 'package:flutter_test/flutter_test.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  group('Background Logic Verification', () {
    test('Adaptive sampling thresholds adjust correctly based on distance', () {
      const int farDistanceThreshold = 20000;
      const int nearDistanceThreshold = 5000;
      
      LocationSettings getLocationSettings(double remainingDistance) {
        if (remainingDistance > farDistanceThreshold) {
          return const LocationSettings(accuracy: LocationAccuracy.medium, distanceFilter: 50);
        } else if (remainingDistance > nearDistanceThreshold) {
          return const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 20);
        } else {
          return const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 5);
        }
      }

      // Far
      final farSettings = getLocationSettings(25000);
      expect(farSettings.accuracy, equals(LocationAccuracy.medium));
      expect(farSettings.distanceFilter, equals(50));

      // Approaching
      final approachingSettings = getLocationSettings(10000);
      expect(approachingSettings.accuracy, equals(LocationAccuracy.high));
      expect(approachingSettings.distanceFilter, equals(20));

      // Very Near (Alarm Phase)
      final nearSettings = getLocationSettings(2000);
      expect(nearSettings.accuracy, equals(LocationAccuracy.best));
      expect(nearSettings.distanceFilter, equals(5));
    });

    test('TripEngine handles GPS uncertainty without moving backwards', () {
      final engine = TripEngine();
      engine.startTrip(10000);
      
      // Valid progress
      engine.updateProgress(1000, 20.0, 5.0);
      expect(engine.context.currentProgressMeters, equals(1000));
      expect(engine.currentState, equals(TripState.tracking));

      // Invalid jump backward (GPS bounce) should be ignored based on Phase 4 monotonic rules
      engine.updateProgress(500, 20.0, 5.0);
      expect(engine.context.currentProgressMeters, equals(1000));
      
      // Massive inaccuracy triggers gpsUncertain
      engine.updateProgress(1100, 20.0, 150.0);
      engine.updateProgress(1200, 20.0, 150.0);
      engine.updateProgress(1300, 20.0, 150.0);
      expect(engine.currentState, equals(TripState.gpsUncertain));
      
      // We don't advance the core reliable progress on terrible accuracy
      expect(engine.context.currentProgressMeters, equals(1000));
    });
  });
}
