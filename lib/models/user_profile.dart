import '../core/constants/app_constants.dart';
import '../features/location/domain/location_model.dart';

/// User profile stored in Firestore at `users/{uid}`. Never contains passwords.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.locale = 'en',
    this.unitSystem = UnitSystem.metric,
    this.selectedLocation,
    this.imageRetentionEnabled = false,
    this.notificationsEnabled = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String locale;
  final UnitSystem unitSystem;
  final PlantLocation? selectedLocation;
  final bool imageRetentionEnabled;
  final bool notificationsEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? locale,
    UnitSystem? unitSystem,
    PlantLocation? selectedLocation,
    bool? imageRetentionEnabled,
    bool? notificationsEnabled,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      locale: locale ?? this.locale,
      unitSystem: unitSystem ?? this.unitSystem,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      imageRetentionEnabled:
          imageRetentionEnabled ?? this.imageRetentionEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'locale': locale,
    'unitSystem': unitSystem.id,
    'selectedLocation': selectedLocation?.toMap(),
    'imageRetentionEnabled': imageRetentionEnabled,
    'notificationsEnabled': notificationsEnabled,
    // Timestamps are set with server values by the repository layer.
  };

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: (map['email'] as String?) ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      locale: (map['locale'] as String?) ?? 'en',
      unitSystem: UnitSystemX.fromId(map['unitSystem'] as String?),
      selectedLocation: map['selectedLocation'] is Map<String, dynamic>
          ? PlantLocation.fromMap(
              map['selectedLocation'] as Map<String, dynamic>,
            )
          : null,
      imageRetentionEnabled: (map['imageRetentionEnabled'] as bool?) ?? false,
      notificationsEnabled: (map['notificationsEnabled'] as bool?) ?? false,
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
    );
  }

  static DateTime? _toDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    // Firestore Timestamp exposes toDate(); accessed dynamically to avoid a
    // hard dependency here in the pure model layer.
    try {
      final dynamic dyn = value;
      final result = dyn.toDate();
      if (result is DateTime) return result;
    } catch (_) {}
    return null;
  }
}
