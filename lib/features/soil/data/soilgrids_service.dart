import '../../../core/networking/api_client.dart';
import '../domain/soil_model.dart';

/// Fetches soil property estimates from the free SoilGrids (ISRIC) REST API.
///
/// SoilGrids returns integer values in "mapped units" that must be divided by
/// each property's `d_factor` to reach conventional units. We apply that factor
/// generically from the response so we stay correct even if ISRIC tweaks a
/// property's scaling.
///
/// No API key is required. See https://www.isric.org/explore/soilgrids/faq
class SoilGridsService {
  SoilGridsService(this._api);

  final ApiClient _api;

  static const String _base =
      'https://rest.isric.org/soilgrids/v2.0/properties/query';

  /// Properties we request. Kept small so the query stays fast.
  static const List<String> _properties = [
    'phh2o', // pH in water
    'clay',
    'sand',
    'silt',
    'soc', // organic carbon
    'nitrogen',
    'bdod', // bulk density
    'wv0033', // water content at field capacity
  ];

  /// Topsoil-focused depth intervals.
  static const List<String> _depths = ['0-5cm', '5-15cm', '15-30cm'];

  Future<SoilProfile> fetch({
    required double lat,
    required double lon,
  }) async {
    final Uri uri = Uri.parse(_base).replace(queryParameters: <String, dynamic>{
      'lon': lon.toString(),
      'lat': lat.toString(),
      'property': _properties,
      'depth': _depths,
      'value': 'mean',
    });

    final Map<String, dynamic> json = await _api.getJson(uri);
    return _parse(json, lat: lat, lon: lon);
  }

  SoilProfile _parse(
    Map<String, dynamic> json, {
    required double lat,
    required double lon,
  }) {
    final props = json['properties'];
    final layersRaw =
        (props is Map<String, dynamic>) ? props['layers'] : null;
    if (layersRaw is! List) {
      return SoilProfile(latitude: lat, longitude: lon, layers: const []);
    }

    // Accumulate per-depth property values keyed by depth label.
    final Map<String, _DepthAcc> byDepth = {};

    for (final layer in layersRaw) {
      if (layer is! Map<String, dynamic>) continue;
      final String name = (layer['name'] as String?) ?? '';
      final double dFactor = _dFactor(layer);
      final depths = layer['depths'];
      if (depths is! List) continue;

      for (final depth in depths) {
        if (depth is! Map<String, dynamic>) continue;
        final String label = (depth['label'] as String?) ?? '';
        if (label.isEmpty) continue;
        final values = depth['values'];
        final num? mean =
            (values is Map<String, dynamic>) ? values['mean'] as num? : null;
        if (mean == null) continue;

        final acc = byDepth.putIfAbsent(label, () => _DepthAcc(label));
        final double converted = mean.toDouble() / dFactor;
        acc.apply(name, converted);
      }
    }

    // Preserve the requested depth ordering (shallowest first).
    final List<SoilLayer> layers = [];
    for (final d in _depths) {
      final acc = byDepth[d];
      if (acc != null) layers.add(acc.build());
    }
    // Include any unexpected depths at the end.
    for (final entry in byDepth.entries) {
      if (!_depths.contains(entry.key)) layers.add(entry.value.build());
    }

    return SoilProfile(
      latitude: lat,
      longitude: lon,
      layers: layers,
      fetchedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  double _dFactor(Map<String, dynamic> layer) {
    final unit = layer['unit_measure'];
    if (unit is Map<String, dynamic>) {
      final num? f = unit['d_factor'] as num?;
      if (f != null && f != 0) return f.toDouble();
    }
    return 1.0;
  }
}

/// Mutable accumulator for a single depth interval while parsing.
class _DepthAcc {
  _DepthAcc(this.label);
  final String label;

  double? ph;
  double? clay;
  double? sand;
  double? silt;
  double? soc;
  double? nitrogen;
  double? bdod;
  double? water;

  void apply(String property, double value) {
    switch (property) {
      case 'phh2o':
        ph = value; // d_factor already yields pH units
        break;
      case 'clay':
        clay = value / 10; // g/kg -> %
        break;
      case 'sand':
        sand = value / 10;
        break;
      case 'silt':
        silt = value / 10;
        break;
      case 'soc':
        soc = value; // g/kg
        break;
      case 'nitrogen':
        nitrogen = value; // g/kg
        break;
      case 'bdod':
        bdod = value; // kg/dm3
        break;
      case 'wv0033':
        water = value; // vol %
        break;
    }
  }

  SoilLayer build() {
    final (int top, int bottom) = _depthBounds(label);
    return SoilLayer(
      label: label,
      topCm: top,
      bottomCm: bottom,
      phH2o: ph,
      clayPct: clay,
      sandPct: sand,
      siltPct: silt,
      socGkg: soc,
      nitrogenGkg: nitrogen,
      bulkDensity: bdod,
      waterContentPct: water,
    );
  }

  (int, int) _depthBounds(String label) {
    // Labels look like "0-5cm", "5-15cm", "15-30cm".
    final cleaned = label.replaceAll('cm', '');
    final parts = cleaned.split('-');
    if (parts.length == 2) {
      final int? a = int.tryParse(parts[0].trim());
      final int? b = int.tryParse(parts[1].trim());
      if (a != null && b != null) return (a, b);
    }
    return (0, 0);
  }
}
