import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../location/application/location_provider.dart';
import '../domain/weather_model.dart';
import 'weather_provider.dart';

/// Weather/location context injected into AI requests and shown as the chat
/// context strip. Unknown values are omitted rather than invented.
class AiContext {
  const AiContext({
    this.values = const {},
    this.displayStrip,
    this.fromCache = false,
  });

  final Map<String, String> values;

  /// One-line strip, e.g. "📍 Amman, JO · 🌡 32°C · 💧 45%".
  final String? displayStrip;

  final bool fromCache;

  bool get isEmpty => values.isEmpty;
}

/// Composes the selected location and latest weather into an [AiContext].
final aiContextProvider = Provider<AiContext>((ref) {
  final location = ref.watch(selectedLocationProvider);
  final WeatherData? weather = ref.watch(currentWeatherDataProvider);

  if (location == null && weather == null) return const AiContext();

  final Map<String, String> values =
      weather?.toAiContext(location?.city ?? '', location?.country) ??
      {
        if (location != null) 'city': location.city,
        if (location?.country != null) 'country': location!.country!,
      };

  final List<String> parts = [];
  if (location != null) {
    final String cc = location.countryCode != null
        ? ', ${location.countryCode!.toUpperCase()}'
        : (location.country != null ? ', ${location.country}' : '');
    parts.add('📍 ${location.city}$cc');
  }
  if (weather?.current.temperatureC != null) {
    parts.add('🌡 ${weather!.current.temperatureC!.round()}°C');
  }
  if (weather?.current.humidity != null) {
    parts.add('💧 ${weather!.current.humidity}%');
  }

  return AiContext(
    values: values,
    displayStrip: parts.isEmpty ? null : parts.join('  ·  '),
    fromCache: weather?.fromCache ?? false,
  );
});
