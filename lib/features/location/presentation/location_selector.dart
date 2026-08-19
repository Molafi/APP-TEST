import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../l10n/app_localizations.dart';
import '../application/location_provider.dart';
import '../domain/location_model.dart';

/// Reusable location picker: "Use my location" plus debounced city search with
/// manual fallback. Handles denied / permanently-denied / services-off states.
class LocationSelector extends ConsumerStatefulWidget {
  const LocationSelector({super.key, this.onSelected});

  /// Called after a location is chosen (e.g. to close a bottom sheet).
  final VoidCallback? onSelected;

  @override
  ConsumerState<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<LocationSelector> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LocationState state = ref.watch(locationControllerProvider);
    final LocationController controller = ref.read(
      locationControllerProvider.notifier,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.selectCity, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.locationRationale,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: state.status == LocationStatus.locating
                ? null
                : () async {
                    await controller.useMyLocation();
                    if (ref.read(locationControllerProvider).status ==
                        LocationStatus.ready) {
                      widget.onSelected?.call();
                    }
                  },
            icon: state.status == LocationStatus.locating
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(l10n.useMyLocation),
          ),
          if (state.status == LocationStatus.permanentlyDenied ||
              state.status == LocationStatus.servicesDisabled ||
              state.status == LocationStatus.denied ||
              state.status == LocationStatus.error)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                state.error != null
                    ? ErrorMapper.message(l10n, state.error!)
                    : l10n.locationDeniedBody,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const Divider(height: AppSpacing.xl),
          TextField(
            controller: _search,
            onChanged: controller.search,
            decoration: InputDecoration(
              hintText: l10n.searchCity,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_search.text.trim().length >= 2 &&
              !state.searching &&
              state.searchResults.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(l10n.noResults),
            ),
          for (final PlantLocation loc in state.searchResults)
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(loc.city),
              subtitle: loc.country != null ? Text(loc.country!) : null,
              onTap: () {
                controller.selectManual(loc);
                widget.onSelected?.call();
              },
            ),
        ],
      ),
    );
  }
}

/// Opens the selector in a modal bottom sheet.
Future<void> showLocationSelector(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: LocationSelector(onSelected: () => Navigator.of(ctx).maybePop()),
    ),
  );
}
