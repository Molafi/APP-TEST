import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/environment.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/services/local_cache_service.dart';
import '../../location/application/location_provider.dart';
import '../../location/domain/location_model.dart';
import '../data/open_meteo_service.dart';
import '../domain/plant_care_rules.dart';
import '../domain/weather_model.dart';

@immutable
class WeatherState {
  const WeatherState({
    this.data,
    this.loading = false,
    this.refreshing = false,
    this.error,
  });

  final WeatherData? data;
  final bool loading;
  final bool refreshing;
  final AppException? error;

  List<PlantCareTip> get tips =>
      data == null ? const [] : PlantCareRules.compute(data!);

  WeatherState copyWith({
    WeatherData? data,
    bool? loading,
    bool? refreshing,
    AppException? error,
    bool clearError = false,
  }) {
    return WeatherState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WeatherController extends StateNotifier<WeatherState> {
  WeatherController(this._ref) : super(const WeatherState()) {
    _restoreCache();
    // React to location changes and fetch fresh weather.
    _ref.listen<PlantLocation?>(selectedLocationProvider, (prev, next) {
      if (next != null && next != prev) {
        fetch(next);
      }
    }, fireImmediately: true);
  }

  final Ref _ref;

  LocalCacheService get _cache => _ref.read(localCacheServiceProvider);
  OpenMeteoService get _service => _ref.read(openMeteoServiceProvider);

  void _restoreCache() {
    final String? raw = _cache.getString(AppConstants.prefCachedWeather);
    if (raw == null) return;
    try {
      final WeatherData cached =
          WeatherData.fromMap(jsonDecode(raw) as Map<String, dynamic>);
      state = state.copyWith(data: cached);
    } catch (_) {}
  }

  Future<void> fetch(PlantLocation location, {bool force = false}) async {
    // Skip refetch if cached data is still fresh (unless forced).
    if (!force &&
        state.data != null &&
        DateTime.now().difference(state.data!.fetchedAt) <
            AppConfig.weatherCacheTtl) {
      return;
    }

    final bool hasData = state.data != null;
    state = state.copyWith(
      loading: !hasData,
      refreshing: hasData,
      clearError: true,
    );

    try {
      final WeatherData data = await _service.fetch(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (!mounted) return;
      state = WeatherState(data: data);
      _cache.setString(
          AppConstants.prefCachedWeather, jsonEncode(data.toMap()));
    } catch (e) {
      if (!mounted) return;
      // Keep any cached data visible; surface a non-blocking error.
      state = state.copyWith(
        loading: false,
        refreshing: false,
        error: ErrorMapper.fromException(e),
        // Mark existing data as cached so the UI shows "cached".
        data: state.data?.asCached(),
      );
    }
  }

  Future<void> refresh() async {
    final PlantLocation? loc = _ref.read(selectedLocationProvider);
    if (loc == null) return;
    await fetch(loc, force: true);
  }
}

final weatherControllerProvider =
    StateNotifierProvider<WeatherController, WeatherState>((ref) {
  return WeatherController(ref);
});

/// The latest weather data (live or cached), or null. Watched by the AI context
/// and the app-bar weather chip. In demo mode this still works via the sample
/// location wired in LocationRepository.
final currentWeatherDataProvider = Provider<WeatherData?>((ref) {
  // Ensure the controller is alive so it reacts to location changes.
  return ref.watch(weatherControllerProvider).data;
});

/// Whether demo fetching is enabled (used to seed a default location so the
/// weather tab shows something immediately in demo mode).
final weatherBootstrapProvider = Provider<void>((ref) {
  if (Environment.isDemo) {
    // Trigger a location resolution which seeds weather via the listener.
    Future<void>.microtask(
        () => ref.read(locationControllerProvider.notifier).useMyLocation());
  }
});
