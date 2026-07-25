import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/plant_care_rules.dart';

class PlantCareTipsCard extends StatelessWidget {
  const PlantCareTipsCard({super.key, required this.tips});

  final List<PlantCareTip> tips;

  String _text(AppLocalizations l10n, PlantCareTip tip) => switch (tip) {
        PlantCareTip.highUv => l10n.tipHighUv,
        PlantCareTip.noRain => l10n.tipNoRain,
        PlantCareTip.highHumidity => l10n.tipHighHumidity,
        PlantCareTip.freezing => l10n.tipFreezing,
        PlantCareTip.hot => l10n.tipHot,
        PlantCareTip.mild => l10n.tipMild,
      };

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Card(
      color: AppColors.leafGreen.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: AppColors.leafGreenDark),
                const SizedBox(width: AppSpacing.sm),
                Text(l10n.plantCareTips,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final PlantCareTip tip in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🌱  '),
                    Expanded(child: Text(_text(l10n, tip))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
