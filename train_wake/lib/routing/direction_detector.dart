import 'package:latlong2/latlong.dart';

/// Detects the user's travel direction based on historical GPS points 
/// and compares it to the railway geometry bearing to determine route direction.
class DirectionDetector {
  final Distance _distance = const Distance();

  /// Determines if the user is traveling 'forward' or 'backward' along the given route.
  /// Needs a window of recent locations to filter noise.
  bool? isTravelingForward({
    required List<LatLng> recentLocations,
    required List<LatLng> routeGeometry,
  }) {
    if (recentLocations.length < 3) return null; // Need sufficient history
    
    // Get bearing of user movement
    final start = recentLocations.first;
    final end = recentLocations.last;
    final movementBearing = _distance.bearing(start, end);
    
    // Compare with the general bearing of the route near the user's position
    // (Implementation simplified for Phase 3)
    // Production version requires matching the exact segment the user is on.
    
    final routeStart = routeGeometry.first;
    final routeEnd = routeGeometry.last;
    final routeBearing = _distance.bearing(routeStart, routeEnd);
    
    // If angle difference is < 90 degrees, traveling forward.
    final angleDiff = _normalizedBearingDiff(movementBearing, routeBearing);
    return angleDiff < 90;
  }
  
  double _normalizedBearingDiff(double b1, double b2) {
    double diff = (b1 - b2).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }
}
