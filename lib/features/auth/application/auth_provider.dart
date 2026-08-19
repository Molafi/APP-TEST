import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/environment.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../data/auth_repository.dart';
import '../data/demo_auth_repository.dart';
import '../data/firebase_auth_repository.dart';

/// Selects the auth backend. In demo mode (or when Firebase is disabled) an
/// in-memory fake is used so the app runs without any credentials.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (Environment.isDemo) return DemoAuthRepository();
  return FirebaseAuthRepository();
});

/// Streamed auth state that drives routing.
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Convenience accessor for the current user (may be null).
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Handles login/register/reset actions and exposes an [AsyncValue] the UI can
/// use to show loading and typed errors. Prevents duplicate in-flight submits.
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repo) : super(const AsyncData<void>(null));

  final AuthRepository _repo;

  bool get isBusy => state.isLoading;

  Future<bool> signIn(String email, String password) =>
      _guard(() => _repo.signInWithEmail(email, password));

  Future<bool> register(String email, String password, String displayName) =>
      _guard(
        () =>
            _repo.registerWithEmail(email, password, displayName: displayName),
      );

  Future<bool> signInWithGoogle() => _guard(_repo.signInWithGoogle);

  Future<bool> sendReset(String email) =>
      _guard(() => _repo.sendPasswordReset(email));

  Future<bool> _guard(Future<void> Function() action) async {
    if (state.isLoading) return false;
    state = const AsyncLoading<void>();
    try {
      await action();
      state = const AsyncData<void>(null);
      return true;
    } catch (raw) {
      final AppException e = ErrorMapper.fromException(raw);
      state = AsyncError<void>(e, StackTrace.current);
      return false;
    }
  }

  void clearError() => state = const AsyncData<void>(null);
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });
