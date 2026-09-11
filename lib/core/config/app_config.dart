/// Centralised, documented tuning constants and limits for the whole app.
/// Every network/model/image/validation limit lives here so behaviour is
/// predictable and testable.
class AppConfig {
  const AppConfig._();

  // --- Direct AI providers -------------------------------------------------
  // Both expose an OpenAI-compatible Chat Completions API, so the single
  // OpenAiCompatibleGateway serves either one by changing only the base URL.
  static const String groqApiBase = 'https://api.groq.com/openai/v1';
  static const String mistralApiBase = 'https://api.mistral.ai/v1';

  /// Base URL for a DEV-ONLY direct provider name.
  ///
  /// A pure function of the name rather than a lookup against the compile-time
  /// defines, so every branch is unit-testable. Unknown, empty and misspelled
  /// names fall back to Groq: silently pointing at the wrong host would surface
  /// as a confusing 401 from a provider the developer never chose.
  static String directAiBaseFor(String provider) {
    return switch (provider.trim().toLowerCase()) {
      'mistral' => mistralApiBase,
      _ => groqApiBase,
    };
  }

  static const Duration aiTimeout = Duration(seconds: 45);
  static const int aiMaxRetries = 3;
  static const int maxInputChars = 4000;
  static const int maxContextMessages = 20;

  // --- Image handling ------------------------------------------------------
  static const int maxImageDimension = 1280; // px, longest edge
  static const int maxImageBytes = 4 * 1024 * 1024; // 4 MB after compression
  static const int imageJpegQuality = 82;
  static const int maxAttachedImages = 1;

  // --- Weather cache -------------------------------------------------------
  static const Duration weatherCacheTtl = Duration(minutes: 30);
  static const Duration weatherStaleAfter = Duration(hours: 3);

  // --- Geocoding -----------------------------------------------------------
  static const String nominatimBase = 'https://nominatim.openstreetmap.org';
  static const String nominatimUserAgent =
      'PlantSenseAI/1.0 (contact: support@plantsense.example)';
  static const Duration geocodeSearchDebounce = Duration(milliseconds: 600);
  static const Duration geocodeCacheTtl = Duration(days: 7);
  static const Duration nominatimMinInterval = Duration(seconds: 1);

  // --- Weather API ---------------------------------------------------------
  static const String openMeteoBase = 'https://api.open-meteo.com/v1/forecast';

  // --- Networking ----------------------------------------------------------
  static const Duration httpTimeout = Duration(seconds: 20);
  static const int httpMaxRetries = 3;

  // --- Validation ----------------------------------------------------------
  static const int maxEmailChars = 254;
  static const int minPasswordChars = 8;
  static const int maxPasswordChars = 128;
  static const int maxDisplayNameChars = 60;

  // --- Rate limits (client side UX guard; enforced again on backend) -------
  static const Duration minTimeBetweenDiagnoses = Duration(seconds: 3);
  static const Duration minTimeBetweenAiRequests = Duration(milliseconds: 800);

  // --- Pagination ----------------------------------------------------------
  static const int chatPageSize = 30;
  static const int historyPageSize = 20;
}
