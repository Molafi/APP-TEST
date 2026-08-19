import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../location/application/location_provider.dart';
import '../../location/presentation/location_selector.dart';
import '../../profile/application/settings_provider.dart';
import '../application/weather_provider.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/hourly_forecast.dart';
import 'widgets/plant_care_tips.dart';
import 'widgets/weekly_forecast.dart';

/// Weather tab body. Pull-to-refresh, cached fallback, unit-aware, and a
/// no-location empty state offering GPS or manual city selection.
class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final WeatherState state = ref.watch(weatherControllerProvider);
    final location = ref.watch(selectedLocationProvider);
    final unit = ref.watch(unitSystemProvider);
    final String locale = Localizations.localeOf(context).languageCode;

    // No location chosen yet.
    if (location == null && state.data == null) {
      return AppEmptyView(
        icon: Icons.location_on_outlined,
        title: l10n.locationTitle,
        message: l10n.locationRationale,
        action: FilledButton.icon(
          onPressed: () => showLocationSelector(context),
          icon: const Icon(Icons.my_location),
          label: Text(l10n.useMyLocation),
        ),
      );
    }

    if (state.loading && state.data == null) {
      return AppLoadingView(label: l10n.loading);
    }

    if (state.data == null && state.error != null) {
      return AppErrorView(
        error: state.error!,
        onRetry: () => ref.read(weatherControllerProvider.notifier).refresh(),
      );
    }

    final data = state.data;
    if (data == null) {
      return AppEmptyView(
        icon: Icons.cloud_off,
        title: l10n.weatherUnavailable,
        action: FilledButton(
          onPressed: () =>
              ref.read(weatherControllerProvider.notifier).refresh(),
          child: Text(l10n.retry),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(weatherControllerProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          CurrentWeatherCard(
            data: data,
            unit: unit,
            locale: locale,
            city: location?.displayLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          PlantCareTipsCard(tips: state.tips),
          const SizedBox(height: AppSpacing.md),
          HourlyForecastStrip(hours: data.hourly, unit: unit, locale: locale),
          const SizedBox(height: AppSpacing.lg),
          WeeklyForecastList(days: data.daily, unit: unit, locale: locale),
        ],
      ),
    );
  }
}
