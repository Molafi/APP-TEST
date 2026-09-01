import 'dart:convert';
import 'dart:math';

import 'ai_gateway.dart';
import 'ai_prompts.dart';

/// Canned, deterministic AI responses used when no AI provider is configured
/// (demo mode) or in tests. Produces valid diagnosis JSON when [jsonMode] is
/// requested, and a helpful structured plant-care answer otherwise. This keeps
/// the app fully usable without any credentials.
class DemoAiGateway extends AiGateway {
  DemoAiGateway([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  Future<String> generate(AiRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (request.jsonMode) {
      if (_isSoilResearch(request)) {
        return _demoSoilReportJson(request);
      }
      return _demoDiagnosisJson(request);
    }
    return _demoChatAnswer(request);
  }

  /// Detects a GeoResearch (soil-research) structured request by the stable
  /// marker that [AiPrompts.soilResearchInstruction] embeds in the user text.
  bool _isSoilResearch(AiRequest request) {
    return request.userText.contains(AiPrompts.soilResearchMarker) ||
        request.systemPrompt.contains(AiPrompts.soilResearchMarker);
  }

  @override
  Stream<String> generateStream(AiRequest request) async* {
    // Diagnosis (JSON) needs the whole document — emit once.
    if (request.jsonMode) {
      yield await generate(request);
      return;
    }
    // Simulate token-by-token streaming of the canned chat answer so the
    // streaming UI can be exercised in demo mode.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final String full = _demoChatAnswer(request);
    final List<String> words = full.split(' ');
    final StringBuffer acc = StringBuffer();
    for (int i = 0; i < words.length; i++) {
      acc.write(i == 0 ? words[i] : ' ${words[i]}');
      yield acc.toString();
      await Future<void>.delayed(const Duration(milliseconds: 18));
    }
  }

  String _demoChatAnswer(AiRequest request) {
    final String q = request.userText.toLowerCase();
    final bool hasImage = request.image != null;

    if (hasImage && q.trim().isEmpty) {
      return "I can see the image you shared. Could you tell me what's "
          "concerning you about this plant? For example, are the leaves "
          "discoloured, spotted, or wilting?\n\n"
          "_(Demo response — configure Groq for full AI analysis.)_";
    }

    String assessment;
    if (q.contains('yellow')) {
      assessment =
          'Yellowing leaves often point to overwatering, poor drainage, or a '
          'nitrogen deficiency. Check whether the soil stays soggy and whether '
          'lower or newer leaves are affected first.';
    } else if (q.contains('water') || q.contains('basil')) {
      assessment =
          'Most herbs like basil prefer consistently moist (not soggy) soil. '
          'Water when the top 2–3 cm feels dry — often every 2–3 days in warm '
          'weather.';
    } else if (q.contains('succulent') || q.contains('soil')) {
      assessment =
          'Succulents need fast-draining soil. A mix of potting soil with '
          'coarse sand or perlite (about 1:1) prevents root rot.';
    } else {
      assessment =
          'Thanks for your question. Based on general plant-care principles, '
          'here is some practical guidance you can adapt to your conditions.';
    }

    final String ctx = request.context['temperature'] != null
        ? '\n\nYour local conditions (${request.context['city'] ?? 'your area'}, '
              '${request.context['temperature']}) are factored into this advice.'
        : '';

    return '🌿 **Assessment**\n$assessment\n\n'
        '💊 **Recommended actions**\n'
        '- Adjust watering to match the plant\'s needs and your climate.\n'
        '- Ensure the pot drains freely and the plant gets appropriate light.\n\n'
        '🌱 **Prevention & ongoing care**\n'
        '- Check soil moisture before watering rather than on a fixed schedule.\n'
        '- Inspect leaves weekly for early signs of pests or disease.\n\n'
        '🛡️ **Safety notes**\n'
        '- Keep fertilizers and any treatments away from children and pets.$ctx\n\n'
        '_AI suggestions may be inaccurate. For serious issues, consult a '
        'qualified horticulturist or local agricultural authority._';
  }

  String _demoDiagnosisJson(AiRequest request) {
    // Occasionally simulate a poor-quality image to exercise that UI path.
    final bool poor = _random.nextInt(6) == 0;
    if (poor) {
      return const JsonEncoder.withIndent('  ').convert({
        'isPlantRelated': true,
        'imageQuality': 'poor',
        'plantName': null,
        'scientificName': null,
        'whatISee': 'The image is a little blurry, so I can\'t be certain.',
        'possibleIssues': [],
        'treatmentSteps': [],
        'preventionTips': [],
        'safetyNotes': [],
        'confidence': 'low',
        'needsMoreInformation': true,
        'followUpQuestions': [
          'Could you retake the photo in bright, indirect light?',
          'Please fill the frame with the affected leaf or area.',
        ],
        'disclaimer':
            'AI suggestions may be inaccurate and do not replace a qualified '
            'botanist or agricultural professional.',
      });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'isPlantRelated': true,
      'imageQuality': 'good',
      'plantName': 'Common houseplant (demo)',
      'scientificName': null,
      'whatISee':
          'Several leaves show yellowing at the margins with a few small brown '
          'spots. Overall the plant looks otherwise upright.',
      'possibleIssues': [
        {
          'name': 'Overwatering / root stress',
          'likelihood': 'medium',
          'reason': 'Marginal yellowing is commonly linked to soggy soil.',
        },
        {
          'name': 'Nutrient deficiency',
          'likelihood': 'low',
          'reason': 'Uniform yellowing can indicate low nitrogen.',
        },
      ],
      'treatmentSteps': [
        'Let the top few centimetres of soil dry before watering again.',
        'Ensure the pot has drainage holes and empty any saucer.',
        'Remove severely affected leaves with clean scissors.',
      ],
      'preventionTips': [
        'Water based on soil moisture, not a fixed schedule.',
        'Provide bright, indirect light and good airflow.',
      ],
      'safetyNotes': [
        'If using any fertilizer, follow label rates and keep away from pets.',
      ],
      'confidence': 'medium',
      'needsMoreInformation': false,
      'followUpQuestions': ['How often are you currently watering this plant?'],
      'disclaimer':
          'AI suggestions may be inaccurate and do not replace a qualified '
          'botanist, horticulturist or local agricultural authority. This is '
          'a demo response.',
    });
  }

  /// Deterministic, valid [SoilReport] JSON for the GeoResearch flow. Values
  /// are qualitative ESTIMATES only — the notes and disclaimer make clear that
  /// exact sodium/salinity/nutrient figures require a professional soil-lab
  /// test. Parses cleanly via SoilReport.parse.
  String _demoSoilReportJson(AiRequest request) {
    final String? city = request.context['city'];
    final bool hasImage = request.image != null;
    final String locationSummary = city != null && city.trim().isNotEmpty
        ? 'Estimated regional soil profile near $city (demo).'
        : 'Estimated regional soil profile for your area (demo).';

    // Mirror the real flow's handling of user requirements and official data so
    // demo mode exercises both branches.
    final String purpose = request.context['surveyPurpose'] ?? 'general';
    final String? requirements = request.context['userRequirements'];
    final bool officialData =
        (request.context['landRecordAvailable'] ?? 'false') == 'true';

    return const JsonEncoder.withIndent('  ').convert({
      'isSoilRelated': true,
      'imageQuality': hasImage ? 'good' : 'unusable',
      'locationSummary': locationSummary,
      'purpose': purpose,
      'userRequirements': requirements,
      'dataSources': <String>[
        if (officialData)
          'Official Land Department record supplied by the user (authoritative)'
        else
          'Estimated from location and regional context only — no official '
              'land record was provided',
        if (hasImage) 'Site/soil photo attached by the user',
        'Regional climate and geology patterns (demo data)',
      ],
      'soilType': 'Sandy loam (estimated from regional context)',
      'soilDepth':
          'Moderately deep (roughly 60–100 cm topsoil, estimate only)',
      'salinity': {
        'level': 'low',
        'note':
            'Salinity appears low based on regional patterns. Exact salt '
            'content requires a professional soil-lab test.',
      },
      'sodium': {
        'level': 'low',
        'note':
            'Sodium is likely within a safe range for most plants. A lab test '
            'is needed to confirm exact sodium levels.',
      },
      'phLevel': 'Approximately neutral (around 6.5–7.5, estimate)',
      'organicMatter':
          'Moderate — typical of managed regional soils (estimate).',
      'nutrients': [
        {
          'name': 'Nitrogen',
          'level': 'medium',
          'note':
              'Likely moderate; supplement for leafy growth. Lab test needed '
              'for exact values.',
        },
        {
          'name': 'Phosphorus',
          'level': 'low',
          'note':
              'Often limited in sandy soils; a lab test confirms exact '
              'phosphorus levels.',
        },
        {
          'name': 'Potassium',
          'level': 'medium',
          'note':
              'Estimated moderate. Confirm with a professional soil test.',
        },
      ],
      'substances': [
        {
          'name': 'Carbonates (lime)',
          'concern': 'low',
          'note':
              'Common in the region; usually not a concern at low levels.',
        },
        {
          'name': 'Clay minerals',
          'concern': 'low',
          'note':
              'A small clay fraction aids water retention. Estimate only.',
        },
      ],
      'geometry': hasImage
          ? 'Granular to fine-crumb structure visible in the photo, with '
                'moderate aggregation (estimate).'
          : 'Structure not assessed — attach a soil/site photo to estimate '
                'geometry (granular, blocky, or compacted).',
      // Deliberately NO 'landRecord' key: the official record shown in a report
      // is attached by the app from what the user entered, never echoed back by
      // the model. Mirrors the real prompt, whose schema omits it too.
      'siteLocation': {
        'address': city,
        'elevation': 'Approximately 300–450 m above sea level (estimate)',
        'areaEstimate': officialData
            ? request.context['landRegisteredArea']
            : 'Not known — provide an official record or plot dimensions',
        'boundaryDescription':
            'Boundaries not surveyed in this demo. A licensed cadastral survey '
            'is required to fix the plot extent.',
        'accessNotes':
            'Assumed reachable by a local road; verify machinery access on site.',
        'terrainSetting': 'Gently undulating plain with scattered cultivation',
      },
      'topography': {
        'summary':
            'Gently sloping ground with no major relief; suitable for most '
            'layouts with modest levelling (demo estimate).',
        'elevationRange': 'Roughly 8–12 m variation across the plot (estimate)',
        'slope': 'Gentle',
        'slopePercent': 3.5,
        'aspect': 'South-facing',
        'landform': 'Alluvial plain margin',
        'relief': 'Low relief',
        'contourSummary':
            'Contours would run broadly east–west; a 0.5 m interval is typical '
            'for plot-scale design.',
        'drainagePattern':
            'Surface water drains gently toward the south-east.',
        'runoffNotes':
            'Minor ponding possible in low corners after heavy rain.',
        'floodRisk': 'low',
        'erosionRisk': 'medium',
        'gradingNotes':
            'Expect light cut-and-fill to create level building or planting '
            'platforms.',
        'notes': [
          'Derived from regional terrain patterns, not from measured survey '
              'points.',
        ],
      },
      'groundwater': {
        'summary':
            'A moderately productive shallow aquifer is typical for this kind '
            'of setting (demo estimate).',
        'waterTableDepth': 'Roughly 15–30 m below ground level (estimate)',
        'aquiferType': 'Unconfined alluvial aquifer',
        'yieldPotential': 'medium',
        'waterQuality':
            'Likely usable for irrigation; test for salinity and nitrates '
            'before drinking use.',
        'salinityRisk': 'low',
        'seasonalVariation':
            'Water table typically rises after the wet season and falls in late '
            'summer.',
        'rechargeNotes':
            'Recharge mainly from seasonal rainfall infiltration.',
        'wellFeasibility':
            'A borehole appears feasible in principle, subject to a '
            'hydrogeological study and a drilling permit.',
        'drillingDepthEstimate': 'Commonly 40–60 m to ensure year-round supply',
        'contaminationRisk': 'low',
        'notes': [
          'No site-specific borehole data was available for this demo.',
        ],
      },
      'buildingSuitability': {
        'summary':
            'Preliminary screening suggests generally workable ground for light '
            'to medium structures (demo estimate only).',
        'suitability': 'medium',
        'bearingCapacity':
            'Likely moderate for sandy loam over firmer substrata — '
            'qualitative only, no design value implied.',
        'bedrockDepth': 'Probably deeper than 10 m (estimate)',
        'foundationSuggestion':
            'Shallow strip or pad footings are a plausible starting hypothesis; '
            'a geotechnical engineer must confirm.',
        'settlementRisk': 'medium',
        'expansiveSoilRisk': 'low',
        'seismicNotes':
            'Check the current national seismic zoning map and apply the local '
            'building code.',
        'excavationNotes':
            'Sandy soils may need shoring for trenches deeper than about 1.2 m.',
        'drainageRequirements':
            'Provide perimeter drainage and grade surfaces away from '
            'foundations.',
        'constraints': [
          'Erosion risk on the sloping margin during construction',
          'Plot boundaries unverified without an official cadastral record',
        ],
        'requiredStudies': [
          'Geotechnical investigation with boreholes and bearing tests',
          'Licensed topographic survey for design-grade contours',
          'Hydrogeological study if a well is planned',
          'Local authority planning and zoning confirmation',
        ],
      },
      'aerialImagery': {
        'interpretation':
            'An aerial view of this area typically shows a patchwork of '
            'cultivated plots separated by tracks, with scattered tree cover '
            'along field edges.',
        'landCover': 'Mixed cultivation with scattered trees and bare ground',
        'visibleFeatures': [
          'Field boundaries and access tracks',
          'Seasonal drainage lines',
          'Scattered built structures nearby',
        ],
      },
      'suitablePlants': [
        'Tomatoes',
        'Peppers',
        'Rosemary',
        'Lavender',
        'Olive',
      ],
      'recommendations': [
        'Add organic compost to improve structure and nutrient retention.',
        'Test drainage before planting moisture-sensitive species.',
        'Obtain a professional soil-lab test for exact nutrient, sodium and '
            'salinity values before major planting or building work.',
      ],
      'safetyNotes': [
        'Do not rely on these estimates for construction, drainage or '
            'foundation decisions — commission a geotechnical/soil survey.',
        'Keep any soil amendments and fertilizers away from children and pets.',
      ],
      'confidence': 'low',
      'needsMoreInformation': !hasImage,
      'followUpQuestions': [
        'Could you attach a clear photo of the soil or site?',
        'What do you plan to grow or build here?',
      ],
      'disclaimer':
          'These are approximate, location-based ESTIMATES and not measured '
          'values. Exact soil depth, sodium, salinity and nutrient figures '
          'require a professional soil-lab test. This is a demo response.',
    });
  }
}
