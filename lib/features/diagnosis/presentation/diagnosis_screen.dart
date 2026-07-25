import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/application/home_provider.dart';
import '../application/diagnosis_provider.dart';
import '../domain/diagnosis_model.dart';
import 'diagnosis_history_screen.dart';
import 'widgets/camera_viewfinder.dart';
import 'widgets/diagnosis_result_card.dart';

/// Camera-based diagnosis flow. Provided as a tab body; the Home shell supplies
/// the Scaffold and app bar.
class DiagnosisScreen extends ConsumerWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DiagnosisState state = ref.watch(diagnosisControllerProvider);
    final DiagnosisController controller =
        ref.read(diagnosisControllerProvider.notifier);

    ref.listen(diagnosisControllerProvider.select((s) => s.error), (prev, next) {
      if (next != null && next != prev) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
              SnackBar(content: Text(ErrorMapper.message(l10n, next))));
      }
    });

    return switch (state.stage) {
      DiagnosisStage.capture => Stack(
          children: [
            Positioned.fill(
              child: CameraViewfinder(onImage: controller.setImage),
            ),
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: SafeArea(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const DiagnosisHistoryScreen()),
                  ),
                  icon: const Icon(Icons.history),
                  label: Text(l10n.diagnosisHistory),
                ),
              ),
            ),
          ],
        ),
      DiagnosisStage.confirm => _ConfirmView(state: state, controller: controller),
      DiagnosisStage.analyzing =>
        _AnalyzingView(state: state, onCancel: controller.cancelAnalysis),
      DiagnosisStage.result => _ResultView(state: state),
    };
  }
}

class _ConfirmView extends StatelessWidget {
  const _ConfirmView({required this.state, required this.controller});
  final DiagnosisState state;
  final DiagnosisController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: state.imageBytes != null
                  ? Image.memory(state.imageBytes!, fit: BoxFit.contain)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.retake,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retake),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _crop(context),
                  icon: const Icon(Icons.crop),
                  label: Text(l10n.cropImage),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => controller.analyze(),
                  icon: const Icon(Icons.biotech_outlined),
                  label: Text(l10n.confirmPhoto),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Lets the user crop to the affected area before analysis. Writes the bytes
  /// to a temp file (image_cropper works with paths), crops, then feeds the
  /// result back into the flow. Failure/cancel leaves the original image.
  Future<void> _crop(BuildContext context) async {
    final Uint8List? bytes = state.imageBytes;
    if (bytes == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      final Directory dir = Directory.systemTemp;
      final File temp = File(
          '${dir.path}/ps_crop_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await temp.writeAsBytes(bytes, flush: true);

      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: temp.path,
        uiSettings: [
          AndroidUiSettings(toolbarTitle: l10n.cropImage, lockAspectRatio: false),
          IOSUiSettings(title: l10n.cropImage),
        ],
      );
      if (cropped == null) return;
      final Uint8List newBytes = await File(cropped.path).readAsBytes();
      controller.setImage(newBytes);
    } catch (_) {
      // Cropping unavailable/cancelled — keep the original image silently.
    }
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView({required this.state, required this.onCancel});
  final DiagnosisState state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (state.imageBytes != null)
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(state.imageBytes!, fit: BoxFit.contain),
                Container(color: Colors.black.withValues(alpha: 0.35)),
                AppLoadingView(label: l10n.analyzing),
              ],
            ),
          ),
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
  final DiagnosisState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Diagnosis d = state.result!;
    final controller = ref.read(diagnosisControllerProvider.notifier);
    final String locale = ref.watch(localeProvider)?.languageCode ?? 'en';

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        if (state.imageBytes != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Image.memory(state.imageBytes!,
                  height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
        DiagnosisResultCard(diagnosis: d, locale: locale),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: state.saved ? null : controller.saveCurrent,
                icon: Icon(state.saved ? Icons.check : Icons.save_outlined),
                label: Text(state.saved ? l10n.diagnosisSaved : l10n.saveDiagnosis),
              ),
              OutlinedButton.icon(
                onPressed: () => _askFollowUp(context, ref, d),
                icon: const Icon(Icons.chat_outlined),
                label: Text(l10n.askFollowUp),
              ),
              OutlinedButton.icon(
                onPressed: () => _share(context, l10n, d),
                icon: const Icon(Icons.ios_share),
                label: Text(l10n.shareSummary),
              ),
              TextButton.icon(
                onPressed: controller.reset,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(l10n.retake),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _askFollowUp(BuildContext context, WidgetRef ref, Diagnosis d) {
    // Hand the diagnosis context to chat and switch to the chat tab so the user
    // does not have to repeat details.
    final String summary = d.plantName != null
        ? 'Follow-up about my ${d.plantName}: ${d.whatISee}'
        : 'Follow-up about my plant diagnosis: ${d.whatISee}';
    ref.read(chatFollowUpProvider.notifier).state = summary;
    ref.read(homeTabProvider.notifier).state = HomeTab.chat;
  }

  Future<void> _share(
      BuildContext context, AppLocalizations l10n, Diagnosis d) async {
    // Open the native share sheet with a plain-text summary.
    try {
      await Share.share(d.toShareText());
    } catch (_) {
      // Fallback to clipboard if sharing is unavailable on the platform.
      await Clipboard.setData(ClipboardData(text: d.toShareText()));
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(l10n.copied)));
      }
    }
  }
}
