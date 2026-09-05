import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:train_wake/features/active_trip/active_trip_map.dart';
import 'package:train_wake/features/active_trip/active_trip_screen.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'package:train_wake/features/map/map_tile_provider.dart';

// Test Notifiers
class TestTripNotifier extends TripStateNotifier {
  final TripState _initialState;
  TestTripNotifier([this._initialState = TripState.tracking]);
  @override
  TripState build() => _initialState;

  void setState(TripState s) => state = s;
}

class TestMatchedPositionNotifier extends MatchedPositionNotifier {
  final LatLng? _initialState;
  TestMatchedPositionNotifier([this._initialState]);
  @override
  LatLng? build() => _initialState;
}

class TestRouteGeometryNotifier extends RouteGeometryNotifier {
  final List<LatLng> _initialState;
  TestRouteGeometryNotifier([this._initialState = const []]);
  @override
  List<LatLng> build() => _initialState;
}

class FakeMapTileProvider implements MapTileProvider {
  @override
  Widget buildTileLayer() {
    return const SizedBox();
  }
}

void main() {
  group('Map Layer Independence & Visualization', () {
    testWidgets('ActiveTripMap consumes route geometry and renders Polyline', (tester) async {
      final route = [
        const LatLng(30.0, 31.0),
        const LatLng(30.1, 31.1),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeGeometryProvider.overrideWith(() => TestRouteGeometryNotifier(route)),
            matchedPositionProvider.overrideWith(() => TestMatchedPositionNotifier(null)),
            tripStateProvider.overrideWith(() => TestTripNotifier(TripState.tracking)),
            mapTileProvider.overrideWithValue(FakeMapTileProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ActiveTripMap(fetchLocation: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final polylineLayerFinder = find.byType(PolylineLayer);
      expect(polylineLayerFinder, findsOneWidget);

      final polylineLayer = tester.widget<PolylineLayer>(polylineLayerFinder);
      expect(polylineLayer.polylines.length, 1);
      expect(polylineLayer.polylines.first.points, route);
    });

    testWidgets('ActiveTripMap renders current position marker when available', (tester) async {
      const position = LatLng(30.05, 31.05);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeGeometryProvider.overrideWith(() => TestRouteGeometryNotifier([])),
            matchedPositionProvider.overrideWith(() => TestMatchedPositionNotifier(position)),
            tripStateProvider.overrideWith(() => TestTripNotifier(TripState.tracking)),
            mapTileProvider.overrideWithValue(FakeMapTileProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ActiveTripMap(fetchLocation: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final markerLayerFinder = find.byType(MarkerLayer);
      expect(markerLayerFinder, findsOneWidget);
      
      final markerLayer = tester.widget<MarkerLayer>(markerLayerFinder);
      expect(markerLayer.markers.length, 1);
      expect(markerLayer.markers.first.point, position);
    });

    testWidgets('ActiveTripMap reduces marker opacity (visual uncertainty) when gpsUncertain', (tester) async {
      const position = LatLng(30.05, 31.05);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeGeometryProvider.overrideWith(() => TestRouteGeometryNotifier([])),
            matchedPositionProvider.overrideWith(() => TestMatchedPositionNotifier(position)),
            tripStateProvider.overrideWith(() => TestTripNotifier(TripState.tracking)),
            mapTileProvider.overrideWithValue(FakeMapTileProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ActiveTripMap(fetchLocation: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(ActiveTripMap));
      final container = ProviderScope.containerOf(context);
      container.read(tripStateProvider.notifier).state = TripState.gpsUncertain;
      
      await tester.pumpAndSettle();

      // Find the AnimatedOpacity wrapping the marker
      final opacityFinder = find.byType(AnimatedOpacity);
      expect(opacityFinder, findsOneWidget);
      
      final animatedOpacity = tester.widget<AnimatedOpacity>(opacityFinder);
      expect(animatedOpacity.opacity, 0.4); // From our implementation
    });
  });
}
