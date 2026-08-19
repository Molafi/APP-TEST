import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../services/local_cache_service.dart';

/// Persisted app theme mode. Non-sensitive preference kept across sessions
/// (and even across logout, per privacy requirements).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._cache) : super(ThemeMode.system) {
    _restore();
  }

  final LocalCacheService _cache;

  void _restore() {
    final String? saved = _cache.getString(AppConstants.prefThemeMode);
    state = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _cache.setString(AppConstants.prefThemeMode, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier(ref.watch(localCacheServiceProvider));
});
