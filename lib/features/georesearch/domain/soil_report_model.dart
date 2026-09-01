import 'dart:convert';

import '../../diagnosis/domain/diagnosis_model.dart' show Confidence, confidenceFrom, ImageQuality, imageQualityFrom;
import 'site_survey_model.dart';
import 'soil_level.dart';

export '../../diagnosis/domain/diagnosis_model.dart' show Confidence, ImageQuality;
// Re-exported so existing `import '.../soil_report_model.dart'` call sites keep
// resolving SoilLevel and the survey models without extra imports.
export 'site_survey_model.dart';
export 'soil_level.dart';

/// A qualitative reading with a level and an optional explanatory note. Used for
/// salinity and sodium, both of which are ESTIMATES only — exact figures need a
/// professional soil-lab test.
class SoilMeasure {
  const SoilMeasure({required this.level, required this.note});

  final SoilLevel level;
  final String note;

  Map<String, dynamic> toMap() => {'level': level.name, 'note': note};

  factory SoilMeasure.fromMap(Map<String, dynamic> m) => SoilMeasure(
    level: soilLevelFrom(m['level'] as String?),
    note: (m['note'] as String?)?.trim() ?? '',
  );
}

/// A single soil nutrient (e.g. Nitrogen / Phosphorus / Potassium) with an
/// estimated level and an optional note.
class SoilNutrient {
  const SoilNutrient({
    required this.name,
    required this.level,
    required this.note,
  });

  final String name;
  final SoilLevel level;
  final String note;

  Map<String, dynamic> toMap() => {
    'name': name,
    'level': level.name,
    'note': note,
  };

  factory SoilNutrient.fromMap(Map<String, dynamic> m) => SoilNutrient(
    name: (m['name'] as String?)?.trim() ?? '',
    level: soilLevelFrom(m['level'] as String?),
    note: (m['note'] as String?)?.trim() ?? '',
  );
}

/// A notable substance / contaminant (e.g. heavy metals, carbonates, clay
/// minerals) with a concern level and an optional note.
class SoilSubstance {
  const SoilSubstance({
    required this.name,
    required this.concern,
    required this.note,
  });

  final String name;
  final SoilLevel concern;
  final String note;

  Map<String, dynamic> toMap() => {
    'name': name,
    'concern': concern.name,
    'note': note,
  };

  factory SoilSubstance.fromMap(Map<String, dynamic> m) => SoilSubstance(
    name: (m['name'] as String?)?.trim() ?? '',
    concern: soilLevelFrom(m['concern'] as String?),
    note: (m['note'] as String?)?.trim() ?? '',
  );
}

/// Strongly typed soil-research result. Every field is null/empty tolerant and
/// parsing never relies on string splitting. This is an ESTIMATE/EDUCATIONAL
/// artifact: qualitative levels and descriptors are inferred from location,
/// regional context and an optional image — real sodium/salinity/nutrient
/// figures require a professional soil-lab test.
class SoilReport {
  const SoilReport({
    required this.isSoilRelated,
    required this.imageQuality,
    this.locationSummary,
    this.soilType,
    this.soilDepth,
    this.salinity,
    this.sodium,
    this.phLevel,
    this.organicMatter,
    required this.nutrients,
    required this.substances,
    this.geometry,
    this.siteLocation,
    this.topography,
    this.groundwater,
    this.buildingSuitability,
    this.landRecord,
    this.aerialImagery,
    this.purpose = SurveyPurpose.general,
    this.userRequirements,
    this.dataSources = const <String>[],
    required this.suitablePlants,
    required this.recommendations,
    required this.safetyNotes,
    required this.confidence,
    required this.needsMoreInformation,
    required this.followUpQuestions,
    required this.disclaimer,
    this.id,
    this.imageReference,
    this.localImagePath,
    this.locationContext,
    this.createdAt,
  });

  /// False when an attached image is unrelated to soil / a site.
  final bool isSoilRelated;
  final ImageQuality imageQuality;

