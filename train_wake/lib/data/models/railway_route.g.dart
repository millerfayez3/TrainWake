// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'railway_route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RailwayRoute _$RailwayRouteFromJson(Map<String, dynamic> json) =>
    _RailwayRoute(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      stationIds: (json['stationIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rawGeometry: (json['rawGeometry'] as List<dynamic>)
          .map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList(),
    );

Map<String, dynamic> _$RailwayRouteToJson(_RailwayRoute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameAr': instance.nameAr,
      'nameEn': instance.nameEn,
      'stationIds': instance.stationIds,
      'rawGeometry': instance.rawGeometry,
    };
