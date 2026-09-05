import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'railway_route.freezed.dart';
part 'railway_route.g.dart';

@freezed
abstract class RailwayRoute with _$RailwayRoute {
  const factory RailwayRoute({
    required String id,
    required String nameAr,
    required String nameEn,
    required List<String> stationIds,
    // Geometry is stored as a list of points (latitude, longitude)
    // Using a custom converter might be needed, but we keep it simple here.
    required List<List<double>> rawGeometry,
  }) = _RailwayRoute;

  const RailwayRoute._();

  factory RailwayRoute.fromJson(Map<String, dynamic> json) => 
      _$RailwayRouteFromJson(json);
      
  /// Converts raw geometry arrays to LatLng objects for spatial processing
  List<LatLng> get geometry {
    return rawGeometry.map((point) => LatLng(point[0], point[1])).toList();
  }
}
