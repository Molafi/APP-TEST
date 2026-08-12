/// Centralised, documented tuning constants and limits for the whole app.
/// Every network/model/image/validation limit lives here so behaviour is
/// predictable and testable.
class AppConfig {
  const AppConfig._();

  // --- Groq / AI -----------------------------------------------------------
  // Groq exposes an OpenAI-compatible Chat Completions API.
  static const String groqApiBase = 'https://api.groq.com/openai/v1';

  // OpenRouter is an OpenAI-compatible gateway fronting Claude, GPT and Gemini
  // behind one endpoint. Used here so image requests can be answered by Claude
  // Opus, which reads plant photos far better than the Llama vision models.
  //
  // NOTE: agentrouter.org was evaluated first and is NOT usable from an app.
  // It sits behind an Aliyun WAF that answers ordinary HTTP clients with an
  // HTTP 200 `text/html` JavaScript challenge page instead of JSON, so no API
  // key can make it work from Flutter (web, mobile or server). Override
  // [Environment.openRouterBaseUrlOverride] to point at any other
  // OpenAI-compatible relay.
  static const String openRouterApiBase = 'https://openrouter.ai/api/v1';
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
