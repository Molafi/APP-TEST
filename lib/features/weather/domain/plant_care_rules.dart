import 'weather_model.dart';

/// Deterministic weather-derived care tips. These run first and always work,
/// even when the AI is unavailable, so weather never blocks on the AI provider.
enum PlantCareTip { highUv, noRain, highHumidity, freezing, hot, mild }

class PlantCareRules {
  const PlantCareRules._();

  /// Computes an ordered, de-duplicated set of tips from [data]. Returns at
  /// least one tip ([PlantCareTip.mild]) so the UI is never empty.
  static List<PlantCareTip> compute(WeatherData data) {
    final tips = <PlantCareTip>[];
    final current = data.current;

    final double? uvToday = data.daily.isNotEmpty
        ? data.daily.first.uvIndexMax
        : current.uvIndex;
    if ((uvToday ?? 0) >= 6) tips.add(PlantCareTip.highUv);

    final double? minToday =
        data.daily.isNotEmpty ? data.daily.first.minC : current.temperatureC;
    if ((minToday ?? 99) <= 0) tips.add(PlantCareTip.freezing);

    if ((current.temperatureC ?? 0) >= 32) tips.add(PlantCareTip.hot);

    if ((current.humidity ?? 0) >= 70) tips.add(PlantCareTip.highHumidity);

    // "No rain expected" over the coming days.
    final bool dryStretch = data.daily.take(5).every((d) =>
        (d.precipitationSum ?? 0) < 0.2 &&
        (d.precipitationProbabilityMax ?? 0) < 20);
    if (data.daily.length >= 3 && dryStretch) tips.add(PlantCareTip.noRain);

    if (tips.isEmpty) tips.add(PlantCareTip.mild);
    return tips;
  }
}
