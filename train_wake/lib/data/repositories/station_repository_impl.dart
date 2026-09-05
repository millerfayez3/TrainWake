import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:train_wake/data/models/station.dart';
import 'package:train_wake/data/models/railway_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stationRepositoryProvider = Provider<StationRepository>((ref) {
  return StationRepository();
});

final stationDataLoaderProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(stationRepositoryProvider);
  await repo.loadData();
});

class StationRepository {
  List<Station> _stations = [];
  List<RailwayRoute> _routes = [];

  Future<void> loadData() async {
    // Load Stations
    final stationsStr = await rootBundle.loadString('assets/data/stations.json');
    final List<dynamic> stationsJson = json.decode(stationsStr);
    _stations = stationsJson.map((json) => Station.fromJson(json)).toList();

    // Load Routes
    final routesStr = await rootBundle.loadString('assets/data/routes.json');
    final List<dynamic> routesJson = json.decode(routesStr);
    _routes = routesJson.map((json) => RailwayRoute.fromJson(json)).toList();
  }

  List<Station> searchStations(String query) {
    if (query.isEmpty) return _stations;
    
    final lowerQuery = query.toLowerCase();
    return _stations.where((s) {
      return s.nameAr.contains(lowerQuery) ||
             s.nameEn.toLowerCase().contains(lowerQuery) ||
             s.aliases.any((alias) => alias.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  RailwayRoute? getRouteById(String id) {
    try {
      return _routes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
