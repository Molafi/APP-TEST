import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../config/environment.dart';
import '../errors/app_exception.dart';
import '../errors/error_mapper.dart';
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
    final String ctx = context.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
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

  /// Emits the response incrementally as **cumulative** text (each event is the
  /// full text so far). The default implementation emits once; transports that
  /// support server-sent events override this for true token streaming.
  Stream<String> generateStream(AiRequest request) async* {
    yield await generate(request);
  }
}

/// Preferred production transport: calls the authenticated Cloud Function proxy
/// so the Groq API key never touches the client. Requires a Firebase ID token
/// supplied by [idTokenProvider].
class BackendAiGateway extends AiGateway {
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
class OpenAiCompatibleGateway extends AiGateway {
  OpenAiCompatibleGateway({
    required this.baseUrl,
    required this.apiKey,
    required this.textModels,
    required this.visionModels,
    ApiClient? client,
  }) : _client = client ?? ApiClient();

  final String baseUrl;
  final String apiKey;

  /// Ordered candidate models; the first that works is used. Subsequent entries
  /// are fallbacks tried when a model is unavailable (e.g. retired on Groq).
  final List<String> textModels;
  final List<String> visionModels;
  final ApiClient _client;

  @override
  Future<String> generate(AiRequest request) async {
    final bool hasImage = request.image != null;
    final List<String> candidates = hasImage ? visionModels : textModels;

    AppException? lastError;
    for (final String model in candidates) {
      try {
        return await _call(request, model, hasImage);
      } on AppException catch (e) {
        // Only fall through for "this model can't be used" style errors.
        final bool modelIssue =
            e.kind == AppErrorKind.modelUnavailable ||
            e.kind == AppErrorKind.notFound ||
            e.kind == AppErrorKind.invalidInput;
        if (!modelIssue) rethrow;
        lastError = e;
      }
    }
    throw lastError ?? const AppException(AppErrorKind.modelUnavailable);
  }

  List<Map<String, dynamic>> _buildMessages(AiRequest request, bool hasImage) {
    return [
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
  }

  Map<String, dynamic> _buildBody(
    AiRequest request,
    String model,
    bool hasImage, {
    bool stream = false,
  }) {
    return {
      'model': model,
      'messages': _buildMessages(request, hasImage),
      'temperature': 0.4,
      if (stream) 'stream': true,
      // JSON mode is only requested for text-only calls; not all vision models
      // accept response_format. Diagnosis relies on a strict instruction plus
      // the tolerant client-side parser instead.
      if (request.jsonMode && !hasImage)
        'response_format': {'type': 'json_object'},
    };
  }

  Future<String> _call(AiRequest request, String model, bool hasImage) async {
    final Map<String, dynamic> res = await _client.postJson(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {'Authorization': 'Bearer $apiKey'},
      body: _buildBody(request, model, hasImage),
      timeout: AppConfig.aiTimeout,
    );
    return _extractText(res);
  }

  @override
  Stream<String> generateStream(AiRequest request) async* {
    final bool hasImage = request.image != null;
    // Streaming is used for text-only chat. For image/JSON diagnosis we want
    // the complete document, so fall back to a single emit.
    if (hasImage || request.jsonMode) {
      yield await generate(request);
      return;
    }

    final String model = (hasImage ? visionModels : textModels).first;
    final http.Client client = http.Client();
    try {
      final http.Request req =
          http.Request('POST', Uri.parse('$baseUrl/chat/completions'))
            ..headers['Authorization'] = 'Bearer $apiKey'
            ..headers['Content-Type'] = 'application/json'
            ..body = jsonEncode(
              _buildBody(request, model, hasImage, stream: true),
            );

      final http.StreamedResponse res = await client
          .send(req)
          .timeout(AppConfig.aiTimeout);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ErrorMapper.fromHttpStatus(res.statusCode);
      }

      final StringBuffer acc = StringBuffer();
      await for (final String line
          in res.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        if (!line.startsWith('data:')) continue;
        final String data = line.substring(5).trim();
        if (data.isEmpty) continue;
        if (data == '[DONE]') break;
        try {
          final Map<String, dynamic> json =
              jsonDecode(data) as Map<String, dynamic>;
          final List<dynamic>? choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;
          final delta = (choices.first as Map)['delta'];
          final piece = (delta is Map) ? delta['content'] : null;
          if (piece is String && piece.isNotEmpty) {
            acc.write(piece);
            yield acc.toString();
          }
        } catch (_) {
          // Ignore malformed keep-alive/comment lines.
        }
      }
      if (acc.isEmpty) {
        // Nothing streamed — fall back to a non-streaming call.
        yield await generate(request);
      }
    } catch (e) {
      // On any streaming failure, fall back to the non-streaming path so the
      // user still gets an answer.
      yield await generate(request);
    } finally {
      client.close();
    }
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
      textModels: Environment.groqTextModels,
      visionModels: Environment.groqVisionModels,
    );
  }
  return DemoAiGateway();
});
