import 'dart:convert';

/// Where the plant lives — affects weather-aware watering advice.
enum PlantPlace { indoor, outdoor }

PlantPlace plantPlaceFrom(String? s) =>
    s == 'outdoor' ? PlantPlace.outdoor : PlantPlace.indoor;

/// A plant the user is tracking in their journal. Photos are referenced by a
/// storage path (never raw bytes in the document).
class Plant {
  const Plant({
    required this.id,
    required this.name,
    this.species,
    this.place = PlantPlace.indoor,
    this.notes,
    this.imageReference,
    this.wateringIntervalDays,
    this.lastWateredAt,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? species;
  final PlantPlace place;
  final String? notes;
  final String? imageReference;

  /// Base watering cadence in days (weather can shorten it — see the schedule
  /// generator). Null means "not set".
  final int? wateringIntervalDays;

  final DateTime? lastWateredAt;
  final DateTime? createdAt;

  Plant copyWith({
    String? name,
    String? species,
    PlantPlace? place,
    String? notes,
    String? imageReference,
    int? wateringIntervalDays,
    DateTime? lastWateredAt,
  }) {
    return Plant(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      place: place ?? this.place,
      notes: notes ?? this.notes,
      imageReference: imageReference ?? this.imageReference,
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'species': species,
    'place': place.name,
    'notes': notes,
    'imageReference': imageReference,
    'wateringIntervalDays': wateringIntervalDays,
    'lastWateredAt': lastWateredAt?.toIso8601String(),
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  factory Plant.fromMap(Map<String, dynamic> m) => Plant(
    id: (m['id'] as String?) ?? '',
    name: (m['name'] as String?) ?? '',
    species: m['species'] as String?,
    place: plantPlaceFrom(m['place'] as String?),
    notes: m['notes'] as String?,
    imageReference: m['imageReference'] as String?,
    wateringIntervalDays: (m['wateringIntervalDays'] as num?)?.toInt(),
    lastWateredAt: _toDate(m['lastWateredAt']),
    createdAt: _toDate(m['createdAt']),
  );

  static String encodeList(List<Plant> list) =>
      jsonEncode(list.map((e) => e.toMap()).toList());

  static List<Plant> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return <Plant>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(Plant.fromMap)
            .toList();
      }
    } catch (_) {}
    return <Plant>[];
  }

  static DateTime? _toDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    try {
      final result = (value as dynamic).toDate();
      if (result is DateTime) return result;
    } catch (_) {}
    return null;
  }
}
