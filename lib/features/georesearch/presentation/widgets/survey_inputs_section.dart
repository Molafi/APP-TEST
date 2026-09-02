import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/soil_research_provider.dart';
import '../../domain/site_survey_model.dart';
import 'purpose_label.dart';

/// Collects the inputs that DRIVE the survey: what the user needs the site for,
/// their own requirements in free text, and — optionally — official Land
/// Department data. When official data is supplied the survey treats it as
/// authoritative; otherwise it falls back to estimates from location context.
class SurveyInputsSection extends StatelessWidget {
  const SurveyInputsSection({
    super.key,
    required this.state,
    required this.controller,
  });

  final SoilResearchState state;
  final SoilResearchController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Purpose -------------------------------------------------------
        Text(
          l10n.georesearchPurpose,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 2),
        // Spells out what the choice actually changes. Without it the chips read
        // as a filter rather than the setting that drives the whole survey.
        Text(
          l10n.georesearchPurposeHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            // Labels come from the shared `purposeLabel` so the chip the user
            // taps and the purpose echoed back in the report always agree.
            for (final (SurveyPurpose p, IconData icon)
                in <(SurveyPurpose, IconData)>[
                  (SurveyPurpose.general, Icons.explore_outlined),
                  (SurveyPurpose.agriculture, Icons.agriculture_outlined),
                  (SurveyPurpose.building, Icons.foundation_outlined),
                  (SurveyPurpose.wellDrilling, Icons.water_drop_outlined),
                  (SurveyPurpose.slopeStability, Icons.terrain_outlined),
                ])
              ChoiceChip(
                selected: state.purpose == p,
                onSelected: (_) => controller.setPurpose(p),
                avatar: Icon(icon, size: 18),
                label: Text(purposeLabel(p, l10n)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // ---- Free-text requirements ---------------------------------------
        TextFormField(
          initialValue: state.requirements,
          minLines: 2,
          maxLines: 4,
          maxLength: 500,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            labelText: l10n.georesearchRequirements,
            hintText: l10n.georesearchRequirementsHint,
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
          ),
          onChanged: controller.setRequirements,
        ),
        const SizedBox(height: AppSpacing.sm),

        // ---- Optional official Land Department data -------------------------
        _LandRecordForm(state: state, controller: controller),
      ],
    );
  }
}

/// Collapsible official-data form. Collapsed by default because it is entirely
/// optional — the survey works without it.
class _LandRecordForm extends StatelessWidget {
  const _LandRecordForm({required this.state, required this.controller});

  final SoilResearchState state;
  final SoilResearchController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LandRecordInfo record = state.landRecord;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: record.available,
        leading: const Icon(Icons.description_outlined),
        title: Text(l10n.georesearchLandRecordSection),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        children: [
          Text(
            l10n.georesearchLandRecordHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: record.available,
            onChanged: controller.setLandRecordAvailable,
            title: Text(l10n.georesearchLandRecordToggle),
          ),
          // Fields stay visible but disabled until the user confirms they have
          // official data, so it is obvious what can be provided.
          _field(
            label: l10n.georesearchLandRecordSource,
            value: record.source,
            enabled: record.available,
            onChanged: (v) =>
                controller.setLandRecord(record.copyWith(source: v)),
          ),
          _field(
            label: l10n.georesearchLandParcelId,
            value: record.parcelId,
            enabled: record.available,
            onChanged: (v) =>
                controller.setLandRecord(record.copyWith(parcelId: v)),
          ),
          _field(
            label: l10n.georesearchLandRegisteredArea,
            value: record.registeredArea,
            enabled: record.available,
            onChanged: (v) =>
                controller.setLandRecord(record.copyWith(registeredArea: v)),
          ),
          _field(
            label: l10n.georesearchLandZoning,
            value: record.zoning,
            enabled: record.available,
            onChanged: (v) =>
                controller.setLandRecord(record.copyWith(zoning: v)),
          ),
          _field(
            label: l10n.georesearchLandClassification,
            value: record.classification,
            enabled: record.available,
            onChanged: (v) =>
                controller.setLandRecord(record.copyWith(classification: v)),
          ),
          _field(
            label: l10n.georesearchLandOwnershipType,
            value: record.ownershipType,
            enabled: record.available,
            onChanged: (v) =>
                controller.setLandRecord(record.copyWith(ownershipType: v)),
          ),
          _field(
            label: l10n.georesearchLandOfficialNotes,
            value: record.officialNotes,
            enabled: record.available,
            maxLines: 3,
            onChanged: (v) =>
                controller.setLandRecord(record.copyWith(officialNotes: v)),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String? value,
    required bool enabled,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: TextFormField(
        // Keyed by label so each field keeps its own state across rebuilds.
        key: ValueKey<String>('land-$label'),
        initialValue: value,
        enabled: enabled,
        maxLines: maxLines,
        // Capped to match the sanitising/truncation applied before these values
        // are sent as authoritative context.
        maxLength: maxLines > 1 ? 300 : 120,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          counterText: '',
        ),
        onChanged: onChanged,
      ),
    );
  }
}
