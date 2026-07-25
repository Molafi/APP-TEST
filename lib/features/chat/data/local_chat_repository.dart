import 'dart:convert';

import '../../../core/services/local_cache_service.dart';
import '../domain/message_model.dart';
import 'chat_repository.dart';

/// SharedPreferences-backed chat store used in demo mode and offline. Persists
/// messages as JSON so history survives restarts without a backend.
class LocalChatRepository implements ChatRepository {
  LocalChatRepository(this._cache);

  static const String _key = 'chat_messages_default';
  final LocalCacheService _cache;

  @override
  Future<List<ChatMessage>> loadMessages() async {
    final String? raw = _cache.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((m) => ChatMessage.fromMap(m['id'] as String? ?? '', m))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    final List<ChatMessage> all = await loadMessages();
    all.add(message);
    await _persist(all);
  }

  @override
  Future<void> updateMessage(ChatMessage message) async {
    final List<ChatMessage> all = await loadMessages();
    final int i = all.indexWhere((m) => m.id == message.id);
    if (i >= 0) {
      all[i] = message;
      await _persist(all);
    }
  }

  @override
  Future<void> deleteAll() => _cache.remove(_key);

  Future<void> _persist(List<ChatMessage> all) async {
    final List<Map<String, dynamic>> list = all
        .map((m) => {
              'id': m.id,
              ...m.toMap(),
              'createdAt': m.createdAt.millisecondsSinceEpoch,
            })
        .toList();
    await _cache.setString(_key, jsonEncode(list));
  }
}
