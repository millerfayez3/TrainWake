import 'package:flutter_test/flutter_test.dart';
import 'package:train_wake/trip/alarm_engine.dart';

void main() {
  group('AlarmEngine', () {
    test('initializes and arms correctly', () {
      final engine = AlarmEngine();
      expect(engine.currentState, equals(AlarmState.notArmed));
      
      engine.evaluate(etaSeconds: 3000, confidence: 1.0, remainingDistanceMeters: 50000);
      expect(engine.currentState, equals(AlarmState.armed));
    });

    test('triggers early warning then main alarm', () {
      final engine = AlarmEngine(wakeOffsetSeconds: 600); // 10 mins
      engine.evaluate(etaSeconds: 3000, confidence: 1.0, remainingDistanceMeters: 50000);
      
      // 10 mins + 2 mins = 720 seconds threshold for early warning
      engine.evaluate(etaSeconds: 700, confidence: 1.0, remainingDistanceMeters: 10000);
      expect(engine.currentState, equals(AlarmState.earlyWarningTriggered));
      
      // Below 600 seconds for main alarm
      engine.evaluate(etaSeconds: 590, confidence: 1.0, remainingDistanceMeters: 8000);
      expect(engine.currentState, equals(AlarmState.unacknowledged));
    });

    test('safety buffer triggers alarm earlier on low confidence', () {
      final engine = AlarmEngine(wakeOffsetSeconds: 600); 
      engine.evaluate(etaSeconds: 3000, confidence: 1.0, remainingDistanceMeters: 50000);
      
      // 600 seconds, but confidence is 0.5. 
      // Safety buffer adds up to 120 seconds * 0.5 = 60 extra seconds.
      // Alarm threshold is now 660. 
      engine.evaluate(etaSeconds: 650, confidence: 0.5, remainingDistanceMeters: 9000);
      
      // Normally 650 wouldn't trigger the 600s main alarm, but with low confidence it does.
      expect(engine.currentState, equals(AlarmState.unacknowledged));
    });

    test('physical proximity safety net bypasses ETA', () {
      final engine = AlarmEngine(wakeOffsetSeconds: 600);
      engine.evaluate(etaSeconds: 3000, confidence: 1.0, remainingDistanceMeters: 50000);
      
      // ETA says 20 mins (maybe stopped), but we are physically 800 meters away!
      engine.evaluate(etaSeconds: 1200, confidence: 1.0, remainingDistanceMeters: 800);
      expect(engine.currentState, equals(AlarmState.unacknowledged));
    });

    test('idempotent evaluation after acknowledgment', () {
      final engine = AlarmEngine();
      engine.restoreState(AlarmState.unacknowledged);
      engine.acknowledgeAlarm(true);
      
      expect(engine.currentState, equals(AlarmState.acknowledged));
      
      // Even if ETA fluctuates, we should stay acknowledged
      engine.evaluate(etaSeconds: 100, confidence: 1.0, remainingDistanceMeters: 1000);
      expect(engine.currentState, equals(AlarmState.acknowledged));
    });
  });
}
