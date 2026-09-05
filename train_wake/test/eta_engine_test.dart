import 'package:flutter_test/flutter_test.dart';
import 'package:train_wake/trip/eta_engine.dart';

void main() {
  group('EtaEngine', () {
    late EtaEngine engine;

    setUp(() {
      engine = EtaEngine();
    });

    test('calculates correct ETA for constant speed', () {
      final eta = engine.calculateEta(
        remainingDistanceMeters: 10000, 
        currentSpeedMps: 20, // 72 km/h
        confidence: 1.0,
      );
      // 10000 / 20 = 500 seconds
      expect(eta, equals(500.0));
    });

    test('applies safety margin based on confidence', () {
      final etaHighConf = engine.calculateEta(
        remainingDistanceMeters: 10000, 
        currentSpeedMps: 20,
        confidence: 1.0,
      );
      
      final etaLowConf = engine.calculateEta(
        remainingDistanceMeters: 10000, 
        currentSpeedMps: 20,
        confidence: 0.5,
      );
      
      // Safety margin is 1.0 + ( (1.0 - 0.5) * 0.5 ) = 1.25
      // 500 * 1.25 = 625
      expect(etaLowConf, greaterThan(etaHighConf!));
      expect(etaLowConf, equals(625.0));
    });

    test('handles temporary stop smoothly (speed drops to 0)', () {
      // First, simulate high speed to populate the window
      engine.calculateEta(remainingDistanceMeters: 10000, currentSpeedMps: 20, confidence: 1.0);
      engine.calculateEta(remainingDistanceMeters: 9000, currentSpeedMps: 20, confidence: 1.0);
      
      // Now drop to 0
      final etaStop = engine.calculateEta(
        remainingDistanceMeters: 8000, 
        currentSpeedMps: 0,
        confidence: 1.0,
      );
      
      // The smoothed speed should be (20+20+0)/3 = 13.333...
      // ETA = 8000 / 13.333 = ~600 seconds
      expect(etaStop, greaterThan(0));
      expect(etaStop, lessThan(8000)); // It shouldn't use 0 or default 11 yet because average is > 1.0
    });
  });
}
