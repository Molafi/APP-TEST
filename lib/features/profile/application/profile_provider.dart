import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/environment.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/services/local_cache_service.dart';
import '../../auth/application/auth_provider.dart';
import '../../chat/application/chat_provider.dart';
import '../../chat/application/conversations_provider.dart';
import '../../diagnosis/application/diagnosis_provider.dart';
import '../../plants/application/plants_provider.dart';
import '../../reminders/application/reminder_provider.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  if (Environment.isDemo) return const NoopProfileRepository();
  return FirestoreProfileRepository();
});

/// Outcome of a destructive operation so the UI can react precisely.
enum DeletionResult { success, reauthRequired, failure }

/// Handles logout and destructive data/account deletion, ensuring private state
/// is cleared and providers are invalidated afterwards.
class ProfileController extends StateNotifier<AsyncValue<void>> {
  ProfileController(this._ref) : super(const AsyncData<void>(null));

  final Ref _ref;

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).signOut();
    _clearPrivateState();
  }

  /// Deletes all user content (chats, diagnoses, reminders, cached data) but
  /// keeps the account. Returns whether it fully succeeded.
  Future<DeletionResult> deleteAllData() async {
    state = const AsyncLoading<void>();
    try {
      // chatRepositoryProvider is scoped to the *active* conversation, so
      // deleting through it alone would leave every other conversation's
      // messages on disk. Delete each conversation explicitly instead: the
      // repository's delete() also drops that chat's `chat_messages_<id>` cache
      // entry (local) or its messages subcollection (Firestore).
      final conversationsRepo = _ref.read(conversationsRepositoryProvider);
      for (final chat in await conversationsRepo.list()) {
        await conversationsRepo.delete(chat.id);
      }
      await _ref.read(chatRepositoryProvider).deleteAll();
      await _ref.read(diagnosisRepositoryProvider).deleteAll();
      await _ref.read(plantsRepositoryProvider).deleteAll();
      final reminders = _ref.read(reminderControllerProvider);
      final reminderCtrl = _ref.read(reminderControllerProvider.notifier);
      for (final r in [...reminders]) {
        await reminderCtrl.remove(r);
      }
      _clearPrivateCaches();
      _clearPrivateState();
      state = const AsyncData<void>(null);
      return DeletionResult.success;
    } catch (e) {
      state = AsyncError<void>(
        ErrorMapper.fromException(e),
        StackTrace.current,
      );
      return DeletionResult.failure;
    }
  }

  /// Deletes all data AND the account. Requires recent auth; if Firebase
  /// reports [AppErrorKind.authExpired], asks the caller to reauthenticate.
  Future<DeletionResult> deleteAccount() async {
    final DeletionResult dataResult = await deleteAllData();
    if (dataResult == DeletionResult.failure) return dataResult;

    state = const AsyncLoading<void>();
    try {
      final user = _ref.read(currentUserProvider);
      if (user != null) {
        await _ref.read(profileRepositoryProvider).deleteUserDocument(user.uid);
      }
      await _ref.read(authRepositoryProvider).deleteAccount();
      state = const AsyncData<void>(null);
      return DeletionResult.success;
    } on AppException catch (e) {
      state = AsyncError<void>(e, StackTrace.current);
      if (e.kind == AppErrorKind.authExpired) {
        return DeletionResult.reauthRequired;
      }
      return DeletionResult.failure;
    } catch (e) {
      state = AsyncError<void>(
        ErrorMapper.fromException(e),
        StackTrace.current,
      );
      return DeletionResult.failure;
    }
  }

  void _clearPrivateCaches() {
    final LocalCacheService cache = _ref.read(localCacheServiceProvider);
    // Clear private, user-scoped keys only. Locale/theme are preserved.
    cache.clearPrivate([
      // Per-conversation message keys are removed by the loop in
      // deleteAllData(); this covers the default chat and the index itself.
      'chat_messages_default',
      'conversations',
      'diagnoses_local',
      'plants_local',
      AppConstants.prefReminders,
      AppConstants.prefCachedWeather,
      AppConstants.prefSelectedLocation,
    ]);
  }

  /// Invalidates user-specific providers so no stale private data lingers.
  void _clearPrivateState() {
    _ref.invalidate(chatControllerProvider);
    _ref.invalidate(diagnosisControllerProvider);
    _ref.invalidate(diagnosisHistoryProvider);
    _ref.invalidate(plantsControllerProvider);
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
      return ProfileController(ref);
    });
