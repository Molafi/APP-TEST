import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/config/app_config.dart';

void main() {
  group('AppConfig.directAiBaseFor', () {
    test('routes each known provider to its OpenAI-compatible base', () {
      expect(
        AppConfig.directAiBaseFor('groq'),
        'https://api.groq.com/openai/v1',
      );
      expect(
        AppConfig.directAiBaseFor('mistral'),
        'https://api.mistral.ai/v1',
      );
    });

    test('is case- and whitespace-insensitive', () {
      // AI_PROVIDER comes from a hand-edited dart-define, so "Mistral" and a
      // stray space must resolve the same as the canonical value.
      expect(AppConfig.directAiBaseFor('MISTRAL'), AppConfig.mistralApiBase);
      expect(AppConfig.directAiBaseFor('  mistral '), AppConfig.mistralApiBase);
    });

    test('an unknown or empty provider falls back to Groq, not a bad host', () {
      // Pointing at the wrong base silently would surface as a confusing 401
      // from a provider the developer never chose, so a misspelling degrades to
      // the default rather than to nothing.
      expect(AppConfig.directAiBaseFor(''), AppConfig.groqApiBase);
      expect(AppConfig.directAiBaseFor('gorq'), AppConfig.groqApiBase);
      expect(AppConfig.directAiBaseFor('openai'), AppConfig.groqApiBase);
    });
  });
}
