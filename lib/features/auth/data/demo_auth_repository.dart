import 'dart:async';

import '../../../core/errors/app_exception.dart';
import 'auth_repository.dart';

/// In-memory auth used in demo mode and tests. Accepts any well-formed
/// credentials and simulates realistic latency. No real accounts are created.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository();

  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _current;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (password.length < 8) {
      throw const AppException(AppErrorKind.invalidCredentials);
    }
    return _emit(
      AuthUser(
        uid: 'demo-${email.hashCode.toUnsigned(32)}',
        email: email,
        displayName: email.split('@').first,
        emailVerified: true,
      ),
    );
  }

  @override
  Future<AuthUser> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _emit(
      AuthUser(
        uid: 'demo-${email.hashCode.toUnsigned(32)}',
        email: email,
        displayName: displayName ?? email.split('@').first,
        emailVerified: false,
      ),
    );
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _emit(
      const AuthUser(
        uid: 'demo-google-user',
        email: 'gardener@example.com',
        displayName: 'Demo Gardener',
        emailVerified: true,
      ),
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  @override
  Future<void> sendEmailVerification() async =>
      Future<void>.delayed(const Duration(milliseconds: 200));

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    if (password.length < 8) {
      throw const AppException(AppErrorKind.invalidCredentials);
    }
  }

  @override
  Future<void> deleteAccount() async {
    _current = null;
    _controller.add(null);
  }

  AuthUser _emit(AuthUser user) {
    _current = user;
    _controller.add(user);
    return user;
  }
}
