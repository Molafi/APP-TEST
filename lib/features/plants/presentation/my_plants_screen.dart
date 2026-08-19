import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/plants_provider.dart';
import '../domain/plant_model.dart';
import 'plant_detail_screen.dart';
import 'widgets/plant_editor_sheet.dart';

/// The "My Plants" journal: a list of tracked plants with add/edit/delete.
class MyPlantsScreen extends ConsumerWidget {
  const MyPlantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PlantsState state = ref.watch(plantsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myPlants)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPlantEditor(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addPlant),
      ),
      body: state.isLoading
          ? const AppLoadingView()
          : state.isEmpty
          ? AppEmptyView(
              icon: Icons.local_florist_outlined,
              title: l10n.plantsEmpty,
              message: l10n.plantsEmptyBody,
              action: FilledButton.icon(
                onPressed: () => showPlantEditor(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.addPlant),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: state.plants.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final Plant p = state.plants[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      p.name.isNotEmpty
                          ? p.name.characters.first.toUpperCase()
                          : '🌿',
                    ),
                  ),
                  title: Text(p.name),
                  subtitle: Text(
                    [
                      if (p.species != null && p.species!.isNotEmpty)
                        p.species!,
                      p.place == PlantPlace.outdoor
                          ? l10n.plantOutdoor
                          : l10n.plantIndoor,
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlantDetailScreen(plantId: p.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
