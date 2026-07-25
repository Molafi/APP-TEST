import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/application/onboarding_provider.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
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
          data: (user) =>
              user == null ? const LoginScreen() : const HomeScreen(),
        );
      },
    );
  }
}
