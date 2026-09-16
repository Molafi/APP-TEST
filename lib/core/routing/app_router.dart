import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/application/app_purpose_provider.dart';
import '../../features/onboarding/application/onboarding_provider.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/purpose_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../bootstrap.dart';

/// State-driven root router. Chooses the top-level screen from startup status,
/// onboarding completion and auth state. Avoids flicker between protected
/// screens by keying transitions on resolved values only.
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> startup = ref.watch(appStartupProvider);

    return startup.when(
      loading: () => const SplashScreen(),
      error: (err, _) => SplashScreen(
        error: err,
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
      data: (_) {
        final bool onboarded = ref.watch(onboardingCompleteProvider);
        if (!onboarded) return const OnboardingScreen();

        final auth = ref.watch(authStateProvider);
        return auth.when(
          loading: () => const SplashScreen(),
          error: (_, __) => const LoginScreen(),
          data: (user) {
            if (user == null) return const LoginScreen();
            // Purpose picker on EVERY entry to the app, not just the first.
            // Gated on the session flag rather than the persisted purpose: the
            // flag resets on each launch (fresh provider container), while the
            // stored purpose survives to pre-select the last choice.
            final bool confirmed = ref.watch(
              purposeConfirmedThisSessionProvider,
            );
            if (!confirmed) return const PurposeScreen();
            return const HomeScreen();
          },
        );
      },
    );
  }
}
