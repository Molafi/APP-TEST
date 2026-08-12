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

  /// Backup models used automatically if the primary one is unavailable (Groq's
  /// free lineup changes over time, so a fallback keeps the app working).
  static const String groqTextModelFallback = String.fromEnvironment(
    'GROQ_TEXT_MODEL_FALLBACK',
    defaultValue: 'llama-3.1-8b-instant',
  );
  static const String groqVisionModelFallback = String.fromEnvironment(
    'GROQ_VISION_MODEL_FALLBACK',
    defaultValue: 'meta-llama/llama-4-maverick-17b-128e-instruct',
  );

  static List<String> get groqTextModels =>
      _dedupe([groqTextModel, groqTextModelFallback]);
  static List<String> get groqVisionModels =>
      _dedupe([groqVisionModel, groqVisionModelFallback]);

  // --- OpenRouter (Claude Opus vision) ------------------------------------
  // OpenRouter is an OpenAI-compatible gateway fronting Claude/GPT/Gemini.
  // Its main use here is image understanding: Claude Opus reads plant photos
  // far more reliably than the Llama vision models, so diagnosis quality
  // improves noticeably. Text chat can stay on Groq (faster and cheaper).

  /// Enables the OpenRouter transport. Off by default so nothing changes for
  /// existing builds.
  static const bool useOpenRouter =
      bool.fromEnvironment('USE_OPENROUTER', defaultValue: false);

  /// DEV-ONLY OpenRouter key (`sk-or-v1-...`) supplied via --dart-define. Never
  /// committed; for release builds use the Cloud Function proxy instead.
  static const String openRouterApiKey =
      String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');

  /// Optional base-URL override (for self-hosted or mirror relays). Empty means
  /// use [AppConfig.openRouterApiBase].
  static const String openRouterBaseUrlOverride =
      String.fromEnvironment('OPENROUTER_BASE_URL', defaultValue: '');

  /// Vision model for image requests. Model IDs on relays drift, so the
  /// fallback is tried automatically when the primary returns 404/400.
  static const String openRouterVisionModel = String.fromEnvironment(
    'OPENROUTER_VISION_MODEL',
    defaultValue: 'anthropic/claude-opus-4.8',
  );
  static const String openRouterVisionModelFallback = String.fromEnvironment(
    'OPENROUTER_VISION_MODEL_FALLBACK',
    defaultValue: 'anthropic/claude-opus-4.6',
  );

  /// Text model, used only when OpenRouter also serves plain chat (i.e. no
  /// Groq key is configured).
  static const String openRouterTextModel = String.fromEnvironment(
    'OPENROUTER_TEXT_MODEL',
    defaultValue: 'anthropic/claude-opus-4.8',
  );
  static const String openRouterTextModelFallback = String.fromEnvironment(
    'OPENROUTER_TEXT_MODEL_FALLBACK',
    defaultValue: 'anthropic/claude-opus-4.6',
  );

  static List<String> get openRouterVisionModels =>
      _dedupe([openRouterVisionModel, openRouterVisionModelFallback]);
  static List<String> get openRouterTextModels =>
      _dedupe([openRouterTextModel, openRouterTextModelFallback]);

  /// True when OpenRouter is switched on *and* actually usable.
  static bool get openRouterReady =>
      useOpenRouter && openRouterApiKey.isNotEmpty;

  /// True when the direct Groq transport is switched on *and* usable.
  static bool get directGroqReady =>
      allowDirectGroq && groqApiKey.isNotEmpty;

  static List<String> _dedupe(List<String> models) {
    final seen = <String>{};
    return [
      for (final m in models)
        if (m.isNotEmpty && seen.add(m)) m,
    ];
  }

  /// True when neither a backend nor a valid dev key is configured, meaning we
  /// must fall back to canned demo AI responses.
  static bool get aiUnavailable {
    if (useAiBackend) return aiBackendUrl.isEmpty;
    // Either direct transport being usable is enough to leave demo mode.
    return !openRouterReady && !directGroqReady;
  }

  static bool get isDemo => demoMode || !useFirebase;
}
