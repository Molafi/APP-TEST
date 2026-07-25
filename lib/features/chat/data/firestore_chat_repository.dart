import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/message_model.dart';
import 'chat_repository.dart';

/// Firestore-backed chat store: users/{uid}/chats/default/messages/{id}.
/// Uses server timestamps and typed serialization; tolerates offline writes
/// (Firestore queues them and syncs when back online).
class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository({
    required this.uid,
    this.chatId = 'default',
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final String chatId;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _messages => _db
      .collection('users')
      .doc(uid)
      .collection('chats')
      .doc(chatId)
      .collection('messages');

  @override
  Future<List<ChatMessage>> loadMessages() async {
    final snap = await _messages.orderBy('createdAt').get();
    return snap.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId)
        .set({
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessagePreview': message.text.length > 80
          ? '${message.text.substring(0, 80)}…'
          : message.text,
    }, SetOptions(merge: true));

    await _messages.doc(message.id).set({
      ...message.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateMessage(ChatMessage message) async {
    await _messages.doc(message.id).set(
      message.toMap(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deleteAll() async {
    final snap = await _messages.get();
    final WriteBatch batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
