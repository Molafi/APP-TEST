import 'package:flutter/material.dart';

import '../../domain/weather_model.dart';

/// Maps a [WeatherCondition] to an accessible icon and a localized description.
/// Descriptions are short and paired with the icon's semantic label so screen
/// readers announce the condition.
class WeatherVisuals {
  const WeatherVisuals._();

  static IconData icon(WeatherCondition c) => switch (c) {
    WeatherCondition.clear => Icons.wb_sunny,
    WeatherCondition.partlyCloudy => Icons.wb_cloudy_outlined,
    WeatherCondition.cloudy => Icons.cloud,
    WeatherCondition.fog => Icons.foggy,
    WeatherCondition.drizzle => Icons.grain,
    WeatherCondition.rain => Icons.water_drop,
    WeatherCondition.snow => Icons.ac_unit,
    WeatherCondition.thunderstorm => Icons.thunderstorm,
    WeatherCondition.unknown => Icons.help_outline,
  };

  /// Localized description. Uses simple English/Arabic labels; extend via ARB
  /// if finer-grained descriptions are needed.
  static String label(WeatherCondition c, String locale) {
    final bool ar = locale == 'ar';
    return switch (c) {
      WeatherCondition.clear => ar ? 'صحو' : 'Clear',
      WeatherCondition.partlyCloudy => ar ? 'غائم جزئيًا' : 'Partly cloudy',
      WeatherCondition.cloudy => ar ? 'غائم' : 'Cloudy',
      WeatherCondition.fog => ar ? 'ضباب' : 'Fog',
      WeatherCondition.drizzle => ar ? 'رذاذ' : 'Drizzle',
      WeatherCondition.rain => ar ? 'مطر' : 'Rain',
      WeatherCondition.snow => ar ? 'ثلج' : 'Snow',
      WeatherCondition.thunderstorm => ar ? 'عاصفة رعدية' : 'Thunderstorm',
      WeatherCondition.unknown => ar ? 'غير معروف' : 'Unknown',
    };
  }
}
