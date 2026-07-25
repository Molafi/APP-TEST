import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/leaf_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../application/onboarding_provider.dart';

class _Page {
  const _Page(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

/// First-launch onboarding. Explains the app, image analysis, location value
/// and privacy/control. Requests NO permissions here — those are contextual.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingCompleteProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<_Page> pages = [
      _Page(Icons.chat_bubble_outline, l10n.onboardingTitle1, l10n.onboardingBody1),
      _Page(Icons.camera_alt_outlined, l10n.onboardingTitle2, l10n.onboardingBody2),
      _Page(Icons.wb_sunny_outlined, l10n.onboardingTitle3, l10n.onboardingBody3),
      _Page(Icons.shield_outlined, l10n.onboardingTitle4, l10n.onboardingBody4),
    ];
    final bool isLast = _index == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.skip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final _Page p = pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (i == 0)
                          const LeafLogo(size: 96)
                        else
                          Icon(p.icon,
                              size: 96,
                              color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(p.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: AppSpacing.md),
                        Text(p.body,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  );
                },
              ),
            ),
            _Dots(count: pages.length, index: _index),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  if (_index > 0)
                    TextButton(
                      onPressed: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                      child: Text(l10n.back),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (isLast) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Text(isLast ? l10n.getStarted : l10n.next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          height: 8,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active ? AppColors.leafGreen : AppColors.mossGray,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
