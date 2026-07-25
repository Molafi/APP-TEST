import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Compact context strip shown above an AI reply, e.g.
/// "📍 Amman, JO · 🌡 32°C · 💧 45%". Indicates when cached weather was used.
class ContextStrip extends StatelessWidget {
  const ContextStrip({super.key, required this.text, this.fromCache = false});

  final String text;
  final bool fromCache;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.mossGray.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          fromCache ? '$text · ${l10n.cachedData}' : text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
