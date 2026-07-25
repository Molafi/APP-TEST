import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/ai_gateway.dart';
import '../../../core/services/ai_prompts.dart';
import '../domain/diagnosis_model.dart';

/// Runs a structured image diagnosis: sends the image + JSON instruction to the
/// AI gateway and parses the result into a typed [Diagnosis]. Malformed output
/// is surfaced as a typed [AppException] (never raw text).
class GeminiDiagnosisService {
  GeminiDiagnosisService(this._gateway);

  final AiGateway _gateway;

  Future<Diagnosis> analyze({
    required String locale,
    required AiImage image,
    Map<String, String> context = const {},
    String? userNote,
  }) async {
    final String raw = await _gateway.generate(AiRequest(
      systemPrompt: AiPrompts.system(locale: locale),
      userText: (userNote?.trim().isNotEmpty ?? false)
          ? '${userNote!.trim()}\n\n${AiPrompts.diagnosisInstruction()}'
          : AiPrompts.diagnosisInstruction(),
      context: context,
      image: image,
      jsonMode: true,
    ));

    try {
      return Diagnosis.parse(raw);
    } on FormatException {
      throw const AppException(AppErrorKind.malformedResponse);
    }
  }
}

final geminiDiagnosisServiceProvider = Provider<GeminiDiagnosisService>((ref) {
  return GeminiDiagnosisService(ref.watch(aiGatewayProvider));
});
