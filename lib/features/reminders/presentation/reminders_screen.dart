import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/application/settings_provider.dart';
import '../application/reminder_provider.dart';
import '../domain/reminder_model.dart';
import 'reminder_body_text.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Reminder> reminders = ref.watch(reminderControllerProvider);
    final String locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref, null),
        icon: const Icon(Icons.add_alarm),
        label: Text(l10n.addReminder),
      ),
      body: reminders.isEmpty
          ? AppEmptyView(
              icon: Icons.notifications_none,
              title: l10n.remindersEmpty,
              message: l10n.remindersEmptyBody,
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final Reminder r = reminders[i];
                return ListTile(
                  leading: Icon(_typeIcon(r.type)),
                  title: Text(r.plantName),
                  subtitle: Text(
                    '${_typeLabel(l10n, r.type)} · '
                    '${DateFormatter.dayAndDate(r.scheduledAt, locale)}'
                    '${r.recurrence != Recurrence.none ? ' · ${_recurrenceLabel(l10n, r.recurrence)}' : ''}'
                    '${r.enabled ? '' : ' · ${l10n.reminderPaused}'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: r.enabled
                            ? l10n.reminderPause
                            : l10n.reminderResume,
                        icon: Icon(
                          r.enabled
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                        ),
                        onPressed: () => ref
                            .read(reminderControllerProvider.notifier)
                            .update(
                              r.copyWith(enabled: !r.enabled),
                              localizedBody: reminderDefaultBody(l10n, r.type),
                            ),
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(reminderControllerProvider.notifier)
                            .remove(r),
                      ),
                    ],
                  ),
                  onTap: () => _openEditor(context, ref, r),
                );
              },
            ),
    );
  }

  IconData _typeIcon(ReminderType t) => switch (t) {
    ReminderType.watering => Icons.water_drop_outlined,
    ReminderType.fertilizing => Icons.spa_outlined,
    ReminderType.repotting => Icons.yard_outlined,
    ReminderType.inspection => Icons.search,
    ReminderType.followUp => Icons.chat_outlined,
  };

  String _typeLabel(AppLocalizations l10n, ReminderType t) => switch (t) {
    ReminderType.watering => l10n.reminderWatering,
    ReminderType.fertilizing => l10n.reminderFertilizing,
    ReminderType.repotting => l10n.reminderRepotting,
    ReminderType.inspection => l10n.reminderInspection,
    ReminderType.followUp => l10n.reminderFollowUp,
  };

  String _recurrenceLabel(AppLocalizations l10n, Recurrence r) => switch (r) {
    Recurrence.none => l10n.recurrenceNone,
    Recurrence.daily => l10n.recurrenceDaily,
    Recurrence.weekly => l10n.recurrenceWeekly,
  };

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    Reminder? existing,
  ) async {
    // Ask for notification permission the first time reminders are used.
    if (existing == null && !ref.read(notificationsEnabledProvider)) {
      final outcome = await ref
          .read(permissionServiceProvider)
          .requestNotifications();
      await ref
          .read(notificationsEnabledProvider.notifier)
          .set(outcome == PermissionOutcome.granted);
    }
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _ReminderEditor(existing: existing),
      ),
    );
  }
}

class _ReminderEditor extends ConsumerStatefulWidget {
  const _ReminderEditor({this.existing});
  final Reminder? existing;

  @override
  ConsumerState<_ReminderEditor> createState() => _ReminderEditorState();
}

class _ReminderEditorState extends ConsumerState<_ReminderEditor> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.plantName ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.existing?.note ?? '',
  );
  late ReminderType _type = widget.existing?.type ?? ReminderType.watering;
  late Recurrence _recurrence = widget.existing?.recurrence ?? Recurrence.none;
  late DateTime _when =
      widget.existing?.scheduledAt ??
      DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (time == null) return;
    setState(
      () => _when = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.reminderPlantName)));
      return;
    }
    final controller = ref.read(reminderControllerProvider.notifier);
    if (widget.existing == null) {
      await controller.add(
        plantName: _name.text.trim(),
        type: _type,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        scheduledAt: _when,
        recurrence: _recurrence,
        localizedBody: reminderDefaultBody(l10n, _type),
      );
    } else {
      await controller.update(
        widget.existing!.copyWith(
          plantName: _name.text.trim(),
          type: _type,
          note: _note.text.trim(),
          scheduledAt: _when,
          recurrence: _recurrence,
        ),
        localizedBody: reminderDefaultBody(l10n, _type),
      );
    }
    if (mounted) await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).languageCode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addReminder, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.reminderPlantName),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<ReminderType>(
            initialValue: _type,
            decoration: InputDecoration(labelText: l10n.reminderType),
            items: [
              DropdownMenuItem(
                value: ReminderType.watering,
                child: Text(l10n.reminderWatering),
              ),
              DropdownMenuItem(
                value: ReminderType.fertilizing,
                child: Text(l10n.reminderFertilizing),
              ),
              DropdownMenuItem(
                value: ReminderType.repotting,
                child: Text(l10n.reminderRepotting),
              ),
              DropdownMenuItem(
                value: ReminderType.inspection,
                child: Text(l10n.reminderInspection),
              ),
              DropdownMenuItem(
                value: ReminderType.followUp,
                child: Text(l10n.reminderFollowUp),
              ),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<Recurrence>(
            initialValue: _recurrence,
            decoration: InputDecoration(labelText: l10n.reminderRecurrence),
            items: [
              DropdownMenuItem(
                value: Recurrence.none,
                child: Text(l10n.recurrenceNone),
              ),
              DropdownMenuItem(
                value: Recurrence.daily,
                child: Text(l10n.recurrenceDaily),
              ),
              DropdownMenuItem(
                value: Recurrence.weekly,
                child: Text(l10n.recurrenceWeekly),
              ),
            ],
            onChanged: (v) => setState(() => _recurrence = v ?? _recurrence),
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(l10n.reminderDateTime),
            subtitle: Text(
              '${DateFormatter.dayAndDate(_when, locale)} · ${DateFormatter.time(_when, locale)}',
            ),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: _pickDateTime,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.reminderNote),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
