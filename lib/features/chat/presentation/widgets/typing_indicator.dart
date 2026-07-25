import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Three-dot leaf-green typing indicator. Respects reduced-motion by showing a
/// static row of dots and a label instead of animating.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion && !_controller.isAnimating) {
      _controller.repeat();
    }

    return Semantics(
      liveRegion: true,
      label: l10n.typing,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reduceMotion)
              const _Dots(t: 0.5)
            else
              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => _Dots(t: _controller.value),
              ),
            const SizedBox(width: 8),
            Text(l10n.typing,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.t});
  final double t;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final double phase = (t + i * 0.2) % 1.0;
        final double opacity = 0.3 + 0.7 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Opacity(
            opacity: opacity.clamp(0.3, 1.0),
            child: const CircleAvatar(
              radius: 4,
              backgroundColor: AppColors.leafGreen,
            ),
          ),
        );
      }),
    );
  }
}
