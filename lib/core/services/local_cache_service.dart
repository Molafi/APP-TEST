import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight wrapper over SharedPreferences for preferences and small cached
/// payloads (weather JSON, geocode results, reminders). Large binary data is
/// never stored here.
class LocalCacheService {
  LocalCacheService(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<void> remove(String key) => _prefs.remove(key);

  /// Clears only private, user-scoped keys. Non-sensitive preferences such as
  /// locale and theme are intentionally preserved.
  Future<void> clearPrivate(Iterable<String> keys) async {
    for (final String k in keys) {
      await _prefs.remove(k);
    }
  }
}

/// Overridden in [main] once SharedPreferences has been loaded.
final localCacheServiceProvider = Provider<LocalCacheService>((ref) {
  throw UnimplementedError('localCacheServiceProvider must be overridden');
});
