import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/environment.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/services/ai_gateway.dart';
import '../../../core/services/local_cache_service.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/utils/image_compressor.dart';
import '../../auth/application/auth_provider.dart';
import '../../weather/application/ai_context_provider.dart';
import '../data/ai_chat_service.dart';
import '../data/chat_repository.dart';
import '../data/firestore_chat_repository.dart';
import '../data/local_chat_repository.dart';
import '../domain/message_model.dart';

/// Selects the chat store: Firestore for a signed-in real user, local
/// (SharedPreferences) otherwise (demo/offline).
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (!Environment.isDemo && user != null) {
    return FirestoreChatRepository(uid: user.uid);
  }
  return LocalChatRepository(ref.watch(localCacheServiceProvider));
});

@immutable
class ChatState {
  const ChatState({
    this.messages = const [],
    this.isLoading = true,
    this.isTyping = false,
    this.draft = '',
    this.error,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String draft;
  final AppException? error;

  bool get isEmpty => messages.isEmpty;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? draft,
    AppException? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      draft: draft ?? this.draft,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._ref) : super(const ChatState()) {
    _load();
  }

  final Ref _ref;
  final Uuid _uuid = const Uuid();
  final ImageCompressor _compressor = const ImageCompressor();

  /// Monotonic token used to ignore responses from superseded requests.
  int _requestSeq = 0;

  ChatRepository get _repo => _ref.read(chatRepositoryProvider);
  AiChatService get _service => _ref.read(aiChatServiceProvider);

  Future<void> _load() async {
    try {
      final List<ChatMessage> msgs = await _repo.loadMessages();
      if (!mounted) return;
      state = state.copyWith(messages: msgs, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
          isLoading: false, error: ErrorMapper.fromException(e));
    }
  }

  void setDraft(String value) {
    // Kept in state so it survives navigation; not persisted (privacy).
    state = state.copyWith(draft: value);
  }

  /// Sends a text message, optionally with a prepared image.
  Future<void> send({String? text, Uint8List? imageBytes}) async {
    final String content = (text ?? state.draft).trim();
    final bool hasImage = imageBytes != null;
    if (content.isEmpty && !hasImage) return;

    AiImage? aiImage;
    String? localPath;
    if (hasImage) {
      try {
        final PreparedImage prepared = await _compressor.prepare(imageBytes);
        aiImage = AiImage(base64: prepared.base64, mimeType: prepared.mimeType);
        localPath = 'memory:${prepared.width}x${prepared.height}';
      } on AppException catch (e) {
        state = state.copyWith(error: e);
        return;
      }
    }

    // Default instruction when only an image is supplied.
    final String effectiveText = content.isEmpty
        ? 'Please analyze this plant/soil photo and tell me what you see.'
        : content;

    final ChatMessage userMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      text: effectiveText,
      status: MessageStatus.sending,
      localImagePath: localPath,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      draft: '',
      isTyping: true,
      clearError: true,
    );
    unawaited(_repo.saveMessage(userMsg));

    await _dispatch(userMsg, aiImage);
  }

  Future<void> retry(ChatMessage failed) async {
    // Rebuild image is not possible (bytes not retained); retry as text.
    _updateMessage(failed.copyWith(status: MessageStatus.sending));
    state = state.copyWith(isTyping: true, clearError: true);
    await _dispatch(failed, null);
  }

  Future<void> _dispatch(ChatMessage userMsg, AiImage? image) async {
    final int seq = ++_requestSeq;
    final AiContext ctx = _ref.read(aiContextProvider);
    final String locale = _ref.read(_localeCodeProvider);

    // History excludes the just-added, in-flight user message.
    final List<ChatMessage> history = state.messages
        .where((m) => m.id != userMsg.id && m.status != MessageStatus.failed)
        .toList();

    final ChatMessage sentUser = userMsg.copyWith(status: MessageStatus.sent);
    final String assistantId = _uuid.v4();
    bool assistantAdded = false;
    String latest = '';

    try {
      final Stream<String> stream = _service.sendMessageStream(
        locale: locale,
        userText: userMsg.text,
        history: history,
        context: ctx.values,
        image: image,
      );

      await for (final String cumulative in stream) {
        if (!mounted || seq != _requestSeq) return; // superseded/cancelled
        latest = cumulative;
        if (!assistantAdded) {
          // First chunk: mark the user message sent, drop the typing dots, and
          // insert the assistant bubble that we then update in place.
          assistantAdded = true;
          state = state.copyWith(
            isTyping: false,
            messages: [
              for (final m in state.messages)
                m.id == userMsg.id ? sentUser : m,
              ChatMessage(
                id: assistantId,
                role: MessageRole.assistant,
                text: cumulative,
                weatherContext: ctx.displayStrip,
                createdAt: DateTime.now(),
              ),
            ],
          );
        } else {
          state = state.copyWith(
            messages: [
              for (final m in state.messages)
                m.id == assistantId ? m.copyWith(text: cumulative) : m,
            ],
          );
        }
      }

      if (!mounted || seq != _requestSeq) return;
      if (!assistantAdded || latest.trim().isEmpty) {
        throw const AppException(AppErrorKind.malformedResponse);
      }

      final ChatMessage finalAssistant = ChatMessage(
        id: assistantId,
        role: MessageRole.assistant,
        text: latest,
        weatherContext: ctx.displayStrip,
        createdAt: DateTime.now(),
      );
      unawaited(_repo.updateMessage(sentUser));
      unawaited(_repo.saveMessage(finalAssistant));
    } catch (e) {
      if (!mounted || seq != _requestSeq) return;
      final AppException err = ErrorMapper.fromException(e);
      final ChatMessage failedUser =
          userMsg.copyWith(status: MessageStatus.failed);
      state = state.copyWith(
        isTyping: false,
        error: err,
        messages: [
          for (final m in state.messages)
            if (m.id != assistantId) // drop any partial assistant bubble
              m.id == userMsg.id ? failedUser : m,
        ],
      );
      unawaited(_repo.updateMessage(failedUser));
    }
  }

  Future<void> deleteConversation() async {
    _requestSeq++; // cancel any in-flight
    state = const ChatState(isLoading: false);
    await _repo.deleteAll();
  }

  void _updateMessage(ChatMessage m) {
    state = state.copyWith(
      messages: [for (final x in state.messages) x.id == m.id ? m : x],
    );
  }
}

/// Active language code for AI requests (so the model replies in the user's
/// selected language). Falls back to English when following an unsupported
/// system locale.
final _localeCodeProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  final String code = locale?.languageCode ?? 'en';
  return code == 'ar' ? 'ar' : 'en';
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref);
});
