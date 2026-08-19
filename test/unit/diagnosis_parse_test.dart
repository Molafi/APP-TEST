import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/diagnosis/domain/diagnosis_model.dart';

void main() {
  group('Diagnosis.parse', () {
    test('parses clean JSON', () {
      const raw = '''
      {
        "isPlantRelated": true,
        "imageQuality": "good",
        "plantName": "Basil",
        "whatISee": "green leaves",
        "possibleIssues": [
          {"name": "Overwatering", "likelihood": "medium", "reason": "soggy"}
        ],
        "treatmentSteps": ["water less"],
        "preventionTips": ["check soil"],
        "safetyNotes": [],
        "confidence": "medium",
        "needsMoreInformation": false,
        "followUpQuestions": [],
        "disclaimer": "AI may be inaccurate"
      }''';
      final d = Diagnosis.parse(raw);
      expect(d.isPlantRelated, isTrue);
      expect(d.plantName, 'Basil');
      expect(d.confidence, Confidence.medium);
      expect(d.possibleIssues.single.likelihood, Likelihood.medium);
      expect(d.treatmentSteps, ['water less']);
    });

    test('strips ```json fences and surrounding prose', () {
      const raw =
          'Here you go:\n```json\n{"whatISee":"x","confidence":"low",'
          '"isPlantRelated":true,"imageQuality":"good"}\n```';
      final d = Diagnosis.parse(raw);
      expect(d.whatISee, 'x');
      expect(d.confidence, Confidence.low);
    });

    test('tolerates missing optional fields', () {
      const raw = '{"whatISee":"only this"}';
      final d = Diagnosis.parse(raw);
      expect(d.whatISee, 'only this');
      expect(d.plantName, isNull);
      expect(d.treatmentSteps, isEmpty);
      expect(d.confidence, Confidence.low); // defaults conservatively
    });

    test('throws FormatException on non-JSON', () {
      expect(
        () => Diagnosis.parse('totally not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('defaults unknown enum values safely', () {
      const raw =
          '{"confidence":"banana","imageQuality":"weird",'
          '"whatISee":"x","isPlantRelated":true}';
      final d = Diagnosis.parse(raw);
      expect(d.confidence, Confidence.low);
      expect(d.imageQuality, ImageQuality.unusable);
    });
  });
}
