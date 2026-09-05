import 'package:freezed_annotation/freezed_annotation.dart';

part 'station.freezed.dart';
part 'station.g.dart';

@freezed
abstract class Station with _$Station {
  const factory Station({
    required String id,
    required String nameAr,
    required String nameEn,
    required double latitude,
    required double longitude,
    @Default([]) List<String> aliases,
    @Default([]) List<String> routeIds,
    @Default({}) Map<String, int> routeIndexes,
    @Default(true) bool isActive,
    String? region,
    String? stationCode,
  }) = _Station;

  factory Station.fromJson(Map<String, dynamic> json) => _$StationFromJson(json);
}
