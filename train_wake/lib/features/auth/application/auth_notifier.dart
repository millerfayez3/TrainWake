import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:train_wake/features/auth/application/auth_providers.dart';
import 'package:train_wake/features/auth/data/auth_repository.dart';
import 'package:train_wake/features/auth/domain/auth_state.dart';
import 'package:train_wake/features/auth/domain/auth_user.dart';

/// Central Riverpod notifier for authentication state.
///
/// Listens to [AuthRepository.authStateChanges()] and translates Firebase
/// user changes into [AuthState] transitions.
///
/// The critical TrainWake trip/alarm path NEVER reads this notifier.
/// It is only consulted by auth UI screens and the HomeScreen AppBar.
class AuthNotifier extends AsyncNotifier<AuthState> {
  StreamSubscription<AuthUser?>? _authSubscription;

  @override
  Future<AuthState> build() async {
    ref.onDispose(() => _authSubscription?.cancel());

    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      // Firebase not configured — auth is unavailable but the app runs normally.
      return const AuthStateSignedOut();
    }

    // Start listening to Firebase auth state changes.
    final completer = Completer<AuthState>();

    _authSubscription = repo.authStateChanges().listen(
      (user) {
        final newState = _toAuthState(user);
        if (!completer.isCompleted) {
          completer.complete(newState);
        } else {
          state = AsyncValue.data(newState);
        }
      },
      onError: (Object e) {
        if (!completer.isCompleted) {
          completer.complete(const AuthStateSignedOut());
        } else {
          state = const AsyncValue.data(AuthStateSignedOut());
        }
      },
    );

    return completer.future;
  }

  // -------------------------------------------------------------------------
  // Sign Up
  // -------------------------------------------------------------------------

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      state = const AsyncValue.data(
        AuthStateError(message: 'المصادقة غير متاحة. تحقق من الاتصال.'),
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final user = await repo.signUp(email: email, password: password);
      // After sign-up, email is always unverified.
      state = AsyncValue.data(
        AuthStateEmailVerificationRequired(user: user),
      );
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthStateError(message: e.message));
    } catch (_) {
      state = const AsyncValue.data(
        AuthStateError(message: 'حصل خطأ غير متوقع. جرب تاني.'),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Sign In
  // -------------------------------------------------------------------------

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      state = const AsyncValue.data(
        AuthStateError(message: 'المصادقة غير متاحة. تحقق من الاتصال.'),
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final user = await repo.signIn(email: email, password: password);
      state = AsyncValue.data(_toAuthState(user));
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthStateError(message: e.message));
    } catch (_) {
      state = const AsyncValue.data(
        AuthStateError(message: 'حصل خطأ غير متوقع. جرب تاني.'),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Google Sign In
  // -------------------------------------------------------------------------

  Future<void> signInWithGoogle() async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) {
      state = const AsyncValue.data(
        AuthStateError(message: 'المصادقة غير متاحة. تحقق من الاتصال.'),
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final user = await repo.signInWithGoogle();
      state = AsyncValue.data(_toAuthState(user));
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthStateError(message: e.message));
    } catch (_) {
      state = const AsyncValue.data(
        AuthStateError(message: 'حصل خطأ في تسجيل الدخول عبر Google.'),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Sign Out
  // -------------------------------------------------------------------------

  /// Signs out without touching active trip state.
  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.signOut();
      state = const AsyncValue.data(AuthStateSignedOut());
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthStateError(message: e.message));
    }
  }

  // -------------------------------------------------------------------------
  // Email Verification
  // -------------------------------------------------------------------------

  Future<void> sendEmailVerification() async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.sendEmailVerification();
    } on AuthException {
      rethrow;
    }
  }

  /// Reloads the Firebase user and re-evaluates emailVerified.
  /// Returns true if verification succeeded, false if still unverified.
  Future<bool> checkEmailVerification() async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) return false;

    try {
      final user = await repo.reloadUser();
      if (user == null) {
        state = const AsyncValue.data(AuthStateSignedOut());
        return false;
      }
      final newState = _toAuthState(user);
      state = AsyncValue.data(newState);
      return user.emailVerified;
    } on AuthException catch (e) {
      state = AsyncValue.data(AuthStateError(message: e.message));
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Password Reset
  // -------------------------------------------------------------------------

  Future<void> sendPasswordResetEmail({required String email}) async {
    final repo = ref.read(authRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.sendPasswordResetEmail(email: email);
    } on AuthException {
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Helper
  // -------------------------------------------------------------------------

  AuthState _toAuthState(AuthUser? user) {
    if (user == null) return const AuthStateSignedOut();
    if (!user.emailVerified) {
      return AuthStateEmailVerificationRequired(user: user);
    }
    if (user.isAdmin) return AuthStateAdminSignedIn(user: user);
    return AuthStateSignedIn(user: user);
  }
}
