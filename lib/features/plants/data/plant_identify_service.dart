import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_gateway.dart';

/// Structured result of identifying a plant from a photo.
class PlantIdentification {
  const PlantIdentification({
    this.isPlant = true,
    this.name,
    this.species,
    this.place,
    this.wateringIntervalDays,
    this.notes,
  });

  final bool isPlant;
  final String? name;
  final String? species;

  /// 'indoor' or 'outdoor' (best guess).
  final String? place;
  final int? wateringIntervalDays;
  final String? notes;

  factory PlantIdentification.parse(String raw) {
    final Object? obj = jsonDecode(_stripFences(raw));
    if (obj is! Map) throw const FormatException('Not a JSON object');
    final map = obj.cast<String, dynamic>();
    return PlantIdentification(
      isPlant: (map['isPlant'] as bool?) ?? true,
      name: _str(map['commonName'] ?? map['name']),
      species: _str(map['scientificName'] ?? map['species']),
      place: _str(map['place'])?.toLowerCase(),
      wateringIntervalDays: (map['wateringIntervalDays'] as num?)?.toInt(),
      notes: _str(map['careNotes'] ?? map['notes']),
    );
  }

  static String? _str(Object? v) {
    if (v is String && v.trim().isNotEmpty && v.trim().toLowerCase() != 'null') {
      return v.trim();
    }
    return null;
  }

  /// Removes ```json fences if the model wrapped the output.
  static String _stripFences(String s) {
    String t = s.trim();
    if (t.startsWith('```')) {
      t = t.replaceFirst(RegExp(r'^```[a-zA-Z]*'), '').trim();
      if (t.endsWith('```')) t = t.substring(0, t.length - 3).trim();
    }
    // Fall back to the first {...} block if extra prose leaked in.
    final int start = t.indexOf('{');
    final int end = t.lastIndexOf('}');
    if (start >= 0 && end > start) return t.substring(start, end + 1);
    return t;
  }
}

/// Uses the AI vision gateway to identify a plant and suggest care details.
class PlantIdentifyService {
  PlantIdentifyService(this._gateway);

  final AiGateway _gateway;

  Future<PlantIdentification> identify({
    required String locale,
    required AiImage image,
  }) async {
    final String raw = await _gateway.generate(AiRequest(
      systemPrompt:
          'You are a botanist. Identify the plant in the image and suggest '
          'basic care. Answer in the user\'s language (locale: $locale). '
          'Respond with ONLY valid JSON, no markdown.',
      userText: _instruction,
      image: image,
      jsonMode: true,
    ));
    return PlantIdentification.parse(raw);
  }

  static const String _instruction = '''
Identify the plant in the attached photo. Respond with ONLY this JSON object:
{
  "isPlant": boolean,
  "commonName": string,
  "scientificName": string,
  "place": "indoor" | "outdoor",
  "wateringIntervalDays": number,
  "careNotes": string
}
Base "wateringIntervalDays" on the species' typical needs (e.g. succulents 10-14,
tropical foliage 5-7, herbs 2-3). Keep "careNotes" to 1-2 short sentences. If the
image is not a plant, set "isPlant" to false.''';
}

final plantIdentifyServiceProvider = Provider<PlantIdentifyService>((ref) {
  return PlantIdentifyService(ref.watch(aiGatewayProvider));
});
