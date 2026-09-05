import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive/hive.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

import 'package:train_wake/core/theme/app_theme.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'package:train_wake/trip/alarm_engine.dart';
import 'package:train_wake/features/active_trip/active_trip_map.dart';
import 'package:train_wake/data/models/station.dart';
import 'package:train_wake/features/alarm/alarm_screen.dart';
import 'package:train_wake/services/background_tracking_service.dart';

// ---------------------------------------------------------------------------
// Riverpod Notifiers
// ---------------------------------------------------------------------------

class TripStateNotifier extends Notifier<TripState> {
  @override
  TripState build() => TripState.tracking;

  void set(TripState s) => state = s;
}

class AlarmStateNotifier extends Notifier<AlarmState> {
  @override
  AlarmState build() => AlarmState.armed;

  void set(AlarmState s) => state = s;
}

final etaProvider = Provider.family<double?, Station?>((ref, destination) {
  if (destination == null) return null;
  final currentPosition = ref.watch(matchedPositionProvider);
  if (currentPosition == null) return null;

  final distance = const Distance().as(
    LengthUnit.Meter,
    currentPosition,
    LatLng(destination.latitude, destination.longitude),
  );

  const speedMetersPerSecond = 16.67; // ~60 km/h average
  return distance / speedMetersPerSecond;
});

class MatchedPositionNotifier extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;
  
  void set(LatLng? pos) => state = pos;
}

class RouteGeometryNotifier extends Notifier<List<LatLng>> {
  @override
  List<LatLng> build() => [];
  
  void set(List<LatLng> geo) => state = geo;
}

final tripStateProvider =
    NotifierProvider<TripStateNotifier, TripState>(TripStateNotifier.new);

final alarmStateProvider =
    NotifierProvider<AlarmStateNotifier, AlarmState>(AlarmStateNotifier.new);

final matchedPositionProvider = 
    NotifierProvider<MatchedPositionNotifier, LatLng?>(MatchedPositionNotifier.new);

final routeGeometryProvider = 
    NotifierProvider<RouteGeometryNotifier, List<LatLng>>(RouteGeometryNotifier.new);

// ---------------------------------------------------------------------------
// Active Trip Screen (Stitch UI)
// ---------------------------------------------------------------------------

class ActiveTripScreen extends ConsumerWidget {
  final Station? destination;
  final String? destinationName;
  final double? destLat;
  final double? destLng;
  final bool fetchMapLocation;

  const ActiveTripScreen({
    super.key,
    this.destination,
    this.destinationName,
    this.destLat,
    this.destLng,
    this.fetchMapLocation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedDestination = destination ??
        (destinationName != null
            ? Station(
                id: destinationName!,
                nameAr: destinationName!,
                nameEn: destinationName!,
                latitude: destLat ?? 30.0444,
                longitude: destLng ?? 31.2357,
              )
            : null);

    ref.listen<AlarmState>(alarmStateProvider, (previous, next) {
      if (next == AlarmState.mainAlarmTriggered) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlarmScreen(
              destinationName: resolvedDestination?.nameAr ?? 'وجهتك',
            ),
          ),
        );
      }
    });

    final tripState = ref.watch(tripStateProvider);
    final eta = ref.watch(etaProvider(resolvedDestination));

    final cardBg = isDark
        ? AppTheme.surfaceDark.withValues(alpha: 0.96)
        : AppTheme.surfaceLowest.withValues(alpha: 0.96);
    final borderColor = isDark ? AppTheme.borderSubtleDark : const Color(0xFFE5DFD7);
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.canvasDark : AppTheme.canvasLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Map Layer
            Positioned.fill(
              child: ActiveTripMap(fetchLocation: fetchMapLocation),
            ),

            // Foreground Floating UI Elements
            Column(
              children: [
                // Top Custom Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, size: 20, color: textPrimary),
                        onPressed: () async {
                          try {
                            final box = Hive.box('trip_state_box');
                            await box.delete('active_trip');
                            BackgroundTrackingService().stopTracking();
                            FlutterRingtonePlayer().stop();
                            Vibration.cancel();
                          } catch (_) {}
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'متابعة الرحلة الحية',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              'Active Train Navigation',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.tertiaryFixed,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'تتبع نشط • Live',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onTertiaryFixed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom Floating Control Cards
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Destination header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryFixed,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.location_on, color: AppTheme.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'وجهتك • Destination',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary,
                                    ),
                                  ),
                                  Text(
                                    resolvedDestination?.nameAr ?? 'الإسكندرية',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryFixed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.alarm_on, size: 14, color: AppTheme.secondary),
                                const SizedBox(width: 4),
                                Text(
                                  'المنبه جاهز',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSecondaryFixed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ETA display
                      _buildEtaDisplay(context, eta, tripState),
                      const SizedBox(height: 14),

                      // Status Indicator
                      _buildStatusIndicator(context, tripState),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtaDisplay(BuildContext context, double? eta, TripState state) {
    if (state == TripState.gpsUncertain) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text(
              'إشارة الـGPS ضعيفة... جاري إعادة الاتصال',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (eta == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final minutes = (eta / 60).ceil();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الوقت المتبقي تقريباً',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                ),
              ),
              Text(
                'Estimated Arrival Time',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  color: isDark ? AppTheme.outlineDark : AppTheme.textOutline,
                ),
              ),
            ],
          ),
          Text(
            '~ $minutes دقيقة',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, TripState state) {
    String statusText = 'TrainWake يتابع رحلتك الآن';
    IconData icon = Icons.shield_outlined;
    Color color = AppTheme.tertiary;

    if (state == TripState.approaching) {
      statusText = 'نقترب من الوجهة...';
      color = AppTheme.secondary;
      icon = Icons.train;
    } else if (state == TripState.alarmArmed) {
      statusText = 'المنبه جاهز';
      color = AppTheme.primary;
      icon = Icons.alarm;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
