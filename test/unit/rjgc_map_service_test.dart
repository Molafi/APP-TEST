import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/georesearch/data/rjgc_map_service.dart';

void main() {
  group('JTM projection', () {
    test('the grid origin maps to the published false easting/northing', () {
      // The strongest invariant available without a reference implementation:
      // on the central meridian at the latitude of origin the result must be
      // exactly the false origin, whatever the series terms do.
      final grid = JtmProjection.forward(latitude: 0, longitude: 37)!;
      expect(grid.easting, closeTo(JtmProjection.falseEasting, 1e-6));
      expect(grid.northing, closeTo(JtmProjection.falseNorthing, 1e-6));
    });

    test('points on the central meridian keep the false easting', () {
      for (final double lat in const [29.0, 31.95, 33.4]) {
        final grid = JtmProjection.forward(latitude: lat, longitude: 37)!;
        expect(
          grid.easting,
          closeTo(JtmProjection.falseEasting, 1e-6),
          reason: 'easting must not drift on the central meridian',
        );
      }
    });

    test('the meridian arc series matches numeric integration', () {
      // Independent check of the only non-trivial term: integrate the meridian
      // radius of curvature directly and compare.
      double numericArc(double latRad, {int steps = 20000}) {
        double f(double t) {
          final double e2 =
              2 / JtmProjection.inverseFlattening -
              1 /
                  (JtmProjection.inverseFlattening *
                      JtmProjection.inverseFlattening);
          return JtmProjection.semiMajorAxis *
              (1 - e2) /
              math.pow(1 - e2 * math.pow(math.sin(t), 2), 1.5);
        }

        final double h = latRad / steps;
        double sum = f(0) + f(latRad);
        for (int i = 1; i < steps; i++) {
          sum += f(i * h) * (i.isOdd ? 4 : 2);
        }
        return sum * h / 3;
      }

      for (final double lat in const [15.0, 29.5, 31.95, 33.4]) {
        final double rad = lat * math.pi / 180.0;
        expect(
          JtmProjection.meridianArc(rad),
          closeTo(numericArc(rad), 0.001),
          reason: 'series and integral disagree at $lat°',
        );
      }
      expect(JtmProjection.meridianArc(0), 0);
    });

    test('a location in Amman projects inside the Jordanian grid', () {
      final grid = JtmProjection.forward(
        latitude: 31.9539,
        longitude: 35.9106,
      )!;
      // West of the central meridian, so east of nothing: easting below the
      // 500 km false origin, northing a few hundred km above the false origin.
      expect(grid.easting, closeTo(397021.1, 0.5));
      expect(grid.northing, closeTo(536604.5, 0.5));
      expect(grid.easting, lessThan(JtmProjection.falseEasting));
    });

    test('easting grows eastward and northing grows northward', () {
      final west = JtmProjection.forward(latitude: 31.9, longitude: 35.5)!;
      final east = JtmProjection.forward(latitude: 31.9, longitude: 36.5)!;
      final south = JtmProjection.forward(latitude: 30.5, longitude: 36.0)!;
      final north = JtmProjection.forward(latitude: 32.5, longitude: 36.0)!;

      expect(east.easting, greaterThan(west.easting));
      expect(north.northing, greaterThan(south.northing));
    });

    test('bad input degrades to null instead of a NaN coordinate', () {
      expect(
        JtmProjection.forward(latitude: double.nan, longitude: 36),
        isNull,
      );
      expect(
        JtmProjection.forward(latitude: 32, longitude: double.infinity),
        isNull,
      );
      expect(JtmProjection.forward(latitude: 89, longitude: 36), isNull);
    });

    test('no datum shift is applied unless parameters are configured', () {
      // Guessing the transformation would silently bias every coordinate, so
      // the default must be "unshifted, and say so".
      expect(JtmProjection.hasDatumShift, isFalse);
      expect(JtmProjection.datumShift(), isNull);
    });
  });

  group('RjgcMapService coverage', () {
    test('recognises locations inside Jordan', () {
      expect(
        RjgcMapService.coversLocation(latitude: 31.95, longitude: 35.91),
        isTrue,
      );
      expect(
        RjgcMapService.coversLocation(latitude: 29.53, longitude: 35.00),
        isTrue,
      );
    });

    test('rejects locations outside Jordan and missing coordinates', () {
      // Riyadh, Cairo, and nothing at all.
      expect(
        RjgcMapService.coversLocation(latitude: 24.71, longitude: 46.67),
        isFalse,
      );
      expect(
        RjgcMapService.coversLocation(latitude: 30.04, longitude: 31.23),
        isFalse,
      );
      expect(
        RjgcMapService.coversLocation(latitude: null, longitude: 35.9),
        isFalse,
      );
      expect(RjgcMapService.coversLocation(), isFalse);
    });

    test('builds a grid reference and public links inside Jordan', () {
      final ref = const RjgcMapService().forLocation(
        latitude: 31.9539,
        longitude: 35.9106,
      )!;

      expect(ref.hasGrid, isTrue);
      expect(ref.gridCode, 'EPSG:3066');
      expect(ref.easting, closeTo(397021.1, 0.5));
      expect(ref.northing, closeTo(536604.5, 0.5));
      expect(ref.authority, contains('RJGC'));
      expect(ref.portalUrl, isNotNull);
      expect(ref.orderUrl, isNotNull);
      // The caveat flag drives which notice the card renders.
      expect(ref.datumShiftApplied, isFalse);
    });

    test('the authority basemap is absent unless a service is configured', () {
      // RJGC access requires an agreement, so no tile URL ships by default —
      // and the rest of the card must still be useful without it.
      final ref = const RjgcMapService().forLocation(
        latitude: 31.9539,
        longitude: 35.9106,
      )!;
      expect(ref.tileUrl, isNull);
      expect(ref.tileAttribution, isNull);
      expect(ref.isEmpty, isFalse);

      expect(
        RjgcMapService.tileUrlFor(latitude: 31.95, longitude: 35.91),
        isNull,
      );
    });

    test('no national grid is offered for sites outside Jordan', () {
      // Quoting a Jordanian grid reference for Riyadh would be misleading, so
      // the whole card is withheld rather than shown with foreign numbers.
      expect(
        const RjgcMapService().forLocation(
          latitude: 24.7136,
          longitude: 46.6753,
        ),
        isNull,
      );
    });

    test('missing coordinates yield no reference at all', () {
      expect(const RjgcMapService().forLocation(), isNull);
      expect(
        const RjgcMapService().forLocation(latitude: 31.95, longitude: null),
        isNull,
      );
      expect(
        const RjgcMapService().forLocation(
          latitude: double.nan,
          longitude: 35.9,
        ),
        isNull,
      );
    });
  });
}
