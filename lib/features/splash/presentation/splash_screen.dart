import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/leaf_logo.dart';
import '../../../l10n/app_localizations.dart';

/// Polished splash with a subtle leaf-growth animation. Honors reduced-motion
/// and can render a recoverable error (with retry) so the user is never stuck.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.error, this.onRetry});

  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget logo = const LeafLogo(size: 120, color: AppColors.leafGreen);
    if (!reduceMotion && error == null) {
      logo = logo
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1.04, 1.04),
            duration: 1600.ms,
            curve: Curves.easeInOut,
          )
          .fadeIn(duration: 600.ms);
    }

    return Scaffold(
      backgroundColor: AppColors.forestGreen,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logo,
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.parchment,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.tagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.parchmentDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (error == null)
                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.parchment,
                    ),
                  ),
                )
              else ...[
                Text(
                  l10n.somethingWentWrong,
                  style: const TextStyle(color: AppColors.parchment),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (onRetry != null)
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