  /// Human-friendly one-line summary of the location this report reasons about.
  final String? locationSummary;

  /// Texture / classification, e.g. "sandy loam".
  final String? soilType;

  /// Depth / profile descriptor, e.g. "shallow (<30cm)" or "deep".
  final String? soilDepth;

  /// Salinity (salt) estimate.
  final SoilMeasure? salinity;

  /// Sodium estimate.
  final SoilMeasure? sodium;

  /// pH descriptor, e.g. "6.5 (slightly acidic)" or "alkaline".
  final String? phLevel;

  /// Organic-matter descriptor / level.
  final String? organicMatter;

  /// Estimated macro-nutrients (typically N, P, K).
  final List<SoilNutrient> nutrients;

  /// Notable substances / contaminants.
  final List<SoilSubstance> substances;

  /// Soil geometry / structure / aggregation, e.g. "granular", "blocky",
  /// "compacted" — most meaningful when derived from an image.
  final String? geometry;

  /// Where the site is and how it is laid out.
  final SiteLocation? siteLocation;

  /// Estimated topographic survey (elevation, slope, drainage, flood/erosion).
  final TopographySurvey? topography;

  /// Estimated groundwater / water-table assessment.
  final GroundwaterAssessment? groundwater;

  /// Preliminary construction-suitability screening.
  final BuildingSuitability? buildingSuitability;

  /// Official Land Department record, when the user supplied one.
  final LandRecordInfo? landRecord;

  /// Aerial/satellite view reference plus its AI interpretation.
  final AerialImageryInfo? aerialImagery;

  /// What the user wants the site for — drives which sections matter.
  final SurveyPurpose purpose;

  /// The user's own stated requirements, echoed back for the record.
  final String? userRequirements;

  /// Which inputs the findings were derived from (official record, coordinates,
  /// photo, regional data), so the user can judge reliability.
  final List<String> dataSources;

  final List<String> suitablePlants;
  final List<String> recommendations;
  final List<String> safetyNotes;
  final Confidence confidence;
  final bool needsMoreInformation;
  final List<String> followUpQuestions;
  final String disclaimer;

  // Persistence / display extras.
  final String? id;
  final String? imageReference;
  final String? localImagePath;
  final String? locationContext;
  final DateTime? createdAt;

  /// Parses a raw model string into a [SoilReport]. Handles fenced code blocks
  /// and leading/trailing prose by extracting the first balanced JSON object.
  /// Throws [FormatException] when no usable JSON is present.
  static SoilReport parse(String raw) {
    final Map<String, dynamic> json = _extractJson(raw);
    return SoilReport.fromJson(json);
  }

