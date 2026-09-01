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

            // ---- Official land record (authoritative when present) ----------
            if (report.landRecord != null && report.landRecord!.hasData)
              _Section(
                emoji: '📜',
                title: l10n.georesearchLandRecordSection,
                body: _LandRecordBody(record: report.landRecord!, l10n: l10n),
              ),

            // ---- Site location ---------------------------------------------
            if (report.siteLocation != null && !report.siteLocation!.isEmpty)
              _Section(
                emoji: '📍',
                title: l10n.georesearchSite,
                body: _SiteLocationBody(site: report.siteLocation!, l10n: l10n),
              ),

            // ---- Topographic survey ----------------------------------------
            if (report.topography != null && !report.topography!.isEmpty)
              _Section(
                emoji: '⛰️',
                title: l10n.georesearchTopography,
                body: _TopographyBody(topo: report.topography!, l10n: l10n),
              ),

            // ---- Groundwater ------------------------------------------------
            if (report.groundwater != null && !report.groundwater!.isEmpty)
              _Section(
                emoji: '💧',
                title: l10n.georesearchGroundwater,
                body: _GroundwaterBody(gw: report.groundwater!, l10n: l10n),
              ),

            // ---- Building suitability ---------------------------------------
            if (report.buildingSuitability != null &&
                !report.buildingSuitability!.isEmpty)
              _Section(
                emoji: '🏗️',
                title: l10n.georesearchBuilding,
                body: _BuildingBody(
                  info: report.buildingSuitability!,
                  l10n: l10n,
                ),
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

            // Where the findings came from, so reliability is judgeable.
            if (report.dataSources.isNotEmpty)
              _Section(
                emoji: '🗂️',
                title: l10n.georesearchDataSources,
                body: _BulletList(items: report.dataSources),
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

/// Official land-registry values. Badged as an official record so the user can
/// tell them apart from the AI's estimates.
class _LandRecordBody extends StatelessWidget {
  const _LandRecordBody({required this.record, required this.l10n});
  final LandRecordInfo record;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.confidenceHigh.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 14,
                color: AppColors.confidenceHigh,
              ),
              const SizedBox(width: 2),
              Text(
                l10n.georesearchLandRecordOfficial,
                style: const TextStyle(
                  color: AppColors.confidenceHigh,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (record.source != null)
          _LabelValue(
            label: l10n.georesearchLandRecordSource,
            value: record.source!,
          ),
        if (record.parcelId != null)
          _LabelValue(
            label: l10n.georesearchLandParcelId,
            value: record.parcelId!,
          ),
        if (record.registeredArea != null)
          _LabelValue(
            label: l10n.georesearchLandRegisteredArea,
            value: record.registeredArea!,
          ),
        if (record.zoning != null)
          _LabelValue(label: l10n.georesearchLandZoning, value: record.zoning!),
        if (record.classification != null)
          _LabelValue(
            label: l10n.georesearchLandClassification,
            value: record.classification!,
          ),
        if (record.ownershipType != null)
          _LabelValue(
            label: l10n.georesearchLandOwnershipType,
            value: record.ownershipType!,
          ),
        if (record.officialNotes != null)
          _LabelValue(
            label: l10n.georesearchLandOfficialNotes,
            value: record.officialNotes!,
          ),
      ],
    );
  }
}

class _SiteLocationBody extends StatelessWidget {
  const _SiteLocationBody({required this.site, required this.l10n});
  final SiteLocation site;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (site.address != null)
          _LabelValue(label: l10n.georesearchSiteAddress, value: site.address!),
        if (site.latitude != null && site.longitude != null)
          _LabelValue(
            label: l10n.georesearchLocation,
            value:
                '${site.latitude!.toStringAsFixed(4)}, ${site.longitude!.toStringAsFixed(4)}',
          ),
        if (site.elevation != null)
          _LabelValue(
            label: l10n.georesearchSiteElevation,
            value: site.elevation!,
          ),
        if (site.areaEstimate != null)
          _LabelValue(
            label: l10n.georesearchSiteArea,
            value: site.areaEstimate!,
          ),
        if (site.boundaryDescription != null)
          _LabelValue(
            label: l10n.georesearchSiteBoundary,
            value: site.boundaryDescription!,
          ),
        if (site.terrainSetting != null)
          _LabelValue(
            label: l10n.georesearchSiteTerrain,
            value: site.terrainSetting!,
          ),
        if (site.accessNotes != null)
          _LabelValue(
            label: l10n.georesearchSiteAccess,
            value: site.accessNotes!,
          ),
      ],
    );
  }
}

