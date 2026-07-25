/// Domain models for the Land & Soil Insights feature.
///
/// Soil property values originate from the SoilGrids (ISRIC) global soil
/// database and are location estimates, NOT live sensor readings. They give a
/// realistic starting point for soil pH, texture and water behaviour that the
/// user can refine with their own meter reading.
library;

/// A single soil depth interval (e.g. 0–5 cm) with the properties SoilGrids
/// exposes. All values here are already converted to human-friendly units.
class SoilLayer {
  const SoilLayer({
    required this.label,
    required this.topCm,
    required this.bottomCm,
    this.phH2o,
    this.clayPct,
    this.sandPct,
    this.siltPct,
    this.socGkg,
    this.nitrogenGkg,
    this.bulkDensity,
    this.waterContentPct,
  });

  /// Raw SoilGrids depth label, e.g. `0-5cm`.
  final String label;
  final int topCm;
  final int bottomCm;

  /// pH measured in water (typical agronomic pH). ~3.5 (very acidic) to
  /// ~10 (very alkaline). 6.0–7.5 suits most plants.
  final double? phH2o;

  final double? clayPct;
  final double? sandPct;
  final double? siltPct;

  /// Soil organic carbon (g/kg) — a proxy for fertility / organic matter.
  final double? socGkg;

  /// Total nitrogen (g/kg).
  final double? nitrogenGkg;

  /// Bulk density (kg/dm³ ≈ g/cm³). High values indicate compaction.
  final double? bulkDensity;

  /// Volumetric water content at field capacity (vol %). Higher = holds more
  /// water after drainage.
  final double? waterContentPct;

  String get displayDepth => '$topCm–$bottomCm cm';

  /// Simplified USDA-style texture class derived from the sand/clay/silt mix.
  String get textureClass {
    final double? c = clayPct;
    final double? s = sandPct;
    final double? si = siltPct;
    if (c == null || s == null || si == null) return 'Unknown';
    if (s >= 70) return 'Sandy';
    if (c >= 40) return 'Clay';
    if (si >= 65) return 'Silty';
    if (c >= 27 && c < 40 && s <= 45) return 'Clay loam';
    return 'Loam';
  }

  /// Qualitative drainage/water behaviour inferred from texture.
  SoilDrainage get drainage {
    switch (textureClass) {
      case 'Sandy':
        return SoilDrainage.fast;
      case 'Clay':
      case 'Clay loam':
        return SoilDrainage.slow;
      case 'Silty':
        return SoilDrainage.moderate;
      default:
        return SoilDrainage.balanced;
    }
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'topCm': topCm,
        'bottomCm': bottomCm,
        'phH2o': phH2o,
        'clayPct': clayPct,
        'sandPct': sandPct,
        'siltPct': siltPct,
        'socGkg': socGkg,
        'nitrogenGkg': nitrogenGkg,
        'bulkDensity': bulkDensity,
        'waterContentPct': waterContentPct,
      };

  factory SoilLayer.fromJson(Map<String, dynamic> m) => SoilLayer(
        label: (m['label'] as String?) ?? '',
        topCm: (m['topCm'] as num?)?.toInt() ?? 0,
        bottomCm: (m['bottomCm'] as num?)?.toInt() ?? 0,
        phH2o: (m['phH2o'] as num?)?.toDouble(),
        clayPct: (m['clayPct'] as num?)?.toDouble(),
        sandPct: (m['sandPct'] as num?)?.toDouble(),
        siltPct: (m['siltPct'] as num?)?.toDouble(),
        socGkg: (m['socGkg'] as num?)?.toDouble(),
        nitrogenGkg: (m['nitrogenGkg'] as num?)?.toDouble(),
        bulkDensity: (m['bulkDensity'] as num?)?.toDouble(),
        waterContentPct: (m['waterContentPct'] as num?)?.toDouble(),
      );
}

enum SoilDrainage { fast, moderate, balanced, slow }

extension SoilDrainageX on SoilDrainage {
  String get label => switch (this) {
        SoilDrainage.fast => 'Fast draining',
        SoilDrainage.moderate => 'Moderate drainage',
        SoilDrainage.balanced => 'Well balanced',
        SoilDrainage.slow => 'Slow draining',
      };

  /// Practical watering guidance implied by drainage.
  String get wateringHint => switch (this) {
        SoilDrainage.fast =>
          'Water little and often — sandy soil dries quickly and holds few nutrients.',
        SoilDrainage.moderate =>
          'Water moderately; silty soil keeps moisture but can crust over.',
        SoilDrainage.balanced =>
          'Loam holds water and nutrients well — water deeply when the top few cm dry out.',
        SoilDrainage.slow =>
          'Water deeply but less often — clay retains water and can waterlog roots.',
      };
}

/// pH interpretation buckets.
enum PhCategory { veryAcidic, acidic, slightlyAcidic, neutral, alkaline }

extension PhCategoryX on PhCategory {
  String get label => switch (this) {
        PhCategory.veryAcidic => 'Very acidic',
        PhCategory.acidic => 'Acidic',
        PhCategory.slightlyAcidic => 'Slightly acidic',
        PhCategory.neutral => 'Neutral',
        PhCategory.alkaline => 'Alkaline',
      };
}

/// A full soil profile at a coordinate, with the shallowest layer treated as
/// "topsoil".
class SoilProfile {
  const SoilProfile({
    required this.latitude,
    required this.longitude,
    required this.layers,
    this.fetchedAtMs,
  });

  final double latitude;
  final double longitude;
  final List<SoilLayer> layers;
  final int? fetchedAtMs;

  bool get isEmpty => layers.isEmpty;

  /// Shallowest available layer (the topsoil).
  SoilLayer? get topsoil => layers.isEmpty ? null : layers.first;

  double? get topsoilPh => topsoil?.phH2o;

  PhCategory? get phCategory {
    final double? ph = topsoilPh;
    if (ph == null) return null;
    if (ph < 5.0) return PhCategory.veryAcidic;
    if (ph < 5.8) return PhCategory.acidic;
    if (ph < 6.5) return PhCategory.slightlyAcidic;
    if (ph <= 7.5) return PhCategory.neutral;
    return PhCategory.alkaline;
  }

  /// Northern hemisphere when latitude is positive.
  bool get isNorthernHemisphere => latitude >= 0;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'fetchedAtMs': fetchedAtMs,
        'layers': layers.map((l) => l.toJson()).toList(),
      };

  factory SoilProfile.fromJson(Map<String, dynamic> m) => SoilProfile(
        latitude: (m['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (m['longitude'] as num?)?.toDouble() ?? 0,
        fetchedAtMs: (m['fetchedAtMs'] as num?)?.toInt(),
        layers: ((m['layers'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SoilLayer.fromJson)
            .toList(),
      );
}
