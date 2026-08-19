import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/services/local_cache_service.dart';
import '../domain/location_model.dart';

/// Reverse-geocoding and city search via Nominatim/OpenStreetMap. Uses a
/// descriptive User-Agent, caches results, and rate-limits to comply with the
/// OSM usage policy. Raw geocoder failures are never surfaced to users.
class NominatimService {
  NominatimService(this._cache, [ApiClient? client])
    : _client = client ?? ApiClient();

  final ApiClient _client;
  final LocalCacheService _cache;
  DateTime? _lastCall;

  static const Map<String, String> _headers = {
    'User-Agent': AppConfig.nominatimUserAgent,
    'Accept': 'application/json',
  };

  Future<void> _respectRateLimit() async {
    final DateTime now = DateTime.now();
    if (_lastCall != null) {
      final Duration since = now.difference(_lastCall!);
      if (since < AppConfig.nominatimMinInterval) {
        await Future<void>.delayed(AppConfig.nominatimMinInterval - since);
      }
    }
    _lastCall = DateTime.now();
  }

  /// Reverse geocode coordinates to a [PlantLocation]. Cached for a week.
  Future<PlantLocation?> reverse({
    required double lat,
    required double lon,
    String locale = 'en',
  }) async {
    final String cacheKey =
        '${AppConstantsGeo.prefix}${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}_$locale';
    final PlantLocation? cached = _readCache(cacheKey);
    if (cached != null) return cached;

    await _respectRateLimit();
    try {
      final Uri uri = Uri.parse('${AppConfig.nominatimBase}/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'jsonv2',
          'accept-language': locale,
          'zoom': '10',
        },
      );
      final Map<String, dynamic> json = await _client.getJson(
        uri,
        headers: _headers,
      );
      final PlantLocation? loc = _fromReverse(json, lat, lon);
      if (loc != null) _writeCache(cacheKey, loc);
      return loc;
    } catch (_) {
      return null; // caller falls back to manual entry
    }
  }

  /// Free-text city search returning candidate places.
  Future<List<PlantLocation>> search(
    String query, {
    String locale = 'en',
  }) async {
    if (query.trim().length < 2) return [];
    await _respectRateLimit();
    try {
      final Uri uri = Uri.parse('${AppConfig.nominatimBase}/search').replace(
        queryParameters: {
          'q': query.trim(),
          'format': 'jsonv2',
          'accept-language': locale,
          'limit': '6',
          'addressdetails': '1',
        },
      );
      // The search endpoint returns a JSON array; ApiClient wraps non-map JSON
      // under a 'data' key.
      final Map<String, dynamic> res = await _client.getJson(
        uri,
        headers: _headers,
      );
      final List list = (res['data'] as List?) ?? const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(_fromSearch)
          .whereType<PlantLocation>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  PlantLocation? _fromReverse(
    Map<String, dynamic> json,
    double lat,
    double lon,
  ) {
    final addr = json['address'] as Map<String, dynamic>?;
    if (addr == null) return null;
    final String? city = _pickLocality(addr);
    if (city == null) return null;
    return PlantLocation(
      latitude: lat,
      longitude: lon,
      city: city,
      country: addr['country'] as String?,
      countryCode: (addr['country_code'] as String?)?.toUpperCase(),
    );
  }

  PlantLocation? _fromSearch(Map<String, dynamic> json) {
    final double? lat = double.tryParse(json['lat']?.toString() ?? '');
    final double? lon = double.tryParse(json['lon']?.toString() ?? '');
    if (lat == null || lon == null) return null;
    final addr = json['address'] as Map<String, dynamic>?;
    final String city = addr != null
        ? (_pickLocality(addr) ?? _shortName(json))
        : _shortName(json);
    return PlantLocation(
      latitude: lat,
      longitude: lon,
      city: city,
      country: addr?['country'] as String?,
      countryCode: (addr?['country_code'] as String?)?.toUpperCase(),
      isManual: true,
    );
  }

  /// Falls back through city → town → village → municipality → county → state.
  String? _pickLocality(Map<String, dynamic> addr) {
    for (final String key in const [
      'city',
      'town',
      'village',
      'municipality',
      'county',
      'state',
    ]) {
      final Object? value = addr[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  String _shortName(Map<String, dynamic> json) {
    final String display = (json['display_name'] as String?) ?? 'Unknown';
    return display.split(',').first.trim();
  }

  PlantLocation? _readCache(String key) {
    final String? raw = _cache.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final int ts = (decoded['_ts'] as num?)?.toInt() ?? 0;
      final DateTime saved = DateTime.fromMillisecondsSinceEpoch(ts);
      if (DateTime.now().difference(saved) > AppConfig.geocodeCacheTtl) {
        return null;
      }
      return PlantLocation.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  void _writeCache(String key, PlantLocation loc) {
    final Map<String, dynamic> map = loc.toMap()
      ..['_ts'] = DateTime.now().millisecondsSinceEpoch;
    _cache.setString(key, jsonEncode(map));
  }
}

/// Local constant to avoid importing the whole constants file for one prefix.
class AppConstantsGeo {
  static const String prefix = 'geocode_';
}

final nominatimServiceProvider = Provider<NominatimService>((ref) {
  return NominatimService(ref.watch(localCacheServiceProvider));
});
