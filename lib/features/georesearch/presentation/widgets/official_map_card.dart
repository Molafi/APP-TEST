import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/site_survey_model.dart';

/// Shows the national mapping authority reference for the site: the projected
/// national-grid coordinates (Jordan Transverse Mercator for RJGC), the
/// authority basemap when one is licensed for the build, and the links for
/// viewing the geoportal or ordering official map sheets, aerial photographs
/// and cadastral extracts.
///
/// Links are copied to the clipboard rather than launched: the project has no
/// URL-launcher dependency, and a copyable address works on every platform
/// including the web build.
///
/// The grid numbers are rendered left-to-right explicitly. Under an Arabic
/// (RTL) layout a bare "397021.1" next to a label can otherwise be reordered by
/// the bidirectional algorithm, and a transposed coordinate handed to a
/// surveyor is worse than no coordinate at all.
class OfficialMapCard extends StatelessWidget {
  const OfficialMapCard({super.key, required this.info});

  final OfficialMapReference info;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.tileUrl != null && info.tileUrl!.isNotEmpty)
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                info.tileUrl!,
                fit: BoxFit.cover,
                semanticLabel: l10n.georesearchOfficialMap,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const ColoredBox(
                    color: Color(0x11000000),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stack) =>
                    _Placeholder(text: l10n.georesearchOfficialMapNotice),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🗺️  ${l10n.georesearchOfficialMap}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),

                if (info.authority.isNotEmpty)
                  _LabelValue(
                    label: l10n.georesearchOfficialMapAuthority,
                    value: info.authority,
                  ),

                if (info.hasGrid) ...[
                  _LabelValue(
                    label: l10n.georesearchOfficialMapGrid,
                    value: info.gridCode != null
                        ? '${info.gridName} (${info.gridCode})'
                        : info.gridName,
                  ),
                  _LabelValue(
                    label: l10n.georesearchOfficialMapEasting,
                    value: '${info.easting!.toStringAsFixed(1)} m',
                    ltrValue: true,
                  ),
                  _LabelValue(
                    label: l10n.georesearchOfficialMapNorthing,
                    value: '${info.northing!.toStringAsFixed(1)} m',
                    ltrValue: true,
                  ),
                ],

                if (info.latitude != null && info.longitude != null)
                  _LabelValue(
                    label: l10n.georesearchOfficialMapWgs,
                    value:
                        '${info.latitude!.toStringAsFixed(5)}, '
                        '${info.longitude!.toStringAsFixed(5)}',
                    ltrValue: true,
                  ),

                // Provenance of the conversion, right next to the numbers it
                // qualifies rather than buried in the footer.
                if (info.hasGrid)
                  _Notice(
                    text: info.datumShiftApplied
                        ? l10n.georesearchOfficialMapShifted
                        : l10n.georesearchOfficialMapUnshifted,
                    warning: !info.datumShiftApplied,
                  ),

                if (info.tileUrl == null)
                  _Notice(text: l10n.georesearchOfficialMapTileUnavailable),

                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (info.hasGrid)
                      ActionChip(
                        avatar: const Icon(Icons.copy_all_outlined, size: 18),
                        label: Text(l10n.georesearchOfficialMapCopy),
                        onPressed: () => _copy(
                          context,
                          info.gridReferenceLine()!,
                          l10n.georesearchOfficialMapCopied,
                        ),
                      ),
                    if (info.portalUrl != null)
                      ActionChip(
                        avatar: const Icon(Icons.public_outlined, size: 18),
                        label: Text(l10n.georesearchOfficialMapPortal),
                        onPressed: () =>
                            _copy(context, info.portalUrl!, l10n.copied),
                      ),
                    if (info.orderUrl != null)
                      ActionChip(
                        avatar: const Icon(Icons.map_outlined, size: 18),
                        label: Text(l10n.georesearchOfficialMapOrder),
                        onPressed: () =>
                            _copy(context, info.orderUrl!, l10n.copied),
                      ),
                  ],
                ),

                // Selectable so the address can be read and copied by hand too.
                if (info.portalUrl != null || info.orderUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: SelectableText(
                      [
                        if (info.portalUrl != null) info.portalUrl!,
                        if (info.orderUrl != null) info.orderUrl!,
                      ].join('\n'),
                      textDirection: TextDirection.ltr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mossGray,
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.georesearchOfficialMapNotice,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.mossGray,
                  ),
                ),
                if (info.tileAttribution != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      info.tileAttribution!,
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

  Future<void> _copy(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({
    required this.label,
    required this.value,
    this.ltrValue = false,
  });
  final String label;
  final String value;

  /// Forces LTR for bare numeric values so RTL layouts cannot reorder them.
  final bool ltrValue;

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: base?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              style: base,
              textDirection: ltrValue ? TextDirection.ltr : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.warning = false});
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final Color color = warning ? AppColors.confidenceLow : AppColors.mossGray;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.warning_amber_outlined : Icons.info_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: warning ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
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
              const Icon(Icons.map_outlined, size: 40),
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
