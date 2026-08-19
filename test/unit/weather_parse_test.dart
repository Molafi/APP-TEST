import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/constants/app_constants.dart';
import 'package:plantsense_ai/features/weather/data/open_meteo_service.dart';
import 'package:plantsense_ai/features/weather/domain/weather_model.dart';

void main() {
  group('OpenMeteoService.parse', () {
    test('parses current + daily and maps weather code', () {
      final json = {
        'timezone': 'Asia/Amman',
        'current': {
          'time': '2026-07-25T12:00',
          'temperature_2m': 32.4,
          'apparent_temperature': 34.0,
          'relative_humidity_2m': 45,
          'uv_index': 8.1,
          'precipitation': 0.0,
          'weather_code': 0,
        },
        'hourly': {
          'time': ['2100-01-01T00:00'],
          'temperature_2m': [20.0],
          'weather_code': [61],
          'precipitation_probability': [80],
        },
        'daily': {
          'time': ['2026-07-25'],
          'weather_code': [95],
          'temperature_2m_max': [36.0],
          'temperature_2m_min': [22.0],
          'uv_index_max': [9.0],
          'precipitation_sum': [0.0],
          'precipitation_probability_max': [10],
        },
      };
      final WeatherData data = OpenMeteoService.parse(json);
      expect(data.current.temperatureC, 32.4);
      expect(data.current.humidity, 45);
      expect(data.current.condition, WeatherCondition.clear);
      expect(data.daily.single.condition, WeatherCondition.thunderstorm);
      expect(data.hourly.single.condition, WeatherCondition.rain);
      expect(data.timezone, 'Asia/Amman');
    });

    test('tolerates missing hourly/daily', () {
      final json = {
        'current': {'temperature_2m': 10.0, 'weather_code': 3},
      };
      final WeatherData data = OpenMeteoService.parse(json);
      expect(data.current.condition, WeatherCondition.cloudy);
      expect(data.hourly, isEmpty);
      expect(data.daily, isEmpty);
      expect(data.current.humidity, isNull);
    });
  });

  group('TemperatureFormat', () {
    test(
      'metric',
      () => expect(TemperatureFormat.format(20.4, UnitSystem.metric), '20°C'),
    );
    test(
      'imperial rounds F',
      () => expect(TemperatureFormat.format(0, UnitSystem.imperial), '32°F'),
    );
    test(
      'null',
      () => expect(TemperatureFormat.format(null, UnitSystem.metric), '—'),
    );
  });
}
