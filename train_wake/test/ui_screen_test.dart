import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:train_wake/features/active_trip/active_trip_screen.dart';
import 'package:train_wake/features/alarm/alarm_screen.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'package:train_wake/trip/alarm_engine.dart';
import 'package:train_wake/features/map/map_tile_provider.dart';

class TestTripNotifier extends TripStateNotifier {
  final TripState _initialState;
  TestTripNotifier([this._initialState = TripState.tracking]);
  @override
  TripState build() => _initialState;
}

class TestAlarmNotifier extends AlarmStateNotifier {
  final AlarmState _initialState;
  TestAlarmNotifier([this._initialState = AlarmState.armed]);
  @override
  AlarmState build() => _initialState;
}


class FakeMapTileProvider implements MapTileProvider {
  @override
  Widget buildTileLayer() {
    return const SizedBox();
  }
}

void main() {
  group('AlarmScreen', () {
    testWidgets('shows wake-up UI when alarm is unacknowledged', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            alarmStateProvider.overrideWith(() => TestAlarmNotifier(AlarmState.unacknowledged)),
          ],
          child: const MaterialApp(
            home: AlarmScreen(destinationName: 'الإسكندرية'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('أنا صاحي'), findsOneWidget);
      expect(find.text('كمّل المتابعة'), findsOneWidget);
      expect(find.text('استيقظ!'), findsOneWidget);
    });

    testWidgets('shows acknowledged view if alarm already completed — idempotent', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            alarmStateProvider.overrideWith(() => TestAlarmNotifier(AlarmState.acknowledged)),
          ],
          child: const MaterialApp(
            home: AlarmScreen(destinationName: 'الإسكندرية'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('تم تأكيد الاستيقاظ'), findsOneWidget);
      expect(find.text('أنا صاحي'), findsNothing);
    });

    testWidgets('destination name appears in alarm screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: AlarmScreen(destinationName: 'دمنهور'),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('دمنهور'), findsOneWidget);
    });
  });

  group('ActiveTripScreen', () {
    testWidgets('shows GPS uncertain message for gpsUncertain state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripStateProvider.overrideWith(() => TestTripNotifier(TripState.gpsUncertain)),
            etaProvider.overrideWith((ref, station) => null),
            mapTileProvider.overrideWithValue(FakeMapTileProvider()),
          ],
          child: const MaterialApp(home: ActiveTripScreen(fetchMapLocation: false)),
        ),
      );
      await tester.pump();
      expect(find.textContaining('GPS'), findsOneWidget);
      expect(find.textContaining('confidence'), findsNothing);
      expect(find.textContaining('bearing'), findsNothing);
      expect(find.textContaining('accuracy'), findsNothing);
    });

    testWidgets('shows ETA in minutes when available', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripStateProvider.overrideWith(() => TestTripNotifier()),
            etaProvider.overrideWith((ref, station) => 1200.0),
            mapTileProvider.overrideWithValue(FakeMapTileProvider()),
          ],
          child: const MaterialApp(home: ActiveTripScreen(fetchMapLocation: false)),
        ),
      );
      await tester.pump();
      expect(find.textContaining('20 دقيقة'), findsOneWidget);
    });

    testWidgets('shows spinner when ETA is null', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripStateProvider.overrideWith(() => TestTripNotifier()),
            etaProvider.overrideWith((ref, station) => null),
            mapTileProvider.overrideWithValue(FakeMapTileProvider()),
          ],
          child: const MaterialApp(home: ActiveTripScreen(fetchMapLocation: false)),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Arabic destination label is present', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripStateProvider.overrideWith(() => TestTripNotifier()),
            etaProvider.overrideWith((ref, station) => 1200.0),
            mapTileProvider.overrideWithValue(FakeMapTileProvider()),
          ],
          child: const MaterialApp(
            locale: Locale('ar'),
            home: ActiveTripScreen(fetchMapLocation: false),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('وجهتك'), findsOneWidget);
    });
  });
}

