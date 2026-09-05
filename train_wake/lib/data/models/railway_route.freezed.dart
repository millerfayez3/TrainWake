// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'railway_route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RailwayRoute {

 String get id; String get nameAr; String get nameEn; List<String> get stationIds; List<List<double>> get rawGeometry;
/// Create a copy of RailwayRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RailwayRouteCopyWith<RailwayRoute> get copyWith => _$RailwayRouteCopyWithImpl<RailwayRoute>(this as RailwayRoute, _$identity);

  /// Serializes this RailwayRoute to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RailwayRoute;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RailwayRoute&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn)&&const DeepCollectionEquality().equals(other.stationIds, _this.stationIds)&&const DeepCollectionEquality().equals(other.rawGeometry, _this.rawGeometry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RailwayRoute;
  return Object.hash(runtimeType,_this.id,_this.nameAr,_this.nameEn,const DeepCollectionEquality().hash(_this.stationIds),const DeepCollectionEquality().hash(_this.rawGeometry));
}

@override
String toString() {
  final _this = this as RailwayRoute;
  return 'RailwayRoute(id: ${_this.id}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn}, stationIds: ${_this.stationIds}, rawGeometry: ${_this.rawGeometry})';
}


}

/// @nodoc
abstract mixin class $RailwayRouteCopyWith<$Res>  {
  factory $RailwayRouteCopyWith(RailwayRoute value, $Res Function(RailwayRoute) _then) = _$RailwayRouteCopyWithImpl;
@useResult
$Res call({
 String id, String nameAr, String nameEn, List<String> stationIds, List<List<double>> rawGeometry
});




}
/// @nodoc
class _$RailwayRouteCopyWithImpl<$Res>
    implements $RailwayRouteCopyWith<$Res> {
  _$RailwayRouteCopyWithImpl(this._self, this._then);

  final RailwayRoute _self;
  final $Res Function(RailwayRoute) _then;

/// Create a copy of RailwayRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameAr = null,Object? nameEn = null,Object? stationIds = null,Object? rawGeometry = null,}) {
  return _then(RailwayRoute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,stationIds: null == stationIds ? _self.stationIds : stationIds // ignore: cast_nullable_to_non_nullable
as List<String>,rawGeometry: null == rawGeometry ? _self.rawGeometry : rawGeometry // ignore: cast_nullable_to_non_nullable
as List<List<double>>,
  ));
}

}


/// Adds pattern-matching-related methods to [RailwayRoute].
extension RailwayRoutePatterns on RailwayRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RailwayRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RailwayRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RailwayRoute value)  $default,){
final _that = this;
switch (_that) {
case _RailwayRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RailwayRoute value)?  $default,){
final _that = this;
switch (_that) {
case _RailwayRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameAr,  String nameEn,  List<String> stationIds,  List<List<double>> rawGeometry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RailwayRoute() when $default != null:
return $default(_that.id,_that.nameAr,_that.nameEn,_that.stationIds,_that.rawGeometry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameAr,  String nameEn,  List<String> stationIds,  List<List<double>> rawGeometry)  $default,) {final _that = this;
switch (_that) {
case _RailwayRoute():
return $default(_that.id,_that.nameAr,_that.nameEn,_that.stationIds,_that.rawGeometry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameAr,  String nameEn,  List<String> stationIds,  List<List<double>> rawGeometry)?  $default,) {final _that = this;
switch (_that) {
case _RailwayRoute() when $default != null:
return $default(_that.id,_that.nameAr,_that.nameEn,_that.stationIds,_that.rawGeometry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RailwayRoute extends RailwayRoute {
  const _RailwayRoute({required this.id, required this.nameAr, required this.nameEn, required  List<String> stationIds, required  List<List<double>> rawGeometry}): _stationIds = stationIds,_rawGeometry = rawGeometry,super._();
  factory _RailwayRoute.fromJson(Map<String, dynamic> json) => _$RailwayRouteFromJson(json);

@override final  String id;
@override final  String nameAr;
@override final  String nameEn;
 final  List<String> _stationIds;
@override List<String> get stationIds {
  if (_stationIds is EqualUnmodifiableListView) return _stationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stationIds);
}

 final  List<List<double>> _rawGeometry;
@override List<List<double>> get rawGeometry {
  if (_rawGeometry is EqualUnmodifiableListView) return _rawGeometry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rawGeometry);
}


/// Create a copy of RailwayRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RailwayRouteCopyWith<_RailwayRoute> get copyWith => __$RailwayRouteCopyWithImpl<_RailwayRoute>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RailwayRouteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RailwayRoute&&(identical(other.id, id) || other.id == id)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&const DeepCollectionEquality().equals(other.stationIds, _stationIds)&&const DeepCollectionEquality().equals(other.rawGeometry, _rawGeometry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nameAr,nameEn,const DeepCollectionEquality().hash(_stationIds),const DeepCollectionEquality().hash(_rawGeometry));
}

@override
String toString() {
    return 'RailwayRoute(id: $id, nameAr: $nameAr, nameEn: $nameEn, stationIds: $stationIds, rawGeometry: $rawGeometry)';
}


}

/// @nodoc
abstract mixin class _$RailwayRouteCopyWith<$Res> implements $RailwayRouteCopyWith<$Res> {
  factory _$RailwayRouteCopyWith(_RailwayRoute value, $Res Function(_RailwayRoute) _then) = __$RailwayRouteCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameAr, String nameEn, List<String> stationIds, List<List<double>> rawGeometry
});




}
/// @nodoc
class __$RailwayRouteCopyWithImpl<$Res>
    implements _$RailwayRouteCopyWith<$Res> {
  __$RailwayRouteCopyWithImpl(this._self, this._then);

  final _RailwayRoute _self;
  final $Res Function(_RailwayRoute) _then;

/// Create a copy of RailwayRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameAr = null,Object? nameEn = null,Object? stationIds = null,Object? rawGeometry = null,}) {
  return _then(_RailwayRoute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,stationIds: null == stationIds ? _self._stationIds : stationIds // ignore: cast_nullable_to_non_nullable
as List<String>,rawGeometry: null == rawGeometry ? _self._rawGeometry : rawGeometry // ignore: cast_nullable_to_non_nullable
as List<List<double>>,
  ));
}


}

// dart format on
