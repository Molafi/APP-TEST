import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_cache_service.dart';
import '../../georesearch/domain/site_survey_model.dart';

/// The app-wide "what do you want to do" choice, reusing the existing
/// [SurveyPurpose] enum rather than inventing a parallel intent type.
///
/// The state is deliberately nullable: `null` means nothing has ever been
/// chosen, so the picker opens on [SurveyPurpose.general]; a stored value (even
/// [SurveyPurpose.general]) is the user's last choice and pre-selects the card.
/// This mirrors the persisted-single-value pattern of [OnboardingNotifier]: the
/// notifier reads [LocalCacheService] in its constructor and writes on every
/// set.
///
/// Note this value does NOT decide whether the picker is shown — that is
/// [purposeConfirmedThisSessionProvider]. The picker appears on every launch;
/// persisting the choice only makes re-confirming it a single tap.
class AppPurposeNotifier extends StateNotifier<SurveyPurpose?> {
  AppPurposeNotifier(this._cache)
    : super(_readInitial(_cache.getString(AppConstants.prefAppPurpose)));

  final LocalCacheService _cache;

  /// Returns null when nothing is stored so the picker shows exactly once;
  /// otherwise parses the stored value with the tolerant [surveyPurposeFrom].
  static SurveyPurpose? _readInitial(String? stored) {
    if (stored == null || stored.trim().isEmpty) return null;
    return surveyPurposeFrom(stored);
  }

  /// Persists the chosen purpose and updates state. Stores [SurveyPurpose.name]
  /// so it round-trips through [surveyPurposeFrom] on the next launch.
  Future<void> setPurpose(SurveyPurpose purpose) async {
    state = purpose;
    await _cache.setString(AppConstants.prefAppPurpose, purpose.name);
  }
}

final appPurposeProvider =
    StateNotifierProvider<AppPurposeNotifier, SurveyPurpose?>((ref) {
      return AppPurposeNotifier(ref.watch(localCacheServiceProvider));
    });

/// True when a purpose has ever been stored. Distinguishes "never chosen"
/// (null) from a deliberately-chosen [SurveyPurpose.general], which is why the
/// notifier's state is nullable.
final purposeChosenProvider = Provider<bool>((ref) {
  return ref.watch(appPurposeProvider) != null;
});

/// Whether the purpose picker has been confirmed **in this session**.
///
/// This — not the persisted purpose — is what the router branches on, so the
/// picker is shown on every entry to the app rather than only once.
///
/// Deliberately NOT persisted: the provider container is created fresh on every
/// app start, so this resets to false each launch. Keeping it separate from
/// [appPurposeProvider] is what lets the previous choice still be remembered and
/// pre-selected while the confirmation is asked for again.
final purposeConfirmedThisSessionProvider = StateProvider<bool>((ref) => false);
