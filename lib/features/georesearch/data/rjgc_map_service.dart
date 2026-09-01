import 'dart:math' as math;

import '../../../core/config/environment.dart';
import '../domain/site_survey_model.dart';

/// A projected grid coordinate pair in metres.
class GridCoordinate {
  const GridCoordinate({required this.easting, required this.northing});
  final double easting;
  final double northing;
}

/// Converts WGS84 geographic coordinates to the **Jordan Transverse Mercator**
/// (JTM) grid used by the Royal Jordanian Geographic Centre (RJGC).
///
/// JTM is the ellipsoidal Transverse Mercator defined by RJGC on the Hayford /
/// International 1924 ellipsoid, with a central meridian of 37°E and a scale
/// factor at origin of 0.9998 (published as EPSG:3066).
///
/// ## What this is and is not
///
/// It is a *locating* conversion: it gives the grid reference you quote when
/// ordering a map sheet or an aerial photograph, or when comparing a GPS
/// reading against an official plan. It is **not** a survey: no datum
/// transformation is applied unless [Environment.jtmDatumShift] supplies the
/// official parameters, so the result can differ from a surveyed JTM coordinate.
/// Boundary, legal and design work still needs a licensed cadastral survey.
///
/// The maths runs entirely offline — no API key and no network call — so the
/// feature works in demo mode and without connectivity.
class JtmProjection {
  const JtmProjection._();

  /// Hayford / International 1924 semi-major axis, in metres.
  static const double semiMajorAxis = 6378388.0;

  /// Inverse flattening of the same ellipsoid.
  static const double inverseFlattening = 297.0;

  /// Scale factor on the central meridian.
  static const double scaleFactor = 0.9998;

  /// Central meridian, degrees east.
  static const double centralMeridian = 37.0;

  /// Latitude of origin, degrees (the equator).
  static const double latitudeOfOrigin = 0.0;

  static const double falseEasting = 500000.0;
  static const double falseNorthing = -3000000.0;

  /// CRS identifier for the grid these values belong to.
  static const String epsgCode = 'EPSG:3066';

  /// WGS84 ellipsoid, used only when a datum shift is configured.
  static const double _wgs84A = 6378137.0;
  static const double _wgs84InvF = 298.257223563;

  static double get _f => 1.0 / inverseFlattening;

  /// First eccentricity squared of the JTM ellipsoid.
  static double get _e2 => 2 * _f - _f * _f;

  /// Meridian arc distance from the equator to [latRad].
  ///
  /// Standard four-term series (EPSG guidance note 7-2 / Snyder); verified
  /// against numeric integration of the meridian radius of curvature to well
  /// under a millimetre across Jordan's latitude range.
  static double meridianArc(double latRad) {
    final double e2 = _e2;
    final double e4 = e2 * e2;
    final double e6 = e4 * e2;
    return semiMajorAxis *
        ((1 - e2 / 4 - 3 * e4 / 64 - 5 * e6 / 256) * latRad -
            (3 * e2 / 8 + 3 * e4 / 32 + 45 * e6 / 1024) * math.sin(2 * latRad) +
            (15 * e4 / 256 + 45 * e6 / 1024) * math.sin(4 * latRad) -
            (35 * e6 / 3072) * math.sin(6 * latRad));
  }

