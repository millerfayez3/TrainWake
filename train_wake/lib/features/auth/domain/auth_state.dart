import 'package:train_wake/features/auth/domain/auth_user.dart';

/// All possible authentication states in TrainWake.
///
/// These are explicit named states — no scattered booleans. The [AuthNotifier]
/// transitions between these states as Firebase reports changes.
sealed class AuthState {
  const AuthState();
}

/// Initial / loading state — evaluating Firebase auth stream.
class AuthStateUnknown extends AuthState {
  const AuthStateUnknown();
}

/// User is not signed in (or signed out).
class AuthStateSignedOut extends AuthState {
  const AuthStateSignedOut();
}

/// Firebase authentication succeeded but email is not yet verified.
/// The user is held at this state until they verify their email.
class AuthStateEmailVerificationRequired extends AuthState {
  final AuthUser user;
  const AuthStateEmailVerificationRequired({required this.user});
}

/// Fully authenticated + email verified + NOT an admin.
class AuthStateSignedIn extends AuthState {
  final AuthUser user;
  const AuthStateSignedIn({required this.user});
}

/// Fully authenticated + email verified + admin == true (from custom claim).
class AuthStateAdminSignedIn extends AuthState {
  final AuthUser user;
  const AuthStateAdminSignedIn({required this.user});
}

/// An auth operation failed with an error message for the user.
class AuthStateError extends AuthState {
  final String message;
  const AuthStateError({required this.message});
}

/// Convenience extension for common checks across the UI.
extension AuthStateX on AuthState {
  bool get isSignedOut => this is AuthStateSignedOut || this is AuthStateUnknown;

  bool get isSignedIn =>
      this is AuthStateSignedIn ||
      this is AuthStateAdminSignedIn ||
      this is AuthStateEmailVerificationRequired;

  bool get isFullyVerified =>
      this is AuthStateSignedIn || this is AuthStateAdminSignedIn;

  bool get isAdmin => this is AuthStateAdminSignedIn;

  AuthUser? get user {
    final s = this;
    if (s is AuthStateSignedIn) return s.user;
    if (s is AuthStateAdminSignedIn) return s.user;
    if (s is AuthStateEmailVerificationRequired) return s.user;
    return null;
  }
}
