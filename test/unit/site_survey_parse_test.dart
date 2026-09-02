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
      expect(surveyPurposeFrom('slopeStability'), SurveyPurpose.slopeStability);
      expect(
        surveyPurposeFrom('slope_stability'),
        SurveyPurpose.slopeStability,
      );
      expect(surveyPurposeFrom(null), SurveyPurpose.general);
      expect(surveyPurposeFrom('garbage'), SurveyPurpose.general);
    });
  });

  group('SlopeStabilityAssessment', () {
    const String full = '''
    {
      "isSoilRelated": true,
      "imageQuality": "good",
      "purpose": "slopeStability",
      "nutrients": [],
      "substances": [],
      "suitablePlants": [],
      "recommendations": [],
      "safetyNotes": [],
      "confidence": "low",
      "needsMoreInformation": false,
      "followUpQuestions": [],
      "disclaimer": "d",
      "slopeStability": {
        "summary": "Shallow creep cannot be ruled out.",
        "hazardLevel": "medium",
        "activityState": "Dormant, unverified without monitoring",
        "movementDirection": "Downslope toward the south-east",
        "movementAzimuth": 135,
        "slipSurfaceDepth": "1-3 m, requires inclinometer measurement",
        "slipSurfaceType": "Shallow translational",
        "movementRate": "Extremely slow; requires GNSS monitoring",
        "movementRateClass": "low",
        "failureMechanism": "Rainfall-driven pore-water pressure",
        "indicators": ["Arc-shaped cracks", "Tilted walls"],
        "triggers": ["Prolonged rainfall", "Cutting the toe"],
        "atRiskStructures": [
          {
            "name": "Houses on the crown",
            "risk": "high",
            "reason": "Tension cracks appear here first",
            "recommendation": "Geotechnical inspection"
          },
          {"name": "Boundary wall", "risk": "medium"}
        ],
        "zones": [
          {
            "name": "Upper plateau",
            "location": "Set back from the crown",
            "buildability": "high",
            "buildableAfterTreatment": true,
            "requiredTreatments": ["Set-back from the crown", "Drainage"],
            "note": "Most favourable area"
          },
          {
            "name": "Sloping margin",
            "buildability": "low",
            "buildableAfterTreatment": false,
            "requiredTreatments": ["Instrumented investigation"]
          }
        ],
        "stabilisationOptions": ["Subsurface drainage"],
        "monitoringPlan": ["Inclinometers in boreholes"],
        "requiredStudies": ["Slope-stability analysis"],
        "notes": ["Desk screening only"]
      }
    }''';

    test('parses every field the UI renders', () {
      final report = SoilReport.parse(full);
      final slope = report.slopeStability!;

      expect(report.purpose, SurveyPurpose.slopeStability);
      expect(slope.isEmpty, isFalse);
      expect(slope.hazardLevel, SoilLevel.medium);
      expect(slope.movementDirection, 'Downslope toward the south-east');
      expect(slope.movementAzimuth, 135);
      expect(slope.slipSurfaceDepth, contains('inclinometer'));
      expect(slope.slipSurfaceType, 'Shallow translational');
      expect(slope.movementRateClass, SoilLevel.low);
      expect(slope.failureMechanism, contains('pore-water'));
      expect(slope.indicators, hasLength(2));
      expect(slope.triggers, hasLength(2));
      expect(slope.stabilisationOptions, ['Subsurface drainage']);
      expect(slope.monitoringPlan, ['Inclinometers in boreholes']);
      expect(slope.requiredStudies, ['Slope-stability analysis']);
      expect(slope.notes, ['Desk screening only']);
    });

    test('parses exposed structures and drops nameless entries', () {
      final slope = SoilReport.parse(full).slopeStability!;
      expect(slope.atRiskStructures, hasLength(2));
      expect(slope.atRiskStructures.first.name, 'Houses on the crown');
      expect(slope.atRiskStructures.first.risk, SoilLevel.high);
      expect(slope.atRiskStructures.first.recommendation, isNotNull);
      // Optional fields simply stay null.
      expect(slope.atRiskStructures.last.reason, isNull);

      // An unlabelled row would show a risk chip attached to nothing.
      final nameless = SoilReport.parse('''
      {
        "isSoilRelated": true, "imageQuality": "good", "nutrients": [],
        "substances": [], "suitablePlants": [], "recommendations": [],
        "safetyNotes": [], "confidence": "low", "needsMoreInformation": false,
        "followUpQuestions": [], "disclaimer": "d",
        "slopeStability": {
          "atRiskStructures": [{"risk": "high"}, {"name": "  "}],
          "zones": [{"buildability": "high"}]
        }
      }''');
      expect(nameless.slopeStability!.atRiskStructures, isEmpty);
      expect(nameless.slopeStability!.zones, isEmpty);
    });

    test('parses zones and their conditional buildability', () {
      final zones = SoilReport.parse(full).slopeStability!.zones;
      expect(zones, hasLength(2));
      expect(zones.first.name, 'Upper plateau');
      expect(zones.first.buildability, SoilLevel.high);
      expect(zones.first.buildableAfterTreatment, isTrue);
      expect(zones.first.requiredTreatments, hasLength(2));
      expect(zones.last.buildableAfterTreatment, isFalse);
    });

    test(
      'a missing or mistyped buildable flag is never read as permission',
      () {
        final report = SoilReport.parse('''
      {
        "isSoilRelated": true, "imageQuality": "good", "nutrients": [],
        "substances": [], "suitablePlants": [], "recommendations": [],
        "safetyNotes": [], "confidence": "low", "needsMoreInformation": false,
        "followUpQuestions": [], "disclaimer": "d",
        "slopeStability": {
          "zones": [
            {"name": "A"},
            {"name": "B", "buildableAfterTreatment": "maybe"},
            {"name": "C", "buildableAfterTreatment": "yes"}
          ]
        }
      }''');

        final zones = report.slopeStability!.zones;
        expect(zones[0].buildableAfterTreatment, isFalse);
        // Unparseable means "no", not "yes".
        expect(zones[1].buildableAfterTreatment, isFalse);
        // A recognised affirmative still works.
        expect(zones[2].buildableAfterTreatment, isTrue);
      },
    );

    test('unrecognised risk levels are hidden, never shown as low', () {
      final report = SoilReport.parse('''
      {
        "isSoilRelated": true, "imageQuality": "good", "nutrients": [],
        "substances": [], "suitablePlants": [], "recommendations": [],
        "safetyNotes": [], "confidence": "low", "needsMoreInformation": false,
        "followUpQuestions": [], "disclaimer": "d",
        "slopeStability": {
          "hazardLevel": "catastrophic",
          "movementRateClass": "unknown",
          "atRiskStructures": [{"name": "House", "risk": "extreme"}],
          "zones": [{"name": "Zone", "buildability": "???"}]
        }
      }''');

      final slope = report.slopeStability!;
      // Rendering "catastrophic" as a reassuring "Low" chip is the worst
      // possible failure for a hazard field.
      expect(slope.hazardLevel, isNull);
      expect(slope.movementRateClass, isNull);
      expect(slope.atRiskStructures.single.risk, isNull);
      expect(slope.zones.single.buildability, isNull);
      // Synonyms the model may use instead of the canonical words still work.
      expect(
        SoilReport.parse('''
        {
          "isSoilRelated": true, "imageQuality": "good", "nutrients": [],
          "substances": [], "suitablePlants": [], "recommendations": [],
          "safetyNotes": [], "confidence": "low", "needsMoreInformation": false,
          "followUpQuestions": [], "disclaimer": "d",
          "slopeStability": {"hazardLevel": "severe"}
        }''').slopeStability!.hazardLevel,
        SoilLevel.high,
      );
    });

    test('a malformed section becomes null rather than throwing', () {
      final report = SoilReport.parse('''
      {
        "isSoilRelated": true, "imageQuality": "good", "nutrients": [],
        "substances": [], "suitablePlants": [], "recommendations": [],
        "safetyNotes": [], "confidence": "low", "needsMoreInformation": false,
        "followUpQuestions": [], "disclaimer": "d",
        "slopeStability": "not an object"
      }''');
      expect(report.slopeStability, isNull);
    });

    test('reports saved before this section existed still load', () {
      final report = SoilReport.parse('''
      {
        "isSoilRelated": true, "imageQuality": "good", "nutrients": [],
        "substances": [], "suitablePlants": [], "recommendations": [],
        "safetyNotes": [], "confidence": "low", "needsMoreInformation": false,
        "followUpQuestions": [], "disclaimer": "d"
      }''');
      expect(report.slopeStability, isNull);
      expect(report.officialMap, isNull);
    });

    test('survives a round trip through toMap/fromStored', () {
      final original = SoilReport.parse(full);
      final restored = SoilReport.fromStored('id-2', {
        'report': original.toMap(),
      });

      final slope = restored.slopeStability!;
      expect(slope.movementDirection, 'Downslope toward the south-east');
      expect(slope.movementAzimuth, 135);
      expect(slope.hazardLevel, SoilLevel.medium);
      expect(slope.atRiskStructures.first.risk, SoilLevel.high);
      expect(slope.zones.first.buildableAfterTreatment, isTrue);
      expect(slope.zones.first.requiredTreatments, hasLength(2));
      expect(slope.zones.last.buildableAfterTreatment, isFalse);
    });

    test('share text carries the movement answers and the zone conditions', () {
      final text = SoilReport.parse(full).toShareText();
      expect(text, contains('Slope stability'));
      expect(text, contains('Downslope toward the south-east'));
      expect(text, contains('Slip-surface depth'));
      expect(text, contains('Houses on the crown'));
      // A zone must never be exported as plainly "buildable".
      expect(text, contains('ONLY after the required treatments'));
      expect(text, contains('not buildable on current evidence'));
    });
  });

  group('OfficialMapReference', () {
    test('round-trips through toMap/fromMap', () {
      const ref = OfficialMapReference(
        authority: 'RJGC',
        gridName: 'Jordan Transverse Mercator (JTM)',
        gridCode: 'EPSG:3066',
        easting: 397021.1,
        northing: 536604.5,
        latitude: 31.9539,
        longitude: 35.9106,
        portalUrl: 'https://example.test/portal',
      );

      final restored = OfficialMapReference.fromMap(ref.toMap());
      expect(restored.hasGrid, isTrue);
      expect(restored.easting, 397021.1);
      expect(restored.gridCode, 'EPSG:3066');
      expect(restored.portalUrl, 'https://example.test/portal');
      // Absent means "no official transformation was applied".
      expect(restored.datumShiftApplied, isFalse);
      expect(restored.isEmpty, isFalse);
    });

    test('a reference with nothing in it reads as empty', () {
      const ref = OfficialMapReference(authority: 'A', gridName: 'G');
      expect(ref.hasGrid, isFalse);
      expect(ref.isEmpty, isTrue);
    });

    group('gridReferenceLine', () {
      test('carries the CRS, both axes and the source coordinates', () {
        const ref = OfficialMapReference(
          authority: 'RJGC',
          gridName: 'Jordan Transverse Mercator (JTM)',
          gridCode: 'EPSG:3066',
          easting: 397021.14,
          northing: 536604.51,
          latitude: 31.95389,
          longitude: 35.91056,
        );

        final String line = ref.gridReferenceLine()!;
        // A bare pair of numbers with no coordinate system is ambiguous: JTM and
        // the older Palestine grid give very different values for one point.
        expect(line, contains('EPSG:3066'));
        expect(line, contains('E 397021.1 m'));
        expect(line, contains('N 536604.5 m'));
        expect(line, contains('WGS84 31.95389, 35.91056'));
      });

      test('the caveat travels inside the copied string', () {
        const unshifted = OfficialMapReference(
          authority: 'RJGC',
          gridName: 'JTM',
          easting: 1.0,
          northing: 2.0,
        );
        // Copying or sharing the numbers must not be able to strip the warning.
        expect(
          unshifted.gridReferenceLine(),
          contains('no datum transformation applied'),
        );

        const shifted = OfficialMapReference(
          authority: 'RJGC',
          gridName: 'JTM',
          easting: 1.0,
          northing: 2.0,
          datumShiftApplied: true,
        );
        expect(
          shifted.gridReferenceLine(),
          isNot(contains('no datum transformation applied')),
        );
      });

      test('is null when there is no grid', () {
        const ref = OfficialMapReference(authority: 'A', gridName: 'G');
        expect(ref.gridReferenceLine(), isNull);
      });

      test('the shared report reuses the same formatter', () {
        final report = SoilReport.parse('''
        {
          "isSoilRelated": true, "imageQuality": "good", "nutrients": [],
          "substances": [], "suitablePlants": [], "recommendations": [],
          "safetyNotes": [], "confidence": "low", "needsMoreInformation": false,
          "followUpQuestions": [], "disclaimer": "d"
        }''').withUserInputs(
          landRecord: null,
          aerialImagery: null,
          officialMap: const OfficialMapReference(
            authority: 'RJGC',
            gridName: 'JTM',
            gridCode: 'EPSG:3066',
            easting: 397021.1,
            northing: 536604.5,
          ),
          purpose: SurveyPurpose.general,
          userRequirements: null,
        );

        final String text = report.toShareText();
        expect(text, contains(report.officialMap!.gridReferenceLine()!));
        expect(text, contains('no datum transformation applied'));
      });
    });

    test('is persisted with the report', () {
      final report =
          SoilReport.parse('''
      {
        "isSoilRelated": true, "imageQuality": "good", "nutrients": [],
        "substances": [], "suitablePlants": [], "recommendations": [],
        "safetyNotes": [], "confidence": "low", "needsMoreInformation": false,
        "followUpQuestions": [], "disclaimer": "d"
      }''').withUserInputs(
            landRecord: null,
            aerialImagery: null,
            officialMap: const OfficialMapReference(
              authority: 'RJGC',
              gridName: 'JTM',
              gridCode: 'EPSG:3066',
              easting: 1.0,
              northing: 2.0,
            ),
            purpose: SurveyPurpose.slopeStability,
            userRequirements: null,
          );

      final restored = SoilReport.fromStored('id-3', {
        'report': report.toMap(),
      });
      expect(restored.officialMap?.easting, 1.0);
      expect(restored.officialMap?.gridCode, 'EPSG:3066');
      expect(restored.purpose, SurveyPurpose.slopeStability);
    });
  });
}
