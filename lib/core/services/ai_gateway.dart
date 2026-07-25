import 'dart:convert';

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
/// so the Gemini key never touches the client. Requires a Firebase ID token
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

/// DEV-ONLY direct transport, guarded by [Environment.allowDirectGemini]. Never
/// ships with a committed key; the key is supplied via --dart-define.
class DirectGeminiGateway implements AiGateway {
  DirectGeminiGateway({required this.apiKey, required this.model, ApiClient? client})
      : _client = client ?? ApiClient();

  final String apiKey;
  final String model;
  final ApiClient _client;

  @override
  Future<String> generate(AiRequest request) async {
    final Uri uri = Uri.parse(
        '${AppConfig.geminiApiBase}/models/$model:generateContent?key=$apiKey');

    final List<Map<String, dynamic>> contents = [
      for (final AiTurn t in request.history)
        {
          'role': t.fromUser ? 'user' : 'model',
          'parts': [
            {'text': t.text}
          ]
        },
      {
        'role': 'user',
        'parts': [
          if (request.image != null)
            {
              'inline_data': {
                'mime_type': request.image!.mimeType,
                'data': request.image!.base64,
              }
            },
          {'text': _composeUserText(request)},
        ],
      },
    ];

    final Map<String, dynamic> body = {
      'system_instruction': {
        'parts': [
          {'text': request.systemPrompt}
        ]
      },
      'contents': contents,
      'generationConfig': {
        if (request.jsonMode) 'responseMimeType': 'application/json',
        'temperature': 0.4,
      },
    };

    final Map<String, dynamic> res = await _client.postJson(uri,
        body: body, timeout: AppConfig.aiTimeout);
    return _extractText(res);
  }

  String _composeUserText(AiRequest request) {
    if (request.context.isEmpty) return request.userText;
    final String ctx = request.context.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    // Delimit untrusted context clearly from the instruction.
    return '[context] $ctx\n[user] ${request.userText}';
  }

  String _extractText(Map<String, dynamic> res) {
    // Handle safety blocks / empty candidates explicitly.
    final prompt = res['promptFeedback'];
    if (prompt is Map && prompt['blockReason'] != null) {
      throw const AppException(AppErrorKind.contentBlocked);
    }
    final List<dynamic>? candidates = res['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const AppException(AppErrorKind.contentBlocked);
    }
    final content = candidates.first['content'];
    final parts = (content is Map) ? content['parts'] as List<dynamic>? : null;
    if (parts == null || parts.isEmpty) {
      throw const AppException(AppErrorKind.malformedResponse);
    }
    final StringBuffer buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['text'] is String) buffer.write(part['text']);
    }
    final String text = buffer.toString().trim();
    if (text.isEmpty) throw const AppException(AppErrorKind.malformedResponse);
    return text;
  }

  static String encodeBody(Map<String, dynamic> body) => jsonEncode(body);
}

final aiGatewayProvider = Provider<AiGateway>((ref) {
  // Demo / unconfigured: use the canned demo gateway so nothing crashes.
  if (Environment.geminiUnavailable) {
    return DemoAiGateway();
  }
  if (Environment.useGeminiBackend) {
    return BackendAiGateway(
      baseUrl: Environment.geminiBackendUrl,
      idTokenProvider: firebaseIdTokenImpl,
    );
  }
  if (Environment.allowDirectGemini) {
    return DirectGeminiGateway(
      apiKey: Environment.geminiDevApiKey,
      model: Environment.geminiModel,
    );
  }
  return DemoAiGateway();
});
