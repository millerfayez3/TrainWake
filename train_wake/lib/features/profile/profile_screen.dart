import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:train_wake/core/theme/app_theme.dart';
import 'package:train_wake/features/auth/application/auth_providers.dart';
import 'package:train_wake/features/auth/domain/auth_state.dart';
import 'package:train_wake/features/history/history_screen.dart';
import 'package:train_wake/features/settings/settings_screen.dart';
import 'package:train_wake/features/auth/presentation/login_screen.dart';
import 'package:train_wake/features/admin/admin_dashboard_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _bufferEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentAuth = ref.watch(currentAuthStateProvider);
    final isAdmin = currentAuth is AuthStateAdminSignedIn;
    final user = authState.asData?.value.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppTheme.surfaceDark : Colors.white;
    final lowBg = isDark ? AppTheme.surfaceContainerDark : AppTheme.surfaceLow;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
    final borderSubtle = isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtle;

    final displayName = user?.displayName ?? 'مسافر قطارات مصر';
    final email = user?.email ?? 'passenger@trainwake.com';

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
              width: 30,
              height: 30,
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
                  'الملف الشخصي',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
                Text(
                  'Passenger Profile & Account',
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
            icon: Icon(Icons.settings_outlined, color: textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: AppTheme.primaryFixed,
                              child: const Icon(Icons.person,
                                  size: 38, color: AppTheme.primary),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppTheme.nileGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      displayName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (user?.isAdmin == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.shield, color: Color(0xFFD97706), size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            'مدير النظام • Admin',
                                            style: GoogleFonts.ibmPlexSans(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFFB45309),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.tertiaryFixed,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'مسافر موثق',
                                        style: GoogleFonts.ibmPlexSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.nileGreen,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: lowBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Google Linked Account',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Reliability Highlight
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: lowBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.workspace_premium,
                                  color: AppTheme.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'سجل التنبيه الدقيق • 14 رحلة آمنة',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.tertiaryFixed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '100% نجاح',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.nileGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Stats Bento
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '14',
                      'رحلة مكتملة',
                      'Trips',
                      AppTheme.primary,
                      cardBg,
                      borderSubtle,
                      textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      '3,420',
                      'كم مقطوعة',
                      'Total km',
                      AppTheme.secondary,
                      cardBg,
                      borderSubtle,
                      textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      '0',
                      'محطات فائتة',
                      'Zero Missed',
                      AppTheme.nileGreen,
                      cardBg,
                      borderSubtle,
                      textSecondary,
                    ),
                  ),
                ],
              ),
              if (isAdmin) ...[
                const SizedBox(height: 20),
                Text(
                  'لوحة تحكم المشرف والعمليات • Operations & Simulation',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFEF3C7),
                          child: const Icon(Icons.admin_panel_settings, color: Color(0xFFD97706), size: 20),
                        ),
                        title: Text(
                          'مركز العمليات والمحاكاة المباشرة',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'محاكاة حركة القطارات المصرية • حقن الأخطاء • فحص الشبكة',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11.5,
                            color: textSecondary,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFD97706)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                          );
                        },
                      ),
                      Divider(height: 1, color: borderSubtle),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                                  );
                                },
                                icon: const Icon(Icons.rocket_launch, size: 16),
                                label: Text(
                                  'فتح مركز العمليات والمحاكاة (Command Center)',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97706),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Account & Preferences Section
              Text(
                'تفضيلات التنبيه والحساب • Settings',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),
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
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.secondaryFixed,
                        child: const Icon(Icons.star, color: AppTheme.secondary, size: 18),
                      ),
                      title: Text(
                        'محطاتي المفضلة',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'المنيا، أسيوط، الجيزة، الإسكندرية',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: textSecondary,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_left, color: textSecondary),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('المحطات المفضلة محفوظة تلقائياً')),
                        );
                      },
                    ),
                    Divider(height: 1, color: borderSubtle),
                    SwitchListTile(
                      value: _bufferEnabled,
                      onChanged: (v) => setState(() => _bufferEnabled = v),
                      activeThumbColor: AppTheme.primary,
                      secondary: CircleAvatar(
                        backgroundColor: AppTheme.primaryFixed,
                        child: const Icon(Icons.alarm, color: AppTheme.primary, size: 18),
                      ),
                      title: Text(
                        'نطاق التنبيه الافتراضي',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'استيقاظ قبل المحطة بـ 10 دقائق (~15 كم)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: borderSubtle),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: lowBg,
                        child: const Icon(Icons.history, color: AppTheme.primary, size: 18),
                      ),
                      title: Text(
                        'سجل الرحلات السابقة',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_left, color: textSecondary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        );
                      },
                    ),
                    Divider(height: 1, color: borderSubtle),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: lowBg,
                        child: Icon(Icons.settings, color: textSecondary, size: 18),
                      ),
                      title: Text(
                        'إعدادات التطبيق والمظهر',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_left, color: textSecondary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Auth Action Button (Sign In / Register if Guest, Sign Out if Logged In)
              SizedBox(
                height: 52,
                child: user != null
                    ? OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(authStateProvider.notifier).signOut();
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.logout, size: 18),
                        label: Text(
                          'تسجيل الخروج — Sign Out',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.login, size: 20),
                        label: Text(
                          'تسجيل الدخول / إنشاء حساب — Login / Register',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String val,
    String label,
    String sub,
    Color color,
    Color cardBg,
    Color borderSubtle,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          Text(
            sub,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 9.5,
              color: textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
