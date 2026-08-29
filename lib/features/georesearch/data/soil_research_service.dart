import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/ai_gateway.dart';
import '../../../core/services/ai_prompts.dart';
import '../domain/soil_report_model.dart';

/// Runs a structured soil-research (GeoResearch) analysis: sends the location
/// context (and an optional site/soil image) plus a JSON instruction to the AI
/// gateway and parses the result into a typed [SoilReport]. Malformed output is
/// surfaced as a typed [AppException] (never raw text).
///
/// This is an ESTIMATE/EDUCATIONAL flow — the prompt requires the model to
/// label values as approximations and recommend a professional soil-lab test.
class SoilResearchService {
  SoilResearchService(this._gateway);

  final AiGateway _gateway;

  Future<SoilReport> analyze({
    required String locale,
    AiImage? image,
    Map<String, String> context = const {},
    String? userNote,
    double? latitude,
    double? longitude,
    SurveyPurpose purpose = SurveyPurpose.general,
    String? requirements,
    LandRecordInfo? landRecord,
  }) async {
    // Enrich the context with coordinates when available so the model can
    // reason about likely regional soil characteristics, plus the user's stated
    // requirements and any official Land Department record they supplied.
    //
    // Official land-record values are passed as separate `land*` context keys
    // (never concatenated into the instruction text) so the prompt can treat
    // them as authoritative data rather than as instructions.
    final Map<String, String> enriched = {
      ...context,
      if (latitude != null) 'latitude': latitude.toStringAsFixed(4),
      if (longitude != null) 'longitude': longitude.toStringAsFixed(4),
      'surveyPurpose': purpose.name,
      if (_cleanRequirements(requirements) != null)
        'userRequirements': _cleanRequirements(requirements)!,
      if (landRecord != null && landRecord.available) ...landRecord.toContext(),
      // Derived from whether official values were actually supplied, not from
      // the switch alone, so "available with nothing filled in" reads as false.
      'landRecordAvailable':
          (landRecord != null && landRecord.available && landRecord.hasData)
              .toString(),
    };

    final String raw = await _gateway.generate(
      AiRequest(
        systemPrompt: AiPrompts.system(locale: locale),
        userText: (userNote?.trim().isNotEmpty ?? false)
            ? '${userNote!.trim()}\n\n${AiPrompts.soilResearchInstruction()}'
            : AiPrompts.soilResearchInstruction(),
        context: enriched,
        image: image,
        jsonMode: true,
      ),
    );

    try {
      return SoilReport.parse(raw);
    } on FormatException {
      throw const AppException(AppErrorKind.malformedResponse);
    }
  }

  /// Normalises the user's free-text requirements for the flattened context
  /// line: newlines and commas are neutralised so the text cannot forge extra
  /// context keys, and length is capped.
  static String? _cleanRequirements(String? raw) {
    if (raw == null) return null;
    final String s = raw
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll(',', ';')
        .trim();
    if (s.isEmpty) return null;
    return s.length > 500 ? '${s.substring(0, 500)}…' : s;
  }
}

final soilResearchServiceProvider = Provider<SoilResearchService>((ref) {
  return SoilResearchService(ref.watch(aiGatewayProvider));
});
