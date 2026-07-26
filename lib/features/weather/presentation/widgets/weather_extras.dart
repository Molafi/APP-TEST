import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../soil/presentation/land_screen.dart';
import '../../domain/weather_model.dart';

/// Current-season badge, hemisphere-aware (uses the plot latitude).
class SeasonCard extends StatelessWidget {
  const SeasonCard({super.key, this.latitude});
  final double? latitude;

  @override
  Widget build(BuildContext context) {
    final _Season s = _seasonFor(latitude, DateTime.now().month);
    return Card(
      child: ListTile(
        leading: Text(s.emoji, style: const TextStyle(fontSize: 28)),
        title: Text('Season · ${s.name}',
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(s.tip),
      ),
    );
  }

  static _Season _seasonFor(double? lat, int month) {
    final bool north = (lat ?? 0) >= 0;
    String base;
    if (month == 12 || month <= 2) {
      base = 'Winter';
    } else if (month <= 5) {
      base = 'Spring';
    } else if (month <= 8) {
      base = 'Summer';
    } else {
      base = 'Autumn';
    }
    if (!north) {
      base = const {
        'Winter': 'Summer',
        'Spring': 'Autumn',
        'Summer': 'Winter',
        'Autumn': 'Spring',
      }[base]!;
    }
    switch (base) {
      case 'Spring':
        return const _Season(
            'Spring', '🌱', 'Planting season — feed and repot as growth starts.');
      case 'Summer':
        return const _Season('Summer', '☀️',
            'Peak watering — water early or late and mulch to hold moisture.');
      case 'Autumn':
        return const _Season('Autumn', '🍂',
            'Harvest and plant bulbs; ease off watering as it cools.');
      case 'Winter':
      default:
        return const _Season('Winter', '❄️',
            'Growth slows — water sparingly and protect roots from frost.');
    }
  }
}

class _Season {
  const _Season(this.name, this.emoji, this.tip);
  final String name;
  final String emoji;
  final String tip;
}

/// A compact "today" summary from the first daily forecast entry.
class TodayGlanceCard extends StatelessWidget {
  const TodayGlanceCard({super.key, required this.today, required this.unit});
  final DailyForecast? today;
  final UnitSystem unit;

  @override
  Widget build(BuildContext context) {
    final DailyForecast? d = today;
    if (d == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today at a glance',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.sm,
              children: [
                _stat(context, Icons.thermostat, 'High',
                    TemperatureFormat.format(d.maxC, unit)),
                _stat(context, Icons.ac_unit, 'Low',
                    TemperatureFormat.format(d.minC, unit)),
                if (d.precipitationProbabilityMax != null)
                  _stat(context, Icons.umbrella, 'Rain',
                      '${d.precipitationProbabilityMax}%'),
                if (d.uvIndexMax != null)
                  _stat(context, Icons.wb_sunny_outlined, 'UV max',
                      d.uvIndexMax!.toStringAsFixed(0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// A simple "should I water today?" recommendation from rain + UV.
class WateringCallCard extends StatelessWidget {
  const WateringCallCard({super.key, required this.data});
  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    final double rainToday = data.daily.isNotEmpty
        ? (data.daily.first.precipitationSum ?? 0)
        : (data.current.precipitation ?? 0);
    final int rainChance = data.daily.isNotEmpty
        ? (data.daily.first.precipitationProbabilityMax ?? 0)
        : 0;

    final String message;
    final IconData icon;
    if (rainToday >= 3 || rainChance >= 70) {
      icon = Icons.umbrella;
      message = 'Rain is likely today — you can probably skip watering outdoor '
          'plants.';
    } else if ((data.current.uvIndex ?? 0) >= 6) {
      icon = Icons.local_fire_department_outlined;
      message = 'Hot and dry with high UV — check soil moisture and water in '
          'the early morning or evening.';
    } else {
      icon = Icons.water_drop_outlined;
      message = 'Dry conditions — water plants whose top few cm of soil feel '
          'dry.';
    }

    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: const Text("Today's watering"),
        subtitle: Text(message),
      ),
    );
  }
}

/// Shortcut into the Land & Soil insights screen.
class LandShortcutCard extends StatelessWidget {
  const LandShortcutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.terrain_outlined,
            color: Theme.of(context).colorScheme.primary),
        title: const Text('Land & Soil'),
        subtitle: const Text('Soil pH, texture, drainage & satellite view'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LandScreen()),
        ),
      ),
    );
  }
}
