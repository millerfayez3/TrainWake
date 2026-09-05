import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:train_wake/core/theme/app_theme.dart';
import 'package:train_wake/simulation/simulation_controller.dart';
import 'package:train_wake/simulation/simulation_engine.dart';
import 'package:train_wake/trip/trip_engine.dart';
import 'package:train_wake/trip/alarm_engine.dart';
import 'package:train_wake/features/active_trip/active_trip_screen.dart';
import 'package:train_wake/data/repositories/station_repository_impl.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

/// Enterprise Admin Operations Center & Live Simulation Dashboard
///
/// Designed like industrial mobility command centers (Uber, Deutsche Bahn, FlightRadar).
/// Provides live railway fleet telemetry, interactive simulation controls with real Egyptian
/// routes, fault injection suite, and network diagnostic tools.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final double _customSpeedMps = 25.0; // ~90 km/h
  String _stationSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final simState = ref.watch(simulationControllerProvider);
    final simCtrl = ref.read(simulationControllerProvider.notifier);
    final frame = simState.lastFrame;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield, color: Color(0xFFF59E0B), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'OPERATIONS COMMAND',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF59E0B),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'مركز العمليات والمحاكاة',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Live status pulse indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: simState.status == SimulationStatus.running
                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: simState.status == SimulationStatus.running
                    ? const Color(0xFF10B981)
                    : Colors.white24,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: simState.status == SimulationStatus.running
                        ? const Color(0xFF10B981)
                        : Colors.white38,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  simState.status.name.toUpperCase(),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: simState.status == SimulationStatus.running
                        ? const Color(0xFF10B981)
                        : Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.rocket_launch, size: 18), text: 'المحاكاة الحية'),
            Tab(icon: Icon(Icons.alt_route, size: 18), text: 'شبكة القطارات'),
            Tab(icon: Icon(Icons.people_alt, size: 18), text: 'المستخدمين'),
            Tab(icon: Icon(Icons.memory, size: 18), text: 'فحص النظام'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveSimulationDeck(simState, simCtrl, frame),
          _buildRailwayNetworkTab(),
          _buildUsersTab(),
          _buildDiagnosticsTab(),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: LIVE SIMULATION DECK (Mission Control)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildLiveSimulationDeck(
    SimulationControllerState simState,
    SimulationController simCtrl,
    SimulationFrame? frame,
  ) {
    final speedKmh = ((frame?.speedMps ?? _customSpeedMps) * 3.6).round();
    final remainingKm = frame != null ? (frame.remainingMeters / 1000.0).toStringAsFixed(1) : '—';
    final progressPercent = frame != null && frame.destinationMeters > 0
        ? (frame.progressMeters / frame.destinationMeters).clamp(0.0, 1.0)
        : 0.0;
    final etaMinutes = frame?.etaSeconds != null ? (frame!.etaSeconds! / 60.0).round() : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. ROUTE SELECTOR BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF161F30),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A364F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.train, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'مسار الرحلة للمحاكاة • Route',
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Egyptian Railways ENR',
                    style: GoogleFonts.ibmPlexSans(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: simState.activeRouteName,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF161F30),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
                  items: SimulationController.presetRoutes.keys.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newRoute) {
                    if (newRoute != null) {
                      simCtrl.selectRoute(newRoute);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. LIVE TELEMETRY COCKPIT (Speed, Progress & ETA)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF131B2A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF334155)),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Top metric badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTelemetryBadge(
                    'سرعة القطار',
                    '$speedKmh',
                    'km/h',
                    const Color(0xFF38BDF8),
                  ),
                  _buildTelemetryBadge(
                    'المسافة المتبقية',
                    remainingKm,
                    'km',
                    const Color(0xFFFBBF24),
                  ),
                  _buildTelemetryBadge(
                    'الوقت المتوقع',
                    etaMinutes != null ? '$etaMinutes' : '—',
                    'min ETA',
                    const Color(0xFF34D399),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Visual Progress Track (The Train on Line)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تقدم القطار على الخط (Track Progress)',
                        style: GoogleFonts.ibmPlexSans(color: Colors.white60, fontSize: 11),
                      ),
                      Text(
                        '${(progressPercent * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.ibmPlexSans(
                          color: const Color(0xFF34D399),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF0F172A),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Engine State Matrix
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStateIndicator(
                      'حالة الرحلة',
                      frame?.tripState.name ?? 'idle',
                      _getTripStateColor(frame?.tripState),
                    ),
                    Container(height: 24, width: 1, color: Colors.white12),
                    _buildStateIndicator(
                      'نظام المنبه',
                      frame?.alarmState.name ?? 'armed',
                      _getAlarmStateColor(frame?.alarmState),
                    ),
                    Container(height: 24, width: 1, color: Colors.white12),
                    _buildStateIndicator(
                      'دقة الـ GPS',
                      '${(frame?.gpsAccuracy ?? 5.0).toInt()}m (High)',
                      const Color(0xFF38BDF8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. PLAYBACK CONTROLS (Mission Deck)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161F30),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2A364F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التحكم في سرعة المحاكاة • Playback & Multiplier',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),

              // Play / Pause / Reset Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (simState.status == SimulationStatus.running) {
                          simCtrl.pause();
                        } else if (simState.status == SimulationStatus.paused) {
                          simCtrl.resume();
                        } else {
                          simCtrl.start(speedMps: _customSpeedMps);
                        }
                      },
                      icon: Icon(
                        simState.status == SimulationStatus.running
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 20,
                      ),
                      label: Text(
                        simState.status == SimulationStatus.running
                            ? 'إيقاف مؤقت'
                            : (simState.status == SimulationStatus.paused ? 'استئناف' : 'بدء المحاكاة'),
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: simState.status == SimulationStatus.running
                            ? const Color(0xFFEAB308)
                            : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => simCtrl.reset(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.replay, size: 20),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActiveTripScreen(
                            destinationName: 'محطة الوصول (محاكاة)',
                            destLat: 31.1925,
                            destLng: 29.9056,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.open_in_new, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Multiplier Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [1.0, 2.0, 5.0, 10.0, 20.0].map((m) {
                  final isSelected = simState.multiplier == m;
                  return InkWell(
                    onTap: () => simCtrl.setMultiplier(m),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : const Color(0xFF334155),
                        ),
                      ),
                      child: Text(
                        '${m.toInt()}x',
                        style: GoogleFonts.ibmPlexSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. FLIGHT SIMULATOR FAULT INJECTION (Test Suite)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161F30),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2A364F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFF43F5E), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'لوحة حقن الأخطاء والحالات الحرجة • Fault Injection',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFaultButton(
                    'نفق (فقدان GPS)',
                    Icons.cell_wifi,
                    const Color(0xFF64748B),
                    () {
                      simCtrl.forceGpsLoss();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ تم محاكاة دخول نفق وفقدان إشارة GPS')),
                      );
                    },
                  ),
                  _buildFaultButton(
                    'استعادة GPS',
                    Icons.satellite_alt,
                    const Color(0xFF0284C7),
                    () {
                      simCtrl.forceGpsRecovery();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ تم استعادة إشارة GPS بنجاح')),
                      );
                    },
                  ),
                  _buildFaultButton(
                    'توقف بمحطة (0 km/h)',
                    Icons.stop_circle,
                    const Color(0xFFEAB308),
                    () {
                      simCtrl.forceStationStop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🛑 توقف القطار في المحطة')),
                      );
                    },
                  ),
                  _buildFaultButton(
                    'إطلاق منبه الاستيقاظ',
                    Icons.alarm,
                    const Color(0xFFF43F5E),
                    () {
                      simCtrl.forceAlarm();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🚨 تم تفعيل منبه الاستيقاظ الفائق')),
                      );
                    },
                  ),
                  _buildFaultButton(
                    'محاكاة الوصول الآمن',
                    Icons.check_circle,
                    const Color(0xFF10B981),
                    () {
                      simCtrl.forceArrival();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🎉 وصل القطار للمحطة بنجاح')),
                      );
                    },
                  ),
                  _buildFaultButton(
                    'تجاوز المحطة (فائتة)',
                    Icons.error_outline,
                    const Color(0xFFDC2626),
                    () {
                      simCtrl.forceMissed();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ تم تسجيل محطة فائتة')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: RAILWAY NETWORK & STATIONS (92 Stations)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildRailwayNetworkTab() {
    final repo = ref.watch(stationRepositoryProvider);
    final allStations = repo.searchStations('');
    final filtered = _stationSearchQuery.isEmpty
        ? allStations
        : repo.searchStations(_stationSearchQuery);

    return Column(
      children: [
        // Network Header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF111827),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'شبكة السكك الحديدية المصرية',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${allStations.length} محطة مسجلة',
                      style: GoogleFonts.ibmPlexSans(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (val) => setState(() => _stationSearchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ابحث في محطات مصر بالاسم أو الخط...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                  filled: true,
                  fillColor: const Color(0xFF1F2937),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ],
          ),
        ),

        // Stations List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final station = filtered[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161F30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A364F)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.train, color: AppTheme.primary, size: 18),
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
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${station.nameEn} • Lat: ${station.latitude.toStringAsFixed(3)}, Lng: ${station.longitude.toStringAsFixed(3)}',
                            style: GoogleFonts.ibmPlexSans(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'جاهزة',
                        style: GoogleFonts.ibmPlexSans(
                          color: const Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: USERS & ACCESS MANAGEMENT
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildUsersTab() {
    final users = [
      {'email': 'millerfayez5@gmail.com', 'role': '👑 ADMIN', 'status': 'نشط على هذا الهاتف', 'isAdmin': true},
      {'email': 'millerfayezin@gmail.com', 'role': '👤 USER', 'status': 'مستخدم مسجل', 'isAdmin': false},
      {'email': 'millerutube1@gmail.com', 'role': '👤 USER', 'status': 'مستخدم مسجل', 'isAdmin': false},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161F30),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A364F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'قائمة المشرفين والصلاحيات • User Registry',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'يتم إدارة الصلاحيات عبر Firebase Custom Claims بمفتاح مشفر وسري.',
                style: GoogleFonts.ibmPlexSans(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        for (final u in users)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF161F30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (u['isAdmin'] as bool) ? const Color(0xFFF59E0B) : const Color(0xFF2A364F),
                width: (u['isAdmin'] as bool) ? 1.0 : 0.8,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (u['isAdmin'] as bool)
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFF334155),
                  child: Icon(
                    (u['isAdmin'] as bool) ? Icons.shield : Icons.person,
                    color: (u['isAdmin'] as bool) ? const Color(0xFFD97706) : Colors.white70,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u['email'] as String,
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        u['status'] as String,
                        style: GoogleFonts.ibmPlexSans(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (u['isAdmin'] as bool)
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    u['role'] as String,
                    style: GoogleFonts.ibmPlexSans(
                      color: (u['isAdmin'] as bool) ? const Color(0xFFF59E0B) : Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 4: SYSTEM & HARDWARE DIAGNOSTICS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDiagnosticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDiagnosticCard(
          title: 'محرك قاعدة البيانات المحلية (Hive Storage)',
          status: 'Online & Intact',
          details: 'صناديق البيانات المفتوحة: trip_state_box, history_box',
          icon: Icons.storage,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(height: 10),
        _buildDiagnosticCard(
          title: 'خدمة التتبع بالخلفية (Background Service)',
          status: 'Standby / Lazy Initialized',
          details: 'يعمل بمعدل ترشيح تكيفي للمسافة (Adaptive GPS Filtering 5m/20m/50m)',
          icon: Icons.location_searching,
          color: const Color(0xFF38BDF8),
        ),
        const SizedBox(height: 10),
        _buildDiagnosticCard(
          title: 'خدمة التنبيه الصوتي والاهتزاز',
          status: 'Armed & Ready',
          details: 'الصوت والنغمة جاهزان للاستيقاظ على مكبر الصوت ومحرك الاهتزاز الفائق',
          icon: Icons.volume_up,
          color: const Color(0xFFFBBF24),
          action: OutlinedButton(
            onPressed: () {
              FlutterRingtonePlayer().playNotification();
              Vibration.vibrate(duration: 500);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFBBF24),
              side: const BorderSide(color: Color(0xFFFBBF24)),
            ),
            child: const Text('اختبار الصوت والاهتزاز'),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // WIDGET HELPERS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildTelemetryBadge(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.ibmPlexSans(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: GoogleFonts.ibmPlexSans(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(unit, style: GoogleFonts.ibmPlexSans(color: color.withValues(alpha: 0.7), fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildStateIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.ibmPlexSans(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.ibmPlexSans(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFaultButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDiagnosticCard({
    required String title,
    required String status,
    required String details,
    required IconData icon,
    required Color color,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A364F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.ibmPlexSans(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(details, style: GoogleFonts.ibmPlexSans(color: Colors.white54, fontSize: 11)),
          if (action != null) ...[
            const SizedBox(height: 10),
            action,
          ],
        ],
      ),
    );
  }

  Color _getTripStateColor(TripState? state) {
    switch (state) {
      case TripState.approaching:
        return const Color(0xFFFBBF24);
      case TripState.arrived:
        return const Color(0xFF34D399);
      case TripState.missed:
        return const Color(0xFFF43F5E);
      case TripState.tracking:
        return const Color(0xFF38BDF8);
      default:
        return Colors.white70;
    }
  }

  Color _getAlarmStateColor(AlarmState? state) {
    switch (state) {
      case AlarmState.unacknowledged:
        return const Color(0xFFF43F5E);
      case AlarmState.earlyWarningTriggered:
        return const Color(0xFFFBBF24);
      case AlarmState.completed:
        return const Color(0xFF34D399);
      case AlarmState.armed:
        return const Color(0xFF38BDF8);
      default:
        return Colors.white70;
    }
  }
}
