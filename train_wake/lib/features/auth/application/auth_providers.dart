import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:train_wake/features/auth/application/auth_notifier.dart';
import 'package:train_wake/features/auth/data/auth_repository.dart';
import 'package:train_wake/features/auth/data/firebase_auth_repository.dart';
import 'package:train_wake/features/auth/domain/auth_state.dart';

/// Provides the [AuthRepository] implementation.
///
/// Returns null if Firebase is not initialized — allowing the app to run
/// without auth when `google-services.json` is missing.
final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  try {
    return FirebaseAuthRepository();
  } catch (_) {
    return null;
  }
});

/// The main auth state provider.
///
/// All auth UI listens to this. The trip/alarm critical path NEVER reads it.
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Convenience provider for quick synchronous access to the current [AuthState].
/// Defaults to [AuthStateSignedOut] while loading.
final currentAuthStateProvider = Provider<AuthState>((ref) {
  final asyncVal = ref.watch(authStateProvider);
  return asyncVal.hasValue ? asyncVal.requireValue : const AuthStateSignedOut();
});
