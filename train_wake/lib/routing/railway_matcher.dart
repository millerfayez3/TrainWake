import 'package:latlong2/latlong.dart';

/// Core spatial utility for matching raw GPS points to railway paths.
class RailwayMatcher {
  final Distance _distance = const Distance();

  /// Finds the closest point on a polyline (railway route) to the given [currentPosition].
  /// Returns the snapped LatLng and the calculated route progress (distance from start).
  ({LatLng snappedPoint, double progressMeters}) matchToRoute({
    required LatLng currentPosition,
    required List<LatLng> routeGeometry,
  }) {
    if (routeGeometry.isEmpty) {
      return (snappedPoint: currentPosition, progressMeters: 0.0);
    }
    if (routeGeometry.length == 1) {
      return (snappedPoint: routeGeometry.first, progressMeters: 0.0);
    }

    double minDistance = double.infinity;
    LatLng bestPoint = routeGeometry.first;
    double bestProgress = 0.0;
    double currentProgressAccumulator = 0.0;

    for (int i = 0; i < routeGeometry.length - 1; i++) {
      final p1 = routeGeometry[i];
      final p2 = routeGeometry[i + 1];
      
      final segmentLength = _distance.distance(p1, p2);
      
      // Project current position onto segment p1->p2
      final projection = _projectPointOntoSegment(currentPosition, p1, p2);
      final distToSegment = _distance.distance(currentPosition, projection);

      if (distToSegment < minDistance) {
        minDistance = distToSegment;
        bestPoint = projection;
        // Progress is the sum of previous segments + distance along current segment
        bestProgress = currentProgressAccumulator + _distance.distance(p1, projection);
      }
      
      currentProgressAccumulator += segmentLength;
    }

    return (snappedPoint: bestPoint, progressMeters: bestProgress);
  }

  /// Projects a point onto a line segment defined by p1 and p2.
  LatLng _projectPointOntoSegment(LatLng p, LatLng p1, LatLng p2) {
    // Simplified flat-earth projection for small distances.
    // For high accuracy production, this should use spherical geometry (Haversine projection).
    
    final x = p.longitude;
    final y = p.latitude;
    final x1 = p1.longitude;
    final y1 = p1.latitude;
    final x2 = p2.longitude;
    final y2 = p2.latitude;

    final A = x - x1;
    final B = y - y1;
    final C = x2 - x1;
    final D = y2 - y1;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    
    double param = -1;
    if (lenSq != 0) { // in case of 0 length line
      param = dot / lenSq;
    }

    double xx, yy;

    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }

    return LatLng(yy, xx);
  }
}
