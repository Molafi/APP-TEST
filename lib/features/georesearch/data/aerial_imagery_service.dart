import 'dart:math' as math;

import '../domain/site_survey_model.dart';

/// Builds an aerial/satellite image reference for a coordinate pair.
///
/// The URL is computed locally with standard Web Mercator (XYZ) tile maths — no
/// API key and no network call are needed to construct it, and the AI is never
/// asked to invent an image URL. Imagery is served by Esri's public World
/// Imagery tile service, which requires the attribution string below.
///
/// This is a CONTEXT view, not a survey product: tiles are undated mosaics and
/// must not be treated as a current, georeferenced aerial survey.
class AerialImageryService {
  const AerialImageryService();

  /// Esri World Imagery XYZ endpoint. Note the `{z}/{y}/{x}` ordering, which
  /// differs from the more common `{z}/{x}/{y}`.
  static const String _template =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile';

  static const String provider = 'Esri World Imagery';
  static const String attribution =
      'Imagery © Esri, Maxar, Earthstar Geographics and the GIS User Community';

  /// Default zoom: close enough to read plot-level features, wide enough to
  /// show surrounding context and access roads.
  static const int defaultZoom = 16;

  /// Web Mercator cannot represent the poles; latitudes are clamped to the
  /// standard projection limit.
  static const double _maxLatitude = 85.05112878;

  /// Highest zoom the World Imagery service serves globally.
  static const int _maxZoom = 19;

  /// Converts a coordinate to its XYZ tile indices at [zoom].
  ///
  /// Returns `(x, y)`. Longitude is wrapped into [-180, 180) and latitude is
  /// clamped to the Mercator limit, so any input yields a valid tile.
  static ({int x, int y}) tileFor({
    required double latitude,
    required double longitude,
    required int zoom,
  }) {
    final int z = zoom.clamp(0, _maxZoom);
    final int n = 1 << z; // 2^z

    // Wrap longitude into [-180, 180). Guard on isFinite, not just isNaN: the
    // modulo below would turn ±infinity back into NaN and make floor() throw.
    double lon = longitude;
    if (!lon.isFinite) lon = 0;
    lon = ((lon + 180) % 360 + 360) % 360 - 180;

    double lat = latitude.isFinite ? latitude : 0;
    lat = lat.clamp(-_maxLatitude, _maxLatitude);

    final double latRad = lat * math.pi / 180.0;
    final int x = ((lon + 180.0) / 360.0 * n).floor().clamp(0, n - 1);
    final int y =
        ((1.0 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
                2.0 *
                n)
            .floor()
            .clamp(0, n - 1);

    return (x: x, y: y);
  }

  /// Builds the tile URL for a coordinate.
  static String urlFor({
    required double latitude,
    required double longitude,
    int zoom = defaultZoom,
  }) {
    final int z = zoom.clamp(0, _maxZoom);
    final tile = tileFor(latitude: latitude, longitude: longitude, zoom: z);
    return '$_template/$z/${tile.y}/${tile.x}';
  }

  /// Builds a displayable [AerialImageryInfo] for the site, or null when no
  /// coordinates are available (the feature degrades silently rather than
  /// showing a broken image).
  AerialImageryInfo? forLocation({
    double? latitude,
    double? longitude,
    int zoom = defaultZoom,
  }) {
    if (latitude == null || longitude == null) return null;
    return AerialImageryInfo(
      url: urlFor(latitude: latitude, longitude: longitude, zoom: zoom),
      provider: provider,
      attribution: attribution,
      zoom: zoom.clamp(0, _maxZoom),
    );
  }
}