  static Map<String, dynamic> _extractJson(String raw) {
    var text = raw.trim();
    // Strip common ```json fences.
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(json)?'), '').trim();
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3).trim();
      }
    }
    // Fast path.
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    // Fallback: find first balanced {...} block.
    final int start = text.indexOf('{');
    if (start < 0) throw const FormatException('No JSON object found');
    int depth = 0;
    for (int i = start; i < text.length; i++) {
      final String ch = text[i];
      if (ch == '{') depth++;
      if (ch == '}') {
        depth--;
        if (depth == 0) {
          final String candidate = text.substring(start, i + 1);
          final decoded = jsonDecode(candidate);
          if (decoded is Map<String, dynamic>) return decoded;
        }
      }
    }
    throw const FormatException('Unbalanced JSON');
  }

  /// Parses a nested sub-object with [build], returning null when the value is
  /// absent or not a JSON object. Keeps [fromJson] tolerant of partial output.
  static T? _sub<T>(Object? v, T Function(Map<String, dynamic>) build) {
    if (v is Map<String, dynamic>) return build(v);
    if (v is Map) return build(Map<String, dynamic>.from(v));
    return null;
  }

  factory SoilReport.fromJson(Map<String, dynamic> j) {
    List<String> strList(Object? v) => (v is List)
        ? v
              .whereType<Object>()
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];

    String? str(Object? v) {
      final String s = (v as String?)?.trim() ?? '';
      return s.isEmpty ? null : s;
    }

    SoilMeasure? measure(Object? v) =>
        v is Map<String, dynamic> ? SoilMeasure.fromMap(v) : null;

    return SoilReport(
      isSoilRelated: (j['isSoilRelated'] as bool?) ?? true,
      imageQuality: imageQualityFrom(j['imageQuality'] as String?),
      locationSummary: str(j['locationSummary']),
      soilType: str(j['soilType']),
      soilDepth: str(j['soilDepth']),
      salinity: measure(j['salinity']),
      sodium: measure(j['sodium']),
      phLevel: str(j['phLevel']),
      organicMatter: str(j['organicMatter']),
      nutrients: (j['nutrients'] is List)
          ? (j['nutrients'] as List)
                .whereType<Map<String, dynamic>>()
                .map(SoilNutrient.fromMap)
                .where((e) => e.name.isNotEmpty)
                .toList()
          : <SoilNutrient>[],
      substances: (j['substances'] is List)
          ? (j['substances'] as List)
                .whereType<Map<String, dynamic>>()
                .map(SoilSubstance.fromMap)
                .where((e) => e.name.isNotEmpty)
                .toList()
          : <SoilSubstance>[],
      geometry: str(j['geometry']),
      siteLocation: _sub(j['siteLocation'], SiteLocation.fromMap),
      topography: _sub(j['topography'], TopographySurvey.fromMap),
      groundwater: _sub(j['groundwater'], GroundwaterAssessment.fromMap),
      buildingSuitability: _sub(
        j['buildingSuitability'],
        BuildingSuitability.fromMap,
      ),
      landRecord: _sub(j['landRecord'], LandRecordInfo.fromMap),
      aerialImagery: _sub(j['aerialImagery'], AerialImageryInfo.fromMap),
      purpose: surveyPurposeFrom(j['purpose'] as String?),
      userRequirements: str(j['userRequirements']),
      dataSources: strList(j['dataSources']),
      suitablePlants: strList(j['suitablePlants']),
      recommendations: strList(j['recommendations']),
      safetyNotes: strList(j['safetyNotes']),
      confidence: confidenceFrom(j['confidence'] as String?),
      needsMoreInformation: (j['needsMoreInformation'] as bool?) ?? false,
      followUpQuestions: strList(j['followUpQuestions']),
      disclaimer: (j['disclaimer'] as String?)?.trim() ?? '',
    );
  }

  /// Overwrites the fields the APP owns rather than the model.
  ///
  /// These four are trust-sensitive: the official land record and the aerial
  /// tile are supplied by the user/app and must never be sourced from model
  /// output (a paraphrased parcel number must not appear behind an "Official
  /// record" badge), and the purpose/requirements are echoes of what the user
  /// actually entered. Assignment is unconditional — passing null CLEARS any
  /// value the model volunteered.
  SoilReport withUserInputs({
    required LandRecordInfo? landRecord,
    required AerialImageryInfo? aerialImagery,
    required SurveyPurpose purpose,
    required String? userRequirements,
  }) {
    return SoilReport(
      isSoilRelated: isSoilRelated,
      imageQuality: imageQuality,
      locationSummary: locationSummary,
      soilType: soilType,
      soilDepth: soilDepth,
      salinity: salinity,
      sodium: sodium,
      phLevel: phLevel,
      organicMatter: organicMatter,
      nutrients: nutrients,
      substances: substances,
      geometry: geometry,
      siteLocation: siteLocation,
      topography: topography,
      groundwater: groundwater,
      buildingSuitability: buildingSuitability,
      landRecord: landRecord,
      aerialImagery: aerialImagery,
      purpose: purpose,
      userRequirements: userRequirements,
      dataSources: dataSources,
      suitablePlants: suitablePlants,
      recommendations: recommendations,
      safetyNotes: safetyNotes,
      confidence: confidence,
      needsMoreInformation: needsMoreInformation,
      followUpQuestions: followUpQuestions,
      disclaimer: disclaimer,
      id: id,
      imageReference: imageReference,
      localImagePath: localImagePath,
      locationContext: locationContext,
      createdAt: createdAt,
    );
  }

  SoilReport withMeta({
    String? id,
    String? imageReference,
    String? localImagePath,
    String? locationContext,
    DateTime? createdAt,
  }) {
    return SoilReport(
      isSoilRelated: isSoilRelated,
      imageQuality: imageQuality,
      locationSummary: locationSummary,
      soilType: soilType,
      soilDepth: soilDepth,
      salinity: salinity,
      sodium: sodium,
      phLevel: phLevel,
      organicMatter: organicMatter,
      nutrients: nutrients,
      substances: substances,
      geometry: geometry,
      siteLocation: siteLocation,
      topography: topography,
      groundwater: groundwater,
      buildingSuitability: buildingSuitability,
      landRecord: landRecord,
      aerialImagery: aerialImagery,
      purpose: purpose,
      userRequirements: userRequirements,
      dataSources: dataSources,
      suitablePlants: suitablePlants,
      recommendations: recommendations,
      safetyNotes: safetyNotes,
      confidence: confidence,
      needsMoreInformation: needsMoreInformation,
      followUpQuestions: followUpQuestions,
      disclaimer: disclaimer,
      id: id ?? this.id,
      imageReference: imageReference ?? this.imageReference,
      localImagePath: localImagePath ?? this.localImagePath,
      locationContext: locationContext ?? this.locationContext,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'isSoilRelated': isSoilRelated,
    'imageQuality': imageQuality.name,
    'locationSummary': locationSummary,
    'soilType': soilType,
    'soilDepth': soilDepth,
    'salinity': salinity?.toMap(),
    'sodium': sodium?.toMap(),
    'phLevel': phLevel,
    'organicMatter': organicMatter,
    'nutrients': nutrients.map((e) => e.toMap()).toList(),
    'substances': substances.map((e) => e.toMap()).toList(),
    'geometry': geometry,
    'siteLocation': siteLocation?.toMap(),
    'topography': topography?.toMap(),
    'groundwater': groundwater?.toMap(),
    'buildingSuitability': buildingSuitability?.toMap(),
    'landRecord': landRecord?.toMap(),
    'aerialImagery': aerialImagery?.toMap(),
    'purpose': purpose.name,
    'userRequirements': userRequirements,
    'dataSources': dataSources,
    'suitablePlants': suitablePlants,
    'recommendations': recommendations,
    'safetyNotes': safetyNotes,
    'confidence': confidence.name,
    'needsMoreInformation': needsMoreInformation,
    'followUpQuestions': followUpQuestions,
    'disclaimer': disclaimer,
    'imageReference': imageReference,
    'locationContext': locationContext,
  };

  factory SoilReport.fromStored(String id, Map<String, dynamic> map) {
    final SoilReport base = SoilReport.fromJson(
      map['report'] is Map<String, dynamic>
          ? map['report'] as Map<String, dynamic>
          : map,
    );
    return base.withMeta(
      id: id,
      imageReference: map['imageReference'] as String?,
      locationContext: map['locationContext'] as String?,
      createdAt: _toDate(map['createdAt']),
    );
  }

  /// Plain-text summary used for the share sheet.
  String toShareText() {
    final StringBuffer b = StringBuffer('PlantSense AI soil report\n');
    if (locationSummary != null) b.writeln('Location: $locationSummary');
    if (soilType != null) b.writeln('Soil type: $soilType');
    if (soilDepth != null) b.writeln('Depth: $soilDepth');
    if (salinity != null) {
      b.writeln('Salinity (estimate): ${salinity!.level.name}');
    }
    if (sodium != null) {
      b.writeln('Sodium (estimate): ${sodium!.level.name}');
    }
    if (phLevel != null) b.writeln('pH: $phLevel');
    if (organicMatter != null) b.writeln('Organic matter: $organicMatter');
    if (nutrients.isNotEmpty) {
      b.writeln('Nutrients (estimate):');
      for (final SoilNutrient n in nutrients) {
        b.writeln('- ${n.name}: ${n.level.name}');
      }
    }
    if (geometry != null) b.writeln('Structure: $geometry');

    final TopographySurvey? topo = topography;
    if (topo != null && !topo.isEmpty) {
      b.writeln('\nTopography (estimate):');
      if (topo.summary != null) b.writeln('- ${topo.summary}');
      if (topo.elevationRange != null) {
        b.writeln('- Elevation: ${topo.elevationRange}');
      }
      if (topo.slope != null) b.writeln('- Slope: ${topo.slope}');
      if (topo.landform != null) b.writeln('- Landform: ${topo.landform}');
      if (topo.drainagePattern != null) {
        b.writeln('- Drainage: ${topo.drainagePattern}');
      }
      if (topo.floodRisk != null) {
        b.writeln('- Flood risk: ${topo.floodRisk!.name}');
      }
      if (topo.erosionRisk != null) {
        b.writeln('- Erosion risk: ${topo.erosionRisk!.name}');
      }
    }

    final GroundwaterAssessment? gw = groundwater;
    if (gw != null && !gw.isEmpty) {
      b.writeln('\nGroundwater (estimate):');
      if (gw.summary != null) b.writeln('- ${gw.summary}');
      if (gw.waterTableDepth != null) {
        b.writeln('- Water table: ${gw.waterTableDepth}');
      }
      if (gw.aquiferType != null) b.writeln('- Aquifer: ${gw.aquiferType}');
      if (gw.yieldPotential != null) {
        b.writeln('- Yield potential: ${gw.yieldPotential!.name}');
      }
      if (gw.waterQuality != null) {
        b.writeln('- Water quality: ${gw.waterQuality}');
      }
      if (gw.wellFeasibility != null) {
        b.writeln('- Well feasibility: ${gw.wellFeasibility}');
      }
    }

    final BuildingSuitability? bs = buildingSuitability;
    if (bs != null && !bs.isEmpty) {
      b.writeln('\nBuilding suitability (screening only):');
      if (bs.suitability != null) {
        b.writeln('- Rating: ${bs.suitability!.name}');
      }
      if (bs.bearingCapacity != null) {
        b.writeln('- Bearing capacity: ${bs.bearingCapacity}');
      }
      if (bs.bedrockDepth != null) {
        b.writeln('- Bedrock depth: ${bs.bedrockDepth}');
      }
      if (bs.foundationSuggestion != null) {
        b.writeln('- Foundation: ${bs.foundationSuggestion}');
      }
      for (final String s in bs.requiredStudies) {
        b.writeln('- Required study: $s');
      }
    }

    final LandRecordInfo? lr = landRecord;
    if (lr != null && lr.hasData) {
      b.writeln('\nLand Department record (official):');
      if (lr.source != null) b.writeln('- Source: ${lr.source}');
      if (lr.parcelId != null) b.writeln('- Parcel: ${lr.parcelId}');
      if (lr.registeredArea != null) {
        b.writeln('- Registered area: ${lr.registeredArea}');
      }
      if (lr.zoning != null) b.writeln('- Zoning: ${lr.zoning}');
      if (lr.classification != null) {
        b.writeln('- Classification: ${lr.classification}');
      }
    }

    if (dataSources.isNotEmpty) {
      b.writeln('\nData sources: ${dataSources.join(', ')}');
    }

    if (suitablePlants.isNotEmpty) {
      b.writeln('Suitable plants: ${suitablePlants.join(', ')}');
    }
    b.writeln('Confidence: ${confidence.name}');
    if (disclaimer.isNotEmpty) b.writeln('\n$disclaimer');
    return b.toString();
  }

  static DateTime? _toDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    try {
      final result = (value as dynamic).toDate();
      if (result is DateTime) return result;
    } catch (_) {}
    return null;
  }
}
