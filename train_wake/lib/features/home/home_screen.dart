import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

import 'package:train_wake/core/theme/app_theme.dart';
import 'package:train_wake/data/models/station.dart';
import 'package:train_wake/data/repositories/station_repository_impl.dart';
import 'package:train_wake/features/active_trip/readiness_screen.dart';
import 'package:train_wake/features/history/history_screen.dart';
import 'package:train_wake/features/profile/profile_screen.dart';
import 'package:train_wake/features/settings/settings_screen.dart';
import 'package:train_wake/features/stations/station_search_screen.dart';
import 'package:train_wake/services/permission_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Station? _selectedStation;
  int _wakeOffsetMinutes = 10;
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    try {
      FlutterRingtonePlayer().stop();
      Vibration.cancel();
    } catch (_) {}
  }

  Future<void> _openStationSearch() async {
    final result = await Navigator.push<StationItem>(
      context,
      MaterialPageRoute(builder: (_) => const StationSearchScreen()),
    );
    if (result != null) {
      setState(() {
        _selectedStation = Station(
          id: result.nameEn,
          nameAr: result.nameAr,
          nameEn: result.nameEn,
          latitude: result.lat,
          longitude: result.lng,
        );
      });
    }
  }

  void _showBufferSelector(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.borderSubtleDark : const Color(0xFFD6D3D1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تحديد وقت المنبه المسبق',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر كم دقيقة قبل محطة الوصول ترغب في إيقاظك',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [5, 10, 15, 20, 30].map((minutes) {
                    final isSelected = _wakeOffsetMinutes == minutes;
                    return ChoiceChip(
                      label: Text(
                        '$minutes دقائق',
                        style: GoogleFonts.ibmPlexSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceLow,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _wakeOffsetMinutes = minutes);
                          Navigator.pop(context);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataLoader = ref.watch(stationDataLoaderProvider);
    final repo = ref.watch(stationRepositoryProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasBg = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
    final cardBg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLowest;
    final lowContainerBg = isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceLow;
    final searchInputBg = isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceContainer;
    final borderColor = isDark ? AppTheme.borderSubtleDark : const Color(0xFFE5DFD7);
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    final outlineColor = isDark ? AppTheme.outlineDark : AppTheme.textOutline;

    return Scaffold(
      backgroundColor: canvasBg,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: borderColor,
              width: 0.8,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentBottomNavIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: AppTheme.primaryFixed,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppTheme.primary),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.location_city_outlined),
              selectedIcon: Icon(Icons.location_city, color: AppTheme.primary),
              label: 'المحطات',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history, color: AppTheme.primary),
              label: 'السجل',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppTheme.primary),
              label: 'حسابي',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: AppTheme.primary),
              label: 'الإعدادات',
            ),
          ],
          onDestinationSelected: (index) async {
            setState(() => _currentBottomNavIndex = index);
            if (index == 1) {
              await _openStationSearch();
              setState(() => _currentBottomNavIndex = 0);
            } else if (index == 2) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
              setState(() => _currentBottomNavIndex = 0);
            } else if (index == 3) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              setState(() => _currentBottomNavIndex = 0);
            } else if (index == 4) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              setState(() => _currentBottomNavIndex = 0);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------------------------------------------------------
            // 1. Stitch App Bar Header
            // ---------------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.surfaceDark.withValues(alpha: 0.95)
                    : AppTheme.canvasLight.withValues(alpha: 0.95),
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  // Brand Icon & Titles
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryFixed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.train,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TrainWake',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              'Active Trip Mode',
                              style: GoogleFonts.ibmPlexSans(
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // GPS Active Live Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.tertiaryFixed.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'GPS Active',
                          style: GoogleFonts.ibmPlexSans(
                            color: AppTheme.tertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Profile Activity Button
                  IconButton(
                    icon: const Icon(
                      Icons.account_circle,
                      size: 24,
                      color: AppTheme.primary,
                    ),
                    tooltip: 'الملف الشخصي والحساب',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),
                  // Settings Shortcut Button
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: textPrimary,
                    ),
                    tooltip: 'الإعدادات والمظهر',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------------------
            // 2. Scrollable Content Body
            // ---------------------------------------------------------------
            Expanded(
              child: dataLoader.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
                error: (err, stack) => Center(
                  child: Text('Error: $err', style: TextStyle(color: textPrimary)),
                ),
                data: (_) {
                  final allStations = repo.searchStations('');
                  if (allStations.isEmpty) {
                    return Center(
                      child: Text('لم يتم العثور على محطات', style: TextStyle(color: textPrimary)),
                    );
                  }

                  _selectedStation ??= allStations.first;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // Greeting Pill & Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryFixed,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bedtime,
                                  size: 14,
                                  color: AppTheme.secondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'نوم هادئ ومضمون • Safe Sleep',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSecondaryFixed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'قطار ٩٨٠ • Train 980',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'هتنزل فين؟',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Where are you getting off? حدد وجهتك ونام مرتاح البال',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fast Interactive Search Card (Instant tap opens station directory)
                      InkWell(
                        onTap: _openStationSearch,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: searchInputBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppTheme.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedStation == null
                                      ? 'ابحث عن محطة... Search station'
                                      : 'المحطة: ${_selectedStation!.nameAr} (اضغط للتغيير)',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: _selectedStation == null ? outlineColor : textPrimary,
                                    fontSize: 14,
                                    fontWeight: _selectedStation == null ? FontWeight.w500 : FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryFixed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'تصفح الكل',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),


                      // -----------------------------------------------------
                      // Selected Destination Target Card (Hero)
                      // -----------------------------------------------------
                      Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: borderColor,
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Card Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryFixed,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'المحطة المحددة • Target',
                                    style: GoogleFonts.ibmPlexSans(
                                      color: AppTheme.onPrimaryFixed,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.satellite_alt,
                                      size: 16,
                                      color: AppTheme.tertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'GPS Locked',
                                      style: GoogleFonts.ibmPlexSans(
                                        color: AppTheme.tertiary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Station Identity & Analog Signage Style
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryFixed,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: AppTheme.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedStation?.nameAr ?? 'اختر المحطة',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_selectedStation?.nameEn ?? ""} • رصيف المحطة',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: _openStationSearch,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    side: BorderSide(color: borderColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(0, 34),
                                  ),
                                  child: Text(
                                    'تغيير',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Journey Telemetry Strip
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: lowContainerBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildTelemetryItem(
                                    labelAr: 'المسافة المتبقية',
                                    value: '48 km',
                                    labelEn: 'Distance',
                                    valueColor: textPrimary,
                                    labelColor: textSecondary,
                                    sublabelColor: outlineColor,
                                  ),
                                  _buildDivider(borderColor),
                                  _buildTelemetryItem(
                                    labelAr: 'السرعة الحالية',
                                    value: '104 km/h',
                                    labelEn: 'Speed',
                                    valueColor: AppTheme.tertiary,
                                    labelColor: textSecondary,
                                    sublabelColor: outlineColor,
                                  ),
                                  _buildDivider(borderColor),
                                  _buildTelemetryItem(
                                    labelAr: 'نصف قطر المنبه',
                                    value: '5 km',
                                    labelEn: 'Geofence',
                                    valueColor: AppTheme.primary,
                                    labelColor: textSecondary,
                                    sublabelColor: outlineColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Wake-up Buffer Setting Selector
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryFixed.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.alarm_on,
                                    color: AppTheme.secondary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'منبه قبلها بـ $_wakeOffsetMinutes دقائق',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.onSecondaryFixed,
                                          ),
                                        ),
                                        Text(
                                          'Wake ${_wakeOffsetMinutes}m before arrival (يشمل اهتزاز قوي)',
                                          style: GoogleFonts.ibmPlexSans(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _showBufferSelector(context, isDark),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'تعديل',
                                        style: GoogleFonts.ibmPlexSans(
                                          color: AppTheme.secondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Primary Trip Activation CTA Button
                            ElevatedButton.icon(
                              onPressed: () => _startTrip(context),
                              icon: const Icon(Icons.play_circle_filled, size: 22),
                              label: Text(
                                'ابدأ الرحلة — Start Trip & Sleep',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // -----------------------------------------------------
                      // Recent / Suggested Stations Section
                      // -----------------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                size: 18,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'المحطات السابقة والمقترحة',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _openStationSearch,
                            child: Text(
                              'عرض الكل',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ...allStations.take(4).map((station) {
                        final isSelected = station.id == _selectedStation?.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedStation = station;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLowest)
                                    : (isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceLow),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : borderColor,
                                  width: isSelected ? 1.5 : 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryFixed
                                          : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceContainer),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.train,
                                      color: isSelected
                                          ? AppTheme.primary
                                          : textSecondary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          station.nameAr,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${station.nameEn} • خط السكة الحديد',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isSelected ? 'المحددة' : 'اختيار',
                                        style: GoogleFonts.ibmPlexSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppTheme.primary
                                              : textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 6),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _openStationSearch,
                          icon: const Icon(Icons.travel_explore, size: 18, color: AppTheme.primary),
                          label: Text(
                            'تصفح وبحث في كافة المحطات (91 محطة) — View All',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Safety & Offline Reassurance Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: searchInputBg.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 18,
                              color: AppTheme.tertiary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'نظام تحديد الموقع يعمل تلقائياً وبأمان في الخلفية وبدون اتصال إنترنت.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryItem({
    required String labelAr,
    required String value,
    required String labelEn,
    required Color valueColor,
    required Color labelColor,
    required Color sublabelColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labelAr,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 10,
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        Text(
          labelEn,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 9,
            color: sublabelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      height: 32,
      width: 1,
      color: color,
    );
  }

  Future<void> _startTrip(BuildContext context) async {
    final station = _selectedStation;
    if (station == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المحطة أولاً')),
      );
      return;
    }

    final permissionService = PermissionService();
    final granted = await permissionService.checkAndRequestLocationPermissions();

    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تفعيل خدمات الموقع للبدء بالرحلة')),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadinessScreen(
            destinationName: station.nameAr,
            destLat: station.latitude,
            destLng: station.longitude,
            bufferMeters: 5000,
          ),
        ),
      );
    }
  }
}
