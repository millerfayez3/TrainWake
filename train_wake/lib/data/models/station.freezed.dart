// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Station {

 String get id; String get nameAr; String get nameEn; double get latitude; double get longitude; List<String> get aliases; List<String> get routeIds; Map<String, int> get routeIndexes; bool get isActive; String? get region; String? get stationCode;
/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StationCopyWith<Station> get copyWith => _$StationCopyWithImpl<Station>(this as Station, _$identity);

  /// Serializes this Station to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Station;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Station&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&const DeepCollectionEquality().equals(other.aliases, _this.aliases)&&const DeepCollectionEquality().equals(other.routeIds, _this.routeIds)&&const DeepCollectionEquality().equals(other.routeIndexes, _this.routeIndexes)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.stationCode, _this.stationCode) || other.stationCode == _this.stationCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Station;
  return Object.hash(runtimeType,_this.id,_this.nameAr,_this.nameEn,_this.latitude,_this.longitude,const DeepCollectionEquality().hash(_this.aliases),const DeepCollectionEquality().hash(_this.routeIds),const DeepCollectionEquality().hash(_this.routeIndexes),_this.isActive,_this.region,_this.stationCode);
}

@override
String toString() {
  final _this = this as Station;
  return 'Station(id: ${_this.id}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, aliases: ${_this.aliases}, routeIds: ${_this.routeIds}, routeIndexes: ${_this.routeIndexes}, isActive: ${_this.isActive}, region: ${_this.region}, stationCode: ${_this.stationCode})';
}


}

/// @nodoc
abstract mixin class $StationCopyWith<$Res>  {
  factory $StationCopyWith(Station value, $Res Function(Station) _then) = _$StationCopyWithImpl;
@useResult
$Res call({
 String id, String nameAr, String nameEn, double latitude, double longitude, List<String> aliases, List<String> routeIds, Map<String, int> routeIndexes, bool isActive, String? region, String? stationCode
});




}
/// @nodoc
class _$StationCopyWithImpl<$Res>
    implements $StationCopyWith<$Res> {
  _$StationCopyWithImpl(this._self, this._then);

  final Station _self;
  final $Res Function(Station) _then;

/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameAr = null,Object? nameEn = null,Object? latitude = null,Object? longitude = null,Object? aliases = null,Object? routeIds = null,Object? routeIndexes = null,Object? isActive = null,Object? region = freezed,Object? stationCode = freezed,}) {
  return _then(Station(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,aliases: null == aliases ? _self.aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,routeIds: null == routeIds ? _self.routeIds : routeIds // ignore: cast_nullable_to_non_nullable
as List<String>,routeIndexes: null == routeIndexes ? _self.routeIndexes : routeIndexes // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,stationCode: freezed == stationCode ? _self.stationCode : stationCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Station].
extension StationPatterns on Station {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Station value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Station value)  $default,){
final _that = this;
switch (_that) {
case _Station():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Station value)?  $default,){
final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameAr,  String nameEn,  double latitude,  double longitude,  List<String> aliases,  List<String> routeIds,  Map<String, int> routeIndexes,  bool isActive,  String? region,  String? stationCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that.id,_that.nameAr,_that.nameEn,_that.latitude,_that.longitude,_that.aliases,_that.routeIds,_that.routeIndexes,_that.isActive,_that.region,_that.stationCode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameAr,  String nameEn,  double latitude,  double longitude,  List<String> aliases,  List<String> routeIds,  Map<String, int> routeIndexes,  bool isActive,  String? region,  String? stationCode)  $default,) {final _that = this;
switch (_that) {
case _Station():
return $default(_that.id,_that.nameAr,_that.nameEn,_that.latitude,_that.longitude,_that.aliases,_that.routeIds,_that.routeIndexes,_that.isActive,_that.region,_that.stationCode);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameAr,  String nameEn,  double latitude,  double longitude,  List<String> aliases,  List<String> routeIds,  Map<String, int> routeIndexes,  bool isActive,  String? region,  String? stationCode)?  $default,) {final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that.id,_that.nameAr,_that.nameEn,_that.latitude,_that.longitude,_that.aliases,_that.routeIds,_that.routeIndexes,_that.isActive,_that.region,_that.stationCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Station implements Station {
  const _Station({required this.id, required this.nameAr, required this.nameEn, required this.latitude, required this.longitude,  List<String> aliases = const [],  List<String> routeIds = const [],  Map<String, int> routeIndexes = const {}, this.isActive = true, this.region, this.stationCode}): _aliases = aliases,_routeIds = routeIds,_routeIndexes = routeIndexes;
  factory _Station.fromJson(Map<String, dynamic> json) => _$StationFromJson(json);

@override final  String id;
@override final  String nameAr;
@override final  String nameEn;
@override final  double latitude;
@override final  double longitude;
 final  List<String> _aliases;
@override@JsonKey() List<String> get aliases {
  if (_aliases is EqualUnmodifiableListView) return _aliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aliases);
}

 final  List<String> _routeIds;
@override@JsonKey() List<String> get routeIds {
  if (_routeIds is EqualUnmodifiableListView) return _routeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routeIds);
}

 final  Map<String, int> _routeIndexes;
@override@JsonKey() Map<String, int> get routeIndexes {
  if (_routeIndexes is EqualUnmodifiableMapView) return _routeIndexes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_routeIndexes);
}

@override@JsonKey() final  bool isActive;
@override final  String? region;
@override final  String? stationCode;

/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StationCopyWith<_Station> get copyWith => __$StationCopyWithImpl<_Station>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Station&&(identical(other.id, id) || other.id == id)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.aliases, _aliases)&&const DeepCollectionEquality().equals(other.routeIds, _routeIds)&&const DeepCollectionEquality().equals(other.routeIndexes, _routeIndexes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.region, region) || other.region == region)&&(identical(other.stationCode, stationCode) || other.stationCode == stationCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nameAr,nameEn,latitude,longitude,const DeepCollectionEquality().hash(_aliases),const DeepCollectionEquality().hash(_routeIds),const DeepCollectionEquality().hash(_routeIndexes),isActive,region,stationCode);
}

@override
String toString() {
    return 'Station(id: $id, nameAr: $nameAr, nameEn: $nameEn, latitude: $latitude, longitude: $longitude, aliases: $aliases, routeIds: $routeIds, routeIndexes: $routeIndexes, isActive: $isActive, region: $region, stationCode: $stationCode)';
}


}

/// @nodoc
abstract mixin class _$StationCopyWith<$Res> implements $StationCopyWith<$Res> {
  factory _$StationCopyWith(_Station value, $Res Function(_Station) _then) = __$StationCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameAr, String nameEn, double latitude, double longitude, List<String> aliases, List<String> routeIds, Map<String, int> routeIndexes, bool isActive, String? region, String? stationCode
});




}
/// @nodoc
class __$StationCopyWithImpl<$Res>
    implements _$StationCopyWith<$Res> {
  __$StationCopyWithImpl(this._self, this._then);

  final _Station _self;
  final $Res Function(_Station) _then;

/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameAr = null,Object? nameEn = null,Object? latitude = null,Object? longitude = null,Object? aliases = null,Object? routeIds = null,Object? routeIndexes = null,Object? isActive = null,Object? region = freezed,Object? stationCode = freezed,}) {
  return _then(_Station(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,aliases: null == aliases ? _self._aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,routeIds: null == routeIds ? _self._routeIds : routeIds // ignore: cast_nullable_to_non_nullable
as List<String>,routeIndexes: null == routeIndexes ? _self._routeIndexes : routeIndexes // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,stationCode: freezed == stationCode ? _self.stationCode : stationCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
