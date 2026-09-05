enum AlarmState {
  notArmed,
  armed,
  earlyWarningTriggered,
  mainAlarmTriggered,
  acknowledged,
  unacknowledged,
  completed,
  cancelled
}

class AlarmEngine {
  AlarmState _currentState = AlarmState.notArmed;
  AlarmState get currentState => _currentState;

  // Configuration
  final double wakeOffsetSeconds;
  final double earlyWarningLeadSeconds = 120.0; // 2 mins before main alarm

  AlarmEngine({this.wakeOffsetSeconds = 600.0}); // Default 10 mins

  void restoreState(AlarmState state) {
    _currentState = state;
  }

  void evaluate({
    required double etaSeconds,
    required double confidence,
    required double remainingDistanceMeters,
  }) {
    if (_currentState == AlarmState.acknowledged || 
        _currentState == AlarmState.completed || 
        _currentState == AlarmState.cancelled) {
      return; // Terminal or acknowledged states ignore further evaluation
    }

    if (_currentState == AlarmState.notArmed && remainingDistanceMeters > 0) {
      _currentState = AlarmState.armed;
    }

    if (_currentState == AlarmState.armed || _currentState == AlarmState.earlyWarningTriggered) {
      // If we are extremely close physically regardless of ETA, trigger alarm as safety net
      if (remainingDistanceMeters < 1000 && _currentState != AlarmState.mainAlarmTriggered && _currentState != AlarmState.unacknowledged) {
        _triggerMainAlarm();
        return;
      }
      
      // Calculate dynamic threshold based on confidence
      // Lower confidence = trigger slightly earlier as a safety buffer
      double safetyBuffer = (1.0 - confidence) * 120.0; // Up to 2 mins extra buffer
      double effectiveAlarmThreshold = wakeOffsetSeconds + safetyBuffer;
      double effectiveWarningThreshold = effectiveAlarmThreshold + earlyWarningLeadSeconds;

      if (etaSeconds <= effectiveAlarmThreshold && _currentState != AlarmState.mainAlarmTriggered && _currentState != AlarmState.unacknowledged) {
        _triggerMainAlarm();
      } else if (etaSeconds <= effectiveWarningThreshold && _currentState == AlarmState.armed) {
        _triggerEarlyWarning();
      }
    }
  }

  void _triggerEarlyWarning() {
    _currentState = AlarmState.earlyWarningTriggered;
    // Android local notification integration would fire here
  }

  void _triggerMainAlarm() {
    _currentState = AlarmState.mainAlarmTriggered;
    // Immediately transitions to unacknowledged pending user action
    _currentState = AlarmState.unacknowledged;
    // Android Full-screen intent + loud sound would fire here
  }

  void acknowledgeAlarm(bool continueTracking) {
    if (_currentState == AlarmState.unacknowledged || _currentState == AlarmState.mainAlarmTriggered) {
      _currentState = AlarmState.acknowledged;
      if (!continueTracking) {
        _currentState = AlarmState.completed;
      }
    }
  }
}
