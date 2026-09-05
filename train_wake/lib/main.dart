import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:train_wake/core/theme/app_theme.dart';
import 'package:train_wake/features/home/home_screen.dart';
import 'package:train_wake/services/background_tracking_service.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'package:train_wake/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Silence any leftover audio/vibration immediately on startup
  try {
    FlutterRingtonePlayer().stop();
    Vibration.cancel();
  } catch (_) {}

  // Initialize Hive for robust local persistence of complex state
  await Hive.initFlutter();
  final tripBox = await Hive.openBox('trip_state_box');
  await Hive.openBox('history_box');

  // Initialize Firebase — failure-tolerant.
  // If google-services.json is missing or Firebase is unreachable,
  // the app still boots and all TrainWake trip/alarm features work normally.
  // Only authentication features become unavailable.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured — auth features will show graceful messages.
    // Trip tracking, GPS, alarms, and Hive continue to function.
  }

  // Only resume background tracking service if there was a genuinely recent in-flight active trip
  final activeTrip = tripBox.get('active_trip');
  if (activeTrip != null && activeTrip['isActive'] == true) {
    final startedAtStr = activeTrip['startedAt'] as String?;
    final startedAt = startedAtStr != null ? DateTime.tryParse(startedAtStr) : null;
    final isStale = startedAt == null || DateTime.now().difference(startedAt).inHours > 10;

    if (isStale) {
      await tripBox.delete('active_trip');
      try {
        final service = FlutterBackgroundService();
        service.invoke('stopService');
      } catch (_) {}
    } else {
      final trackingService = BackgroundTrackingService();
      await trackingService.initialize();
    }
  } else {
    try {
      final service = FlutterBackgroundService();
      service.invoke('stopService');
    } catch (_) {}
  }

  runApp(
    const ProviderScope(
      child: TrainWakeApp(),
    ),
  );
}

class TrainWakeApp extends ConsumerWidget {
  const TrainWakeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'TrainWake',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // Defaulting to Arabic-first as requested
          child: child ?? const SizedBox(),
        );
      },
      home: const HomeScreen(),
    );
  }
}