class _TopographyBody extends StatelessWidget {
  const _TopographyBody({required this.topo, required this.l10n});
  final TopographySurvey topo;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topo.summary != null) Text(topo.summary!),
        if (topo.elevationRange != null)
          _LabelValue(
            label: l10n.georesearchTopoElevationRange,
            value: topo.elevationRange!,
          ),
        if (topo.slope != null)
          _LabelValue(
            label: l10n.georesearchTopoSlope,
            value: topo.slopePercent != null
                ? '${topo.slope!} (~${topo.slopePercent!.toStringAsFixed(1)}%)'
                : topo.slope!,
          ),
        if (topo.aspect != null)
          _LabelValue(label: l10n.georesearchTopoAspect, value: topo.aspect!),
        if (topo.landform != null)
          _LabelValue(
            label: l10n.georesearchTopoLandform,
            value: topo.landform!,
          ),
        if (topo.relief != null)
          _LabelValue(label: l10n.georesearchTopoRelief, value: topo.relief!),
        if (topo.contourSummary != null)
          _LabelValue(
            label: l10n.georesearchTopoContours,
            value: topo.contourSummary!,
          ),
        if (topo.drainagePattern != null)
          _LabelValue(
            label: l10n.georesearchTopoDrainage,
            value: topo.drainagePattern!,
          ),
        if (topo.runoffNotes != null)
          _LabelValue(
            label: l10n.georesearchTopoRunoff,
            value: topo.runoffNotes!,
          ),
        if (topo.gradingNotes != null)
          _LabelValue(
            label: l10n.georesearchTopoGrading,
            value: topo.gradingNotes!,
          ),
        if (topo.floodRisk != null || topo.erosionRisk != null) ...[
          const SizedBox(height: AppSpacing.xs),
          if (topo.floodRisk != null)
            _RiskRow(
              label: l10n.georesearchTopoFloodRisk,
              level: topo.floodRisk!,
              l10n: l10n,
            ),
          if (topo.erosionRisk != null)
            _RiskRow(
              label: l10n.georesearchTopoErosionRisk,
              level: topo.erosionRisk!,
              l10n: l10n,
            ),
        ],
        if (topo.notes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          _BulletList(items: topo.notes),
        ],
        _MiniNotice(text: l10n.georesearchTopoNotice),
      ],
    );
  }
}

class _GroundwaterBody extends StatelessWidget {
  const _GroundwaterBody({required this.gw, required this.l10n});
  final GroundwaterAssessment gw;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (gw.summary != null) Text(gw.summary!),
        if (gw.waterTableDepth != null)
          _LabelValue(
            label: l10n.georesearchGwWaterTable,
            value: gw.waterTableDepth!,
          ),
        if (gw.aquiferType != null)
          _LabelValue(
            label: l10n.georesearchGwAquifer,
            value: gw.aquiferType!,
          ),
        if (gw.waterQuality != null)
          _LabelValue(
            label: l10n.georesearchGwQuality,
            value: gw.waterQuality!,
          ),
        if (gw.seasonalVariation != null)
          _LabelValue(
            label: l10n.georesearchGwSeasonal,
            value: gw.seasonalVariation!,
          ),
        if (gw.rechargeNotes != null)
          _LabelValue(
            label: l10n.georesearchGwRecharge,
            value: gw.rechargeNotes!,
          ),
        if (gw.wellFeasibility != null)
          _LabelValue(
            label: l10n.georesearchGwWellFeasibility,
            value: gw.wellFeasibility!,
          ),
        if (gw.drillingDepthEstimate != null)
          _LabelValue(
            label: l10n.georesearchGwDrillingDepth,
            value: gw.drillingDepthEstimate!,
          ),
        const SizedBox(height: AppSpacing.xs),
        if (gw.yieldPotential != null)
          _RiskRow(
            label: l10n.georesearchGwYield,
            level: gw.yieldPotential!,
            l10n: l10n,
            // High yield is a good outcome, so use the positive palette.
            concern: false,
          ),
        if (gw.salinityRisk != null)
          _RiskRow(
            label: l10n.georesearchGwSalinityRisk,
            level: gw.salinityRisk!,
            l10n: l10n,
          ),
        if (gw.contaminationRisk != null)
          _RiskRow(
            label: l10n.georesearchGwContamination,
            level: gw.contaminationRisk!,
            l10n: l10n,
          ),
        if (gw.notes.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          _BulletList(items: gw.notes),
        ],
        _MiniNotice(text: l10n.georesearchGwNotice),
      ],
    );
  }
}

