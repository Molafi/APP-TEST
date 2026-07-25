import 'package:flutter/widgets.dart';

/// App-wide non-tuning constants: supported locales, route names, prefs keys.
class AppConstants {
  const AppConstants._();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
    Locale('es'),
  ];

  // SharedPreferences keys.
  static const String prefOnboardingComplete = 'onboarding_complete_v1';
  static const String prefLanguageChosen = 'language_chosen_v1';
  static const String prefLocale = 'app_locale';
  static const String prefThemeMode = 'app_theme_mode';
  static const String prefUnitSystem = 'unit_system';
  static const String prefSelectedLocation = 'selected_location';
  static const String prefCachedWeather = 'cached_weather';
  static const String prefImageRetention = 'image_retention_enabled';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefAnalyticsEnabled = 'analytics_enabled';
  static const String prefReminders = 'reminders_local';
  static const String prefGeocodeCachePrefix = 'geocode_';

  // Route names.
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeHome = '/home';
  static const String routeDiagnosisHistory = '/diagnosis-history';
  static const String routeReminders = '/reminders';
  static const String routeSettings = '/settings';
  static const String routePrivacy = '/privacy';
}

enum UnitSystem { metric, imperial }

extension UnitSystemX on UnitSystem {
  String get id => name;
  static UnitSystem fromId(String? id) => UnitSystem.values.firstWhere(
        (e) => e.name == id,
        orElse: () => UnitSystem.metric,
      );
}
