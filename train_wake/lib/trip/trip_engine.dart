enum TripState {
  idle,
  preparing,
  tracking,
  approaching,
  alarmArmed,
  alarmTriggered,
  gpsUncertain,
  arrived,
  missed,
  ended
}

class TripContext {
  double currentProgressMeters = 0.0;
  double destinationProgressMeters = 0.0;
  double remainingRailwayDistance = 0.0;
  
  double? lastReliableProgress;
  double? lastReliableSpeed;
  DateTime? lastReliableTimestamp;
  
  double routeConfidence = 1.0;
  double gpsConfidence = 1.0;
}

class TripEngine {
  TripState _currentState = TripState.idle;
  TripState get currentState => _currentState;
  
  final TripContext _context = TripContext();
  TripContext get context => _context;

  void startTrip(double destinationProgress) {
    _context.destinationProgressMeters = destinationProgress;
    _transitionTo(TripState.tracking);
  }

  /// Resets engine to initial idle state. Used by SimulationEngine.reset().
  void reset() {
    _currentState = TripState.idle;
    _context.currentProgressMeters = 0.0;
    _context.destinationProgressMeters = 0.0;
    _context.remainingRailwayDistance = 0.0;
    _context.lastReliableProgress = null;
    _context.lastReliableSpeed = null;
    _context.lastReliableTimestamp = null;
    _context.routeConfidence = 1.0;
    _context.gpsConfidence = 1.0;
  }

  /// DEVELOPER / TEST HOOK ONLY. Bypasses normal transition guards.
  /// Must NOT be called from any production trip flow.
  /// Used by SimulationEngine force actions to support isolated testing.
  void forceState(TripState newState) {
    _currentState = newState;
  }

  void updateProgress(double newProgress, double speed, double gpsAccuracy) {
    if (_currentState == TripState.idle || _currentState == TripState.ended) return;

    // Reject extremely poor GPS
    if (gpsAccuracy > 100) {
      _context.gpsConfidence *= 0.5;
      if (_context.gpsConfidence < 0.3) {
        _transitionTo(TripState.gpsUncertain);
      }
      return;
    }

    // Monotonic enforcement (simplified)
    if (_context.lastReliableProgress != null && newProgress < _context.lastReliableProgress!) {
      // Possible GPS bounce backward; ignore for now
      return; 
    }

    _context.lastReliableProgress = newProgress;
    _context.currentProgressMeters = newProgress;
    _context.lastReliableSpeed = speed;
    _context.lastReliableTimestamp = DateTime.now();
    _context.gpsConfidence = 1.0; // Restored

    _context.remainingRailwayDistance = _context.destinationProgressMeters - _context.currentProgressMeters;

    if (_currentState == TripState.gpsUncertain) {
      _transitionTo(TripState.tracking);
    }

    _evaluateState();
  }

  void _evaluateState() {
    if (_context.remainingRailwayDistance <= 0) {
      _transitionTo(TripState.arrived);
      return;
    }

    // If remaining distance is less than 5km, we are approaching
    if (_context.remainingRailwayDistance < 5000 && _currentState == TripState.tracking) {
      _transitionTo(TripState.approaching);
    }
    
    // If remaining distance is less than 2km, arm the alarm
    if (_context.remainingRailwayDistance < 2000 && _currentState == TripState.approaching) {
      _transitionTo(TripState.alarmArmed);
    }
  }

  void _transitionTo(TripState newState) {
    // Basic state machine enforcement could go here
    _currentState = newState;
  }
}
