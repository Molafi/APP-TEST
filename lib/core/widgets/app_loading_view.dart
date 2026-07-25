import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

/// Centered loading indicator with an optional label. Respects reduced motion
/// by using the platform's default (non-flashy) progress indicator.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(label!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
