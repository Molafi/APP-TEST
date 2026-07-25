import '../../../core/constants/app_constants.dart';

/// WMO weather-code condition categories used to pick an accessible icon and a
/// localized description.
enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
  unknown,
}

WeatherCondition conditionFromCode(int? code) {
  if (code == null) return WeatherCondition.unknown;
  if (code == 0) return WeatherCondition.clear;
  if (code == 1 || code == 2) return WeatherCondition.partlyCloudy;
  if (code == 3) return WeatherCondition.cloudy;
  if (code == 45 || code == 48) return WeatherCondition.fog;
  if (code >= 51 && code <= 57) return WeatherCondition.drizzle;
  if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
    return WeatherCondition.rain;
  }
  if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
    return WeatherCondition.snow;
  }
  if (code >= 95) return WeatherCondition.thunderstorm;
  return WeatherCondition.unknown;
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.humidity,
    required this.uvIndex,
    required this.precipitation,
    required this.condition,
    required this.time,
  });

  final double? temperatureC;
  final double? apparentTemperatureC;
  final int? humidity;
  final double? uvIndex;
  final double? precipitation;
  final WeatherCondition condition;
  final DateTime time;

  Map<String, dynamic> toMap() => {
        't': temperatureC,
        'at': apparentTemperatureC,
        'h': humidity,
        'uv': uvIndex,
        'p': precipitation,
        'c': condition.name,
        'time': time.toIso8601String(),
      };

  factory CurrentWeather.fromMap(Map<String, dynamic> m) => CurrentWeather(
        temperatureC: (m['t'] as num?)?.toDouble(),
        apparentTemperatureC: (m['at'] as num?)?.toDouble(),
        humidity: (m['h'] as num?)?.toInt(),
        uvIndex: (m['uv'] as num?)?.toDouble(),
        precipitation: (m['p'] as num?)?.toDouble(),
        condition: WeatherCondition.values.firstWhere(
          (e) => e.name == m['c'],
          orElse: () => WeatherCondition.unknown,
        ),
        time: DateTime.tryParse(m['time'] as String? ?? '') ?? DateTime.now(),
      );
}

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperatureC,
    required this.condition,
    required this.precipitationProbability,
  });

  final DateTime time;
  final double? temperatureC;
  final WeatherCondition condition;
  final int? precipitationProbability;

  Map<String, dynamic> toMap() => {
        'time': time.toIso8601String(),
        't': temperatureC,
        'c': condition.name,
        'pp': precipitationProbability,
      };

  factory HourlyForecast.fromMap(Map<String, dynamic> m) => HourlyForecast(
        time: DateTime.tryParse(m['time'] as String? ?? '') ?? DateTime.now(),
        temperatureC: (m['t'] as num?)?.toDouble(),
        condition: WeatherCondition.values.firstWhere(
          (e) => e.name == m['c'],
          orElse: () => WeatherCondition.unknown,
        ),
        precipitationProbability: (m['pp'] as num?)?.toInt(),
      );
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.minC,
    required this.maxC,
    required this.condition,
    required this.precipitationSum,
    required this.uvIndexMax,
    required this.precipitationProbabilityMax,
  });

  final DateTime date;
  final double? minC;
  final double? maxC;
  final WeatherCondition condition;
  final double? precipitationSum;
  final double? uvIndexMax;
  final int? precipitationProbabilityMax;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'min': minC,
        'max': maxC,
        'c': condition.name,
        'ps': precipitationSum,
        'uv': uvIndexMax,
        'ppm': precipitationProbabilityMax,
      };

  factory DailyForecast.fromMap(Map<String, dynamic> m) => DailyForecast(
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        minC: (m['min'] as num?)?.toDouble(),
        maxC: (m['max'] as num?)?.toDouble(),
        condition: WeatherCondition.values.firstWhere(
          (e) => e.name == m['c'],
          orElse: () => WeatherCondition.unknown,
        ),
        precipitationSum: (m['ps'] as num?)?.toDouble(),
        uvIndexMax: (m['uv'] as num?)?.toDouble(),
        precipitationProbabilityMax: (m['ppm'] as num?)?.toInt(),
      );
}

/// Full weather bundle plus provenance metadata (fetch time + live/cached).
class WeatherData {
  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
    required this.timezone,
    this.fromCache = false,
  });

  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;
  final String timezone;
  final bool fromCache;

  bool get isStale =>
      DateTime.now().difference(fetchedAt).inHours >= 3;

  WeatherData asCached() => WeatherData(
        current: current,
        hourly: hourly,
        daily: daily,
        fetchedAt: fetchedAt,
        timezone: timezone,
        fromCache: true,
      );

  Map<String, dynamic> toMap() => {
        'current': current.toMap(),
        'hourly': hourly.map((e) => e.toMap()).toList(),
        'daily': daily.map((e) => e.toMap()).toList(),
        'fetchedAt': fetchedAt.toIso8601String(),
        'timezone': timezone,
      };

  factory WeatherData.fromMap(Map<String, dynamic> m) => WeatherData(
        current:
            CurrentWeather.fromMap(m['current'] as Map<String, dynamic>? ?? {}),
        hourly: ((m['hourly'] as List?) ?? [])
            .whereType<Map<String, dynamic>>()
            .map(HourlyForecast.fromMap)
            .toList(),
        daily: ((m['daily'] as List?) ?? [])
            .whereType<Map<String, dynamic>>()
            .map(DailyForecast.fromMap)
            .toList(),
        fetchedAt:
            DateTime.tryParse(m['fetchedAt'] as String? ?? '') ?? DateTime.now(),
        timezone: (m['timezone'] as String?) ?? 'auto',
        fromCache: true,
      );

  /// Compact context object injected into AI requests. Omits unknown values.
  Map<String, String> toAiContext(String city, String? country) {
    final Map<String, String> ctx = {};
    if (city.isNotEmpty) ctx['city'] = city;
    if (country != null && country.isNotEmpty) ctx['country'] = country;
    if (current.temperatureC != null) {
      ctx['temperature'] = '${current.temperatureC!.round()}°C';
    }
    if (current.humidity != null) ctx['humidity'] = '${current.humidity}%';
    if (current.uvIndex != null) {
      ctx['uvIndex'] = current.uvIndex!.toStringAsFixed(1);
    }
    if (current.precipitation != null) {
      ctx['precipitation'] = '${current.precipitation} mm';
    }
    ctx['weatherTimestamp'] = fetchedAt.toIso8601String();
    return ctx;
  }
}

/// Unit conversion helpers kept with the model.
class TemperatureFormat {
  const TemperatureFormat._();

  static String format(double? celsius, UnitSystem unit) {
    if (celsius == null) return '—';
    if (unit == UnitSystem.imperial) {
      return '${(celsius * 9 / 5 + 32).round()}°F';
    }
    return '${celsius.round()}°C';
  }
}
