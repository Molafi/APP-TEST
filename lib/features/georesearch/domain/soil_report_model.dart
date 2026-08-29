import 'dart:convert';

import '../../diagnosis/domain/diagnosis_model.dart' show Confidence, confidenceFrom, ImageQuality, imageQualityFrom;

export '../../diagnosis/domain/diagnosis_model.dart' show Confidence, ImageQuality;

/// A qualitative low/medium/high level used for salinity, sodium, nutrients and
/// substance concern. Kept separate from [Confidence]/[ImageQuality] but shares
/// the same `xFrom(String?)` parsing convention as the diagnosis enums.
enum SoilLevel { low, medium, high }

SoilLevel soilLevelFrom(String? s) => switch (s?.toLowerCase()) {
  'high' => SoilLevel.high,
  'medium' => SoilLevel.medium,
  _ => SoilLevel.low,
};

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
      suitablePlants: strList(j['suitablePlants']),
      recommendations: strList(j['recommendations']),
      safetyNotes: strList(j['safetyNotes']),
      confidence: confidenceFrom(j['confidence'] as String?),
      needsMoreInformation: (j['needsMoreInformation'] as bool?) ?? false,
      followUpQuestions: strList(j['followUpQuestions']),
      disclaimer: (j['disclaimer'] as String?)?.trim() ?? '',
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
