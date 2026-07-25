import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/services/local_cache_service.dart';
import '../../location/application/location_provider.dart';
import '../data/soilgrids_service.dart';
import '../domain/soil_model.dart';

/// SoilGrids service backed by a dedicated HTTP client that is disposed with
/// the provider container.
final soilGridsServiceProvider = Provider<SoilGridsService>((ref) {
  final client = ApiClient();
  ref.onDispose(client.dispose);
  return SoilGridsService(client);
});

/// Cache-first soil profile for the currently selected location.
///
/// Soil composition does not change day to day, so a location result is cached
/// indefinitely (keyed to ~1 km precision) and only refetched when missing.
final soilProfileProvider =
    FutureProvider.autoDispose<SoilProfile?>((ref) async {
  final location = ref.watch(selectedLocationProvider);
  if (location == null) return null;

  final cache = ref.watch(localCacheServiceProvider);
  final String key =
      'soil_${location.latitude.toStringAsFixed(2)}_${location.longitude.toStringAsFixed(2)}';

  final String? cached = cache.getString(key);
  if (cached != null && cached.isNotEmpty) {
    try {
      return SoilProfile.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    } catch (_) {
      // Fall through and refetch on corrupt cache.
    }
  }

  final SoilProfile profile = await ref.read(soilGridsServiceProvider).fetch(
        lat: location.latitude,
        lon: location.longitude,
      );

  if (!profile.isEmpty) {
    await cache.setString(key, jsonEncode(profile.toJson()));
  }
  return profile;
});

/// Persisted user-entered pH from a physical meter/test kit, keyed by location.
/// Lets people override the database estimate with a real reading.
class ManualPhController extends StateNotifier<double?> {
  ManualPhController(this._ref) : super(null) {
    _restore();
  }

  final Ref _ref;

  LocalCacheService get _cache => _ref.read(localCacheServiceProvider);

  String get _key {
    final loc = _ref.read(selectedLocationProvider);
    if (loc == null) return 'manual_ph_none';
    return 'manual_ph_${loc.latitude.toStringAsFixed(2)}_${loc.longitude.toStringAsFixed(2)}';
  }

  void _restore() {
    final String? raw = _cache.getString(_key);
    if (raw != null) state = double.tryParse(raw);
  }

  Future<void> set(double? value) async {
    state = value;
    if (value == null) {
      await _cache.remove(_key);
    } else {
      await _cache.setString(_key, value.toString());
    }
  }
}

final manualPhProvider =
    StateNotifierProvider.autoDispose<ManualPhController, double?>((ref) {
  return ManualPhController(ref);
});
