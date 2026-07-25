/// Reads immutable, compile-time build configuration provided via
/// `--dart-define`. No secrets are stored here; the Gemini key lives only on
/// the server. Defaults are chosen so the app launches in a safe demo mode.
class Environment {
  const Environment._();

  /// When true the app runs entirely on local fake services and never contacts
  /// Firebase, Gemini, Open-Meteo or Nominatim. This keeps the app launchable
  /// without any developer credentials.
  static const bool demoMode =
      bool.fromEnvironment('DEMO_MODE', defaultValue: true);

  /// Whether Firebase should be initialised. When false (or in demo mode) the
  /// app uses an in-memory auth/database fake.
  static const bool useFirebase =
      bool.fromEnvironment('USE_FIREBASE', defaultValue: false);

  /// Prefer the secure backend proxy for all Gemini traffic.
  static const bool useGeminiBackend =
      bool.fromEnvironment('USE_GEMINI_BACKEND', defaultValue: true);

  /// Endpoint of the deployed Cloud Function proxy (not a secret).
  static const String geminiBackendUrl =
      String.fromEnvironment('GEMINI_BACKEND_URL', defaultValue: '');

  /// DEV-ONLY escape hatch for calling Gemini directly. Guarded so it can never
  /// be enabled accidentally in a release without an explicit define.
  static const bool allowDirectGemini =
      bool.fromEnvironment('ALLOW_DIRECT_GEMINI', defaultValue: false);

  /// DEV-ONLY key supplied via --dart-define. Empty in all committed configs.
  static const String geminiDevApiKey =
      String.fromEnvironment('GEMINI_DEV_API_KEY', defaultValue: '');

  static const String geminiModel =
      String.fromEnvironment('GEMINI_MODEL', defaultValue: 'gemini-2.0-flash');

  /// True when neither a backend nor a valid dev key is configured, meaning we
  /// must fall back to canned demo AI responses.
  static bool get geminiUnavailable {
    if (useGeminiBackend) return geminiBackendUrl.isEmpty;
    if (allowDirectGemini) return geminiDevApiKey.isEmpty;
    return true;
  }

  static bool get isDemo => demoMode || !useFirebase;
}
