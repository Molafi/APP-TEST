import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../config/environment.dart';
import '../errors/app_exception.dart';
import '../networking/api_client.dart';
import 'demo_ai_gateway.dart';
import 'firebase_id_token.dart';

/// A single prior conversation turn passed as context to the model.
class AiTurn {
  const AiTurn({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
}

/// An image part for multimodal (vision) requests.
class AiImage {
  const AiImage({required this.base64, required this.mimeType});
  final String base64;
  final String mimeType;

  /// Data URL form expected by OpenAI-compatible `image_url` parts.
  String get dataUrl => 'data:$mimeType;base64,$base64';
}

/// A normalized request for the AI, independent of transport.
class AiRequest {
  const AiRequest({
    required this.systemPrompt,
    required this.userText,
    this.context = const {},
    this.history = const [],
    this.image,
    this.jsonMode = false,
  });

  final String systemPrompt;
  final String userText;
  final Map<String, String> context;
  final List<AiTurn> history;
  final AiImage? image;
  final bool jsonMode;

  /// Composes the user text with any available (untrusted) context, clearly
  /// delimited from the instruction.
  String composeUserText() {
    if (context.isEmpty) return userText;
    final String ctx =
        context.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return '[context] $ctx\n[user] $userText';
  }

  /// Payload sent to the secure Cloud Function proxy (unchanged across
  /// providers — the function decides which provider/model to call).
  Map<String, dynamic> toBackendPayload() => {
        'system': systemPrompt,
        'text': userText,
        'context': context,
        'history': history
            .map((t) => {'role': t.fromUser ? 'user' : 'model', 'text': t.text})
            .toList(),
        if (image != null)
          'image': {'mimeType': image!.mimeType, 'data': image!.base64},
        'jsonMode': jsonMode,
      };
}

/// Transport-agnostic AI gateway. Returns raw model text; callers parse.
abstract class AiGateway {
  Future<String> generate(AiRequest request);
}

/// Preferred production transport: calls the authenticated Cloud Function proxy
/// so the Groq API key never touches the client. Requires a Firebase ID token
/// supplied by [idTokenProvider].
class BackendAiGateway implements AiGateway {
  BackendAiGateway({
    required this.baseUrl,
    required this.idTokenProvider,
    ApiClient? client,
  }) : _client = client ?? ApiClient();

  final String baseUrl;
  final Future<String?> Function() idTokenProvider;
  final ApiClient _client;

  @override
  Future<String> generate(AiRequest request) async {
    final String? token = await idTokenProvider();
    if (token == null) throw const AppException(AppErrorKind.unauthenticated);
    final Map<String, dynamic> res = await _client.postJson(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
      body: request.toBackendPayload(),
      timeout: AppConfig.aiTimeout,
    );
    final String? text = res['text'] as String?;
    if (text == null || text.isEmpty) {
      throw const AppException(AppErrorKind.malformedResponse);
    }
    return text;
  }
}

/// DEV-ONLY direct transport that calls Groq's OpenAI-compatible Chat
/// Completions API from the client. Guarded by [Environment.allowDirectGroq];
/// never ships with a committed key (supplied via --dart-define). The same
/// class works for any OpenAI-compatible provider by changing [baseUrl].
class OpenAiCompatibleGateway implements AiGateway {
  OpenAiCompatibleGateway({
    required this.baseUrl,
    required this.apiKey,
    required this.textModel,
    required this.visionModel,
    ApiClient? client,
  }) : _client = client ?? ApiClient();

  final String baseUrl;
  final String apiKey;
  final String textModel;
  final String visionModel;
  final ApiClient _client;

  @override
  Future<String> generate(AiRequest request) async {
    final bool hasImage = request.image != null;
    final Uri uri = Uri.parse('$baseUrl/chat/completions');

    final List<Map<String, dynamic>> messages = [
      {'role': 'system', 'content': request.systemPrompt},
      for (final AiTurn t in request.history)
        {'role': t.fromUser ? 'user' : 'assistant', 'content': t.text},
      {
        'role': 'user',
        'content': hasImage
            // Multimodal content array (text + image).
            ? [
                {'type': 'text', 'text': request.composeUserText()},
                {
                  'type': 'image_url',
                  'image_url': {'url': request.image!.dataUrl},
                },
              ]
            : request.composeUserText(),
      },
    ];

    final Map<String, dynamic> body = {
      'model': hasImage ? visionModel : textModel,
      'messages': messages,
      'temperature': 0.4,
      // JSON mode is only requested for text-only calls; not all vision models
      // accept response_format. Diagnosis relies on a strict instruction plus
      // the tolerant client-side parser instead.
      if (request.jsonMode && !hasImage)
        'response_format': {'type': 'json_object'},
    };

    final Map<String, dynamic> res = await _client.postJson(
      uri,
      headers: {'Authorization': 'Bearer $apiKey'},
      body: body,
      timeout: AppConfig.aiTimeout,
    );
    return _extractText(res);
  }

  String _extractText(Map<String, dynamic> res) {
    final List<dynamic>? choices = res['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const AppException(AppErrorKind.malformedResponse);
    }
    final first = choices.first;
    final message = (first is Map) ? first['message'] : null;
    // A non-null finish for content filtering surfaces as empty content.
    final content = (message is Map) ? message['content'] : null;
    if (content is! String || content.trim().isEmpty) {
      throw const AppException(AppErrorKind.malformedResponse);
    }
    return content.trim();
  }
}

final aiGatewayProvider = Provider<AiGateway>((ref) {
  // Demo / unconfigured: use the canned demo gateway so nothing crashes.
  if (Environment.aiUnavailable) {
    return DemoAiGateway();
  }
  if (Environment.useAiBackend) {
    return BackendAiGateway(
      baseUrl: Environment.aiBackendUrl,
      idTokenProvider: firebaseIdTokenImpl,
    );
  }
  if (Environment.allowDirectGroq) {
    return OpenAiCompatibleGateway(
      baseUrl: AppConfig.groqApiBase,
      apiKey: Environment.groqApiKey,
      textModel: Environment.groqTextModel,
      visionModel: Environment.groqVisionModel,
    );
  }
  return DemoAiGateway();
});
