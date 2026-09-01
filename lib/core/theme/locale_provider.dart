import 'dart:ui' show PlatformDispatcher;

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

/// Resolves the locale the app is ACTUALLY rendering in.
///
/// [explicit] is the user's Settings choice; `null` means "follow the device".
/// In that case the device's preferred locales are matched against
/// [AppConstants.supportedLocales] using the same algorithm `MaterialApp` uses,
/// so this can never disagree with the locale Flutter resolved for
/// `AppLocalizations`.
///
/// This matters because the naive `locale?.languageCode ?? 'en'` used to answer
/// "en" for a user on an Arabic device who had never opened Settings — the UI
/// was Arabic (Flutter resolved the device locale) but every AI request asked
/// for English, so labels and values disagreed.
Locale resolveAppLocale(Locale? explicit, {List<Locale>? deviceLocales}) {
  if (explicit != null) {
    for (final Locale supported in AppConstants.supportedLocales) {
      if (supported.languageCode == explicit.languageCode) return supported;
    }
    // An unsupported saved code (e.g. a stale preference) is ignored and the
    // device locale decides, matching MaterialApp's own fallback behaviour.
  }
  final List<Locale> preferred =
      deviceLocales ?? PlatformDispatcher.instance.locales;
  return basicLocaleListResolution(preferred, AppConstants.supportedLocales);
}

/// The effective language code (`en`, `ar`, `fr`, `es`) for everything that
/// happens outside a widget `BuildContext`: AI prompts, demo content, date and
/// number formatting, and speech/TTS locales.
///
/// Use this instead of reading [localeProvider] directly — it accounts for
/// "follow the device" and never silently falls back to English.
///
/// Note: a change to the *device* locale while the app is running does not
/// invalidate this provider (only an explicit Settings change does). That is
/// acceptable because the OS restarts or rebuilds the app on a locale change.
final appLocaleCodeProvider = Provider<String>((ref) {
  return resolveAppLocale(ref.watch(localeProvider)).languageCode;
});
