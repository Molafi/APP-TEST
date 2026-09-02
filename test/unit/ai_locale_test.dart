import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/services/ai_gateway.dart';
import 'package:plantsense_ai/core/services/demo_ai_gateway.dart';
import 'package:plantsense_ai/core/theme/locale_provider.dart';
import 'package:plantsense_ai/features/georesearch/data/soil_research_service.dart';
import 'package:plantsense_ai/features/georesearch/domain/soil_report_model.dart';

import '../mocks/mocks.dart';

/// Regression tests for "switching to Arabic does not translate everything".
///
/// Two independent causes were at play:
///  1. the effective locale was resolved as `en` whenever the user had not
///     explicitly picked a language, even on an Arabic device;
///  2. the demo gateway — the DEFAULT gateway when no AI provider is configured
///     — returned hardcoded English text regardless of locale.
void main() {
  group('resolveAppLocale', () {
    test('an explicit supported choice wins', () {
      expect(
        resolveAppLocale(
          const Locale('ar'),
          deviceLocales: const [Locale('en')],
        ).languageCode,
        'ar',
      );
    });

    test('following the device resolves the device language, not English', () {
      // This is the bug: an Arabic device with no explicit choice used to send
      // `en` to the AI while the UI rendered Arabic.
      expect(
        resolveAppLocale(
          null,
          deviceLocales: const [Locale('ar')],
        ).languageCode,
        'ar',
      );
      expect(
        resolveAppLocale(
          null,
          deviceLocales: const [Locale('ar', 'JO')],
        ).languageCode,
        'ar',
      );
    });

    test('every supported language is preserved, not clamped to en/ar', () {
      for (final String code in const ['en', 'ar', 'fr', 'es']) {
        expect(
          resolveAppLocale(Locale(code), deviceLocales: const []).languageCode,
          code,
        );
      }
    });

    test('an unsupported language falls back through the device list', () {
      expect(
        resolveAppLocale(
          const Locale('de'),
          deviceLocales: const [Locale('fr')],
        ).languageCode,
        'fr',
      );
      // Nothing usable anywhere: the first supported locale is used, matching
      // MaterialApp's own behaviour.
      expect(
        resolveAppLocale(
          const Locale('de'),
          deviceLocales: const [Locale('de')],
        ).languageCode,
        'en',
      );
    });
  });

  group('AiRequest carries the locale to the transport', () {
    test('the soil-research service passes it through', () async {
      final gateway = FakeAiGateway(reply: _minimalReply);
      await SoilResearchService(gateway).analyze(locale: 'ar');

      expect(gateway.lastRequest!.locale, 'ar');
      // And the backend payload forwards it, so the Cloud Function can enforce
      // the language server-side too.
      expect(gateway.lastRequest!.toBackendPayload()['locale'], 'ar');
    });

    test('it defaults to English rather than being null', () {
      const request = AiRequest(systemPrompt: 's', userText: 'u');
      expect(request.locale, 'en');
    });
  });

  group('DemoAiGateway localizes its canned content', () {
    test('the soil report comes back in Arabic', () async {
      final report = await SoilResearchService(
        DemoAiGateway(),
      ).analyze(locale: 'ar', context: const {'city': 'العقبة'});

      // The exact English string from the original bug report must be gone.
      expect(report.siteLocation!.elevation, isNot(contains('Approximately')));
      expect(report.siteLocation!.elevation, contains('نحو'));
      expect(report.soilType, contains('تربة'));
      expect(report.disclaimer, contains('تقديرات'));
      expect(report.slopeStability!.movementDirection, contains('حركة'));
      expect(report.recommendations.first, isNot(matches(r'^[A-Za-z]')));
    });

    test('English is unchanged', () async {
      final report = await SoilResearchService(
        DemoAiGateway(),
      ).analyze(locale: 'en');

      expect(report.siteLocation!.elevation, contains('Approximately'));
      expect(report.soilType, contains('Sandy loam'));
    });

    test('enum tokens stay English so the report still parses', () async {
      // Translating "low"/"medium"/"high" or "good"/"poor"/"unusable" would make
      // the tolerant parsers silently drop levels — the opposite of a fix.
      final report = await SoilResearchService(
        DemoAiGateway(),
      ).analyze(locale: 'ar');

      expect(report.confidence, Confidence.low);
      expect(report.salinity!.level, SoilLevel.low);
      expect(report.slopeStability!.hazardLevel, SoilLevel.low);
      expect(report.slopeStability!.movementRateClass, SoilLevel.low);
      expect(report.topography!.erosionRisk, SoilLevel.medium);
      // A level that failed to parse would be null, not a defaulted "low".
      expect(report.groundwater!.yieldPotential, SoilLevel.medium);
    });

    test(
      'an unsupported demo language falls back to English, not a crash',
      () async {
        final report = await SoilResearchService(
          DemoAiGateway(),
        ).analyze(locale: 'fr');

        expect(report.soilType, contains('Sandy loam'));
      },
    );

    test('the chat answer is Arabic and matches Arabic keywords', () async {
      final gateway = DemoAiGateway();
      final reply = await gateway.generate(
        const AiRequest(
          systemPrompt: 'sys',
          userText: 'لماذا يحدث اصفرار في أوراق نبتتي؟',
          locale: 'ar',
        ),
      );

      expect(reply, contains('التقييم'));
      // The Arabic keyword must reach the yellowing branch; before the fix only
      // the English word 'yellow' could, so Arabic users always got the generic
      // fallback answer.
      expect(reply, contains('الإفراط في الريّ'));
    });

    test('the diagnosis document is Arabic but keeps its enum tokens', () async {
      final gateway = DemoAiGateway();
      final raw = await gateway.generate(
        const AiRequest(
          systemPrompt: 'sys',
          userText: 'diagnose',
          jsonMode: true,
          locale: 'ar',
        ),
      );

      expect(raw, contains('"imageQuality"'));
      // Tokens the parser matches.
      expect(
        RegExp(
          r'"(imageQuality|confidence)": "(good|poor|unusable|low|medium|high)"',
        ).hasMatch(raw),
        isTrue,
      );
      // And at least one Arabic value.
      expect(RegExp(r'[\u0600-\u06FF]').hasMatch(raw), isTrue);
    });
  });
}

const String _minimalReply = '''
{
  "isSoilRelated": true,
  "imageQuality": "good",
  "nutrients": [],
  "substances": [],
  "suitablePlants": [],
  "recommendations": [],
  "safetyNotes": [],
  "confidence": "low",
  "needsMoreInformation": false,
  "followUpQuestions": [],
  "disclaimer": "d"
}''';
