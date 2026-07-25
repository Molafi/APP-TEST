enum MessageRole { user, assistant }

enum MessageStatus { sending, sent, failed }

/// A single chat message. Images are referenced by a storage path or a local
/// temp path — raw base64 is never persisted in the message document.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.status = MessageStatus.sent,
    this.imageReference,
    this.localImagePath,
    this.weatherContext,
    required this.createdAt,
  });

  final String id;
  final MessageRole role;
  final String text;
  final MessageStatus status;

  /// Storage path/URL for a retained image (null when not retained).
  final String? imageReference;

  /// Local file path for an attached image awaiting send (never persisted).
  final String? localImagePath;

  /// Human-readable context strip shown above assistant replies.
  final String? weatherContext;

  final DateTime createdAt;

  bool get hasImage => imageReference != null || localImagePath != null;

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
    String? imageReference,
    String? weatherContext,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      status: status ?? this.status,
      imageReference: imageReference ?? this.imageReference,
      localImagePath: localImagePath,
      weatherContext: weatherContext ?? this.weatherContext,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'text': text,
        'status': status.name,
        'imageReference': imageReference,
        'weatherContext': weatherContext,
        // createdAt set with server timestamp by the repository.
      };

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      role: map['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      text: (map['text'] as String?) ?? '',
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      imageReference: map['imageReference'] as String?,
      weatherContext: map['weatherContext'] as String?,
      createdAt: _toDate(map['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _toDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    try {
      final result = (value as dynamic).toDate();
      if (result is DateTime) return result;
    } catch (_) {}
    return null;
  }
}
