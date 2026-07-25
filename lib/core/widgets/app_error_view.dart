import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_spacing.dart';
import '../errors/app_exception.dart';
import '../errors/error_mapper.dart';

/// Reusable recoverable-error view with an actionable retry button. Never shows
/// raw exception text.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  final Object error;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppException e = ErrorMapper.fromException(error);
    final String message = ErrorMapper.message(l10n, e);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, semanticLabel: l10n.a11yError),
            const SizedBox(height: AppSpacing.lg),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
