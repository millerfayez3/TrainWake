

class EtaEngine {
  final List<double> _recentSpeeds = [];
  static const int _speedWindowSize = 5;

  /// Clears the speed window. Used by SimulationEngine.reset().
  void reset() => _recentSpeeds.clear();

  /// Returns the estimated time to arrival in seconds.
  /// Accounts for smoothed speed and a basic safety margin.
  double? calculateEta({
    required double remainingDistanceMeters,
    required double currentSpeedMps,
    required double confidence,
  }) {
    if (remainingDistanceMeters < 0) return 0;
    
    // Smooth the speed
    _recentSpeeds.add(currentSpeedMps);
    if (_recentSpeeds.length > _speedWindowSize) {
      _recentSpeeds.removeAt(0);
    }

    double smoothedSpeed = _recentSpeeds.reduce((a, b) => a + b) / _recentSpeeds.length;
    
    // Prevent division by zero and handle temporary station stops.
    // If the smoothed speed drops near zero, we assume a temporary stop 
    // and use a conservative default travel speed (e.g., 40 km/h = 11 m/s) 
    // for ETA calculation to avoid infinity.
    if (smoothedSpeed < 1.0) {
      smoothedSpeed = 11.0; 
    }

    // Base ETA in seconds
    double rawEta = remainingDistanceMeters / smoothedSpeed;

    // Apply safety margin based on confidence. Lower confidence -> higher safety margin
    double safetyMultiplier = 1.0 + ((1.0 - confidence) * 0.5); // Up to 50% extra time
    
    return rawEta * safetyMultiplier;
  }
}
