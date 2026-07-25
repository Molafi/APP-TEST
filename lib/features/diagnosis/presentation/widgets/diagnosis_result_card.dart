import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/diagnosis_model.dart';

/// Structured diagnosis card. Confidence and likelihood are always shown with
/// an icon + text label (never colour alone) for accessibility.
class DiagnosisResultCard extends StatelessWidget {
  const DiagnosisResultCard({super.key, required this.diagnosis, this.locale = 'en'});

  final Diagnosis diagnosis;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    // Guard rails for non-plant / poor image results.
    if (!diagnosis.isPlantRelated) {
      return _NoticeCard(
        icon: Icons.help_outline,
        text: l10n.notPlantRelated,
      );
    }
    if (diagnosis.needsMoreInformation ||
        diagnosis.imageQuality != ImageQuality.good) {
      return _NoticeCard(
        icon: Icons.image_not_supported_outlined,
        text: l10n.poorImageQuality,
        followUps: diagnosis.followUpQuestions,
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
            if (diagnosis.plantName != null)
              _Section(
                emoji: '🌿',
                title: l10n.diagnosisPlant,
                body: Text(diagnosis.scientificName != null
                    ? '${diagnosis.plantName} (${diagnosis.scientificName})'
                    : diagnosis.plantName!),
              ),
            if (diagnosis.whatISee.isNotEmpty)
              _Section(
                emoji: '👁️',
                title: l10n.diagnosisWhatISee,
                body: Text(diagnosis.whatISee),
              ),
            if (diagnosis.possibleIssues.isNotEmpty)
              _Section(
                emoji: '⚠️',
                title: l10n.diagnosisIssue,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final PossibleIssue i in diagnosis.possibleIssues)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LikelihoodChip(likelihood: i.likelihood, l10n: l10n),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(i.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  if (i.reason.isNotEmpty)
                                    Text(i.reason,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            if (diagnosis.treatmentSteps.isNotEmpty)
              _Section(
                emoji: '💊',
                title: l10n.diagnosisTreatment,
                body: _NumberedList(items: diagnosis.treatmentSteps),
              ),
            if (diagnosis.preventionTips.isNotEmpty)
              _Section(
                emoji: '🌱',
                title: l10n.diagnosisPrevention,
                body: _BulletList(items: diagnosis.preventionTips),
              ),
            if (diagnosis.safetyNotes.isNotEmpty)
              _Section(
                emoji: '🛡️',
                title: l10n.diagnosisSafety,
                body: _BulletList(items: diagnosis.safetyNotes),
              ),
            const Divider(height: AppSpacing.xl),
            Text(
              diagnosis.disclaimer.isNotEmpty
                  ? diagnosis.disclaimer
                  : l10n.aiDisclaimerLong,
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
    final (IconData icon, Color color, String label) = switch (diagnosis.confidence) {
      Confidence.high => (Icons.verified, AppColors.confidenceHigh, l10n.confidenceHigh),
      Confidence.medium => (Icons.check_circle_outline, AppColors.confidenceMedium, l10n.confidenceMedium),
      Confidence.low => (Icons.info_outline, AppColors.confidenceLow, l10n.confidenceLow),
    };
    return Semantics(
      label: l10n.a11yConfidence(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text('${l10n.diagnosisConfidence}: $label',
                style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.emoji, required this.title, required this.body});
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
          Text('$emoji  $title',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          body,
        ],
      ),
    );
  }
}

class _LikelihoodChip extends StatelessWidget {
  const _LikelihoodChip({required this.likelihood, required this.l10n});
  final Likelihood likelihood;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (Color c, String label, IconData icon) = switch (likelihood) {
      Likelihood.high => (AppColors.confidenceHigh, l10n.likelihoodHigh, Icons.arrow_upward),
      Likelihood.medium => (AppColors.confidenceMedium, l10n.likelihoodMedium, Icons.drag_handle),
      Likelihood.low => (AppColors.confidenceLow, l10n.likelihoodLow, Icons.arrow_downward),
    };
    return Tooltip(
      message: label,
      child: Icon(icon, size: 18, color: c, semanticLabel: label),
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
              children: [const Text('•  '), Expanded(child: Text(s))],
            ),
          ),
      ],
    );
  }
}

class _NumberedList extends StatelessWidget {
  const _NumberedList({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i + 1}.  ',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Expanded(child: Text(items[i])),
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
                    child: Text(text,
                        style: Theme.of(context).textTheme.bodyLarge)),
              ],
            ),
            if (followUps != null && followUps!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              for (final String q in followUps!)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [const Text('•  '), Expanded(child: Text(q))],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
