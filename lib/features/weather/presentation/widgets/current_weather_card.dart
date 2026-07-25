import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/weather_model.dart';
import 'weather_visuals.dart';

class CurrentWeatherCard extends StatelessWidget {
  const CurrentWeatherCard({
    super.key,
    required this.data,
    required this.unit,
    required this.locale,
    this.city,
  });

  final WeatherData data;
  final UnitSystem unit;
  final String locale;
  final String? city;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CurrentWeather c = data.current;
    final String condition = WeatherVisuals.label(c.condition, locale);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    city ?? l10n.currentWeather,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _Provenance(data: data, locale: locale, l10n: l10n),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  WeatherVisuals.icon(c.condition),
                  size: 56,
                  semanticLabel: l10n.a11yWeatherIcon(condition),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TemperatureFormat.format(c.temperatureC, unit),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text(condition),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              children: [
                _Metric(
                  icon: Icons.thermostat,
                  label: l10n.feelsLike(
                      TemperatureFormat.format(c.apparentTemperatureC, unit)),
                ),
                if (c.humidity != null)
                  _Metric(icon: Icons.water_drop_outlined, label: '${l10n.humidity}: ${c.humidity}%'),
                if (c.uvIndex != null)
                  _Metric(icon: Icons.wb_sunny_outlined, label: '${l10n.uvIndex}: ${c.uvIndex!.toStringAsFixed(1)}'),
                if (c.precipitation != null)
                  _Metric(icon: Icons.umbrella_outlined, label: '${l10n.precipitation}: ${c.precipitation} mm'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.xs),
        Text(label),
      ],
    );
  }
}

class _Provenance extends StatelessWidget {
  const _Provenance({required this.data, required this.locale, required this.l10n});
  final WeatherData data;
  final String locale;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.fromCache ? Icons.cloud_off : Icons.cloud_done,
                size: 14),
            const SizedBox(width: 2),
            Text(data.fromCache ? l10n.cachedData : l10n.liveData,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Text(
          l10n.lastUpdated(
              DateFormatter.relativeUpdated(data.fetchedAt, locale)),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
