import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/errors/app_exception.dart';
import 'package:plantsense_ai/core/services/ai_gateway.dart';
import 'package:plantsense_ai/core/services/ai_prompts.dart';
import 'package:plantsense_ai/core/services/demo_ai_gateway.dart';
import 'package:plantsense_ai/features/georesearch/data/soil_research_service.dart';
import 'package:plantsense_ai/features/georesearch/domain/soil_report_model.dart';

import '../mocks/mocks.dart';

void main() {
  group('SoilResearchService.analyze', () {
    test('returns a populated SoilReport for canned gateway output', () async {
      const canned = '''
      {
        "isSoilRelated": true,
        "imageQuality": "good",
        "soilType": "sandy loam",
        "salinity": {"level": "low", "note": "estimate; lab test needed"},
        "sodium": {"level": "low", "note": "estimate; lab test needed"},
        "nutrients": [{"name": "Nitrogen", "level": "medium", "note": "ok"}],
        "substances": [],
        "suitablePlants": ["Tomatoes"],
        "recommendations": ["Add compost"],
        "safetyNotes": [],
        "confidence": "low",
        "needsMoreInformation": false,
        "followUpQuestions": [],
        "disclaimer": "Estimates require a professional soil-lab test."
      }''';
      final gateway = FakeAiGateway(reply: canned);
      final service = SoilResearchService(gateway);

      final report = await service.analyze(
        locale: 'en',
        context: const {'city': 'Riyadh'},
        latitude: 24.7136,
        longitude: 46.6753,
      );

      expect(report.soilType, 'sandy loam');
      expect(report.salinity?.level, SoilLevel.low);
      expect(report.nutrients.single.name, 'Nitrogen');
      expect(report.confidence, Confidence.low);

      // The request must be JSON-mode, carry the soil marker and the enriched
      // coordinate context.
      expect(gateway.lastRequest?.jsonMode, isTrue);
      expect(
        gateway.lastRequest?.userText.contains(AiPrompts.soilResearchMarker),
        isTrue,
      );
      expect(gateway.lastRequest?.context['latitude'], '24.7136');
      expect(gateway.lastRequest?.context['longitude'], '46.6753');
    });

    test('surfaces AppException(malformedResponse) on bad output', () async {
      final gateway = FakeAiGateway(reply: 'totally not json');
      final service = SoilResearchService(gateway);

      expect(
        () => service.analyze(locale: 'en'),
        throwsA(
          isA<AppException>().having(
            (e) => e.kind,
            'kind',
            AppErrorKind.malformedResponse,
          ),
        ),
      );
    });

    test('DemoAiGateway returns a parseable SoilReport for soil requests',
        () async {
      final gateway = DemoAiGateway();
      final service = SoilResearchService(gateway);

      final report = await service.analyze(
        locale: 'en',
        context: const {'city': 'Riyadh'},
      );

      // Demo output must be a valid, populated SoilReport (estimate flow).
      expect(report.isSoilRelated, isTrue);
      expect(report.soilType, isNotNull);
      expect(report.salinity, isNotNull);
      expect(report.sodium, isNotNull);
      expect(report.nutrients, isNotEmpty);
      expect(report.disclaimer, isNotEmpty);
      expect(report.confidence, Confidence.low);
    });

    test('DemoAiGateway still returns diagnosis JSON for non-soil requests',
        () async {
      final gateway = DemoAiGateway();
      final raw = await gateway.generate(
        const AiRequest(
          systemPrompt: 'sys',
          userText: 'diagnose this plant',
          jsonMode: true,
        ),
      );
      // Diagnosis JSON has isPlantRelated, not isSoilRelated.
      expect(raw.contains('isPlantRelated'), isTrue);
      expect(raw.contains('isSoilRelated'), isFalse);
    });
  });
}