  /// Projects WGS84 [latitude]/[longitude] (degrees) onto the JTM grid.
  ///
  /// Returns null for non-finite input or a latitude outside the projection's
  /// usable band, so a bad GPS fix degrades to "no grid reference" rather than
  /// a NaN masquerading as a coordinate.
  static GridCoordinate? forward({
    required double latitude,
    required double longitude,
  }) {
    if (!latitude.isFinite || !longitude.isFinite) return null;
    if (latitude.abs() > 84.0) return null;

    double lat = latitude;
    double lon = longitude;

    final ({double dx, double dy, double dz})? shift = datumShift();
    if (shift != null) {
      final ({double lat, double lon}) shifted = _applyDatumShift(
        latitude: lat,
        longitude: lon,
        dx: shift.dx,
        dy: shift.dy,
        dz: shift.dz,
      );
      lat = shifted.lat;
      lon = shifted.lon;
    }

    final double phi = lat * math.pi / 180.0;
    final double lam = lon * math.pi / 180.0;
    final double lam0 = centralMeridian * math.pi / 180.0;

    final double e2 = _e2;
    final double ep2 = e2 / (1 - e2);
    final double sinPhi = math.sin(phi);
    final double cosPhi = math.cos(phi);
    final double tanPhi = math.tan(phi);

    final double nu = semiMajorAxis / math.sqrt(1 - e2 * sinPhi * sinPhi);
    final double t = tanPhi * tanPhi;
    final double c = ep2 * cosPhi * cosPhi;
    final double a = (lam - lam0) * cosPhi;
    final double a2 = a * a;
    final double a3 = a2 * a;
    final double a4 = a2 * a2;
    final double a5 = a4 * a;
    final double a6 = a4 * a2;

    final double m = meridianArc(phi);
    final double m0 = meridianArc(latitudeOfOrigin * math.pi / 180.0);

    final double easting =
        falseEasting +
        scaleFactor *
            nu *
            (a +
                (1 - t + c) * a3 / 6 +
                (5 - 18 * t + t * t + 72 * c - 58 * ep2) * a5 / 120);

    final double northing =
        falseNorthing +
        scaleFactor *
            (m -
                m0 +
                nu *
                    tanPhi *
                    (a2 / 2 +
                        (5 - t + 9 * c + 4 * c * c) * a4 / 24 +
                        (61 - 58 * t + t * t + 600 * c - 330 * ep2) *
                            a6 /
                            720));

    if (!easting.isFinite || !northing.isFinite) return null;
    return GridCoordinate(easting: easting, northing: northing);
  }

  /// Parses [Environment.jtmDatumShift] (`dx,dy,dz` in metres).
  ///
  /// Returns null when unset, malformed, or all zeros — in every one of those
  /// cases no transformation is applied, which is deliberate: a zero-translation
  /// change of ellipsoid would still move the result by ~100 m while implying a
  /// precision the app does not have.
  static ({double dx, double dy, double dz})? datumShift() {
    final List<String> parts = Environment.jtmDatumShift
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.length != 3) return null;
    final double? dx = double.tryParse(parts[0]);
    final double? dy = double.tryParse(parts[1]);
    final double? dz = double.tryParse(parts[2]);
    if (dx == null || dy == null || dz == null) return null;
    if (!dx.isFinite || !dy.isFinite || !dz.isFinite) return null;
    if (dx == 0 && dy == 0 && dz == 0) return null;
    return (dx: dx, dy: dy, dz: dz);
  }

  /// True when official datum parameters were supplied for this build.
  static bool get hasDatumShift => datumShift() != null;

  /// Exact 3-parameter (geocentric translation) datum shift: WGS84 geodetic →
  /// geocentric XYZ → translate → geodetic on the JTM ellipsoid.
  static ({double lat, double lon}) _applyDatumShift({
    required double latitude,
    required double longitude,
    required double dx,
    required double dy,
    required double dz,
  }) {
    final double phi = latitude * math.pi / 180.0;
    final double lam = longitude * math.pi / 180.0;

    // Source (WGS84) → geocentric.
    final double fs = 1.0 / _wgs84InvF;
    final double e2s = 2 * fs - fs * fs;
    final double nS = _wgs84A / math.sqrt(1 - e2s * math.sin(phi) * math.sin(phi));
    final double x = nS * math.cos(phi) * math.cos(lam) + dx;
    final double y = nS * math.cos(phi) * math.sin(lam) + dy;
    final double z = nS * (1 - e2s) * math.sin(phi) + dz;

    // Geocentric → target ellipsoid geodetic (iterative; converges in a few
    // passes at these magnitudes).
    final double e2t = _e2;
    final double p = math.sqrt(x * x + y * y);
    double latOut = math.atan2(z, p * (1 - e2t));
    for (int i = 0; i < 6; i++) {
      final double nT =
          semiMajorAxis / math.sqrt(1 - e2t * math.sin(latOut) * math.sin(latOut));
      latOut = math.atan2(z + e2t * nT * math.sin(latOut), p);
    }
    final double lonOut = math.atan2(y, x);

    return (lat: latOut * 180.0 / math.pi, lon: lonOut * 180.0 / math.pi);
  }
}

