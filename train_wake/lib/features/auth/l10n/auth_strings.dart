/// All user-facing authentication strings for TrainWake.
///
/// Supports Arabic and English. The app defaults to Arabic (RTL).
/// String keys are organised by screen for easy navigation.
///
/// NEVER hard-code auth strings inside widget build() methods.
/// Always reference this file.
class AuthStrings {
  const AuthStrings._();

  // -------------------------------------------------------------------------
  // General
  // -------------------------------------------------------------------------
  static const String appName = 'TrainWake';
  static const String continueWithoutAccount = 'تابع بدون حساب';
  static const String continueWithoutAccountEn = 'Continue without account';
  static const String loading = 'جاري التحميل...';
  static const String cancel = 'إلغاء';
  static const String retry = 'جرب تاني';
  static const String orDivider = 'أو';
  static const String orDividerEn = 'OR';
  static const String googleSignIn = 'تسجيل الدخول عبر Google';
  static const String googleSignInEn = 'Sign in with Google';
  static const String googleSignUp = 'التسجيل عبر Google';
  static const String googleSignUpEn = 'Sign up with Google';

  // -------------------------------------------------------------------------
  // Login Screen
  // -------------------------------------------------------------------------
  static const String loginTitle = 'تسجيل الدخول';
  static const String loginTitleEn = 'Sign In';
  static const String emailLabel = 'الإيميل';
  static const String emailHint = 'example@email.com';
  static const String passwordLabel = 'كلمة المرور';
  static const String loginButton = 'سجل دخول';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String noAccount = 'ماعندكش حساب؟ ';
  static const String createAccount = 'أنشئ حساب';
  static const String loginUnavailable =
      'تسجيل الدخول غير متاح. تحقق من إعداد Firebase.';

  // -------------------------------------------------------------------------
  // Sign Up Screen
  // -------------------------------------------------------------------------
  static const String signupTitle = 'إنشاء حساب';
  static const String signupTitleEn = 'Create Account';
  static const String confirmPasswordLabel = 'تأكيد كلمة المرور';
  static const String confirmPasswordHint = 'أكد كلمة المرور';
  static const String signupButton = 'أنشئ الحساب';
  static const String alreadyHaveAccount = 'عندك حساب بالفعل؟ ';
  static const String signIn = 'سجل دخول';

  // Validation
  static const String emailRequired = 'الإيميل مطلوب';
  static const String emailInvalid = 'الإيميل غير صحيح';
  static const String passwordRequired = 'كلمة المرور مطلوبة';
  static const String confirmPasswordRequired = 'تأكيد كلمة المرور مطلوب';
  static const String passwordMismatch = 'كلمة المرور مش متطابقة';

  // -------------------------------------------------------------------------
  // Email Verification Screen
  // -------------------------------------------------------------------------
  static const String verificationTitle = 'تأكيد الإيميل';
  static const String verificationExplanation =
      'بعتنالك رسالة تأكيد على إيميلك. افتح الرسالة واضغط على الرابط عشان تأكد حسابك.';
  static const String verificationEmailSentTo = 'تم الإرسال إلى';
  static const String resendVerification = 'إعادة إرسال رسالة التأكيد';
  static const String resendSuccess = 'تم إرسال رسالة تأكيد جديدة.';
  static const String resendRateLimited =
      'استنى شوية وجرب إرسال الرسالة تاني.';
  static const String iHaveVerified = 'تحققت من الإيميل';
  static const String stillUnverified =
      'لسه الإيميل مش متأكد. افتح رسالة التأكيد واضغط على رابط التأكيد، وبعدها جرّب تاني.';
  static const String verificationSuccessful = 'تم التحقق بنجاح! 🎉';
  static const String mustVerifyFirst = 'لازم تأكد إيميلك الأول';
  static const String signOutFromVerification = 'تسجيل الخروج';

  // -------------------------------------------------------------------------
  // Forgot Password Screen
  // -------------------------------------------------------------------------
  static const String forgotPasswordTitle = 'استرجاع كلمة المرور';
  static const String forgotPasswordExplanation =
      'أدخل إيميلك وهنبعتلك رابط لإعادة تعيين كلمة المرور.';
  static const String sendResetEmail = 'إرسال رابط الاسترجاع';
  static const String resetEmailSent =
      'تم إرسال رابط استرجاع كلمة المرور. تحقق من إيميلك.';
  static const String backToLogin = 'رجوع لتسجيل الدخول';

  // -------------------------------------------------------------------------
  // Admin Dashboard
  // -------------------------------------------------------------------------
  static const String adminDashboardTitle = 'لوحة التحكم';
  static const String adminOverview = 'نظرة عامة';
  static const String adminAccountInfo = 'معلومات الحساب';
  static const String adminSystem = 'معلومات النظام';
  static const String adminEmail = 'الإيميل';
  static const String adminUid = 'معرف المستخدم';
  static const String adminVerified = 'الإيميل مؤكد';
  static const String adminRole = 'الدور';
  static const String adminRoleValue = 'مسؤول (Admin)';
  static const String adminAppVersion = 'إصدار التطبيق';
  static const String adminLogout = 'تسجيل الخروج';
  static const String adminNotice =
      'ملحوظة: صلاحيات الإدارة الحقيقية تُدار من الخادم فقط.';

  // -------------------------------------------------------------------------
  // Account section on HomeScreen
  // -------------------------------------------------------------------------
  static const String accountButton = 'حساب';
  static const String signedInAs = 'مسجل دخول كـ';
  static const String logoutButton = 'تسجيل الخروج';
  static const String logoutActiveTrip =
      'تسجيل الخروج لن يوقف رحلتك الحالية.';
  static const String adminDashboardButton = 'لوحة التحكم';
}
