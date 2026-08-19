import '../../weather/domain/weather_model.dart';
import 'plant_model.dart';

/// Computes a weather-aware watering cadence for a plant. Deterministic and
/// pure so it is easy to unit test. Weather only shortens/lengthens a sensible
/// baseline; it never invents data when weather is unavailable.
class WateringScheduler {
  const WateringScheduler._();

  /// Returns the recommended number of days until the next watering.
  static int intervalDays(Plant plant, WeatherData? weather) {
    // Baseline by location, or the user's own setting if provided.
    int interval =
        plant.wateringIntervalDays ??
        (plant.place == PlantPlace.outdoor ? 3 : 7);

    if (weather != null) {
      final double? temp = weather.current.temperatureC;
      final int? humidity = weather.current.humidity;

      // Hot and dry → water more often.
      if ((temp ?? 0) >= 30) interval -= 1;
      if ((humidity ?? 100) < 35) interval -= 1;

      // Outdoor plants: meaningful rain in the next days → wait longer.
      if (plant.place == PlantPlace.outdoor && weather.daily.isNotEmpty) {
        final bool rainSoon = weather.daily
            .take(2)
            .any(
              (d) =>
                  (d.precipitationSum ?? 0) >= 3 ||
                  (d.precipitationProbabilityMax ?? 0) >= 60,
            );
        if (rainSoon) interval += 2;
      }
    }

    return interval.clamp(1, 30);
  }

  /// Next watering date/time — defaults to 9:00 AM local on the target day.
  static DateTime nextWatering(
    Plant plant,
    WeatherData? weather, {
    DateTime? from,
  }) {
    final DateTime base = from ?? DateTime.now();
    final int days = intervalDays(plant, weather);
    final DateTime day = base.add(Duration(days: days));
    return DateTime(day.year, day.month, day.day, 9, 0);
  }
}
