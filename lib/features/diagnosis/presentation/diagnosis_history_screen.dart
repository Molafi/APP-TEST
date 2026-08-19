import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/diagnosis_provider.dart';
import '../domain/diagnosis_model.dart';
import 'widgets/diagnosis_result_card.dart';

/// List of saved diagnoses with the ability to view details and delete.
class DiagnosisHistoryScreen extends ConsumerWidget {
  const DiagnosisHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Diagnosis>> history = ref.watch(
      diagnosisHistoryProvider,
    );
    final String locale = ref.watch(localeProvider)?.languageCode ?? 'en';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagnosisHistory)),
      body: history.when(
        loading: () => const AppLoadingView(),
        error: (e, _) => AppErrorView(
          error: e,
          onRetry: () => ref.invalidate(diagnosisHistoryProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyView(
              icon: Icons.local_florist_outlined,
              title: l10n.diagnosisHistoryEmpty,
              message: l10n.diagnosisHistoryEmptyBody,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(diagnosisHistoryProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                final Diagnosis d = items[i];
                return ListTile(
                  leading: const Icon(Icons.eco_outlined),
                  title: Text(d.plantName ?? l10n.diagnosisPlant),
                  subtitle: Text(
                    d.createdAt != null
                        ? DateFormatter.dayAndDate(d.createdAt!, locale)
                        : '',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.delete,
                    onPressed: () => _confirmDelete(context, ref, l10n, d),
                  ),
                  onTap: () => _openDetail(context, d, locale),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, Diagnosis d, String locale) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: Text(
              d.plantName ?? AppLocalizations.of(ctx).diagnosisHistory,
            ),
          ),
          body: ListView(
            children: [DiagnosisResultCard(diagnosis: d, locale: locale)],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Diagnosis d,
  ) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.deleteConversationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok == true && d.id != null) {
      await ref.read(diagnosisRepositoryProvider).delete(d.id!);
      ref.invalidate(diagnosisHistoryProvider);
    }
  }
}
