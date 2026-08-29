import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/georesearch/domain/soil_report_model.dart';

void main() {
  group('SoilReport.parse', () {
    test('parses clean JSON', () {
      const raw = '''
      {
        "isSoilRelated": true,
        "imageQuality": "good",
        "locationSummary": "Near Riyadh",
        "soilType": "sandy loam",
        "soilDepth": "moderately deep",
        "salinity": {"level": "medium", "note": "some salt"},
        "sodium": {"level": "low", "note": "safe range"},
        "phLevel": "7.2 (neutral)",
        "organicMatter": "moderate",
        "nutrients": [
          {"name": "Nitrogen", "level": "medium", "note": "ok"},
          {"name": "Phosphorus", "level": "low", "note": "limited"},
          {"name": "Potassium", "level": "high", "note": "abundant"}
        ],
        "substances": [
          {"name": "Carbonates", "concern": "low", "note": "typical"}
        ],
        "geometry": "granular",
        "suitablePlants": ["Tomatoes", "Olive"],
        "recommendations": ["Add compost"],
        "safetyNotes": ["Commission a lab test"],
        "confidence": "medium",
        "needsMoreInformation": false,
        "followUpQuestions": ["Attach a photo?"],
        "disclaimer": "Estimates require a lab test"
      }''';
      final r = SoilReport.parse(raw);
      expect(r.isSoilRelated, isTrue);
      expect(r.imageQuality, ImageQuality.good);
      expect(r.soilType, 'sandy loam');
      expect(r.salinity?.level, SoilLevel.medium);
      expect(r.salinity?.note, 'some salt');
      expect(r.sodium?.level, SoilLevel.low);
      expect(r.phLevel, '7.2 (neutral)');
      expect(r.nutrients.length, 3);
      expect(r.nutrients.first.name, 'Nitrogen');
      expect(r.nutrients[2].level, SoilLevel.high);
      expect(r.substances.single.name, 'Carbonates');
      expect(r.substances.single.concern, SoilLevel.low);
      expect(r.geometry, 'granular');
      expect(r.suitablePlants, ['Tomatoes', 'Olive']);
      expect(r.confidence, Confidence.medium);
      expect(r.followUpQuestions, ['Attach a photo?']);
      expect(r.disclaimer, 'Estimates require a lab test');
    });

    test('strips ```json fences and surrounding prose', () {
      const raw =
          'Here is your soil report:\n```json\n'
          '{"isSoilRelated":true,"imageQuality":"good",'
          '"soilType":"clay","confidence":"low",'
          '"nutrients":[],"substances":[],'
          '"suitablePlants":[],"recommendations":[],"safetyNotes":[],'
          '"followUpQuestions":[],"needsMoreInformation":false,'
          '"disclaimer":"lab test needed"}\n```\nHope that helps!';
      final r = SoilReport.parse(raw);
      expect(r.soilType, 'clay');
      expect(r.confidence, Confidence.low);
      expect(r.disclaimer, 'lab test needed');
    });

    test('tolerates missing optional fields', () {
      const raw = '{"soilType":"only this"}';
      final r = SoilReport.parse(raw);
      expect(r.soilType, 'only this');
      expect(r.salinity, isNull);
      expect(r.sodium, isNull);
      expect(r.nutrients, isEmpty);
      expect(r.substances, isEmpty);
      expect(r.isSoilRelated, isTrue); // defaults to true
      expect(r.confidence, Confidence.low); // defaults conservatively
    });

    test('throws FormatException on non-JSON', () {
      expect(
        () => SoilReport.parse('totally not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('defaults unknown enum values safely', () {
      const raw =
          '{"confidence":"banana","imageQuality":"weird",'
          '"soilType":"x","isSoilRelated":true,'
          '"salinity":{"level":"nope","note":"n"}}';
      final r = SoilReport.parse(raw);
      expect(r.confidence, Confidence.low);
      expect(r.imageQuality, ImageQuality.unusable);
      expect(r.salinity?.level, SoilLevel.low); // unknown -> low
    });

    test('drops nameless nutrients and substances', () {
      const raw =
          '{"nutrients":[{"level":"high","note":"n"},'
          '{"name":"Potassium","level":"medium","note":"ok"}],'
          '"substances":[{"concern":"high","note":"c"}]}';
      final r = SoilReport.parse(raw);
      expect(r.nutrients.length, 1);
      expect(r.nutrients.single.name, 'Potassium');
      expect(r.substances, isEmpty);
    });
  });
}
