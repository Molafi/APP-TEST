import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/local_cache_service.dart';
import '../domain/chat_model.dart';

/// Stores conversation metadata (title, preview, timestamps). Messages
/// themselves live in [ChatRepository], keyed by the same conversation id.
abstract class ConversationsRepository {
  Future<List<Chat>> list();
  Future<void> upsert(Chat chat);

  /// Deletes the conversation metadata AND its messages.
  Future<void> delete(String id);
}

class LocalConversationsRepository implements ConversationsRepository {
  LocalConversationsRepository(this._cache);

  static const String _key = 'conversations';
  final LocalCacheService _cache;

  @override
  Future<List<Chat>> list() async {
    final String? raw = _cache.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final chats = decoded
            .whereType<Map<String, dynamic>>()
            .map((m) => Chat.fromMap(m['id'] as String? ?? '', m))
            .toList();
        chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return chats;
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> upsert(Chat chat) async {
    final List<Chat> all = await list();
    final int i = all.indexWhere((c) => c.id == chat.id);
    if (i >= 0) {
      all[i] = chat;
    } else {
      all.add(chat);
    }
    await _persist(all);
  }

  @override
  Future<void> delete(String id) async {
    final List<Chat> all = await list();
    all.removeWhere((c) => c.id == id);
    await _persist(all);
    // Remove the conversation's messages too.
    await _cache.remove('chat_messages_$id');
  }

  Future<void> _persist(List<Chat> all) async {
    final list = all
        .map((c) => {
              'id': c.id,
              'title': c.title,
              'lastMessagePreview': c.lastMessagePreview,
              'createdAt': c.createdAt.millisecondsSinceEpoch,
              'updatedAt': c.updatedAt.millisecondsSinceEpoch,
            })
        .toList();
    await _cache.setString(_key, jsonEncode(list));
  }
}

class FirestoreConversationsRepository implements ConversationsRepository {
  FirestoreConversationsRepository(
      {required this.uid, FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(uid).collection('chats');

  @override
  Future<List<Chat>> list() async {
    final snap = await _col.orderBy('updatedAt', descending: true).get();
    return snap.docs.map((d) => Chat.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<void> upsert(Chat chat) async {
    await _col.doc(chat.id).set({
      'title': chat.title,
      'lastMessagePreview': chat.lastMessagePreview,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String id) async {
    final msgs = await _col.doc(id).collection('messages').get();
    final WriteBatch batch = _db.batch();
    for (final d in msgs.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_col.doc(id));
    await batch.commit();
  }
}
