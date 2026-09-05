import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:train_wake/core/theme/app_theme.dart';
import 'package:train_wake/core/theme/theme_provider.dart';
import 'package:train_wake/features/auth/presentation/admin_dashboard_screen.dart';
import 'package:train_wake/features/developer/developer_screen.dart';
import 'package:vibration/vibration.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedBufferMinutes = 10;
  bool _isPlayingAudio = false;
  bool _vibrationEnabled = true;
  bool _dndOverrideEnabled = true;

  @override
  void dispose() {
    if (_isPlayingAudio) {
      FlutterRingtonePlayer().stop();
    }
    super.dispose();
  }

  void _toggleAudioPreview() {
    if (_isPlayingAudio) {
      FlutterRingtonePlayer().stop();
      setState(() => _isPlayingAudio = false);
    } else {
      try {
        FlutterRingtonePlayer().playAlarm(
          volume: 0.8,
          looping: false,
          asAlarm: true,
        );
        setState(() => _isPlayingAudio = true);
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && _isPlayingAudio) {
            FlutterRingtonePlayer().stop();
            setState(() => _isPlayingAudio = false);
          }
        });
      } catch (_) {}
    }
  }

  void _toggleVibration(bool val) {
    setState(() => _vibrationEnabled = val);
    if (val) {
      try {
        Vibration.vibrate(duration: 400);
      } catch (_) {}
    }
  }

  void _showBufferPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'اختر توقيت الاستيقاظ الافتراضي',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                for (final mins in [5, 10, 15, 20])
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: _selectedBufferMinutes == mins
                        ? AppTheme.primaryFixed
                        : null,
                    title: Text(
                      'قبل المحطة بـ $mins دقائق (~${mins * 1.5 ~/ 1} كم)',
                      style: GoogleFonts.ibmPlexSans(
                        fontWeight: _selectedBufferMinutes == mins
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _selectedBufferMinutes == mins
                            ? AppTheme.onPrimaryFixed
                            : null,
                      ),
                    ),
                    trailing: _selectedBufferMinutes == mins
                        ? const Icon(Icons.check_circle, color: AppTheme.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedBufferMinutes = mins);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppTheme.surfaceDark : Colors.white;
    final lowBg = isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceLow;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    final borderSubtle = isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtle;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.train, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قطاري / TrainWake',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                Text(
                  'Settings & Preferences',
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'محاكاة GPS للمطورين',
            icon: CircleAvatar(
              radius: 17,
              backgroundColor: lowBg,
              child: const Icon(Icons.science_outlined, size: 18, color: AppTheme.primary),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeveloperScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'إدارة النظام',
            icon: CircleAvatar(
              radius: 17,
              backgroundColor: lowBg,
              child: const Icon(Icons.admin_panel_settings_outlined,
                  size: 18, color: AppTheme.secondary),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sub-header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإعدادات والتفضيلات',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'تخصيص تجربة السفر وضمان وصولك وأنت بكامل يقظتك',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune, color: AppTheme.primary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // SECTION 1: Appearance / المظهر والسمة
              _buildSectionHeader(Icons.palette_outlined, 'المظهر والسمة / Appearance', textPrimary),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildThemeSegmentButton(
                        icon: Icons.light_mode,
                        label: 'النهاري',
                        isSelected: currentThemeMode == ThemeMode.light,
                        onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light),
                        lowBg: lowBg,
                        cardBg: cardBg,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildThemeSegmentButton(
                        icon: Icons.dark_mode,
                        label: 'الليلي',
                        isSelected: currentThemeMode == ThemeMode.dark,
                        onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark),
                        lowBg: lowBg,
                        cardBg: cardBg,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildThemeSegmentButton(
                        icon: Icons.brightness_auto,
                        label: 'تلقائي',
                        isSelected: currentThemeMode == ThemeMode.system,
                        onTap: () => ref.read(themeModeProvider.notifier).setTheme(ThemeMode.system),
                        lowBg: lowBg,
                        cardBg: cardBg,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 2: Language / اللغة والخط
              _buildSectionHeader(Icons.language, 'اللغة والخط / Language', textPrimary),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderSubtle),
                ),
                child: Column(
                  children: [
                    // Arabic (Active)
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryFixed,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'ع',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'العربية (Arabic)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'الواجهة والنداءات الصوتية الكاملة',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: borderSubtle),
                    // English
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: lowBg,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'EN',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'English',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'Bilingual UI & Rail Stations',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_left, color: textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 3: Alarm & Wake Settings
              _buildSectionHeader(Icons.alarm, 'إعدادات المنبه والاستيقاظ / Alarm', textPrimary),
              const SizedBox(height: 8),
              Material(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: borderSubtle),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Wake Buffer
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: lowBg,
                        child: const Icon(Icons.hourglass_top, color: AppTheme.primary, size: 18),
                      ),
                      title: Text(
                        'توقيت الاستيقاظ الافتراضي',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'قبل المحطة بـ $_selectedBufferMinutes دقائق (~${_selectedBufferMinutes * 1.5 ~/ 1} كم)',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      trailing: TextButton.icon(
                        onPressed: _showBufferPicker,
                        icon: const Icon(Icons.edit, size: 14, color: AppTheme.primary),
                        label: Text(
                          'تعديل',
                          style: GoogleFonts.ibmPlexSans(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: borderSubtle),

                    // Ringtone Preview
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: lowBg,
                        child: const Icon(Icons.volume_up, color: AppTheme.secondary, size: 18),
                      ),
                      title: Text(
                        'نغمة التنبيه القوية',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'نغمة متصاعدة ومسموعة للاستيقاظ من النوم',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: CircleAvatar(
                          radius: 16,
                          backgroundColor: _isPlayingAudio ? Colors.red : AppTheme.primary,
                          child: Icon(
                            _isPlayingAudio ? Icons.stop : Icons.play_arrow,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: _toggleAudioPreview,
                      ),
                    ),
                    Divider(height: 1, color: borderSubtle),

                    // Haptic Vibration Switch
                    SwitchListTile(
                      value: _vibrationEnabled,
                      onChanged: _toggleVibration,
                      activeThumbColor: AppTheme.primary,
                      secondary: CircleAvatar(
                        backgroundColor: lowBg,
                        child: const Icon(Icons.vibration, color: AppTheme.nileGreen, size: 18),
                      ),
                      title: Text(
                        'الاهتزاز الفائق للنائم',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'نمط ارتجاج قوي ومستمر لإيقاظ المسافرين',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: borderSubtle),

                    // DND Override
                    SwitchListTile(
                      value: _dndOverrideEnabled,
                      onChanged: (v) => setState(() => _dndOverrideEnabled = v),
                      activeThumbColor: AppTheme.primary,
                      secondary: CircleAvatar(
                        backgroundColor: lowBg,
                        child: const Icon(Icons.do_not_disturb_off, color: AppTheme.primary, size: 18),
                      ),
                      title: Text(
                        'اختراق وضع الصامت (DND)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'إطلاق التنبيه حتى لو كان الهاتف في وضع كتم الصوت',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 4: Battery Guidance (Xiaomi / Android)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1A16) : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.battery_alert, color: AppTheme.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'توجيهات البطارية لأجهزة شاومي وأندرويد',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'لضمان عمل الرصد في الخلفية أثناء إغلاق الشاشة والنوم، تأكد من ضبط توفير البطارية على "بلا قيود" (No Restrictions) والسماح بالتشغيل التلقائي للتطبيق.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color textPrimary) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSegmentButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color lowBg,
    required Color cardBg,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : lowBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppTheme.outline,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
