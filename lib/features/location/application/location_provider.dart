import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/services/local_cache_service.dart';
import '../../../core/theme/locale_provider.dart';
import '../data/location_repository.dart';
import '../data/nominatim_service.dart';
import '../domain/location_model.dart';

enum LocationStatus {
  idle,
  locating,
  ready,
  denied,
  permanentlyDenied,
  servicesDisabled,
  error,
}

@immutable
class LocationState {
  const LocationState({
    this.location,
    this.status = LocationStatus.idle,
    this.error,
    this.searchResults = const [],
    this.searching = false,
  });

  final PlantLocation? location;
  final LocationStatus status;
  final AppException? error;
  final List<PlantLocation> searchResults;
  final bool searching;

  LocationState copyWith({
    PlantLocation? location,
    LocationStatus? status,
    AppException? error,
    List<PlantLocation>? searchResults,
    bool? searching,
    bool clearError = false,
  }) {
    return LocationState(
      location: location ?? this.location,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      searchResults: searchResults ?? this.searchResults,
      searching: searching ?? this.searching,
    );
  }
}

class LocationController extends StateNotifier<LocationState> {
  LocationController(this._ref) : super(const LocationState()) {
    _restore();
  }

  final Ref _ref;
  Timer? _debounce;

  LocalCacheService get _cache => _ref.read(localCacheServiceProvider);
  NominatimService get _geocoder => _ref.read(nominatimServiceProvider);
  String get _locale => _ref.read(appLocaleCodeProvider);

  void _restore() {
    final String? raw = _cache.getString(AppConstants.prefSelectedLocation);
    if (raw == null) return;
    try {
      final PlantLocation loc = PlantLocation.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      state = state.copyWith(location: loc, status: LocationStatus.ready);
    } catch (_) {}
  }

  Future<void> useMyLocation() async {
    state = state.copyWith(status: LocationStatus.locating, clearError: true);
    try {
      final pos = await _ref.read(locationRepositoryProvider).currentPosition();
      final PlantLocation? resolved = await _geocoder.reverse(
        lat: pos.lat,
        lon: pos.lon,
        locale: _locale,
      );
      final PlantLocation loc =
          resolved ??
          PlantLocation(
            latitude: pos.lat,
            longitude: pos.lon,
            city: 'My location',
          );
      _apply(loc);
    } catch (e) {
      final AppException err = ErrorMapper.fromException(e);
      state = state.copyWith(
        status: switch (err.kind) {
          AppErrorKind.permissionPermanentlyDenied =>
            LocationStatus.permanentlyDenied,
          AppErrorKind.permissionDenied => LocationStatus.denied,
          AppErrorKind.locationServicesDisabled =>
            LocationStatus.servicesDisabled,
          _ => LocationStatus.error,
        },
        error: err,
      );
    }
  }

  void selectManual(PlantLocation location) => _apply(location);

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      state = state.copyWith(searchResults: [], searching: false);
      return;
    }
    state = state.copyWith(searching: true);
    _debounce = Timer(AppConfig.geocodeSearchDebounce, () async {
      final List<PlantLocation> results = await _geocoder.search(
        query,
        locale: _locale,
      );
      if (!mounted) return;
      state = state.copyWith(searchResults: results, searching: false);
    });
  }

  void clearSearch() =>
      state = state.copyWith(searchResults: [], searching: false);

  void _apply(PlantLocation location) {
    state = state.copyWith(
      location: location,
      status: LocationStatus.ready,
      searchResults: [],
      clearError: true,
    );
    _cache.setString(
      AppConstants.prefSelectedLocation,
      jsonEncode(location.toMap()),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final locationControllerProvider =
    StateNotifierProvider<LocationController, LocationState>((ref) {
      return LocationController(ref);
    });

/// Convenience: the currently selected location (or null). Watched by the AI
/// context and weather providers.
final selectedLocationProvider = Provider<PlantLocation?>((ref) {
  return ref.watch(locationControllerProvider).location;
});
