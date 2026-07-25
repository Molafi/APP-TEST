/// Minimal authenticated-user view used by the app, decoupled from Firebase.
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
}

/// Auth abstraction so the UI/providers depend on an interface and can be
/// backed by Firebase in production or an in-memory fake in demo/tests.
abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Future<AuthUser> signInWithEmail(String email, String password);

  Future<AuthUser> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  });

  Future<AuthUser> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> sendEmailVerification();

  Future<void> signOut();

  /// Re-authenticates the current user, required by some destructive actions.
  Future<void> reauthenticateWithPassword(String password);

  /// Deletes the auth account (data cleanup is handled separately by the
  /// profile repository before this is called).
  Future<void> deleteAccount();
}
