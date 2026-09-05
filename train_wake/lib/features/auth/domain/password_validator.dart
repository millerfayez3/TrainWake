/// Pure Dart password validator — zero Firebase dependency.
///
/// TrainWake password policy:
///   - Minimum 8 characters
///   - At least 1 uppercase letter
///   - At least 1 lowercase letter
///   - At least 1 digit
///   - At least 1 special character
///
/// Client-side validation provides immediate user feedback only.
/// The actual security boundary is Firebase Authentication's server-side
/// password policy configured in the Firebase Console.
class PasswordValidator {
  const PasswordValidator._();

  /// Validates [password] and returns a localized Arabic error message,
  /// or null if the password is valid.
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير على الأقل';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير على الأقل';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم على الأقل';
    }
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/]'))) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص على الأقل (مثل ! @ # \$)';
    }
    return null; // valid
  }

  /// Returns a list of requirement strings (Arabic) for inline UI feedback.
  static List<PasswordRequirement> requirements(String password) {
    return [
      PasswordRequirement(
        label: '8 أحرف على الأقل',
        met: password.length >= 8,
      ),
      PasswordRequirement(
        label: 'حرف كبير (A-Z)',
        met: password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordRequirement(
        label: 'حرف صغير (a-z)',
        met: password.contains(RegExp(r'[a-z]')),
      ),
      PasswordRequirement(
        label: 'رقم (0-9)',
        met: password.contains(RegExp(r'[0-9]')),
      ),
      PasswordRequirement(
        label: 'رمز خاص (!@#\$...)',
        met: password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/]')),
      ),
    ];
  }

  /// Quick boolean check — used internally and in tests.
  static bool isValid(String password) => validate(password) == null;
}

/// A single password requirement with its label and whether it is met.
class PasswordRequirement {
  final String label;
  final bool met;

  const PasswordRequirement({required this.label, required this.met});
}
