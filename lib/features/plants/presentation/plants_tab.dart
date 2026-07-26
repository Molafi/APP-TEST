import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/services/ai_gateway.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/utils/image_compressor.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/plants_provider.dart';
import '../data/plant_identify_service.dart';
import '../domain/plant_model.dart';
import 'plant_detail_screen.dart';
import 'widgets/plant_editor_sheet.dart';

/// Body-only "My Plants" view for the home bottom-navigation tab (the home
/// shell already provides the Scaffold + app bar). Offers manual add and an
/// AI "scan a plant" flow that fills the editor from a photo.
class PlantsTab extends ConsumerWidget {
  const PlantsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PlantsState state = ref.watch(plantsControllerProvider);

    if (state.isLoading) return const AppLoadingView();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _scanPlant(context, ref),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Scan plant (AI)'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showPlantEditor(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addPlant),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isEmpty
              ? _EmptyPlants(onScan: () => _scanPlant(context, ref))
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: state.plants.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final Plant p = state.plants[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(p.name.isNotEmpty
                            ? p.name.characters.first.toUpperCase()
                            : '🌿'),
                      ),
                      title: Text(p.name),
                      subtitle: Text([
                        if (p.species != null && p.species!.isNotEmpty)
                          p.species!,
                        p.place == PlantPlace.outdoor
                            ? l10n.plantOutdoor
                            : l10n.plantIndoor,
                      ].join(' · ')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlantDetailScreen(plantId: p.id),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Takes a photo, asks the AI to identify the plant, then opens the editor
  /// pre-filled for review.
  Future<void> _scanPlant(BuildContext context, WidgetRef ref) async {
    final XFile? file = await _pickImage(context);
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();

    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AnalyzingDialog(),
    );

    try {
      final PreparedImage prepared =
          await const ImageCompressor().prepare(bytes);
      final String locale = ref.read(localeProvider)?.languageCode ?? 'en';
      final PlantIdentification id =
          await ref.read(plantIdentifyServiceProvider).identify(
                locale: locale,
                image: AiImage(
                    base64: prepared.base64, mimeType: prepared.mimeType),
              );

      if (context.mounted) Navigator.of(context).pop(); // close dialog
      if (!context.mounted) return;

      if (!id.isPlant) {
        _snack(context, 'No plant detected in that photo. Try another.');
        return;
      }

      await showPlantEditor(
        context,
        prefill: Plant(
          id: '',
          name: id.name ?? '',
          species: id.species,
          place: plantPlaceFrom(id.place),
          notes: id.notes,
          wateringIntervalDays: id.wateringIntervalDays,
        ),
      );
    } catch (_) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        _snack(context, 'Could not analyze the photo. Please try again.');
      }
    }
  }

  Future<XFile?> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;
    return picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _EmptyPlants extends StatelessWidget {
  const _EmptyPlants({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_florist_outlined,
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.plantsEmpty,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Snap a photo and let AI identify your plant and set up its care.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Scan a plant'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyzingDialog extends StatelessWidget {
  const _AnalyzingDialog();

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: AppSpacing.lg),
          Expanded(child: Text('Identifying your plant…')),
        ],
      ),
    );
  }
}
