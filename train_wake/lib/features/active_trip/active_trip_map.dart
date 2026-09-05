import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:train_wake/features/active_trip/active_trip_screen.dart';
import 'package:train_wake/features/map/map_tile_provider.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:train_wake/trip/alarm_engine.dart';

class ActiveTripMap extends ConsumerStatefulWidget {
  final bool fetchLocation;
  const ActiveTripMap({super.key, this.fetchLocation = true});

  @override
  ConsumerState<ActiveTripMap> createState() => _ActiveTripMapState();
}

class _ActiveTripMapState extends ConsumerState<ActiveTripMap> {
  final MapController _mapController = MapController();
  bool _userHasPanned = false;
  LatLng? _lastKnownPosition;
  StreamSubscription? _updateSubscription;
  StreamSubscription? _alarmSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.fetchLocation) {
      _fetchInitialLocation();
    }
    try {
      _updateSubscription = FlutterBackgroundService().on('update').listen((event) {
        if (event != null && event['lat'] != null && event['lng'] != null) {
          final lat = (event['lat'] as num).toDouble();
          final lng = (event['lng'] as num).toDouble();
          ref.read(matchedPositionProvider.notifier).set(LatLng(lat, lng));
        }
      });

      _alarmSubscription = FlutterBackgroundService().on('alarmTriggered').listen((event) {
        if (mounted) {
          ref.read(alarmStateProvider.notifier).set(AlarmState.mainAlarmTriggered);
        }
      });
    } catch (_) {
      // Ignore exception in test environments where FlutterBackgroundService is unsupported
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _alarmSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchInitialLocation() async {
    try {
      // Get a fast network-based fix before the GPS stream warms up
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      if (mounted) {
        ref.read(matchedPositionProvider.notifier).set(LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final routeGeometry = ref.watch(routeGeometryProvider);
    final matchedPosition = ref.watch(matchedPositionProvider);
    final tripState = ref.watch(tripStateProvider);

    // Update last known position if we have a valid new one
    if (matchedPosition != null && tripState != TripState.gpsUncertain) {
      _lastKnownPosition = matchedPosition;
    }

    // Auto-follow logic (debounced implicitly by the provider updates)
    if (!_userHasPanned && _lastKnownPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Prevent constant jitter by only moving if distance is significant
        // (In a real app, you might use a distance check here)
        try {
          _mapController.move(_lastKnownPosition!, _mapController.camera.zoom);
        } catch (_) {
          // Controller might not be ready yet
        }
      });
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _lastKnownPosition ?? const LatLng(30.0444, 31.2357), // Cairo default
            initialZoom: 14,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                setState(() => _userHasPanned = true);
              }
            },
          ),
          children: [
            ref.watch(mapTileProvider).buildTileLayer(),
            if (routeGeometry.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeGeometry,
                    strokeWidth: 4.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            MarkerLayer(
              markers: _buildMarkers(_lastKnownPosition, tripState),
            ),
          ],
        ),
        
        // Recenter Button
        if (_userHasPanned)
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                setState(() => _userHasPanned = false);
                if (_lastKnownPosition != null) {
                  _mapController.move(_lastKnownPosition!, 15);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),
      ],
    );
  }

  List<Marker> _buildMarkers(LatLng? position, TripState state) {
    final markers = <Marker>[];

    if (position != null) {
      // If GPS is uncertain, pulse or fade the marker
      final isUncertain = state == TripState.gpsUncertain;
      
      markers.add(
        Marker(
          point: position,
          width: 48,
          height: 48,
          child: AnimatedOpacity(
            opacity: isUncertain ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.train, color: Colors.white, size: 24),
            ),
          ),
        ),
      );
    }

    // TODO: Add destination marker using DestinationStationProvider later
    return markers;
  }
}
