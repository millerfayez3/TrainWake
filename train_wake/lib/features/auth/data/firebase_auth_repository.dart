import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:train_wake/features/auth/data/auth_repository.dart';
import 'package:train_wake/features/auth/data/auth_error_mapper.dart';
import 'package:train_wake/features/auth/domain/auth_user.dart';

/// Firebase-backed implementation of [AuthRepository].
///
/// This is the only file in the project that imports [firebase_auth].
/// All Firebase types are translated into domain types before leaving
/// this class, enforcing the isolation boundary.
class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  // -------------------------------------------------------------------------
  // Stream
  // -------------------------------------------------------------------------

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return await _toAuthUser(fbUser);
    });
  }

  // -------------------------------------------------------------------------
  // Current user
  // -------------------------------------------------------------------------

  @override
  AuthUser? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    // Synchronous — admin claim may be stale until token refresh, acceptable
    // for UI-only routing.
    return _toAuthUserSync(fbUser);
  }

  // -------------------------------------------------------------------------
  // Sign Up
  // -------------------------------------------------------------------------

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user!;
      // Send verification email immediately after account creation.
      await fbUser.sendEmailVerification();
      return await _toAuthUser(fbUser);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.map(e));
    }
  }

  // -------------------------------------------------------------------------
  // Sign In
  // -------------------------------------------------------------------------

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return await _toAuthUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.map(e));
    }
  }

  // -------------------------------------------------------------------------
  // Google Sign In
  // -------------------------------------------------------------------------

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('تم إلغاء تسجيل الدخول عبر Google.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return await _toAuthUser(userCredential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.map(e));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('فشل تسجيل الدخول عبر Google: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Sign Out
  // -------------------------------------------------------------------------

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        GoogleSignIn().signOut().catchError((_) => null),
      ]);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.map(e));
    }
  }

  // -------------------------------------------------------------------------
  // Email Verification
  // -------------------------------------------------------------------------

  @override
  Future<void> sendEmailVerification() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) {
      throw const AuthException('لم يتم العثور على مستخدم مسجل دخوله');
    }
    try {
      await fbUser.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.map(e));
    }
  }

  @override
  Future<AuthUser?> reloadUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    try {
      await fbUser.reload();
      // After reload(), we must re-fetch from FirebaseAuth.instance.currentUser
      // because the original reference may be stale.
      final refreshed = _firebaseAuth.currentUser;
      if (refreshed == null) return null;
      return await _toAuthUser(refreshed, true);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.map(e));
    }
  }

  // -------------------------------------------------------------------------
  // Password Reset
  // -------------------------------------------------------------------------

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.map(e));
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Async version — reads admin claim from the ID token.
  Future<AuthUser> _toAuthUser(fb.User fbUser, [bool forceRefresh = false]) async {
    bool isAdmin = false;
    try {
      final idTokenResult = await fbUser.getIdTokenResult(forceRefresh);
      isAdmin = idTokenResult.claims?['admin'] == true;
    } catch (_) {
      // If we can't read claims (e.g., offline), treat as non-admin.
      isAdmin = false;
    }
    return AuthUser(
      uid: fbUser.uid,
      email: fbUser.email,
      emailVerified: fbUser.emailVerified,
      isAdmin: isAdmin,
      displayName: fbUser.displayName,
    );
  }

  /// Synchronous version — does NOT read fresh admin claim from server.
  /// Suitable only for UI hints where latency matters more than freshness.
  AuthUser _toAuthUserSync(fb.User fbUser) {
    return AuthUser(
      uid: fbUser.uid,
      email: fbUser.email,
      emailVerified: fbUser.emailVerified,
      isAdmin: false, // conservatively false without async claim fetch
      displayName: fbUser.displayName,
    );
  }
}
