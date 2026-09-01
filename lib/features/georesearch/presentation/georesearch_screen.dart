import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/application/home_provider.dart';
import '../../weather/application/ai_context_provider.dart';
import '../application/soil_research_provider.dart';
import '../domain/soil_report_model.dart';
import 'widgets/aerial_view_card.dart';
import 'widgets/official_map_card.dart';
import 'widgets/soil_report_card.dart';
import 'widgets/survey_inputs_section.dart';

/// Stage-driven GeoResearch (soil analysis) flow. Provided as a tab body; the
/// Home shell supplies the Scaffold and app bar.
class GeoResearchScreen extends ConsumerWidget {
  const GeoResearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SoilResearchState state = ref.watch(soilResearchControllerProvider);
    final SoilResearchController controller = ref.read(
      soilResearchControllerProvider.notifier,
    );

    ref.listen(soilResearchControllerProvider.select((s) => s.error), (
      prev,
      next,
    ) {
      if (next != null && next != prev) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text(ErrorMapper.message(l10n, next))),
          );
      }
    });

    return switch (state.stage) {
      SoilResearchStage.input => _InputView(state: state, controller: controller),
      SoilResearchStage.analyzing => _AnalyzingView(
        onCancel: controller.cancelAnalysis,
      ),
      SoilResearchStage.result => _ResultView(state: state),
    };
  }
}

class _InputView extends ConsumerWidget {
  const _InputView({required this.state, required this.controller});
  final SoilResearchState state;
  final SoilResearchController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AiContext ctx = ref.watch(aiContextProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l10n.georesearchIntro, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.lg),

        // Purpose, free-text requirements and optional Land Department data.
        SurveyInputsSection(state: state, controller: controller),
        const SizedBox(height: AppSpacing.lg),

        // Location context strip (or a hint to set a location).
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.place_outlined),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    ctx.displayStrip ?? l10n.georesearchNoLocation,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Optional photo preview + attach/change controls.
        if (state.imageBytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Image.memory(
              state.imageBytes!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickPhoto(context),
                  icon: const Icon(Icons.image_outlined),
                  label: Text(l10n.georesearchChangePhoto),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.clearImage,
                  icon: const Icon(Icons.close),
                  label: Text(l10n.georesearchRemovePhoto),
                ),
              ),
            ],
          ),
        ] else
          OutlinedButton.icon(
            onPressed: () => _pickPhoto(context),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(l10n.georesearchAddPhoto),
          ),

        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: () => controller.analyze(),
          icon: const Icon(Icons.travel_explore),
          label: Text(l10n.georesearchAnalyze),
        ),
      ],
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.georesearchTakePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.georesearchChoosePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final XFile? file = await ImagePicker().pickImage(source: source);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      controller.setImage(bytes);
    } catch (_) {
      // Picker unavailable/cancelled — keep the current state silently.
    }
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView({required this.onCancel});
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: AppLoadingView(label: l10n.georesearchAnalyzing)),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close),
            label: Text(l10n.cancelAnalysis),
          ),
        ),
      ],
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.state});
  final SoilResearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SoilReport report = state.result!;
    final controller = ref.read(soilResearchControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        if (state.imageBytes != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Image.memory(
                state.imageBytes!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        // Aerial/satellite context view. Without coordinates there is no tile
        // to show, so explain why rather than silently omitting the card.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: report.aerialImagery != null
              ? AerialViewCard(info: report.aerialImagery!)
              : Card(
                  child: ListTile(
                    leading: const Icon(Icons.satellite_alt_outlined),
                    title: Text(l10n.georesearchAerialUnavailable),
                  ),
                ),
        ),
        // National mapping-authority reference (RJGC grid + official map
        // links). Absent without coordinates, or outside Jordan's coverage.
        if (report.officialMap != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.md,
            ),
            child: OfficialMapCard(info: report.officialMap!),
          ),
        SoilReportCard(report: report),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: state.saved ? null : controller.saveCurrent,
                icon: Icon(state.saved ? Icons.check : Icons.save_outlined),
                label: Text(
                  state.saved ? l10n.georesearchSaved : l10n.georesearchSave,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _askFollowUp(context, ref, report),
                icon: const Icon(Icons.chat_outlined),
                label: Text(l10n.askFollowUp),
              ),
              OutlinedButton.icon(
                onPressed: () => _share(context, l10n, report),
                icon: const Icon(Icons.ios_share),
                label: Text(l10n.shareSummary),
              ),
              TextButton.icon(
                onPressed: controller.reset,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _askFollowUp(BuildContext context, WidgetRef ref, SoilReport report) {
    // Hand the soil context to chat and switch to the chat tab so the user does
    // not have to repeat details.
    final String subject = report.soilType ?? report.locationSummary ?? 'my soil';
    final String summary = 'Follow-up about $subject soil analysis.';
    ref.read(chatFollowUpProvider.notifier).state = summary;
    ref.read(homeTabProvider.notifier).state = HomeTab.chat;
  }

  Future<void> _share(
    BuildContext context,
    AppLocalizations l10n,
    SoilReport report,
  ) async {
    try {
      await Share.share(report.toShareText());
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: report.toShareText()));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(l10n.copied)));
      }
    }
  }
}