class _BuildingBody extends StatelessWidget {
  const _BuildingBody({required this.info, required this.l10n});
  final BuildingSuitability info;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (info.summary != null) Text(info.summary!),
        if (info.suitability != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: _RiskRow(
              label: l10n.georesearchBuildRating,
              level: info.suitability!,
              l10n: l10n,
              // High suitability is favourable.
              concern: false,
            ),
          ),
        if (info.bearingCapacity != null)
          _LabelValue(
            label: l10n.georesearchBuildBearing,
            value: info.bearingCapacity!,
          ),
        if (info.bedrockDepth != null)
          _LabelValue(
            label: l10n.georesearchBuildBedrock,
            value: info.bedrockDepth!,
          ),
        if (info.foundationSuggestion != null)
          _LabelValue(
            label: l10n.georesearchBuildFoundation,
            value: info.foundationSuggestion!,
          ),
        if (info.seismicNotes != null)
          _LabelValue(
            label: l10n.georesearchBuildSeismic,
            value: info.seismicNotes!,
          ),
        if (info.excavationNotes != null)
          _LabelValue(
            label: l10n.georesearchBuildExcavation,
            value: info.excavationNotes!,
          ),
        if (info.drainageRequirements != null)
          _LabelValue(
            label: l10n.georesearchBuildDrainage,
            value: info.drainageRequirements!,
          ),
        if (info.settlementRisk != null)
          _RiskRow(
            label: l10n.georesearchBuildSettlement,
            level: info.settlementRisk!,
            l10n: l10n,
          ),
        if (info.expansiveSoilRisk != null)
          _RiskRow(
            label: l10n.georesearchBuildExpansive,
            level: info.expansiveSoilRisk!,
            l10n: l10n,
          ),
        if (info.constraints.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.georesearchBuildConstraints,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          _BulletList(items: info.constraints),
        ],
        if (info.requiredStudies.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.georesearchBuildRequiredStudies,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          _BulletList(items: info.requiredStudies),
        ],
        _MiniNotice(text: l10n.georesearchBuildNotice, warning: true),
      ],
    );
  }
}

/// A labelled qualitative level (risk, yield or suitability) rendered with the
/// shared chip so colour is always paired with a text label.
class _RiskRow extends StatelessWidget {
  const _RiskRow({
    required this.label,
    required this.level,
    required this.l10n,
    this.concern = true,
  });
  final String label;
  final SoilLevel level;
  final AppLocalizations l10n;
  final bool concern;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          _LevelChip(level: level, l10n: l10n, concern: concern),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small per-section caveat naming the professional study that section cannot
/// replace. [warning] raises the emphasis for the construction disclaimer.
class _MiniNotice extends StatelessWidget {
  const _MiniNotice({required this.text, this.warning = false});
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final Color color = warning ? AppColors.confidenceLow : AppColors.mossGray;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.warning_amber_outlined : Icons.info_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontStyle: warning ? FontStyle.normal : FontStyle.italic,
                fontWeight: warning ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
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
