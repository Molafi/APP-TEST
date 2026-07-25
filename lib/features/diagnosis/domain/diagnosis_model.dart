import 'dart:convert';

enum Likelihood { low, medium, high }

enum Confidence { low, medium, high }

enum ImageQuality { good, poor, unusable }

Likelihood likelihoodFrom(String? s) => switch (s?.toLowerCase()) {
      'high' => Likelihood.high,
      'medium' => Likelihood.medium,
      _ => Likelihood.low,
    };

Confidence confidenceFrom(String? s) => switch (s?.toLowerCase()) {
      'high' => Confidence.high,
      'medium' => Confidence.medium,
      _ => Confidence.low,
    };

ImageQuality imageQualityFrom(String? s) => switch (s?.toLowerCase()) {
      'good' => ImageQuality.good,
      'poor' => ImageQuality.poor,
      _ => ImageQuality.unusable,
    };

class PossibleIssue {
  const PossibleIssue({
    required this.name,
    required this.likelihood,
    required this.reason,
  });

  final String name;
  final Likelihood likelihood;
  final String reason;

  Map<String, dynamic> toMap() =>
      {'name': name, 'likelihood': likelihood.name, 'reason': reason};

  factory PossibleIssue.fromMap(Map<String, dynamic> m) => PossibleIssue(
        name: (m['name'] as String?)?.trim() ?? '',
        likelihood: likelihoodFrom(m['likelihood'] as String?),
        reason: (m['reason'] as String?)?.trim() ?? '',
      );
}

/// Strongly typed diagnosis result. Optional fields tolerate omission; parsing
/// never relies on string splitting and degrades gracefully on malformed data.
class Diagnosis {
  const Diagnosis({
    required this.isPlantRelated,
    required this.imageQuality,
    this.plantName,
    this.scientificName,
    required this.whatISee,
    required this.possibleIssues,
    required this.treatmentSteps,
    required this.preventionTips,
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

  final bool isPlantRelated;
  final ImageQuality imageQuality;
  final String? plantName;
  final String? scientificName;
  final String whatISee;
  final List<PossibleIssue> possibleIssues;
  final List<String> treatmentSteps;
  final List<String> preventionTips;
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

  /// Parses a raw model string into a [Diagnosis]. Handles fenced code blocks
  /// and leading/trailing prose by extracting the first balanced JSON object.
  /// Throws [FormatException] when no usable JSON is present.
  static Diagnosis parse(String raw) {
    final Map<String, dynamic> json = _extractJson(raw);
    return Diagnosis.fromJson(json);
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

  factory Diagnosis.fromJson(Map<String, dynamic> j) {
    List<String> strList(Object? v) => (v is List)
        ? v.whereType<Object>().map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return Diagnosis(
      isPlantRelated: (j['isPlantRelated'] as bool?) ?? true,
      imageQuality: imageQualityFrom(j['imageQuality'] as String?),
      plantName: (j['plantName'] as String?)?.trim().isEmpty ?? true
          ? null
          : (j['plantName'] as String).trim(),
      scientificName: (j['scientificName'] as String?)?.trim().isEmpty ?? true
          ? null
          : (j['scientificName'] as String).trim(),
      whatISee: (j['whatISee'] as String?)?.trim() ?? '',
      possibleIssues: (j['possibleIssues'] is List)
          ? (j['possibleIssues'] as List)
              .whereType<Map<String, dynamic>>()
              .map(PossibleIssue.fromMap)
              .where((e) => e.name.isNotEmpty)
              .toList()
          : <PossibleIssue>[],
      treatmentSteps: strList(j['treatmentSteps']),
      preventionTips: strList(j['preventionTips']),
      safetyNotes: strList(j['safetyNotes']),
      confidence: confidenceFrom(j['confidence'] as String?),
      needsMoreInformation: (j['needsMoreInformation'] as bool?) ?? false,
      followUpQuestions: strList(j['followUpQuestions']),
      disclaimer: (j['disclaimer'] as String?)?.trim() ?? '',
    );
  }

  Diagnosis withMeta({
    String? id,
    String? imageReference,
    String? localImagePath,
    String? locationContext,
    DateTime? createdAt,
  }) {
    return Diagnosis(
      isPlantRelated: isPlantRelated,
      imageQuality: imageQuality,
      plantName: plantName,
      scientificName: scientificName,
      whatISee: whatISee,
      possibleIssues: possibleIssues,
      treatmentSteps: treatmentSteps,
      preventionTips: preventionTips,
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
        'isPlantRelated': isPlantRelated,
        'imageQuality': imageQuality.name,
        'plantName': plantName,
        'scientificName': scientificName,
        'whatISee': whatISee,
        'possibleIssues': possibleIssues.map((e) => e.toMap()).toList(),
        'treatmentSteps': treatmentSteps,
        'preventionTips': preventionTips,
        'safetyNotes': safetyNotes,
        'confidence': confidence.name,
        'needsMoreInformation': needsMoreInformation,
        'followUpQuestions': followUpQuestions,
        'disclaimer': disclaimer,
        'imageReference': imageReference,
        'locationContext': locationContext,
      };

  factory Diagnosis.fromStored(String id, Map<String, dynamic> map) {
    final Diagnosis base = Diagnosis.fromJson(map['diagnosis'] is Map<String, dynamic>
        ? map['diagnosis'] as Map<String, dynamic>
        : map);
    return base.withMeta(
      id: id,
      imageReference: map['imageReference'] as String?,
      locationContext: map['locationContext'] as String?,
      createdAt: _toDate(map['createdAt']),
    );
  }

  /// Plain-text summary used for the share sheet.
  String toShareText() {
    final StringBuffer b = StringBuffer('PlantSense AI diagnosis\n');
    if (plantName != null) b.writeln('Plant: $plantName');
    if (whatISee.isNotEmpty) b.writeln('What I see: $whatISee');
    if (possibleIssues.isNotEmpty) {
      b.writeln('Issues:');
      for (final PossibleIssue i in possibleIssues) {
        b.writeln('- ${i.name} (${i.likelihood.name})');
      }
    }
    if (treatmentSteps.isNotEmpty) {
      b.writeln('Treatment:');
      for (final String s in treatmentSteps) {
        b.writeln('- $s');
      }
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
