import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

/// Maps [FirebaseAuthException] error codes to localized user-friendly Arabic strings.
///
/// Raw Firebase error codes are NEVER shown to the user.
/// All messages default to a generic friendly error if the code is unrecognised.
class AuthErrorMapper {
  const AuthErrorMapper._();

  static String map(FirebaseAuthException e) {
    switch (e.code) {
      // --- Registration errors ---
      case 'email-already-in-use':
        return 'الإيميل ده مستخدم بالفعل. جرب تسجيل الدخول أو استرجاع كلمة المرور.';
      case 'invalid-email':
        return 'الإيميل غير صحيح. تأكد من كتابته صح.';
      case 'operation-not-allowed':
        return 'تسجيل الحسابات مش متاح دلوقتي. جرب تاني بعد شوية.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة. استخدم كلمة مرور أقوى.';

      // --- Login errors ---
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        // Deliberately combine user-not-found + wrong-password to prevent
        // user enumeration attacks.
        return 'الإيميل أو كلمة المرور غلط. جرب تاني.';
      case 'user-disabled':
        return 'الحساب ده اتوقف. تواصل مع الدعم.';
      case 'too-many-requests':
        return 'محاولات كتير جداً. انتظر شوية وجرب تاني.';

      // --- Network errors ---
      case 'network-request-failed':
        return 'مفيش اتصال بالانترنت. تأكد من الاتصال وجرب تاني.';

      // --- Password reset ---
      case 'auth/invalid-email':
        return 'الإيميل غير صحيح.';

      // --- Verification / session ---
      case 'requires-recent-login':
        return 'لازم تسجل دخول تاني عشان تكمل العملية دي.';
      case 'expired-action-code':
        return 'الرابط انتهت صلاحيته. اطلب رابط جديد.';
      case 'invalid-action-code':
        return 'الرابط غير صحيح أو اتستخدم قبل كده.';

      // --- Generic fallback ---
      default:
        return 'حصل خطأ. جرب تاني أو تواصل مع الدعم.';
    }
  }
}