/// Builds the Royal Jordanian Geographic Centre (RJGC) reference for a site:
/// the JTM grid coordinates, the official basemap tile (when a service is
/// licensed for this build) and the public links for viewing and ordering
/// official maps, aerial photographs and cadastral extracts.
///
/// Everything is derived from the coordinates and build configuration, never
/// from AI output — the prompt explicitly forbids the model from emitting an
/// `officialMap` object, so an authority-badged grid reference can only ever
/// come from this class.
class RjgcMapService {
  const RjgcMapService();

  static const String authority =
      'Royal Jordanian Geographic Centre (RJGC) — المركز الجغرافي الملكي الأردني';

  static const String gridName = 'Jordan Transverse Mercator (JTM)';

  /// Jordan's approximate bounding box, used only to decide whether the JTM
  /// grid is meaningful for a site. Outside it the projection would still return
  /// a number, but quoting a Jordanian national grid reference for, say, Spain
  /// would be misleading.
  static const double minLatitude = 29.0;
  static const double maxLatitude = 33.5;
  static const double minLongitude = 34.8;
  static const double maxLongitude = 39.4;

  /// Web Mercator tile limit, matching the aerial imagery service.
  static const double _maxTileLatitude = 85.05112878;
  static const int _maxZoom = 19;
  static const int defaultZoom = 16;

  /// True when [latitude]/[longitude] fall inside Jordan's coverage box.
  static bool coversLocation({double? latitude, double? longitude}) {
    if (latitude == null || longitude == null) return false;
    if (!latitude.isFinite || !longitude.isFinite) return false;
    return latitude >= minLatitude &&
        latitude <= maxLatitude &&
        longitude >= minLongitude &&
        longitude <= maxLongitude;
  }

  /// Builds the authority basemap tile URL, or null when no service is
  /// configured for this build (the usual case, since RJGC access requires an
  /// agreement).
  static String? tileUrlFor({
    required double latitude,
    required double longitude,
    int zoom = defaultZoom,
  }) {
    if (!Environment.rjgcTilesConfigured) return null;
    if (!latitude.isFinite || !longitude.isFinite) return null;
    final String template = Environment.rjgcTileUrl;

    final int z = zoom.clamp(0, _maxZoom);
    final int n = 1 << z;

    final double lon = ((longitude + 180) % 360 + 360) % 360 - 180;
    final double lat = latitude.clamp(-_maxTileLatitude, _maxTileLatitude);
    final double latRad = lat * math.pi / 180.0;

    final int x = ((lon + 180.0) / 360.0 * n).floor().clamp(0, n - 1);
    final int y =
        ((1.0 -
                    math.log(math.tan(latRad) + 1 / math.cos(latRad)) /
                        math.pi) /
                2.0 *
                n)
            .floor()
            .clamp(0, n - 1);

    return template
        .replaceAll('{z}', '$z')
        .replaceAll('{x}', '$x')
        .replaceAll('{y}', '$y');
  }

  /// Builds the displayable reference for a site, or null when there are no
  /// usable coordinates (the card then simply does not render).
  OfficialMapReference? forLocation({
    double? latitude,
    double? longitude,
    int zoom = defaultZoom,
  }) {
    if (latitude == null || longitude == null) return null;
    if (!latitude.isFinite || !longitude.isFinite) return null;

    final bool inJordan = coversLocation(
      latitude: latitude,
      longitude: longitude,
    );

    // The grid reference is only offered where it means something.
    final GridCoordinate? grid = inJordan
        ? JtmProjection.forward(latitude: latitude, longitude: longitude)
        : null;

    final String? tile = inJordan
        ? tileUrlFor(latitude: latitude, longitude: longitude, zoom: zoom)
        : null;

    final OfficialMapReference reference = OfficialMapReference(
      authority: authority,
      gridName: gridName,
      gridCode: grid != null ? JtmProjection.epsgCode : null,
      easting: grid?.easting,
      northing: grid?.northing,
      latitude: latitude,
      longitude: longitude,
      tileUrl: tile,
      tileAttribution: tile != null && Environment.rjgcTileAttribution.isNotEmpty
          ? Environment.rjgcTileAttribution
          : null,
      portalUrl: inJordan && Environment.rjgcPortalUrl.isNotEmpty
          ? Environment.rjgcPortalUrl
          : null,
      orderUrl: inJordan && Environment.rjgcOrderUrl.isNotEmpty
          ? Environment.rjgcOrderUrl
          : null,
      datumShiftApplied: grid != null && JtmProjection.hasDatumShift,
    );

    return reference.isEmpty ? null : reference;
  }
}
