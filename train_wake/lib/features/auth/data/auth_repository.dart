import 'package:train_wake/features/auth/domain/auth_user.dart';

/// Abstract repository interface for authentication operations.
///
/// Firebase remains replaceable at this boundary. The rest of the app
/// (Riverpod notifiers, UI) only depends on this interface, never on
/// [firebase_auth] types directly.
abstract interface class AuthRepository {
  /// Stream of the current [AuthUser], emitting null when signed out.
  /// Fires immediately with the current state on subscription.
  Stream<AuthUser?> authStateChanges();

  /// The currently signed-in user, or null.
  AuthUser? get currentUser;

  /// Creates a new account with [email] and [password].
  /// Sends a verification email after creation.
  /// Throws [AuthException] on failure.
  Future<AuthUser> signUp({
    required String email,
    required String password,
  });

  /// Signs in with [email] and [password].
  /// Throws [AuthException] on failure.
  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  /// Signs in using Google Sign-In.
  /// Throws [AuthException] on failure or user cancellation.
  Future<AuthUser> signInWithGoogle();

  /// Signs out the current user.
  /// MUST NOT affect active trip state — callers are responsible for
  /// preserving Hive trip persistence.
  Future<void> signOut();

  /// Sends an email verification to the currently signed-in user.
  /// Throws [AuthException] on failure.
  Future<void> sendEmailVerification();

  /// Reloads the current user from Firebase to get the latest [emailVerified]
  /// status. Must be called before inspecting [emailVerified] after the user
  /// clicks "I've verified".
  Future<AuthUser?> reloadUser();

  /// Sends a password reset email to [email].
  /// Throws [AuthException] on failure.
  Future<void> sendPasswordResetEmail({required String email});
}

/// Domain-level authentication exception with a localized message.
///
/// The data layer catches [FirebaseAuthException] and maps it to this type
/// so no Firebase types leak into the domain/application layers.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
