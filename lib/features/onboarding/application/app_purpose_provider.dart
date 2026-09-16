import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_cache_service.dart';
import '../../georesearch/domain/site_survey_model.dart';

/// The app-wide "what do you want to do" choice, reusing the existing
/// [SurveyPurpose] enum rather than inventing a parallel intent type.
///
/// The state is deliberately nullable: `null` means the user has NOT chosen a
/// purpose yet, so the router shows the one-time picker. A stored value (even
/// [SurveyPurpose.general]) means the user made a deliberate choice, so the
/// picker is skipped. This mirrors the persisted-single-value pattern of
/// [OnboardingNotifier]: the notifier reads [LocalCacheService] in its
/// constructor and writes on every set.
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

/// True once the user has chosen an app purpose. Lets the router tell "not yet
/// chosen" (null) apart from a deliberately-chosen [SurveyPurpose.general].
final purposeChosenProvider = Provider<bool>((ref) {
  return ref.watch(appPurposeProvider) != null;
});
