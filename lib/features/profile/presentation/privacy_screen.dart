import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Static privacy & data explanation. Content is fully localized.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<(IconData, String)> items = [
      (Icons.person_outline, l10n.privacyProfile),
      (Icons.location_on_outlined, l10n.privacyLocation),
      (Icons.image_outlined, l10n.privacyImages),
      (Icons.cloud_outlined, l10n.privacyProviders),
      (Icons.settings_backup_restore, l10n.privacyControl),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.privacyIntro,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          for (final (icon, text) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                      child: Text(text,
                          style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(l10n.aiDisclaimerLong,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
