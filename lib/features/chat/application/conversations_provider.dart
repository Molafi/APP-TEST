import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/environment.dart';
import '../../../core/services/local_cache_service.dart';
import '../../auth/application/auth_provider.dart';
import '../data/conversations_repository.dart';
import '../domain/chat_model.dart';

/// The id of the conversation currently shown in the chat tab.
final currentChatIdProvider = StateProvider<String>((ref) => 'default');

final conversationsRepositoryProvider = Provider<ConversationsRepository>((
  ref,
) {
  final user = ref.watch(currentUserProvider);
  if (!Environment.isDemo && user != null) {
    return FirestoreConversationsRepository(uid: user.uid);
  }
  return LocalConversationsRepository(ref.watch(localCacheServiceProvider));
});

/// Manages the list of conversations (create / rename / delete / reorder by
/// recency). The active conversation is tracked by [currentChatIdProvider].
class ConversationsController extends StateNotifier<List<Chat>> {
  ConversationsController(this._ref) : super(const []) {
    _load();
  }

  final Ref _ref;
  final Uuid _uuid = const Uuid();

  ConversationsRepository get _repo =>
      _ref.read(conversationsRepositoryProvider);

  Future<void> _load() async {
    try {
      state = await _repo.list();
    } catch (_) {
      state = const [];
    }
  }

  /// Creates a new conversation and makes it active.
  Future<String> create({String title = 'New conversation'}) async {
    final String id = _uuid.v4();
    final DateTime now = DateTime.now();
    final Chat chat = Chat(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: now,
    );
    state = [chat, ...state];
    _ref.read(currentChatIdProvider.notifier).state = id;
    await _repo.upsert(chat);
    return id;
  }

  Future<void> open(String id) async {
    _ref.read(currentChatIdProvider.notifier).state = id;
  }

  Future<void> rename(String id, String title) async {
    Chat? updated;
    state = [
      for (final c in state)
        if (c.id == id)
          updated = Chat(
            id: c.id,
            title: title,
            createdAt: c.createdAt,
            updatedAt: DateTime.now(),
            lastMessagePreview: c.lastMessagePreview,
          )
        else
          c,
    ];
    if (updated != null) await _repo.upsert(updated);
  }

  /// Updates recency + preview (and sets the title from the first message when
  /// the conversation is still untitled).
  Future<void> touch(String id, {String? preview, String? autoTitle}) async {
    final int i = state.indexWhere((c) => c.id == id);
    final DateTime now = DateTime.now();
    final Chat base = i >= 0
        ? state[i]
        : Chat(
            id: id,
            title: 'New conversation',
            createdAt: now,
            updatedAt: now,
          );
    final bool untitled =
        base.title.isEmpty || base.title == 'New conversation';
    final Chat updated = Chat(
      id: id,
      title: (untitled && autoTitle != null && autoTitle.isNotEmpty)
          ? _shorten(autoTitle)
          : base.title,
      createdAt: base.createdAt,
      updatedAt: now,
      lastMessagePreview: preview ?? base.lastMessagePreview,
    );
    final List<Chat> list = [updated, ...state.where((c) => c.id != id)];
    state = list;
    await _repo.upsert(updated);
  }

  Future<void> delete(Chat chat) async {
    await _repo.delete(chat.id);
    state = state.where((c) => c.id != chat.id).toList();
    // If we deleted the active conversation, switch to another (or default).
    if (_ref.read(currentChatIdProvider) == chat.id) {
      _ref.read(currentChatIdProvider.notifier).state = state.isNotEmpty
          ? state.first.id
          : 'default';
    }
  }

  String _shorten(String s) => s.length <= 40 ? s : '${s.substring(0, 40)}…';
}

final conversationsControllerProvider =
    StateNotifierProvider<ConversationsController, List<Chat>>((ref) {
      return ConversationsController(ref);
    });
