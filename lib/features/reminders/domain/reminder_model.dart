import 'dart:convert';

enum ReminderType { watering, fertilizing, repotting, inspection, followUp }

enum Recurrence { none, daily, weekly }

ReminderType reminderTypeFrom(String? s) => ReminderType.values.firstWhere(
  (e) => e.name == s,
  orElse: () => ReminderType.watering,
);

Recurrence recurrenceFrom(String? s) => Recurrence.values.firstWhere(
  (e) => e.name == s,
  orElse: () => Recurrence.none,
);

class Reminder {
  const Reminder({
    required this.id,
    required this.plantName,
    required this.type,
    this.note,
    required this.scheduledAt,
    this.recurrence = Recurrence.none,
    this.enabled = true,
    this.createdAt,
  });

  final String id;
  final String plantName;
  final ReminderType type;
  final String? note;
  final DateTime scheduledAt;
  final Recurrence recurrence;
  final bool enabled;
  final DateTime? createdAt;

  /// Stable notification id derived from the reminder id.
  int get notificationId => id.hashCode & 0x7fffffff;

  Reminder copyWith({
    String? plantName,
    ReminderType? type,
    String? note,
    DateTime? scheduledAt,
    Recurrence? recurrence,
    bool? enabled,
  }) {
    return Reminder(
      id: id,
      plantName: plantName ?? this.plantName,
      type: type ?? this.type,
      note: note ?? this.note,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      recurrence: recurrence ?? this.recurrence,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'plantName': plantName,
    'type': type.name,
    'note': note,
    'scheduledAt': scheduledAt.toIso8601String(),
    'recurrence': recurrence.name,
    'enabled': enabled,
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  factory Reminder.fromMap(Map<String, dynamic> m) => Reminder(
    id: (m['id'] as String?) ?? '',
    plantName: (m['plantName'] as String?) ?? '',
    type: reminderTypeFrom(m['type'] as String?),
    note: m['note'] as String?,
    scheduledAt:
        DateTime.tryParse(m['scheduledAt'] as String? ?? '') ?? DateTime.now(),
    recurrence: recurrenceFrom(m['recurrence'] as String?),
    enabled: (m['enabled'] as bool?) ?? true,
    createdAt: DateTime.tryParse(m['createdAt'] as String? ?? ''),
  );

  static String encodeList(List<Reminder> list) =>
      jsonEncode(list.map((e) => e.toMap()).toList());

  static List<Reminder> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return <Reminder>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(Reminder.fromMap)
            .toList();
      }
    } catch (_) {}
    return <Reminder>[];
  }
}
