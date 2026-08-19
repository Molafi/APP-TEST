import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_cache_service.dart';

/// Tracks whether first-launch onboarding has been completed. Persisted locally
/// so it is shown only once.
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._cache)
    : super(_cache.getBool(AppConstants.prefOnboardingComplete));

  final LocalCacheService _cache;

  Future<void> complete() async {
    state = true;
    await _cache.setBool(AppConstants.prefOnboardingComplete, true);
  }
}

final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
      return OnboardingNotifier(ref.watch(localCacheServiceProvider));
    });
