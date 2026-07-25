import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../location/application/location_provider.dart';
import '../../../location/presentation/location_selector.dart';
import '../../../profile/application/settings_provider.dart';
import '../../../weather/application/weather_provider.dart';
import '../../../weather/domain/weather_model.dart';
import '../../../weather/presentation/widgets/weather_visuals.dart';
import '../../application/home_provider.dart';

/// Shared app bar: title plus a tappable city label (opens location selector)
/// and a compact current-weather chip (switches to the Weather tab).
class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final location = ref.watch(selectedLocationProvider);
    final WeatherData? weather = ref.watch(currentWeatherDataProvider);
    final unit = ref.watch(unitSystemProvider);
    final String locale = Localizations.localeOf(context).languageCode;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (location != null)
            InkWell(
              onTap: () => showLocationSelector(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place_outlined, size: 14),
                  const SizedBox(width: 2),
                  Text(location.city,
                      style: Theme.of(context).textTheme.bodySmall),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
        ],
      ),
      actions: [
        if (weather?.current.temperatureC != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ActionChip(
              avatar: Icon(
                WeatherVisuals.icon(weather!.current.condition),
                size: 18,
                semanticLabel: WeatherVisuals.label(
                    weather.current.condition, locale),
              ),
              label: Text(
                  TemperatureFormat.format(weather.current.temperatureC, unit)),
              onPressed: () =>
                  ref.read(homeTabProvider.notifier).state = HomeTab.weather,
            ),
          )
        else
          IconButton(
            tooltip: l10n.locationTitle,
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () => showLocationSelector(context),
          ),
      ],
    );
  }
}
