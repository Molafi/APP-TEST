import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/weather_model.dart';
import 'weather_visuals.dart';

class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({
    super.key,
    required this.hours,
    required this.unit,
    required this.locale,
  });

  final List<HourlyForecast> hours;
  final UnitSystem unit;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const SizedBox.shrink();
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(l10n.hourlyForecast,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: hours.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final HourlyForecast h = hours[i];
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormatter.time(h.time, locale),
                          style: Theme.of(context).textTheme.bodySmall),
                      Icon(
                        WeatherVisuals.icon(h.condition),
                        semanticLabel: WeatherVisuals.label(h.condition, locale),
                      ),
                      Text(TemperatureFormat.format(h.temperatureC, unit)),
                      if (h.precipitationProbability != null)
                        Text(l10n.rainChance(h.precipitationProbability!),
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
