import '../domain/message_model.dart';

/// Persistence abstraction for a user's conversation. The app uses a single
/// active conversation ("default") for simplicity; the interface can be
/// extended to multiple chats without changing callers.
abstract class ChatRepository {
  Future<List<ChatMessage>> loadMessages();
  Future<void> saveMessage(ChatMessage message);
  Future<void> updateMessage(ChatMessage message);
  Future<void> deleteAll();
}
