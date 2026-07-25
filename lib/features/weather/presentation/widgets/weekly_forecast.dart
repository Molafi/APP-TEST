import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/weather_model.dart';
import 'weather_visuals.dart';

class WeeklyForecastList extends StatelessWidget {
  const WeeklyForecastList({
    super.key,
    required this.days,
    required this.unit,
    required this.locale,
  });

  final List<DailyForecast> days;
  final UnitSystem unit;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(l10n.sevenDayForecast,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Column(
            children: [
              for (final DailyForecast d in days)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(DateFormatter.dayAndDate(d.date, locale)),
                      ),
                      Icon(
                        WeatherVisuals.icon(d.condition),
                        semanticLabel: WeatherVisuals.label(d.condition, locale),
                      ),
                      const Spacer(),
                      if (d.precipitationProbabilityMax != null)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: Row(
                            children: [
                              const Icon(Icons.water_drop_outlined, size: 14),
                              Text('${d.precipitationProbabilityMax}%',
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      Text(
                        '${TemperatureFormat.format(d.minC, unit)} / ${TemperatureFormat.format(d.maxC, unit)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
