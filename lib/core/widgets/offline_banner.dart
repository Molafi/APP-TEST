import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_spacing.dart';
import '../services/connectivity_service.dart';

/// Non-blocking banner shown when the device is offline. Collapses to nothing
/// when online so it never occupies space or blocks interaction.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool online =
        ref.watch(connectivityStatusProvider).valueOrNull ?? true;
    if (online) return const SizedBox.shrink();

    final AppLocalizations l10n = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [
              const Icon(Icons.cloud_off, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.offlineBanner,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
