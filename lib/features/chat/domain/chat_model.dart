/// A conversation. Messages live in a subcollection; this holds metadata used
/// for the (future) conversation list and previews.
class Chat {
  const Chat({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessagePreview,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessagePreview;

  Map<String, dynamic> toMap() => {
        'title': title,
        'lastMessagePreview': lastMessagePreview,
        // timestamps set with server values by the repository.
      };

  factory Chat.fromMap(String id, Map<String, dynamic> map) => Chat(
        id: id,
        title: (map['title'] as String?) ?? 'Conversation',
        createdAt: _toDate(map['createdAt']) ?? DateTime.now(),
        updatedAt: _toDate(map['updatedAt']) ?? DateTime.now(),
        lastMessagePreview: map['lastMessagePreview'] as String?,
      );

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
