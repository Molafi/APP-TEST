import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/georesearch/domain/soil_report_model.dart';

void main() {
  group('SoilReport survey sections', () {
    test('parses topography, groundwater, building and land record', () {
      const raw = '''
      {
        "isSoilRelated": true,
        "imageQuality": "good",
        "purpose": "building",
        "userRequirements": "Build a two-storey house",
        "dataSources": ["Official Land Department record", "Regional geology"],
        "nutrients": [],
        "substances": [],
        "suitablePlants": [],
        "recommendations": [],
        "safetyNotes": [],
        "confidence": "medium",
        "needsMoreInformation": false,
        "followUpQuestions": [],
        "disclaimer": "Estimates only.",
        "siteLocation": {
          "address": "Plot 12, North District",
          "latitude": 24.71,
          "longitude": 46.67,
          "elevation": "620 m",
          "areaEstimate": "500 sq m",
          "boundaryDescription": "Rectangular plot",
          "accessNotes": "Paved road access",
          "terrainSetting": "Valley floor"
        },
        "topography": {
          "summary": "Gently sloping",
          "elevationRange": "615-625 m",
          "slope": "Gentle",
          "slopePercent": 4.2,
          "aspect": "North-facing",
          "landform": "Alluvial fan",
          "relief": "Low relief",
          "contourSummary": "0.5 m interval",
          "drainagePattern": "Drains south",
          "runoffNotes": "Minor ponding",
          "floodRisk": "medium",
          "erosionRisk": "high",
          "gradingNotes": "Light cut and fill",
          "notes": ["Desk study only"]
        },
        "groundwater": {
          "summary": "Shallow aquifer",
          "waterTableDepth": "15-25 m",
          "aquiferType": "Unconfined alluvial",
          "yieldPotential": "high",
          "waterQuality": "Usable for irrigation",
          "salinityRisk": "low",
          "seasonalVariation": "Rises in winter",
          "rechargeNotes": "Rainfall infiltration",
          "wellFeasibility": "Feasible subject to study",
          "drillingDepthEstimate": "40-60 m",
          "contaminationRisk": "medium",
          "notes": ["No borehole data"]
        },
        "buildingSuitability": {
          "summary": "Generally workable",
          "suitability": "medium",
          "bearingCapacity": "Moderate",
          "bedrockDepth": "> 10 m",
          "foundationSuggestion": "Strip footings",
          "settlementRisk": "medium",
          "expansiveSoilRisk": "low",
          "seismicNotes": "Check zoning map",
          "excavationNotes": "Shoring below 1.2 m",
          "drainageRequirements": "Perimeter drainage",
          "constraints": ["Erosion risk"],
          "requiredStudies": ["Geotechnical investigation"]
        },
        "landRecord": {
          "available": true,
          "source": "Land Department",
          "parcelId": "P-12345",
          "registeredArea": "500 sq m",
          "zoning": "Residential",
          "classification": "Urban",
          "ownershipType": "Freehold",
          "officialNotes": "No easements"
        },
        "aerialImagery": {
          "interpretation": "Cultivated plots",
          "landCover": "Cropland",
          "visibleFeatures": ["Access track"]
        }
      }''';

      final report = SoilReport.parse(raw);

      expect(report.purpose, SurveyPurpose.building);
      expect(report.userRequirements, 'Build a two-storey house');
      expect(report.dataSources, hasLength(2));

      final site = report.siteLocation!;
      expect(site.address, 'Plot 12, North District');
      expect(site.latitude, 24.71);
      expect(site.areaEstimate, '500 sq m');
      expect(site.isEmpty, isFalse);

      final topo = report.topography!;
      expect(topo.slope, 'Gentle');
      expect(topo.slopePercent, 4.2);
      expect(topo.floodRisk, SoilLevel.medium);
      expect(topo.erosionRisk, SoilLevel.high);
      expect(topo.notes.single, 'Desk study only');
      expect(topo.isEmpty, isFalse);

      final gw = report.groundwater!;
      expect(gw.waterTableDepth, '15-25 m');
      expect(gw.yieldPotential, SoilLevel.high);
      expect(gw.salinityRisk, SoilLevel.low);
      expect(gw.contaminationRisk, SoilLevel.medium);
      expect(gw.isEmpty, isFalse);

      final bs = report.buildingSuitability!;
      expect(bs.suitability, SoilLevel.medium);
      expect(bs.foundationSuggestion, 'Strip footings');
      expect(bs.requiredStudies.single, 'Geotechnical investigation');
      expect(bs.isEmpty, isFalse);

      final lr = report.landRecord!;
      expect(lr.available, isTrue);
      expect(lr.parcelId, 'P-12345');
      expect(lr.zoning, 'Residential');
      expect(lr.hasData, isTrue);

      expect(report.aerialImagery!.landCover, 'Cropland');
    });

    test('older reports without the new sections still parse', () {
      // Backward compatibility: reports saved before these fields existed must
      // still load, with the new sections simply absent.
      const legacy = '''
      {
        "isSoilRelated": true,
        "imageQuality": "good",
        "soilType": "sandy loam",
        "nutrients": [],
        "substances": [],
        "suitablePlants": [],
        "recommendations": [],
        "safetyNotes": [],
        "confidence": "low",
        "needsMoreInformation": false,
        "followUpQuestions": [],
        "disclaimer": "Estimate."
      }''';

      final report = SoilReport.parse(legacy);
      expect(report.soilType, 'sandy loam');
      expect(report.siteLocation, isNull);
      expect(report.topography, isNull);
      expect(report.groundwater, isNull);
      expect(report.buildingSuitability, isNull);
      expect(report.landRecord, isNull);
      expect(report.aerialImagery, isNull);
      // Purpose falls back to a safe default rather than throwing.
      expect(report.purpose, SurveyPurpose.general);
      expect(report.dataSources, isEmpty);
    });

    test('unrecognised risk values are hidden, never shown as "low"', () {
      // Fail-safe: rendering an unparseable "severe"/"unknown" as a reassuring
      // green "Low" chip would understate a hazard, so the field is dropped.
      const raw = '''
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
        "disclaimer": "d",
        "topography": {"floodRisk": "unknown", "erosionRisk": "catastrophic", "notes": []},
        "groundwater": {"salinityRisk": "not sure", "contaminationRisk": "", "notes": []},
        "buildingSuitability": {"settlementRisk": "???", "constraints": [], "requiredStudies": []}
      }''';

      final report = SoilReport.parse(raw);
      expect(report.topography!.floodRisk, isNull);
      expect(report.topography!.erosionRisk, isNull);
      expect(report.groundwater!.salinityRisk, isNull);
      expect(report.groundwater!.contaminationRisk, isNull);
      expect(report.buildingSuitability!.settlementRisk, isNull);
    });

    test('common level synonyms are recognised rather than dropped', () {
      const raw = '''
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
        "disclaimer": "d",
        "topography": {"floodRisk": "Moderate", "erosionRisk": "SEVERE", "notes": []},
        "groundwater": {"salinityRisk": "negligible", "notes": []}
      }''';

      final report = SoilReport.parse(raw);
      expect(report.topography!.floodRisk, SoilLevel.medium);
      expect(report.topography!.erosionRisk, SoilLevel.high);
      expect(report.groundwater!.salinityRisk, SoilLevel.low);
    });

    test('malformed sections degrade to null instead of throwing', () {
      const bad = '''
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
        "disclaimer": "d",
        "topography": "not an object",
        "groundwater": 42,
        "buildingSuitability": [],
        "landRecord": null,
        "purpose": "nonsense-value"
      }''';

      final report = SoilReport.parse(bad);
      expect(report.topography, isNull);
      expect(report.groundwater, isNull);
      expect(report.buildingSuitability, isNull);
      expect(report.landRecord, isNull);
      expect(report.purpose, SurveyPurpose.general);
    });

    test('survives a round trip through toMap/fromStored', () {
      const raw = '''
      {
        "isSoilRelated": true,
        "imageQuality": "good",
        "purpose": "wellDrilling",
        "nutrients": [],
        "substances": [],
        "suitablePlants": [],
        "recommendations": [],
        "safetyNotes": [],
        "confidence": "low",
        "needsMoreInformation": false,
        "followUpQuestions": [],
        "disclaimer": "d",
        "topography": {"slope": "Steep", "floodRisk": "high", "notes": []},
        "groundwater": {"waterTableDepth": "30 m", "yieldPotential": "low", "notes": []},
        "buildingSuitability": {"suitability": "low", "constraints": [], "requiredStudies": []},
        "landRecord": {"available": true, "parcelId": "X-9"}
      }''';

      final original = SoilReport.parse(raw);
      final restored = SoilReport.fromStored('id-1', {
        'report': original.toMap(),
      });

      expect(restored.id, 'id-1');
      expect(restored.purpose, SurveyPurpose.wellDrilling);
      expect(restored.topography?.slope, 'Steep');
      expect(restored.topography?.floodRisk, SoilLevel.high);
      expect(restored.groundwater?.waterTableDepth, '30 m');
      expect(restored.groundwater?.yieldPotential, SoilLevel.low);
      expect(restored.buildingSuitability?.suitability, SoilLevel.low);
      expect(restored.landRecord?.parcelId, 'X-9');
    });

    test('share text includes the new survey sections', () {
      const raw = '''
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
        "disclaimer": "d",
        "dataSources": ["Official Land Department record"],
        "topography": {"summary": "Gentle plain", "floodRisk": "low", "notes": []},
        "groundwater": {"waterTableDepth": "20 m", "notes": []},
        "buildingSuitability": {"bearingCapacity": "Moderate", "constraints": [], "requiredStudies": ["Geotechnical investigation"]},
        "landRecord": {"available": true, "parcelId": "P-1", "zoning": "Residential"}
      }''';

      final text = SoilReport.parse(raw).toShareText();
      expect(text, contains('Topography'));
      expect(text, contains('Gentle plain'));
      expect(text, contains('Groundwater'));
      expect(text, contains('20 m'));
      expect(text, contains('Building suitability'));
      expect(text, contains('Geotechnical investigation'));
      expect(text, contains('Land Department record'));
      expect(text, contains('P-1'));
      expect(text, contains('Data sources'));
    });
  });

  group('LandRecordInfo', () {
    test('hasData is false for an empty record', () {
      expect(const LandRecordInfo().hasData, isFalse);
      expect(const LandRecordInfo(available: true).hasData, isFalse);
    });

    test('toContext only emits provided values', () {
      const record = LandRecordInfo(
        available: true,
        parcelId: 'P-7',
        zoning: 'Agricultural',
      );
      final ctx = record.toContext();
      expect(ctx['landParcelId'], 'P-7');
      expect(ctx['landZoning'], 'Agricultural');
      // Absent fields must not appear as blank placeholders.
      expect(ctx.containsKey('landRegisteredArea'), isFalse);
      expect(ctx.containsKey('landOfficialNotes'), isFalse);
    });

    test('copyWith preserves untouched fields', () {
      const record = LandRecordInfo(parcelId: 'P-1', zoning: 'Residential');
      final updated = record.copyWith(available: true);
      expect(updated.available, isTrue);
      expect(updated.parcelId, 'P-1');
      expect(updated.zoning, 'Residential');
    });
  });

  group('surveyPurposeFrom', () {
    test('parses known values and defaults safely', () {
      expect(surveyPurposeFrom('building'), SurveyPurpose.building);
      expect(surveyPurposeFrom('agriculture'), SurveyPurpose.agriculture);
      expect(surveyPurposeFrom('wellDrilling'), SurveyPurpose.wellDrilling);
      expect(surveyPurposeFrom('well_drilling'), SurveyPurpose.wellDrilling);
      expect(surveyPurposeFrom(null), SurveyPurpose.general);
      expect(surveyPurposeFrom('garbage'), SurveyPurpose.general);
    });
  });
}
