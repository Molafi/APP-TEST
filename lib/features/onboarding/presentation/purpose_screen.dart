import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/leaf_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../georesearch/application/soil_research_provider.dart';
import '../../georesearch/domain/site_survey_model.dart';
import '../../georesearch/presentation/widgets/purpose_label.dart';
import '../../home/application/home_provider.dart';
import '../application/app_purpose_provider.dart';

/// One-time purpose picker shown at app start (after onboarding and auth,
/// before Home). Lets the user say what they want the app for — plants,
/// building, wells, etc. — reusing the existing [SurveyPurpose] enum.
///
/// Requests NO permissions here (those are contextual, like onboarding). The
/// choice sets the initial Home tab and seeds the GeoResearch survey purpose.
class PurposeScreen extends ConsumerStatefulWidget {
  const PurposeScreen({super.key});

  @override
  ConsumerState<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends ConsumerState<PurposeScreen> {
  /// The purpose to apply on Continue. Defaults to general so the button is
  /// always actionable; the selection is confirmed explicitly.
  SurveyPurpose _selected = SurveyPurpose.general;

  /// Icon for each purpose, matching the chips in survey_inputs_section.dart.
  static IconData _iconFor(SurveyPurpose purpose) {
    return switch (purpose) {
      SurveyPurpose.general => Icons.explore_outlined,
      SurveyPurpose.agriculture => Icons.agriculture_outlined,
      SurveyPurpose.building => Icons.foundation_outlined,
      SurveyPurpose.wellDrilling => Icons.water_drop_outlined,
      SurveyPurpose.slopeStability => Icons.terrain_outlined,
    };
  }

  Future<void> _confirm() async {
    final SurveyPurpose chosen = _selected;
    // Set the target Home tab and seed the GeoResearch survey BEFORE the
    // persisted purpose write. setPurpose assigns provider state synchronously,
    // which flips the router to Home; doing that last would let Home build one
    // frame on its default Chat tab before correcting. Ordering the tab/seed
    // first means the very first Home frame is already on the right tab.
    ref.read(homeTabProvider.notifier).state = homeTabForPurpose(chosen);
    ref.read(soilResearchControllerProvider.notifier).setPurpose(chosen);
    await ref.read(appPurposeProvider.notifier).setPurpose(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl),
              child: LeafLogo(size: 72),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xs,
              ),
              child: Text(
                l10n.purposeScreenTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                l10n.purposeScreenSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  for (final SurveyPurpose p in SurveyPurpose.values)
                    _PurposeCard(
                      icon: _iconFor(p),
                      label: purposeLabel(p, l10n),
                      selected: p == _selected,
                      onTap: () => setState(() => _selected = p),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _confirm,
                  child: Text(l10n.purposeScreenContinue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A large, accessible option card. Selection is signalled by BOTH a check icon
/// and the border/colour, so the state is never conveyed by colour alone.
class _PurposeCard extends StatelessWidget {
  const _PurposeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(
                  color: selected ? scheme.primary : scheme.outlineVariant,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 28, color: scheme.primary),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected ? scheme.primary : scheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
