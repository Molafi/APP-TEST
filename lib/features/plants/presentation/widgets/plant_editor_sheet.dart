import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/plants_provider.dart';
import '../../domain/plant_model.dart';

/// Opens the add/edit plant sheet. Pass [existing] to edit.
Future<void> showPlantEditor(BuildContext context, {Plant? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _PlantEditor(existing: existing),
    ),
  );
}

class _PlantEditor extends ConsumerStatefulWidget {
  const _PlantEditor({this.existing});
  final Plant? existing;

  @override
  ConsumerState<_PlantEditor> createState() => _PlantEditorState();
}

class _PlantEditorState extends ConsumerState<_PlantEditor> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _species =
      TextEditingController(text: widget.existing?.species ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.existing?.notes ?? '');
  late final TextEditingController _interval = TextEditingController(
      text: widget.existing?.wateringIntervalDays?.toString() ?? '');
  late PlantPlace _place = widget.existing?.place ?? PlantPlace.indoor;

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _notes.dispose();
    _interval.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.reminderPlantName)));
      return;
    }
    await ref.read(plantsControllerProvider.notifier).addOrUpdate(
          existing: widget.existing,
          name: _name.text.trim(),
          species: _species.text.trim().isEmpty ? null : _species.text.trim(),
          place: _place,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          wateringIntervalDays: int.tryParse(_interval.text.trim()),
        );
    if (mounted) await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.existing == null ? l10n.addPlant : l10n.editPlant,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.reminderPlantName),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _species,
            decoration: InputDecoration(labelText: l10n.plantSpecies),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<PlantPlace>(
            initialValue: _place,
            decoration: InputDecoration(labelText: l10n.plantLocation),
            items: [
              DropdownMenuItem(
                  value: PlantPlace.indoor, child: Text(l10n.plantIndoor)),
              DropdownMenuItem(
                  value: PlantPlace.outdoor, child: Text(l10n.plantOutdoor)),
            ],
            onChanged: (v) => setState(() => _place = v ?? _place),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _interval,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.wateringInterval),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.plantNotes),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
