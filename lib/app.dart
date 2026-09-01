import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/locale_provider.dart';
import 'core/theme/theme_provider.dart';
import 'l10n/app_localizations.dart';

/// Root MaterialApp. Wires localization (EN/AR), light/dark themes and the
/// state-driven router. Directionality (LTR/RTL) is handled automatically by
/// Flutter based on the active locale — no manual Directionality wrapper.
class PlantSenseApp extends ConsumerWidget {
  const PlantSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale? locale = ref.watch(localeProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    // Resolved (not raw) so a user on an Arabic device who never opened
    // Settings still gets the Arabic font, matching the locale Flutter picks.
    final bool isArabic = ref.watch(appLocaleCodeProvider) == 'ar';

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppConstants.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: themeMode,
      theme: AppTheme.light(isArabic: isArabic),
      darkTheme: AppTheme.dark(isArabic: isArabic),
      // Cap text scaling so very large system fonts never clip critical UI,
      // while still honouring accessibility scaling within a sane range.
      builder: (context, child) {
        final MediaQueryData mq = MediaQuery.of(context);
        final double scale =
            mq.textScaler.scale(14) / 14; // resolve current factor
        final double clamped = scale.clamp(0.85, 1.6);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(clamped)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppRouter(),
    );
  }
}
