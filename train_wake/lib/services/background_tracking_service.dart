import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'package:train_wake/trip/trip_engine.dart';

// The background entry point must be top-level or static.
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // 1. Initialize isolated environment
  DartPluginRegistrant.ensureInitialized();
  await Hive.initFlutter();
  
  // 2. Load persistent TripState
  // TODO: Add proper TypeAdapters for robust serialization
  final box = await Hive.openBox('trip_state_box');
  final activeTripData = box.get('active_trip');
  
  if (activeTripData == null || activeTripData['isActive'] != true) {
    // Never run or sound alarm if trip is not actively started
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
    try {
      Vibration.cancel();
    } catch (_) {}
    service.stopSelf();
    return;
  }

  // 3. Initialize Production Pipeline
  final tripEngine = TripEngine();
  // ... restore state from activeTripData into tripEngine context ...

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 4. Adaptive Sampling Configuration
  LocationSettings getLocationSettings(double remainingDistance) {
    if (remainingDistance > 10000) {
      return const LocationSettings(accuracy: LocationAccuracy.medium, distanceFilter: 50);
    } else if (remainingDistance > 3000) {
      return const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 20);
    } else {
      return const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);
    }
  }

  bool hasAlarmFired = false;

  // 5. Connect GPS Stream to production logic
  StreamSubscription<Position>? positionStream;

  service.on('stopAlarm').listen((event) {
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
    try {
      Vibration.cancel();
    } catch (_) {}
  });

  service.on('stopService').listen((event) {
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}
    try {
      Vibration.cancel();
    } catch (_) {}
    positionStream?.cancel();
    service.stopSelf();
  });
  
  void startStream(LocationSettings settings) {
    positionStream?.cancel();
    positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position position) async {
      
      // Feed GPS into RailwayMatcher -> DirectionDetector -> TripEngine
      // tripEngine.updateProgress(calculatedProgress, position.speed, position.accuracy);
      
      // Update foreground notification — flutter_local_notifications v22: all named params
      await flutterLocalNotificationsPlugin.show(
        id: 888,
        title: 'TrainWake — يتابع رحلتك',
        body: 'جاري حساب وقت الوصول...',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'train_wake_tracking',
            'Active Trip Tracking',
            channelDescription: 'TrainWake background trip tracking',
            icon: 'ic_bg_service_small',
            ongoing: true,
            importance: Importance.low,
            priority: Priority.low,
          ),
        ),
      );

      final destLat = (activeTripData['destLat'] ?? activeTripData['lat']) as double?;
      final destLng = (activeTripData['destLng'] ?? activeTripData['lng']) as double?;

      if (destLat != null && destLng != null && !hasAlarmFired) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          destLat,
          destLng,
        );

        if (distance <= 5000) { // 5km threshold
          hasAlarmFired = true;
          
          FlutterRingtonePlayer().playAlarm(looping: true, asAlarm: true, volume: 1.0);
          Vibration.hasVibrator().then((hasVibrator) {
            if (hasVibrator == true) {
              Vibration.vibrate(pattern: [500, 1000, 500, 1000, 500, 1000, 500, 1000], repeat: 1);
            }
          });
          
          await flutterLocalNotificationsPlugin.show(
            id: 889,
            title: 'استيقظ! لقد اقتربت من محطتك!',
            body: 'المسافة المتبقية أقل من 5 كم.',
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'train_wake_alarm',
                'Alarm Trigger',
                channelDescription: 'High priority alarm channel',
                importance: Importance.max,
                priority: Priority.max,
                fullScreenIntent: true,
                enableVibration: true,
              ),
            ),
          );

          service.invoke('alarmTriggered');
        }
      }
      
      // Send update to UI Isolate
      service.invoke(
        'update',
        {
          "lat": position.latitude,
          "lng": position.longitude,
        },
      );

      // Persist the updated state safely back to Hive without clobbering destination coordinates
      final updatedData = Map<dynamic, dynamic>.from(activeTripData);
      updatedData['currentLat'] = position.latitude;
      updatedData['currentLng'] = position.longitude;
      box.put('active_trip', updatedData);
      
      if (tripEngine.currentState == TripState.ended) {
        positionStream?.cancel();
        service.stopSelf();
      }
    });
  }

  // Start with default settings, update dynamically via stream later
  startStream(getLocationSettings(25000));
}

class BackgroundTrackingService {
  Future<void> initialize() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_bg_service_small');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'train_wake_tracking',
      'Active Trip Tracking',
      description: 'TrainWake background trip tracking',
      importance: Importance.low, // importance must be low or higher for foreground
    );

    const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
      'train_wake_alarm',
      'Alarm Trigger',
      description: 'High priority alarm channel',
      importance: Importance.max,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(alarmChannel);

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'train_wake_tracking',
        initialNotificationTitle: 'TrainWake',
        initialNotificationContent: 'Initializing Tracking...',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: (ServiceInstance service) => false,
      ),
    );
  }

  Future<void> startTracking() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  Future<void> startTrip({
    required double destLat,
    required double destLng,
    required String destinationName,
    double alarmBufferMeters = 5000,
    int wakeOffsetMinutes = 10,
  }) async {
    final box = Hive.box('trip_state_box');
    await box.put('active_trip', {
      'destinationId': destinationName,
      'destinationName': destinationName,
      'destLat': destLat,
      'destLng': destLng,
      'lat': destLat,
      'lng': destLng,
      'isActive': true,
      'progress': 0.0,
      'alarmBufferMeters': alarmBufferMeters,
      'wakeOffsetMinutes': wakeOffsetMinutes,
    });
    await startTracking();
  }

  void stopTracking() {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
  }
}
