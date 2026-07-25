import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/application/home_provider.dart';
import '../../profile/application/settings_provider.dart';
import '../../reminders/application/reminder_provider.dart';
import '../../reminders/domain/reminder_model.dart';
import '../../weather/application/weather_provider.dart';
import '../application/plants_provider.dart';
import '../domain/plant_model.dart';
import '../domain/watering_scheduler.dart';
import 'widgets/plant_editor_sheet.dart';

/// Detail view for a single plant: info, care actions, and links into chat and
/// the watering schedule.
class PlantDetailScreen extends ConsumerWidget {
  const PlantDetailScreen({super.key, required this.plantId});

  final String plantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).languageCode;
    Plant? plant;
    for (final Plant p in ref.watch(plantsControllerProvider).plants) {
      if (p.id == plantId) {
        plant = p;
        break;
      }
    }

    // If the plant was deleted, close the screen.
    if (plant == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        actions: [
          IconButton(
            tooltip: l10n.editPlant,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showPlantEditor(context, existing: plant),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, l10n, plant),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _InfoRow(
            icon: Icons.local_florist_outlined,
            label: l10n.plantSpecies,
            value: (plant.species?.isNotEmpty ?? false)
                ? plant.species!
                : '—',
          ),
          _InfoRow(
            icon: Icons.home_outlined,
            label: l10n.plantLocation,
            value: plant.place == PlantPlace.outdoor
                ? l10n.plantOutdoor
                : l10n.plantIndoor,
          ),
          if (plant.lastWateredAt != null)
            _InfoRow(
              icon: Icons.water_drop_outlined,
              label: l10n.markWatered,
              value: DateFormatter.dayAndDate(plant.lastWateredAt!, locale),
            ),
          if (plant.notes != null && plant.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(l10n.plantNotes,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(plant.notes!),
          ],
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: () => _askAbout(context, ref, plant),
                icon: const Icon(Icons.chat_outlined),
                label: Text(l10n.askAboutPlant),
              ),
              OutlinedButton.icon(
                onPressed: () => ref
                    .read(plantsControllerProvider.notifier)
                    .markWatered(plant),
                icon: const Icon(Icons.water_drop),
                label: Text(l10n.markWatered),
              ),
              OutlinedButton.icon(
                onPressed: () => _scheduleWatering(context, ref, l10n, plant),
                icon: const Icon(Icons.event_available_outlined),
                label: Text(l10n.generateWateringSchedule),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _askAbout(BuildContext context, WidgetRef ref, Plant plant) {
    final String prompt = plant.species != null
        ? 'How do I care for my ${plant.name} (${plant.species})?'
        : 'How do I care for my ${plant.name}?';
    ref.read(chatFollowUpProvider.notifier).state = prompt;
    ref.read(homeTabProvider.notifier).state = HomeTab.chat;
    // Reveal the home shell (chat tab) behind this pushed detail screen.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Future<void> _scheduleWatering(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, Plant plant) async {
    // Request notification permission the first time if needed.
    if (!ref.read(notificationsEnabledProvider)) {
      final outcome =
          await ref.read(permissionServiceProvider).requestNotifications();
      await ref
          .read(notificationsEnabledProvider.notifier)
          .set(outcome == PermissionOutcome.granted);
    }
    final weather = ref.read(currentWeatherDataProvider);
    final DateTime when = WateringScheduler.nextWatering(plant, weather);
    await ref.read(reminderControllerProvider.notifier).add(
          plantName: plant.name,
          type: ReminderType.watering,
          scheduledAt: when,
          recurrence: Recurrence.none,
          note: null,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.wateringScheduleCreated)));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, Plant plant) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text('${l10n.delete} "${plant.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(plantsControllerProvider.notifier).remove(plant);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
