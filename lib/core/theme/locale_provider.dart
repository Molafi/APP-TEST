import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../services/local_cache_service.dart';

/// App locale. `null` means "follow the device locale". Persisted as a
/// non-sensitive preference and can be changed at runtime without a restart.
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._cache) : super(null) {
    final String? saved = _cache.getString(AppConstants.prefLocale);
    if (saved != null && saved.isNotEmpty) state = Locale(saved);
  }

  final LocalCacheService _cache;

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _cache.remove(AppConstants.prefLocale);
    } else {
      await _cache.setString(AppConstants.prefLocale, locale.languageCode);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.watch(localCacheServiceProvider));
});
