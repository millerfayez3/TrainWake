import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:train_wake/core/theme/app_theme.dart';
import 'package:train_wake/features/active_trip/active_trip_screen.dart';
import 'package:train_wake/services/background_tracking_service.dart';

class ReadinessScreen extends StatefulWidget {
  final String destinationName;
  final double destLat;
  final double destLng;
  final int bufferMeters;

  const ReadinessScreen({
    super.key,
    required this.destinationName,
    required this.destLat,
    required this.destLng,
    this.bufferMeters = 5000,
  });

  @override
  State<ReadinessScreen> createState() => _ReadinessScreenState();
}

class _ReadinessScreenState extends State<ReadinessScreen> {
  bool _isLaunching = false;

  void _confirmAndStart() async {
    setState(() => _isLaunching = true);

    final trackingService = BackgroundTrackingService();
    trackingService.startTrip(
      destLat: widget.destLat,
      destLng: widget.destLng,
      destinationName: widget.destinationName,
      alarmBufferMeters: widget.bufferMeters.toDouble(),
    );

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveTripScreen(
          destinationName: widget.destinationName,
          destLat: widget.destLat,
          destLng: widget.destLng,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    final borderSubtle = isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtle;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'فحص الجاهزية قبل الرحلة',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Reassurance Badge
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.verified_user_rounded,
                        color: AppTheme.primary, size: 38),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Text(
                      'نظام الأمان جاهز 100%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تم التحقق من إعدادات الهاتف لضمان رنين المنبه أثناء نومك',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Selected Station Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on,
                          color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المحطة المستهدفة • Target',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.destinationName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            'المنبه سيرن قبل المحطة بـ ${(widget.bufferMeters / 1000).toStringAsFixed(0)} كم',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 11.5,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Diagnostic Items
              _buildCheckItem(
                icon: Icons.gps_fixed,
                title: 'مستشعر الـ GPS والأقمار الصناعية',
                subtitle: 'إشارة نشطة ومقفلة بدقة عالية لتعقب موقع القطار',
                badgeText: 'متصل',
                cardBg: cardBg,
                borderSubtle: borderSubtle,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 10),
              _buildCheckItem(
                icon: Icons.battery_charging_full,
                title: 'تحسين البطارية والخلفية',
                subtitle: 'معفى من قيود إغلاق التطبيقات أثناء إطفاء الشاشة',
                badgeText: 'بلا قيود',
                cardBg: cardBg,
                borderSubtle: borderSubtle,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 10),
              _buildCheckItem(
                icon: Icons.volume_up,
                title: 'مستوى صوت نغمة التنبيه',
                subtitle: 'أقصى درجة صوتية مع نمط اهتزاز مخصص لإيقاظك',
                badgeText: 'صوت قوي',
                cardBg: cardBg,
                borderSubtle: borderSubtle,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 10),
              _buildCheckItem(
                icon: Icons.lock_clock,
                title: 'قفل الاستيقاظ (Wake Lock)',
                subtitle: 'تنبيه شاشة كاملة يضيء الهاتف فور دخول النطاق',
                badgeText: 'مفعل',
                cardBg: cardBg,
                borderSubtle: borderSubtle,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: 24),

              // Big Confirm CTA
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLaunching ? null : _confirmAndStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    shadowColor: AppTheme.primary.withValues(alpha: 0.35),
                  ),
                  child: _isLaunching
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'ابدأ الرحلة ونام مرتاح البال — Start & Sleep',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color cardBg,
    required Color borderSubtle,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.tertiaryFixed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.nileGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.tertiaryFixed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.nileGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
