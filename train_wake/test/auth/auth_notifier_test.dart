import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:train_wake/features/auth/data/auth_repository.dart';
import 'package:train_wake/features/auth/domain/auth_user.dart';
import 'package:train_wake/features/auth/domain/auth_state.dart';
import 'package:train_wake/features/auth/application/auth_providers.dart';

@GenerateMocks([AuthRepository])
import 'auth_notifier_test.mocks.dart';

// ---------------------------------------------------------------------------
// Helper to build a ProviderContainer with a mocked AuthRepository.
// ---------------------------------------------------------------------------
ProviderContainer makeContainer(MockAuthRepository mockRepo) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );
}

void main() {
  group('AuthNotifier — signIn', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
      // Default: auth stream emits null (signed out)
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
    });

    test('signedOut initial state when stream emits null', () async {
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      // Wait for async build to complete
      await Future.delayed(Duration.zero);
      final state = container.read(currentAuthStateProvider);
      expect(state, isA<AuthStateSignedOut>());
    });

    test('signIn with verified non-admin user → AuthStateSignedIn', () async {
      final verifiedUser = AuthUser(
        uid: 'uid-123',
        email: 'user@test.com',
        emailVerified: true,
        isAdmin: false,
      );
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(mockRepo.signIn(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => verifiedUser);

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      await container.read(authStateProvider.notifier).signIn(
        email: 'user@test.com',
        password: 'TrainWake123!',
      );

      final state = container.read(currentAuthStateProvider);
      expect(state, isA<AuthStateSignedIn>());
      expect((state as AuthStateSignedIn).user.email, 'user@test.com');
    });

    test('signIn with unverified user → AuthStateEmailVerificationRequired', () async {
      final unverifiedUser = AuthUser(
        uid: 'uid-456',
        email: 'unverified@test.com',
        emailVerified: false,
        isAdmin: false,
      );
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(mockRepo.signIn(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => unverifiedUser);

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      await container.read(authStateProvider.notifier).signIn(
        email: 'unverified@test.com',
        password: 'TrainWake123!',
      );

      final state = container.read(currentAuthStateProvider);
      expect(state, isA<AuthStateEmailVerificationRequired>());
    });

    test('signIn with verified admin user → AuthStateAdminSignedIn', () async {
      final adminUser = AuthUser(
        uid: 'uid-admin',
        email: 'admin@test.com',
        emailVerified: true,
        isAdmin: true,
      );
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(mockRepo.signIn(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => adminUser);

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      await container.read(authStateProvider.notifier).signIn(
        email: 'admin@test.com',
        password: 'TrainWake123!',
      );

      final state = container.read(currentAuthStateProvider);
      expect(state, isA<AuthStateAdminSignedIn>());
    });

    test('signIn failure → AuthStateError with message', () async {
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(mockRepo.signIn(email: anyNamed('email'), password: anyNamed('password')))
          .thenThrow(const AuthException('الإيميل أو كلمة المرور غلط. جرب تاني.'));

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      await container.read(authStateProvider.notifier).signIn(
        email: 'wrong@test.com',
        password: 'wrongPass',
      );

      final state = container.read(currentAuthStateProvider);
      expect(state, isA<AuthStateError>());
      expect((state as AuthStateError).message, contains('غلط'));
    });

    test('signInWithGoogle success → AuthStateSignedIn', () async {
      final googleUser = AuthUser(
        uid: 'uid-google',
        email: 'google@test.com',
        emailVerified: true,
        displayName: 'Google User',
        isAdmin: false,
      );
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(mockRepo.signInWithGoogle())
          .thenAnswer((_) async => googleUser);

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      await container.read(authStateProvider.notifier).signInWithGoogle();

      final state = container.read(currentAuthStateProvider);
      expect(state, isA<AuthStateSignedIn>());
      expect((state as AuthStateSignedIn).user.email, 'google@test.com');
    });

    test('signOut → AuthStateSignedOut', () async {
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(mockRepo.signOut()).thenAnswer((_) async {});

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      await container.read(authStateProvider.notifier).signOut();

      final state = container.read(currentAuthStateProvider);
      expect(state, isA<AuthStateSignedOut>());
    });

    test('unverified admin claim without emailVerified → NOT admin dashboard', () async {
      // Admin claim true but email not verified → stays at verification screen
      final unverifiedAdmin = AuthUser(
        uid: 'uid-admin-unverified',
        email: 'admin@test.com',
        emailVerified: false,
        isAdmin: true, // claim is there, but email unverified
      );
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(mockRepo.signIn(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => unverifiedAdmin);

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      await container.read(authStateProvider.notifier).signIn(
        email: 'admin@test.com',
        password: 'TrainWake123!',
      );

      final state = container.read(currentAuthStateProvider);
      // Must not be admin dashboard — must be verification required
      expect(state, isA<AuthStateEmailVerificationRequired>());
      expect(state, isNot(isA<AuthStateAdminSignedIn>()));
    });

    test('checkEmailVerification returns false when still unverified', () async {
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(mockRepo.reloadUser()).thenAnswer((_) async => AuthUser(
            uid: 'uid-456',
            email: 'u@test.com',
            emailVerified: false,
            isAdmin: false,
          ));

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final result = await container.read(authStateProvider.notifier).checkEmailVerification();
      expect(result, isFalse);
    });

    test('checkEmailVerification returns true when now verified', () async {
      when(mockRepo.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(mockRepo.reloadUser()).thenAnswer((_) async => AuthUser(
            uid: 'uid-789',
            email: 'v@test.com',
            emailVerified: true,
            isAdmin: false,
          ));

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final result = await container.read(authStateProvider.notifier).checkEmailVerification();
      expect(result, isTrue);
    });
  });

  group('AuthNotifier — null repo (Firebase unavailable)', () {
    test('auth state remains signedOut when repo is null', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final state = container.read(currentAuthStateProvider);
      expect(state, isA<AuthStateSignedOut>());
    });

    test('signIn with null repo produces error state', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);
      // Keep the provider alive and listening to updates
      container.listen(currentAuthStateProvider, (prev, next) {});
      await Future.delayed(Duration.zero);

      await container.read(authStateProvider.notifier).signIn(
        email: 'test@test.com',
        password: 'Test123!',
      );

      await Future.delayed(Duration.zero);
      final state = container.read(currentAuthStateProvider);
      expect(state, isA<AuthStateError>());
    });
  });
}
