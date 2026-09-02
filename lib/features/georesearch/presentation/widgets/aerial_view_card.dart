import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/site_survey_model.dart';

/// Shows the aerial/satellite view of the site plus the AI's reading of what
/// such a view implies. The image is a public map tile, so it can fail to load
/// (offline, blocked network); loading and error states degrade gracefully to a
/// placeholder rather than a broken image or an exception.
class AerialViewCard extends StatelessWidget {
  const AerialViewCard({super.key, required this.info});

  final AerialImageryInfo info;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.url.isNotEmpty)
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                info.url,
                fit: BoxFit.cover,
                // Decorative-with-caption: the interpretation text below
                // conveys the meaning, so keep the label short.
                semanticLabel: l10n.georesearchAerial,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const ColoredBox(
                    color: Color(0x11000000),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stack) =>
                    _Placeholder(text: l10n.georesearchAerialNotice),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🛰️  ${l10n.georesearchAerial}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (info.landCover != null)
                  _kv(
                    context,
                    l10n.georesearchAerialLandCover,
                    info.landCover!,
                  ),
                if (info.interpretation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(info.interpretation!),
                  ),
                if (info.visibleFeatures.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.georesearchAerialFeatures,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  for (final String f in info.visibleFeatures)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(child: Text(f)),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.georesearchAerialNotice,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.mossGray,
                  ),
                ),
                if (info.attribution.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      info.attribution,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mossGray,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String label, String value) {
    return RichText(
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
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x11000000),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.satellite_alt_outlined, size: 40),
              const SizedBox(height: AppSpacing.sm),
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
