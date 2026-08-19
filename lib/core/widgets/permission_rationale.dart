import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// Reusable card explaining why a permission is needed, with primary and
/// secondary actions (e.g. "Allow" / "Use manual entry" or "Open Settings").
class PermissionRationale extends StatelessWidget {
  const PermissionRationale({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
