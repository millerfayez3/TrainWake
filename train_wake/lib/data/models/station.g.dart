// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Station _$StationFromJson(Map<String, dynamic> json) => _Station(
  id: json['id'] as String,
  nameAr: json['nameAr'] as String,
  nameEn: json['nameEn'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  aliases:
      (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  routeIds:
      (json['routeIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  routeIndexes:
      (json['routeIndexes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  isActive: json['isActive'] as bool? ?? true,
  region: json['region'] as String?,
  stationCode: json['stationCode'] as String?,
);

Map<String, dynamic> _$StationToJson(_Station instance) => <String, dynamic>{
  'id': instance.id,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'aliases': instance.aliases,
  'routeIds': instance.routeIds,
  'routeIndexes': instance.routeIndexes,
  'isActive': instance.isActive,
  'region': instance.region,
  'stationCode': instance.stationCode,
};
