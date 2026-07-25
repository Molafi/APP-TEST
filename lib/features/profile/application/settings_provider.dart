import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/local_cache_service.dart';

/// Persisted unit system (metric/imperial). Non-sensitive preference.
class UnitSystemNotifier extends StateNotifier<UnitSystem> {
  UnitSystemNotifier(this._cache)
      : super(UnitSystemX.fromId(_cache.getString(AppConstants.prefUnitSystem)));

  final LocalCacheService _cache;

  Future<void> set(UnitSystem system) async {
    state = system;
    await _cache.setString(AppConstants.prefUnitSystem, system.id);
  }
}

final unitSystemProvider =
    StateNotifierProvider<UnitSystemNotifier, UnitSystem>((ref) {
  return UnitSystemNotifier(ref.watch(localCacheServiceProvider));
});

/// Image-retention preference. OFF by default (privacy): images are deleted
/// after analysis unless the user opts in.
class ImageRetentionNotifier extends StateNotifier<bool> {
  ImageRetentionNotifier(this._cache)
      : super(_cache.getBool(AppConstants.prefImageRetention));

  final LocalCacheService _cache;

  Future<void> set(bool value) async {
    state = value;
    await _cache.setBool(AppConstants.prefImageRetention, value);
  }
}

final imageRetentionProvider =
    StateNotifierProvider<ImageRetentionNotifier, bool>((ref) {
  return ImageRetentionNotifier(ref.watch(localCacheServiceProvider));
});

/// Whether the user has enabled notifications (reminders). OFF by default.
class NotificationsEnabledNotifier extends StateNotifier<bool> {
  NotificationsEnabledNotifier(this._cache)
      : super(_cache.getBool(AppConstants.prefNotificationsEnabled));

  final LocalCacheService _cache;

  Future<void> set(bool value) async {
    state = value;
    await _cache.setBool(AppConstants.prefNotificationsEnabled, value);
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, bool>((ref) {
  return NotificationsEnabledNotifier(ref.watch(localCacheServiceProvider));
});

/// Whether the user has opted in to usage analytics + crash reporting. OFF by
/// default; nothing is collected unless explicitly enabled.
class AnalyticsEnabledNotifier extends StateNotifier<bool> {
  AnalyticsEnabledNotifier(this._cache)
      : super(_cache.getBool(AppConstants.prefAnalyticsEnabled));

  final LocalCacheService _cache;

  Future<void> set(bool value) async {
    state = value;
    await _cache.setBool(AppConstants.prefAnalyticsEnabled, value);
  }
}

final analyticsEnabledProvider =
    StateNotifierProvider<AnalyticsEnabledNotifier, bool>((ref) {
  return AnalyticsEnabledNotifier(ref.watch(localCacheServiceProvider));
});
