import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../location/application/location_provider.dart';
import '../../location/domain/location_model.dart';
import '../application/soil_provider.dart';
import '../domain/soil_model.dart';

/// Land & Soil Insights.
///
/// Shows a satellite view of the user's land plus location-based soil
/// estimates (pH, texture, drainage/water behaviour, fertility) and seasonal
/// guidance. Soil figures are estimates from the SoilGrids global database, not
/// live sensor readings — the user can override pH with a real meter reading.
class LandScreen extends ConsumerWidget {
  const LandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlantLocation? location = ref.watch(selectedLocationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Land & Soil')),
      body: location == null
          ? _NoLocationView(
              onUseMyLocation: () =>
                  ref.read(locationControllerProvider.notifier).useMyLocation(),
            )
          : _LandBody(location: location),
    );
  }
}

class _NoLocationView extends StatelessWidget {
  const _NoLocationView({required this.onUseMyLocation});
  final VoidCallback onUseMyLocation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public,
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSpacing.lg),
            Text('Set your location',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'We use your location to look up the soil beneath your land and '
              'show a satellite view of the area.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onUseMyLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Use my location'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandBody extends ConsumerWidget {
  const _LandBody({required this.location});
  final PlantLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SoilProfile?> soil = ref.watch(soilProfileProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(soilProfileProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _LocationHeader(location: location),
          const SizedBox(height: AppSpacing.md),
          _SatelliteCard(location: location),
          const SizedBox(height: AppSpacing.lg),
          soil.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _ErrorCard(
              onRetry: () => ref.invalidate(soilProfileProvider),
            ),
            data: (profile) {
              if (profile == null || profile.isEmpty) {
                return const _UnavailableCard();
              }
              return _SoilReport(profile: profile);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.location});
  final PlantLocation location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.place, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(location.displayLabel,
              style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

/// Static satellite imagery for the plot, via free Esri World Imagery export.
class _SatelliteCard extends StatelessWidget {
  const _SatelliteCard({required this.location});
  final PlantLocation location;

  String get _imageUrl {
    const double d = 0.02; // ~2 km window
    final double lonMin = location.longitude - d;
    final double lonMax = location.longitude + d;
    final double latMin = location.latitude - d;
    final double latMax = location.latitude + d;
    return 'https://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/export'
        '?bbox=$lonMin,$latMin,$lonMax,$latMax'
        '&bboxSR=4326&imageSR=4326&size=640,400&format=jpg&f=image';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 640 / 400,
            child: Image.network(
              _imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, _, __) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text('Satellite image unavailable offline',
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text('Satellite view of your land (≈2 km across)',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SoilReport extends ConsumerWidget {
  const _SoilReport({required this.profile});
  final SoilProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SoilLayer? top = profile.topsoil;
    final double? manualPh = ref.watch(manualPhProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PhCard(profile: profile, manualPh: manualPh),
        const SizedBox(height: AppSpacing.md),
        if (top != null) _TextureCard(layer: top),
        const SizedBox(height: AppSpacing.md),
        if (top != null) _WaterCard(layer: top),
        const SizedBox(height: AppSpacing.md),
        if (top != null) _FertilityCard(layer: top),
        const SizedBox(height: AppSpacing.md),
        _LayersCard(profile: profile),
        const SizedBox(height: AppSpacing.md),
        _SeasonCard(profile: profile),
        const SizedBox(height: AppSpacing.md),
        const _DisclaimerText(),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _PhCard extends ConsumerWidget {
  const _PhCard({required this.profile, required this.manualPh});
  final SoilProfile profile;
  final double? manualPh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double? estimate = profile.topsoilPh;
    final double? shown = manualPh ?? estimate;
    final PhCategory? category = profile.phCategory;

    return _SectionCard(
      icon: Icons.science_outlined,
      title: 'Soil pH',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                shown != null ? shown.toStringAsFixed(1) : '—',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (category != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Chip(label: Text(category.label)),
                ),
            ],
          ),
          if (manualPh != null && estimate != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Your reading (database estimate: ${estimate.toStringAsFixed(1)})',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: AppSpacing.md),
          if (shown != null) _PhScale(ph: shown),
          const SizedBox(height: AppSpacing.md),
          Text(_advice(category),
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _enterReading(context, ref),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(manualPh == null
                  ? 'Enter my meter reading'
                  : 'Edit / clear my reading'),
            ),
          ),
        ],
      ),
    );
  }

  String _advice(PhCategory? c) {
    switch (c) {
      case PhCategory.veryAcidic:
      case PhCategory.acidic:
        return 'Acidic soil. Great for blueberries, azaleas and camellias. '
            'Add garden lime to raise pH for most vegetables.';
      case PhCategory.slightlyAcidic:
        return 'Slightly acidic — ideal for the widest range of plants and '
            'good nutrient availability.';
      case PhCategory.neutral:
        return 'Neutral soil suits most vegetables, herbs and lawns.';
      case PhCategory.alkaline:
        return 'Alkaline soil. Good for lavender and lilac. Add compost or '
            'elemental sulphur to lower pH for acid-loving plants.';
      case null:
        return 'pH estimate unavailable for this location.';
    }
  }

  Future<void> _enterReading(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: manualPh?.toStringAsFixed(1) ?? '',
    );
    final double? result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Soil pH reading'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'pH (3.5 – 10)',
            hintText: 'e.g. 6.5',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, -1.0), // sentinel: clear
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return; // cancelled
    if (result < 0) {
      await ref.read(manualPhProvider.notifier).set(null);
      return;
    }
    final clamped = result.clamp(3.5, 10.0);
    await ref.read(manualPhProvider.notifier).set(clamped.toDouble());
  }
}

/// Horizontal acidity→alkalinity scale with a marker at the current pH.
class _PhScale extends StatelessWidget {
  const _PhScale({required this.ph});
  final double ph;

  @override
  Widget build(BuildContext context) {
    final double t = ((ph - 3.5) / (10 - 3.5)).clamp(0.0, 1.0);
    final double alignX = t * 2 - 1;
    return Column(
      children: [
        SizedBox(
          height: 18,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE53935), // acidic (red)
                      Color(0xFF43A047), // neutral (green)
                      Color(0xFF1E88E5), // alkaline (blue)
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment(alignX, 0),
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Acidic', style: TextStyle(fontSize: 11)),
            Text('Neutral', style: TextStyle(fontSize: 11)),
            Text('Alkaline', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _TextureCard extends StatelessWidget {
  const _TextureCard({required this.layer});
  final SoilLayer layer;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.grain,
      title: 'Soil texture (topsoil)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(layer.textureClass,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: AppSpacing.sm),
          _CompositionBar(
            clay: layer.clayPct,
            sand: layer.sandPct,
            silt: layer.siltPct,
          ),
        ],
      ),
    );
  }
}

class _CompositionBar extends StatelessWidget {
  const _CompositionBar({this.clay, this.sand, this.silt});
  final double? clay;
  final double? sand;
  final double? silt;

  @override
  Widget build(BuildContext context) {
    final double c = clay ?? 0;
    final double s = sand ?? 0;
    final double si = silt ?? 0;
    final double total = (c + s + si);
    if (total <= 0) {
      return const Text('Composition unavailable');
    }
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              Expanded(
                flex: (s * 10).round().clamp(1, 100000),
                child: Container(height: 16, color: const Color(0xFFD7A86E)),
              ),
              Expanded(
                flex: (si * 10).round().clamp(1, 100000),
                child: Container(height: 16, color: const Color(0xFF9CCC65)),
              ),
              Expanded(
                flex: (c * 10).round().clamp(1, 100000),
                child: Container(height: 16, color: const Color(0xFF8D6E63)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: AppSpacing.md,
          children: [
            _legend(const Color(0xFFD7A86E), 'Sand ${s.round()}%'),
            _legend(const Color(0xFF9CCC65), 'Silt ${si.round()}%'),
            _legend(const Color(0xFF8D6E63), 'Clay ${c.round()}%'),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}

class _WaterCard extends StatelessWidget {
  const _WaterCard({required this.layer});
  final SoilLayer layer;

  @override
  Widget build(BuildContext context) {
    final SoilDrainage drainage = layer.drainage;
    final double? water = layer.waterContentPct;
    return _SectionCard(
      icon: Icons.water_drop_outlined,
      title: 'Water & drainage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(drainage.label,
              style: Theme.of(context).textTheme.titleMedium),
          if (water != null) ...[
            const SizedBox(height: 4),
            Text('Holds ~${water.round()}% water at field capacity',
                style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(drainage.wateringHint,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _FertilityCard extends StatelessWidget {
  const _FertilityCard({required this.layer});
  final SoilLayer layer;

  @override
  Widget build(BuildContext context) {
    final double? soc = layer.socGkg;
    final double? n = layer.nitrogenGkg;
    final double? bd = layer.bulkDensity;
    return _SectionCard(
      icon: Icons.eco_outlined,
      title: 'Fertility & structure',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (soc != null)
            _row('Organic carbon', '${soc.toStringAsFixed(1)} g/kg',
                _socNote(soc)),
          if (n != null)
            _row('Nitrogen', '${n.toStringAsFixed(1)} g/kg', ''),
          if (bd != null)
            _row('Bulk density', '${bd.toStringAsFixed(2)} kg/dm³',
                bd > 1.6 ? 'Compacted — consider aerating' : 'Good structure'),
          if (soc == null && n == null && bd == null)
            const Text('Fertility data unavailable for this location.'),
        ],
      ),
    );
  }

  String _socNote(double soc) {
    if (soc < 10) return 'Low organic matter — add compost';
    if (soc < 20) return 'Moderate organic matter';
    return 'Rich in organic matter';
  }

  Widget _row(String label, String value, String note) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: Text(label)),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (note.isNotEmpty)
                    Text(note, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _LayersCard extends StatelessWidget {
  const _LayersCard({required this.profile});
  final SoilProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.layers_outlined,
      title: 'Soil layers by depth',
      child: Column(
        children: [
          for (final layer in profile.layers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(layer.displayDepth,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text(
                      '${layer.textureClass}'
                      '${layer.phH2o != null ? ' · pH ${layer.phH2o!.toStringAsFixed(1)}' : ''}',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.profile});
  final SoilProfile profile;

  @override
  Widget build(BuildContext context) {
    final int month = DateTime.now().month;
    final String season = _season(month, profile.isNorthernHemisphere);
    return _SectionCard(
      icon: Icons.calendar_month_outlined,
      title: 'This season · $season',
      child: Text(_tips(season)),
    );
  }

  String _season(int month, bool north) {
    // Meteorological seasons.
    final bool isWinter = month == 12 || month <= 2;
    final bool isSpring = month >= 3 && month <= 5;
    final bool isSummer = month >= 6 && month <= 8;
    String northSeason;
    if (isWinter) {
      northSeason = 'Winter';
    } else if (isSpring) {
      northSeason = 'Spring';
    } else if (isSummer) {
      northSeason = 'Summer';
    } else {
      northSeason = 'Autumn';
    }
    if (north) return northSeason;
    // Flip for southern hemisphere.
    return const {
      'Winter': 'Summer',
      'Spring': 'Autumn',
      'Summer': 'Winter',
      'Autumn': 'Spring',
    }[northSeason]!;
  }

  String _tips(String season) {
    switch (season) {
      case 'Spring':
        return 'Prime planting time. Prepare beds, add compost, and start '
            'watering as growth accelerates. Watch for late frosts.';
      case 'Summer':
        return 'Peak watering season. Water early morning or evening, mulch to '
            'retain moisture, and feed hungry crops every 2–3 weeks.';
      case 'Autumn':
        return 'Harvest and plant cover crops or bulbs. Reduce watering as '
            'temperatures drop, and add organic matter for next year.';
      case 'Winter':
      default:
        return 'Growth slows. Water sparingly, protect roots from frost with '
            'mulch, and plan next season\'s layout.';
    }
  }
}

class _DisclaimerText extends StatelessWidget {
  const _DisclaimerText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Soil figures are location estimates from the SoilGrids (ISRIC) global '
      'database, not live sensor readings. For precise results, use a soil test '
      'kit and enter your pH above.',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Text("Couldn't load soil data. Check your connection."),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'No soil data is available for this exact spot (it may be over water '
          'or a built-up area). Try a nearby location.',
        ),
      ),
    );
  }
}
