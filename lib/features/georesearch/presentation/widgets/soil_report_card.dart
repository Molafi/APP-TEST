import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/soil_report_model.dart';

/// Structured soil-report card. Confidence and levels are always shown with an
/// icon + text label (never colour alone) for accessibility. Values are clearly
/// framed as ESTIMATES with a prominent lab-test disclaimer.
class SoilReportCard extends StatelessWidget {
  const SoilReportCard({super.key, required this.report});

  final SoilReport report;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    // Guard rail for unrelated images.
    if (!report.isSoilRelated) {
      return _NoticeCard(
        icon: Icons.help_outline,
        text: l10n.georesearchNotSoilRelated,
        followUps: report.followUpQuestions,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _confidenceBadge(context, l10n),
            const SizedBox(height: AppSpacing.md),

            // Prominent estimate / lab-test notice at the top.
            _EstimateBanner(text: l10n.georesearchEstimateNotice),
            const SizedBox(height: AppSpacing.md),

            if (report.locationSummary != null ||
                report.soilType != null ||
                report.soilDepth != null)
              _Section(
                emoji: '🗺️',
                title: l10n.georesearchLocation,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report.locationSummary != null)
                      Text(report.locationSummary!),
                    if (report.soilType != null)
                      _LabelValue(
                        label: l10n.georesearchSoilType,
                        value: report.soilType!,
                      ),
                    if (report.soilDepth != null)
                      _LabelValue(
                        label: l10n.georesearchDepth,
                        value: report.soilDepth!,
                      ),
                  ],
                ),
              ),

            if (report.salinity != null || report.sodium != null)
              _Section(
                emoji: '🧂',
                title: l10n.georesearchSalinitySodium,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report.salinity != null)
                      _MeasureRow(
                        label: l10n.georesearchSalinity,
                        measure: report.salinity!,
                        l10n: l10n,
                      ),
                    if (report.sodium != null)
                      _MeasureRow(
                        label: l10n.georesearchSodium,
                        measure: report.sodium!,
                        l10n: l10n,
                      ),
                  ],
                ),
              ),

            if (report.phLevel != null || report.organicMatter != null)
              _Section(
                emoji: '⚗️',
                title: l10n.georesearchPhOrganic,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report.phLevel != null)
                      _LabelValue(
                        label: l10n.georesearchPh,
                        value: report.phLevel!,
                      ),
                    if (report.organicMatter != null)
                      _LabelValue(
                        label: l10n.georesearchOrganicMatter,
                        value: report.organicMatter!,
                      ),
                  ],
                ),
              ),

            if (report.nutrients.isNotEmpty)
              _Section(
                emoji: '🌱',
                title: l10n.georesearchNutrients,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final SoilNutrient n in report.nutrients)
                      _LevelItem(
                        name: n.name,
                        level: n.level,
                        note: n.note,
                        l10n: l10n,
                      ),
                  ],
                ),
              ),

            if (report.substances.isNotEmpty)
              _Section(
                emoji: '⚠️',
                title: l10n.georesearchSubstances,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final SoilSubstance s in report.substances)
                      _LevelItem(
                        name: s.name,
                        level: s.concern,
                        note: s.note,
                        l10n: l10n,
                        concern: true,
                      ),
                  ],
                ),
              ),

            if (report.geometry != null)
              _Section(
                emoji: '🧱',
                title: l10n.georesearchGeometry,
                body: Text(report.geometry!),
              ),

            if (report.suitablePlants.isNotEmpty)
              _Section(
                emoji: '🪴',
                title: l10n.georesearchSuitablePlants,
                body: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final String p in report.suitablePlants)
                      Chip(
                        label: Text(p),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),

            if (report.recommendations.isNotEmpty)
              _Section(
                emoji: '✅',
                title: l10n.georesearchRecommendations,
                body: _BulletList(items: report.recommendations),
              ),

            if (report.safetyNotes.isNotEmpty)
              _Section(
                emoji: '🛡️',
                title: l10n.georesearchSafety,
                body: _BulletList(items: report.safetyNotes),
              ),

            const Divider(height: AppSpacing.xl),
            Text(
              report.disclaimer.isNotEmpty
                  ? report.disclaimer
                  : l10n.georesearchEstimateNotice,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.mossGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confidenceBadge(BuildContext context, AppLocalizations l10n) {
    final (
      IconData icon,
      Color color,
      String label,
    ) = switch (report.confidence) {
      Confidence.high => (
        Icons.verified,
        AppColors.confidenceHigh,
        l10n.confidenceHigh,
      ),
      Confidence.medium => (
        Icons.check_circle_outline,
        AppColors.confidenceMedium,
        l10n.confidenceMedium,
      ),
      Confidence.low => (
        Icons.info_outline,
        AppColors.confidenceLow,
        l10n.confidenceLow,
      ),
    };
    return Semantics(
      label: l10n.a11yConfidence(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${l10n.diagnosisConfidence}: $label',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstimateBanner extends StatelessWidget {
  const _EstimateBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.soilAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined, size: 20, color: AppColors.soilAmber),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.emoji,
    required this.title,
    required this.body,
  });
  final String emoji;
  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji  $title',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          body,
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _MeasureRow extends StatelessWidget {
  const _MeasureRow({
    required this.label,
    required this.measure,
    required this.l10n,
  });
  final String label;
  final SoilMeasure measure;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LevelChip(level: measure.level, l10n: l10n),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (measure.note.isNotEmpty)
                  Text(
                    measure.note,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelItem extends StatelessWidget {
  const _LevelItem({
    required this.name,
    required this.level,
    required this.note,
    required this.l10n,
    this.concern = false,
  });
  final String name;
  final SoilLevel level;
  final String note;
  final AppLocalizations l10n;
  final bool concern;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LevelChip(level: level, l10n: l10n, concern: concern),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (note.isNotEmpty)
                  Text(note, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.level,
    required this.l10n,
    this.concern = false,
  });
  final SoilLevel level;
  final AppLocalizations l10n;
  final bool concern;

  @override
  Widget build(BuildContext context) {
    // For nutrients/measures, "high" is a strong (green) reading; for concern
    // (substances/contaminants) "high" is a warning (red). The colour is always
    // paired with a text label.
    final (Color c, String label, IconData icon) = switch (level) {
      SoilLevel.high => (
        concern ? AppColors.confidenceLow : AppColors.confidenceHigh,
        concern ? l10n.concernHigh : l10n.levelHigh,
        concern ? Icons.warning_amber_outlined : Icons.arrow_upward,
      ),
      SoilLevel.medium => (
        AppColors.confidenceMedium,
        concern ? l10n.concernMedium : l10n.levelMedium,
        Icons.drag_handle,
      ),
      SoilLevel.low => (
        concern ? AppColors.confidenceHigh : AppColors.confidenceLow,
        concern ? l10n.concernLow : l10n.levelLow,
        concern ? Icons.check_circle_outline : Icons.arrow_downward,
      ),
    };
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c, semanticLabel: label),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final String s in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(s)),
              ],
            ),
          ),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.icon, required this.text, this.followUps});
  final IconData icon;
  final String text;
  final List<String>? followUps;

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
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            if (followUps != null && followUps!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              for (final String q in followUps!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(q)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
