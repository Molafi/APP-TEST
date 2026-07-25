/// Reads immutable, compile-time build configuration provided via
/// `--dart-define`. No secrets are stored here; the Groq key lives only on the
/// server (Cloud Function). Defaults are chosen so the app launches in a safe
/// demo mode without any credentials.
class Environment {
  const Environment._();

  /// When true the app runs entirely on local fake services and never contacts
  /// Firebase, Groq, Open-Meteo or Nominatim. Keeps the app launchable without
  /// any developer credentials.
  static const bool demoMode =
      bool.fromEnvironment('DEMO_MODE', defaultValue: true);

  /// Whether Firebase should be initialised. When false (or in demo mode) the
  /// app uses an in-memory auth/database fake.
  static const bool useFirebase =
      bool.fromEnvironment('USE_FIREBASE', defaultValue: false);

  /// Prefer the secure backend proxy for all AI traffic (the Cloud Function
  /// calls Groq server-side so the key never ships in the app).
  static const bool useAiBackend =
      bool.fromEnvironment('USE_AI_BACKEND', defaultValue: true);

  /// Endpoint of the deployed Cloud Function proxy (not a secret).
  static const String aiBackendUrl =
      String.fromEnvironment('AI_BACKEND_URL', defaultValue: '');

  /// DEV-ONLY escape hatch for calling Groq directly from the client. Guarded
  /// so it can never be enabled accidentally in a release without an explicit
  /// define. Use only for local development.
  static const bool allowDirectGroq =
      bool.fromEnvironment('ALLOW_DIRECT_GROQ', defaultValue: false);

  /// DEV-ONLY key supplied via --dart-define. Empty in all committed configs.
  static const String groqApiKey =
      String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

  /// Text (chat) model. Override if Groq's free lineup changes.
  static const String groqTextModel = String.fromEnvironment(
    'GROQ_TEXT_MODEL',
    defaultValue: 'llama-3.3-70b-versatile',
  );

  /// Vision model used when an image is attached (plant diagnosis).
  static const String groqVisionModel = String.fromEnvironment(
    'GROQ_VISION_MODEL',
    defaultValue: 'meta-llama/llama-4-scout-17b-16e-instruct',
  );

  /// True when neither a backend nor a valid dev key is configured, meaning we
  /// must fall back to canned demo AI responses.
  static bool get aiUnavailable {
    if (useAiBackend) return aiBackendUrl.isEmpty;
    if (allowDirectGroq) return groqApiKey.isEmpty;
    return true;
  }

  static bool get isDemo => demoMode || !useFirebase;
}
