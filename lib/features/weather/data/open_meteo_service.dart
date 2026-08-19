import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/networking/api_client.dart';
import '../domain/weather_model.dart';

/// Fetches and parses Open-Meteo forecasts into typed [WeatherData]. Tolerates
/// nullable/missing fields and never throws on partial data.
class OpenMeteoService {
  OpenMeteoService([ApiClient? client]) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<WeatherData> fetch({
    required double latitude,
    required double longitude,
  }) async {
    final Uri uri = Uri.parse(AppConfig.openMeteoBase).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,apparent_temperature,relative_humidity_2m,uv_index,precipitation,weather_code',
        'hourly':
            'temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,weather_code',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,uv_index_max,precipitation_sum,precipitation_probability_max',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final Map<String, dynamic> json = await _client.getJson(uri);
    return parse(json);
  }

  /// Pure parser, extracted for unit testing.
  static WeatherData parse(Map<String, dynamic> json) {
    final String timezone = (json['timezone'] as String?) ?? 'auto';

    final current = json['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw const AppException(AppErrorKind.malformedResponse);
    }

    final CurrentWeather currentWeather = CurrentWeather(
      temperatureC: (current['temperature_2m'] as num?)?.toDouble(),
      apparentTemperatureC: (current['apparent_temperature'] as num?)
          ?.toDouble(),
      humidity: (current['relative_humidity_2m'] as num?)?.toInt(),
      uvIndex: (current['uv_index'] as num?)?.toDouble(),
      precipitation: (current['precipitation'] as num?)?.toDouble(),
      condition: conditionFromCode((current['weather_code'] as num?)?.toInt()),
      time:
          DateTime.tryParse(current['time'] as String? ?? '') ?? DateTime.now(),
    );

    final List<HourlyForecast> hourly = _parseHourly(
      json['hourly'] as Map<String, dynamic>?,
    );
    final List<DailyForecast> daily = _parseDaily(
      json['daily'] as Map<String, dynamic>?,
    );

    return WeatherData(
      current: currentWeather,
      hourly: hourly,
      daily: daily,
      fetchedAt: DateTime.now(),
      timezone: timezone,
    );
  }

  static List<HourlyForecast> _parseHourly(Map<String, dynamic>? h) {
    if (h == null) return [];
    final List times = (h['time'] as List?) ?? const [];
    final List temps = (h['temperature_2m'] as List?) ?? const [];
    final List codes = (h['weather_code'] as List?) ?? const [];
    final List pop = (h['precipitation_probability'] as List?) ?? const [];

    final DateTime now = DateTime.now();
    final List<HourlyForecast> out = [];
    for (int i = 0; i < times.length; i++) {
      final DateTime t = DateTime.tryParse(times[i].toString()) ?? now;
      // Keep the next 24 hours from now.
      if (t.isBefore(now.subtract(const Duration(hours: 1)))) continue;
      out.add(
        HourlyForecast(
          time: t,
          temperatureC: i < temps.length
              ? (temps[i] as num?)?.toDouble()
              : null,
          condition: conditionFromCode(
            i < codes.length ? (codes[i] as num?)?.toInt() : null,
          ),
          precipitationProbability: i < pop.length
              ? (pop[i] as num?)?.toInt()
              : null,
        ),
      );
      if (out.length >= 24) break;
    }
    return out;
  }

  static List<DailyForecast> _parseDaily(Map<String, dynamic>? d) {
    if (d == null) return [];
    final List times = (d['time'] as List?) ?? const [];
    final List codes = (d['weather_code'] as List?) ?? const [];
    final List max = (d['temperature_2m_max'] as List?) ?? const [];
    final List min = (d['temperature_2m_min'] as List?) ?? const [];
    final List uv = (d['uv_index_max'] as List?) ?? const [];
    final List psum = (d['precipitation_sum'] as List?) ?? const [];
    final List ppm = (d['precipitation_probability_max'] as List?) ?? const [];

    final List<DailyForecast> out = [];
    for (int i = 0; i < times.length; i++) {
      out.add(
        DailyForecast(
          date: DateTime.tryParse(times[i].toString()) ?? DateTime.now(),
          condition: conditionFromCode(
            i < codes.length ? (codes[i] as num?)?.toInt() : null,
          ),
          maxC: i < max.length ? (max[i] as num?)?.toDouble() : null,
          minC: i < min.length ? (min[i] as num?)?.toDouble() : null,
          uvIndexMax: i < uv.length ? (uv[i] as num?)?.toDouble() : null,
          precipitationSum: i < psum.length
              ? (psum[i] as num?)?.toDouble()
              : null,
          precipitationProbabilityMax: i < ppm.length
              ? (ppm[i] as num?)?.toInt()
              : null,
        ),
      );
    }
    return out;
  }
}

final openMeteoServiceProvider = Provider<OpenMeteoService>(
  (ref) => OpenMeteoService(),
);
