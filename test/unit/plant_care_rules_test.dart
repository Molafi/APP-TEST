import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/weather/domain/plant_care_rules.dart';
import 'package:plantsense_ai/features/weather/domain/weather_model.dart';

WeatherData _build({
  double? temp,
  int? humidity,
  double? uvMax,
  double? minC,
  double precipSum = 5,
  int precipProb = 60,
}) {
  return WeatherData(
    current: CurrentWeather(
      temperatureC: temp,
      apparentTemperatureC: temp,
      humidity: humidity,
      uvIndex: uvMax,
      precipitation: 0,
      condition: WeatherCondition.clear,
      time: DateTime(2026, 7, 25),
    ),
    hourly: const [],
    daily: List.generate(
      5,
      (_) => DailyForecast(
        date: DateTime(2026, 7, 25),
        minC: minC,
        maxC: temp,
        condition: WeatherCondition.clear,
        precipitationSum: precipSum,
        uvIndexMax: uvMax,
        precipitationProbabilityMax: precipProb,
      ),
    ),
    fetchedAt: DateTime(2026, 7, 25),
    timezone: 'UTC',
  );
}

void main() {
  test('high UV triggers highUv tip', () {
    final tips = PlantCareRules.compute(_build(uvMax: 8));
    expect(tips, contains(PlantCareTip.highUv));
  });

  test('freezing triggers freezing tip', () {
    final tips = PlantCareRules.compute(_build(minC: -2));
    expect(tips, contains(PlantCareTip.freezing));
  });

  test('hot triggers hot tip', () {
    final tips = PlantCareRules.compute(_build(temp: 35));
    expect(tips, contains(PlantCareTip.hot));
  });

  test('high humidity triggers tip', () {
    final tips = PlantCareRules.compute(_build(humidity: 80));
    expect(tips, contains(PlantCareTip.highHumidity));
  });

  test('dry stretch triggers noRain tip', () {
    final tips =
        PlantCareRules.compute(_build(precipSum: 0, precipProb: 5));
    expect(tips, contains(PlantCareTip.noRain));
  });

  test('mild fallback when nothing notable', () {
    final tips = PlantCareRules.compute(
        _build(temp: 20, humidity: 40, uvMax: 3, minC: 12));
    expect(tips, contains(PlantCareTip.mild));
  });
}
