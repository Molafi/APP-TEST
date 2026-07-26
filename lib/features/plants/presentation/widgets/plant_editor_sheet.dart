import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../reminders/application/reminder_provider.dart';
import '../../../reminders/domain/reminder_model.dart';
import '../../application/plants_provider.dart';
import '../../domain/plant_model.dart';

/// Opens the add/edit plant sheet.
///
/// - Pass [existing] to edit an existing plant.
/// - Pass [prefill] to pre-populate the fields for a brand-new plant (e.g. from
///   the AI photo scan). A [prefill] plant is NOT treated as existing, so
///   saving creates a new record and schedules its first watering reminder.
Future<void> showPlantEditor(
  BuildContext context, {
  Plant? existing,
  Plant? prefill,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _PlantEditor(existing: existing, prefill: prefill),
    ),
  );
}

class _PlantEditor extends ConsumerStatefulWidget {
  const _PlantEditor({this.existing, this.prefill});
  final Plant? existing;
  final Plant? prefill;

  @override
  ConsumerState<_PlantEditor> createState() => _PlantEditorState();
}

class _PlantEditorState extends ConsumerState<_PlantEditor> {
  Plant? get _seed => widget.existing ?? widget.prefill;

  late final TextEditingController _name =
      TextEditingController(text: _seed?.name ?? '');
  late final TextEditingController _species =
      TextEditingController(text: _seed?.species ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: _seed?.notes ?? '');
  late final TextEditingController _interval = TextEditingController(
      text: _seed?.wateringIntervalDays?.toString() ?? '');
  late PlantPlace _place = _seed?.place ?? PlantPlace.indoor;

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
    final int? interval = int.tryParse(_interval.text.trim());
    final Plant saved =
        await ref.read(plantsControllerProvider.notifier).addOrUpdate(
              existing: widget.existing,
              name: _name.text.trim(),
              species:
                  _species.text.trim().isEmpty ? null : _species.text.trim(),
              place: _place,
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              wateringIntervalDays: interval,
            );

    // For a newly added plant with a watering cadence, auto-schedule the first
    // watering reminder. Failures (e.g. no notification permission) must not
    // block saving the plant.
    bool reminderSet = false;
    if (widget.existing == null && interval != null && interval > 0) {
      try {
        await ref.read(reminderControllerProvider.notifier).add(
              plantName: saved.name,
              type: ReminderType.watering,
              note: 'Water your ${saved.name}',
              scheduledAt: DateTime.now().add(Duration(days: interval)),
              recurrence: interval <= 1 ? Recurrence.daily : Recurrence.none,
            );
        reminderSet = true;
      } catch (_) {
        // Ignore reminder scheduling errors.
      }
    }

    if (!mounted) return;
    await Navigator.of(context).maybePop();
    if (reminderSet && mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
            content: Text('Reminder set to water ${saved.name} in '
                '$interval day${interval == 1 ? '' : 's'}.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool fromScan = widget.existing == null && widget.prefill != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.existing == null ? l10n.addPlant : l10n.editPlant,
              style: Theme.of(context).textTheme.titleLarge),
          if (fromScan) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'AI-filled from your photo — review and edit before saving.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
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
