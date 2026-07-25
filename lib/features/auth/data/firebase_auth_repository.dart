import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/app_exception.dart';
import 'auth_repository.dart';

/// Firebase-backed auth. Maps Firebase error codes to friendly typed
/// [AppException]s and never surfaces raw exception text.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _google = googleSignIn ?? GoogleSignIn();

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _google;

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(_map);

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return _requireUser(cred.user);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AuthUser> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      if (displayName != null && displayName.trim().isNotEmpty) {
        await cred.user?.updateDisplayName(displayName.trim());
      }
      await cred.user?.sendEmailVerification();
      await cred.user?.reload();
      return _requireUser(_auth.currentUser);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _google.signIn();
      if (account == null) {
        // User cancelled — treated as an invalid-input (non-retryable) signal.
        throw const AppException(AppErrorKind.invalidInput,
            debugDetail: 'google sign-in cancelled');
      }
      final GoogleSignInAuthentication gAuth = await account.authentication;
      final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      return _requireUser(cred.user);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      // Do not reveal whether the email exists; only surface network issues.
      if (e.code == 'network-request-failed') {
        throw const AppException(AppErrorKind.noConnection);
      }
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> signOut() async {
    await _google.signOut().catchError((_) {});
    await _auth.signOut();
  }

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    final fb.User? user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AppException(AppErrorKind.unauthenticated);
    }
    try {
      final cred = fb.EmailAuthProvider.credential(
          email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AppException(AppErrorKind.authExpired);
      }
      throw _mapError(e);
    }
  }

  AuthUser _requireUser(fb.User? user) {
    final AuthUser? mapped = _map(user);
    if (mapped == null) throw const AppException(AppErrorKind.unauthenticated);
    return mapped;
  }

  AuthUser? _map(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  AppException _mapError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const AppException(AppErrorKind.invalidInput);
      case 'user-disabled':
        return const AppException(AppErrorKind.invalidCredentials,
            debugDetail: 'user-disabled');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AppException(AppErrorKind.invalidCredentials);
      case 'email-already-in-use':
        return const AppException(AppErrorKind.invalidInput,
            debugDetail: 'email-already-in-use');
      case 'weak-password':
        return const AppException(AppErrorKind.invalidInput,
            debugDetail: 'weak-password');
      case 'too-many-requests':
        return const AppException(AppErrorKind.rateLimited);
      case 'network-request-failed':
        return const AppException(AppErrorKind.noConnection);
      case 'requires-recent-login':
        return const AppException(AppErrorKind.authExpired);
      default:
        return AppException(AppErrorKind.unknown, debugDetail: e.code);
    }
  }
}
