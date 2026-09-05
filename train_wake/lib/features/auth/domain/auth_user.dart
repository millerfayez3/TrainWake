/// Immutable value object representing an authenticated TrainWake user.
///
/// Completely decoupled from firebase_auth — the repository boundary translates
/// between [firebase_auth.User] and this type so that the rest of the app
/// never imports Firebase directly.
class AuthUser {
  final String uid;
  final String? email;
  final bool emailVerified;
  final bool isAdmin;
  final String? displayName;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    required this.isAdmin,
    this.displayName,
  });

  AuthUser copyWith({
    String? uid,
    String? email,
    bool? emailVerified,
    bool? isAdmin,
    String? displayName,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  String toString() =>
      'AuthUser(uid: $uid, email: $email, emailVerified: $emailVerified, isAdmin: $isAdmin)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          emailVerified == other.emailVerified &&
          isAdmin == other.isAdmin;

  @override
  int get hashCode =>
      uid.hashCode ^ email.hashCode ^ emailVerified.hashCode ^ isAdmin.hashCode;
}
