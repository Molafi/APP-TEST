import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/ai_gateway.dart';
import '../../../core/services/ai_prompts.dart';
import '../domain/message_model.dart';

/// Builds AI requests for conversational chat and returns the model's text.
/// Provider-agnostic — the underlying [AiGateway] decides how the request is
/// fulfilled (Groq backend proxy, direct dev client, or demo fake). Trims
/// history to the configured context window and injects available
/// weather/location context (unknown values are omitted upstream).
class AiChatService {
  AiChatService(this._gateway);

  final AiGateway _gateway;

  Future<String> sendMessage({
    required String locale,
    required String userText,
    required List<ChatMessage> history,
    Map<String, String> context = const {},
    AiImage? image,
  }) {
    final List<AiTurn> turns = history
        .where((m) => m.text.trim().isNotEmpty)
        .map((m) => AiTurn(fromUser: m.role == MessageRole.user, text: m.text))
        .toList();
    final List<AiTurn> trimmed = turns.length > AppConfig.maxContextMessages
        ? turns.sublist(turns.length - AppConfig.maxContextMessages)
        : turns;

    return _gateway.generate(AiRequest(
      systemPrompt: AiPrompts.system(locale: locale),
      userText: userText,
      context: context,
      history: trimmed,
      image: image,
    ));
  }
}

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService(ref.watch(aiGatewayProvider));
});
