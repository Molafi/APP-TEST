/// Reads immutable, compile-time build configuration provided via
/// `--dart-define`. No secrets are stored here; the Groq key lives only on the
/// server (Cloud Function). Defaults are chosen so the app launches in a safe
/// demo mode without any credentials.
class Environment {
  const Environment._();

  /// When true the app runs entirely on local fake services and never contacts
  /// Firebase, Groq, Open-Meteo or Nominatim. Keeps the app launchable without
  /// any developer credentials.
  static const bool demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );

  /// Whether Firebase should be initialised. When false (or in demo mode) the
  /// app uses an in-memory auth/database fake.
  static const bool useFirebase = bool.fromEnvironment(
    'USE_FIREBASE',
    defaultValue: false,
  );

  /// Prefer the secure backend proxy for all AI traffic (the Cloud Function
  /// calls Groq server-side so the key never ships in the app).
  static const bool useAiBackend = bool.fromEnvironment(
    'USE_AI_BACKEND',
    defaultValue: true,
  );

  /// Endpoint of the deployed Cloud Function proxy (not a secret).
  static const String aiBackendUrl = String.fromEnvironment(
    'AI_BACKEND_URL',
    defaultValue: '',
  );

  /// DEV-ONLY escape hatch for calling Groq directly from the client. Guarded
  /// so it can never be enabled accidentally in a release without an explicit
  /// define. Use only for local development.
  static const bool allowDirectGroq = bool.fromEnvironment(
    'ALLOW_DIRECT_GROQ',
    defaultValue: false,
  );

  /// DEV-ONLY key supplied via --dart-define. Empty in all committed configs.
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

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

  static List<String> _dedupe(List<String> models) {
    final seen = <String>{};
    return [
      for (final m in models)
        if (m.isNotEmpty && seen.add(m)) m,
    ];
  }

  // ---------------------------------------------------------------------------
  // National mapping authority (Royal Jordanian Geographic Centre — RJGC)
  //
  // RJGC does not publish an open, keyless tile service: access to its official
  // basemaps normally requires an agreement with the Centre. So the endpoint is
  // a build-time define rather than a constant, and every RJGC feature degrades
  // gracefully when it is absent — the grid-coordinate conversion and the
  // public links still work, only the official basemap layer is unavailable.
  // ---------------------------------------------------------------------------

  /// XYZ/WMTS tile template for the authority basemap, using `{z}`, `{x}` and
  /// `{y}` placeholders. Empty means "not licensed for this build".
  static const String rjgcTileUrl = String.fromEnvironment(
    'RJGC_TILE_URL',
    defaultValue: '',
  );

  /// Attribution string the authority requires alongside its imagery.
  static const String rjgcTileAttribution = String.fromEnvironment(
    'RJGC_TILE_ATTRIBUTION',
    defaultValue: '',
  );

  /// Public geoportal / map viewer.
  static const String rjgcPortalUrl = String.fromEnvironment(
    'RJGC_PORTAL_URL',
    defaultValue: 'https://rjgc.gov.jo/',
  );

  /// Where official maps, aerial photographs and cadastral extracts are ordered.
  static const String rjgcOrderUrl = String.fromEnvironment(
    'RJGC_ORDER_URL',
    defaultValue: 'https://rjgc.gov.jo/eservices/',
  );

  /// Optional geocentric datum shift from WGS84 to the Jordanian national datum
  /// as `dx,dy,dz` in metres (a 3-parameter Molodensky translation).
  ///
  /// Left EMPTY on purpose: the official parameters must come from RJGC, and
  /// inventing them would silently bias every converted coordinate. When empty
  /// the conversion is performed without a datum shift and is labelled as such.
  static const String jtmDatumShift = String.fromEnvironment(
    'JTM_DATUM_SHIFT',
    defaultValue: '',
  );

  static bool get rjgcTilesConfigured => rjgcTileUrl.isNotEmpty;

  /// True when neither a backend nor a valid dev key is configured, meaning we
  /// must fall back to canned demo AI responses.
  static bool get aiUnavailable {
    if (useAiBackend) return aiBackendUrl.isEmpty;
    if (allowDirectGroq) return groqApiKey.isEmpty;
    return true;
  }

  static bool get isDemo => demoMode || !useFirebase;
}
