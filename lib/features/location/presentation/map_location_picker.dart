import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../application/location_provider.dart';
import '../domain/location_model.dart';

/// Default map centre when the user has no selected location yet: the demo
/// coordinates used elsewhere in the app (Amman, Jordan).
const LatLng _kDefaultCentre = LatLng(31.9539, 35.9106);

/// Interactive OpenStreetMap picker. The user pans/zooms the map and taps to
/// drop a pin (or leaves it centred), then confirms to reverse-geocode the
/// coordinates and store them via [LocationController].
///
/// Uses key-free OSM raster tiles so it runs on Android, iOS and Flutter web
/// without an API key, consistent with the app's OSM/Nominatim usage. OSM
/// attribution stays visible per the OSM tile usage policy.
class MapLocationPicker extends ConsumerStatefulWidget {
  const MapLocationPicker({super.key, this.onSelected});

  /// Called after a location has been chosen and applied, so a host bottom
  /// sheet can close itself.
  final VoidCallback? onSelected;

  @override
  ConsumerState<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends ConsumerState<MapLocationPicker> {
  late final MapController _map = MapController();
  late LatLng _pin;
  bool _confirming = false;
  bool _tileError = false;

  @override
  void initState() {
    super.initState();
    final PlantLocation? current = ref.read(selectedLocationProvider);
    _pin = current != null
        ? LatLng(current.latitude, current.longitude)
        : _kDefaultCentre;
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _onTap(TapPosition _, LatLng point) {
    setState(() => _pin = point);
  }

  Future<void> _confirm() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _confirming = true);
    final NavigatorState navigator = Navigator.of(context);
    try {
      await ref
          .read(locationControllerProvider.notifier)
          .selectPinnedLocation(
            lat: _pin.latitude,
            lon: _pin.longitude,
            fallbackCity: l10n.mapDroppedPin,
          );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
    if (!mounted) return;
    widget.onSelected?.call();
    // If hosted in a route (no onSelected close), pop ourselves.
    if (widget.onSelected == null && navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            l10n.mapPickerTitle,
            style: theme.textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter: _pin,
                  initialZoom: 11,
                  minZoom: 2,
                  maxZoom: 18,
                  onTap: _onTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'plantsense_ai',
                    maxZoom: 18,
                    // A blocked or unreachable tile server (common on web
                    // behind strict CORS) must not crash the picker; show a
                    // transparent tile and surface a hint instead.
                    errorTileCallback: (tile, error, stackTrace) {
                      if (!_tileError && mounted) {
                        setState(() => _tileError = true);
                      }
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pin,
                        width: 44,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: Icon(
                          Icons.location_on,
                          size: 44,
                          color: theme.colorScheme.error,
                          semanticLabel: l10n.mapPickerTitle,
                        ),
                      ),
                    ],
                  ),
                  // OSM attribution must remain visible per the tile policy.
                  RichAttributionWidget(
                    attributions: const [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              if (_tileError)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Material(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Text(
                        l10n.geocodeFailed,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton.icon(
            onPressed: _confirming ? null : _confirm,
            icon: _confirming
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(l10n.mapPickerConfirm),
          ),
        ),
      ],
    );
  }
}

/// Opens the map picker as a large modal bottom sheet. [onSelected] is invoked
/// after a location is applied so the caller can close any outer sheet.
Future<void> showMapLocationPicker(
  BuildContext context, {
  VoidCallback? onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final double height = MediaQuery.of(ctx).size.height * 0.85;
      return SizedBox(
        height: height,
        child: MapLocationPicker(
          onSelected: () {
            Navigator.of(ctx).maybePop();
            onSelected?.call();
          },
        ),
      );
    },
  );
}
