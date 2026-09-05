import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:train_wake/core/theme/app_theme.dart';
import 'package:train_wake/features/auth/application/auth_providers.dart';
import 'package:train_wake/features/auth/data/auth_repository.dart';
import 'package:train_wake/features/auth/domain/auth_state.dart';
import 'package:train_wake/features/auth/domain/auth_user.dart';
import 'package:train_wake/features/auth/l10n/auth_strings.dart';
import 'package:train_wake/features/auth/presentation/admin_dashboard_screen.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final AuthUser user;
  const EmailVerificationScreen({super.key, required this.user});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isCheckingVerification = false;
  bool _isResending = false;
  DateTime? _lastResendTime;
  String? _statusMessage;
  bool _statusIsError = false;

  static const _resendCooldownSeconds = 45;

  late final AnimationController _spinController;
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();

  Timer? _countdownTimer;
  int _secondsRemaining = 299; // 04:59

  bool get _canResend {
    if (_lastResendTime == null) return true;
    return DateTime.now().difference(_lastResendTime!).inSeconds >=
        _resendCooldownSeconds;
  }

  int get _secondsUntilResend {
    if (_lastResendTime == null) return 0;
    final elapsed = DateTime.now().difference(_lastResendTime!).inSeconds;
    return (_resendCooldownSeconds - elapsed).clamp(0, _resendCooldownSeconds);
  }

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      }
    });

    _otpController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _countdownTimer?.cancel();
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final code = _otpController.text;

    return Scaffold(
      backgroundColor: AppTheme.canvasLight,
      appBar: AppBar(
        backgroundColor: AppTheme.canvasLight.withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => _signOut(),
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
            Text(
              'Otp Verification',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.surfaceContainer,
              child: const Icon(Icons.person, color: AppTheme.textPrimary, size: 18),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subtle Ambient Journey Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'حساب المسافر الآمن • Secure Transit ID',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'خطوة 2 من 2',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Hero Visual Badge
              Center(
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RotationTransition(
                        turns: _spinController,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.25),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignCenter,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.28),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: AppTheme.primary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Editorial Typography Header
              Center(
                child: Column(
                  children: [
                    Text(
                      'تأكيد الرمز',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enter Verification Code',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Target Destination Email Display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.forward_to_inbox,
                              color: AppTheme.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            widget.user.email ?? 'passenger@trainwake.com',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أرسلنا رابط ورسالة تحقق لتأكيد بريدك الإلكتروني وتسجيل رحلتك بأمان',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // OTP Digits Display
              GestureDetector(
                onTap: () => _otpFocus.requestFocus(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    final isFilled = index < code.length;
                    final isActive = index == code.length;
                    final digit = isFilled ? code[index] : '';

                    return Container(
                      width: 46,
                      height: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isFilled
                            ? Colors.white
                            : (isActive
                                ? Colors.white
                                : AppTheme.surfaceContainer),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? AppTheme.primary
                              : (isFilled
                                  ? AppTheme.borderSubtle
                                  : Colors.transparent),
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: isFilled
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isFilled
                            ? Text(
                                digit,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              )
                            : (isActive
                                ? Container(
                                    width: 14,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                : Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppTheme.outlineVariant
                                          .withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                  )),
                      ),
                    );
                  }),
                ),
              ),

              // Hidden textfield for native input capture
              Opacity(
                opacity: 0,
                child: SizedBox(
                  height: 1,
                  child: TextField(
                    controller: _otpController,
                    focusNode: _otpFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (val) {
                      if (val.length == 6) {
                        _checkVerification();
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Countdown Expiry Timer
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, color: AppTheme.secondary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'ينتهي الرمز خلال ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        _formatTimer(_secondsRemaining),
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        ' دقيقة • Expires in ${_formatTimer(_secondsRemaining)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Status message banner
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _statusIsError
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _statusIsError
                          ? const Color(0xFFFFCDD2)
                          : const Color(0xFFC8E6C9),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusIsError ? Icons.error_outline : Icons.check_circle_outline,
                        color: _statusIsError ? Colors.red.shade700 : Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            color: _statusIsError
                                ? Colors.red.shade900
                                : Colors.green.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Primary CTA Button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isCheckingVerification ? null : _checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                    shadowColor: AppTheme.primary.withValues(alpha: 0.35),
                  ),
                  child: _isCheckingVerification
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_open_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'تحقق ومتابعة — Verify & Continue',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Resend Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'لم يصلك الرمز أو الرابط؟',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: (_isResending || !_canResend) ? null : _resend,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      backgroundColor: AppTheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _isResending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.autorenew, size: 16, color: AppTheme.secondary),
                    label: Text(
                      _canResend
                          ? 'إعادة الإرسال'
                          : 'إعادة الإرسال ($_secondsUntilResend ث)',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _canResend ? AppTheme.textPrimary : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Alternative Methods Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.support_agent,
                            color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'خيارات بديلة لتسجيل الدخول',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'إذا وصلك بريد التحقق افتح الرابط ثم اضغط "تحقق ومتابعة". تأكد أيضاً من تفقد مجلد الرسائل غير المرغوب فيها (Spam / Junk).',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('خدمة التحقق بالرسائل النصية SMS قيد التفعيل'),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppTheme.borderSubtle),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.sms_outlined, size: 16, color: AppTheme.primary),
                            label: Text(
                              'إرسال SMS',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يمكنك التواصل مع فريق الدعم: support@trainwake.com'),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: AppTheme.borderSubtle),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline, size: 16, color: AppTheme.secondary),
                            label: Text(
                              'دعم المسافرين',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Rail Watermark
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.train, size: 16, color: AppTheme.outline),
                  const SizedBox(width: 6),
                  Text(
                    'منظومة تنبيهات قطارات النوم والسفر السريع • TrainWake Secure Transit',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 10,
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _checkVerification() async {
    setState(() {
      _isCheckingVerification = true;
      _statusMessage = null;
    });

    final verified =
        await ref.read(authStateProvider.notifier).checkEmailVerification();

    if (!mounted) return;

    if (verified) {
      final authState = ref.read(currentAuthStateProvider);
      setState(() {
        _statusMessage = AuthStrings.verificationSuccessful;
        _statusIsError = false;
        _isCheckingVerification = false;
      });
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      if (authState is AuthStateAdminSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.popUntil(context, (r) => r.isFirst);
      }
    } else {
      setState(() {
        _statusMessage = AuthStrings.stillUnverified;
        _statusIsError = true;
        _isCheckingVerification = false;
      });
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authStateProvider.notifier).sendEmailVerification();
      _lastResendTime = DateTime.now();
      setState(() {
        _statusMessage = AuthStrings.resendSuccess;
        _statusIsError = false;
        _isResending = false;
      });
      Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted || _canResend) {
          t.cancel();
        }
        if (mounted) setState(() {});
      });
    } on AuthException catch (e) {
      final isRateLimited =
          e.message.contains('استنى') || e.message.contains('كتير');
      setState(() {
        _statusMessage =
            isRateLimited ? AuthStrings.resendRateLimited : e.message;
        _statusIsError = true;
        _isResending = false;
      });
    } catch (_) {
      setState(() {
        _statusMessage = AuthStrings.resendRateLimited;
        _statusIsError = true;
        _isResending = false;
      });
    }
  }

  Future<void> _signOut() async {
    await ref.read(authStateProvider.notifier).signOut();
    if (!mounted) return;
    Navigator.popUntil(context, (r) => r.isFirst);
  }
}
