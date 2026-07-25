/// A selected place with coordinates and a human-friendly label. Coordinates
/// are only persisted when the user opts in; a saved city label is preferred
/// for context so exact GPS is not stored unnecessarily.
class PlantLocation {
  const PlantLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    this.country,
    this.countryCode,
    this.timezone,
    this.isManual = false,
  });

  final double latitude;
  final double longitude;
  final String city;
  final String? country;
  final String? countryCode;
  final String? timezone;

  /// True when chosen via manual search rather than GPS.
  final bool isManual;

  String get displayLabel {
    if (country != null && country!.isNotEmpty) return '$city, $country';
    return city;
  }

  PlantLocation copyWith({String? timezone}) => PlantLocation(
        latitude: latitude,
        longitude: longitude,
        city: city,
        country: country,
        countryCode: countryCode,
        timezone: timezone ?? this.timezone,
        isManual: isManual,
      );

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'country': country,
        'countryCode': countryCode,
        'timezone': timezone,
        'isManual': isManual,
      };

  factory PlantLocation.fromMap(Map<String, dynamic> map) => PlantLocation(
        latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
        city: (map['city'] as String?) ?? 'Unknown',
        country: map['country'] as String?,
        countryCode: map['countryCode'] as String?,
        timezone: map['timezone'] as String?,
        isManual: (map['isManual'] as bool?) ?? false,
      );

  @override
  bool operator ==(Object other) =>
      other is PlantLocation &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.city == city;

  @override
  int get hashCode => Object.hash(latitude, longitude, city);
}
