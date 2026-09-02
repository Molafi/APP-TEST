import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/georesearch/data/aerial_imagery_service.dart';

void main() {
  group('AerialImageryService.tileFor', () {
    test('maps a known coordinate to the expected Web Mercator tile', () {
      // Reference values for the standard XYZ scheme at zoom 16.
      // Riyadh: 24.7136 N, 46.6753 E.
      final tile = AerialImageryService.tileFor(
        latitude: 24.7136,
        longitude: 46.6753,
        zoom: 16,
      );
      expect(tile.x, 41264);
      expect(tile.y, 28122);
    });

    test('origin maps to the centre tile boundary', () {
      final tile = AerialImageryService.tileFor(
        latitude: 0,
        longitude: 0,
        zoom: 1,
      );
      // At zoom 1 the world is a 2x2 grid; (0,0) sits at the grid centre, which
      // floors into tile (1, 1).
      expect(tile.x, 1);
      expect(tile.y, 1);
    });

    test(
      'clamps latitude beyond the Mercator limit instead of overflowing',
      () {
        const int zoom = 8;
        const int maxIndex = (1 << zoom) - 1;
        for (final double lat in <double>[89.9, -89.9, 200, -200]) {
          final tile = AerialImageryService.tileFor(
            latitude: lat,
            longitude: 10,
            zoom: zoom,
          );
          expect(tile.y, inInclusiveRange(0, maxIndex), reason: 'lat=$lat');
          expect(tile.x, inInclusiveRange(0, maxIndex), reason: 'lat=$lat');
        }
      },
    );

    test('wraps out-of-range longitude into a valid tile', () {
      const int zoom = 4;
      const int maxIndex = (1 << zoom) - 1;
      for (final double lon in <double>[181, -181, 540, -540]) {
        final tile = AerialImageryService.tileFor(
          latitude: 10,
          longitude: lon,
          zoom: zoom,
        );
        expect(tile.x, inInclusiveRange(0, maxIndex), reason: 'lon=$lon');
      }
    });

    test('tolerates NaN coordinates without throwing', () {
      final tile = AerialImageryService.tileFor(
        latitude: double.nan,
        longitude: double.nan,
        zoom: 5,
      );
      expect(tile.x, inInclusiveRange(0, 31));
      expect(tile.y, inInclusiveRange(0, 31));
    });
  });

  group('AerialImageryService.urlFor', () {
    test('builds an Esri World Imagery URL in z/y/x order', () {
      final String url = AerialImageryService.urlFor(
        latitude: 24.7136,
        longitude: 46.6753,
        zoom: 16,
      );
      // Esri serves tiles as {z}/{y}/{x}, not the more common {z}/{x}/{y}.
      expect(url, endsWith("/16/28122/41264"));
      expect(url, startsWith('https://'));
      expect(url, contains('World_Imagery'));
    });

    test('clamps zoom to the service maximum', () {
      final String url = AerialImageryService.urlFor(
        latitude: 10,
        longitude: 10,
        zoom: 99,
      );
      expect(url, contains('/19/'));
    });
  });

  group('AerialImageryService.forLocation', () {
    const service = AerialImageryService();

    test('returns null when coordinates are missing so the UI degrades', () {
      expect(service.forLocation(latitude: null, longitude: null), isNull);
      expect(service.forLocation(latitude: 10, longitude: null), isNull);
      expect(service.forLocation(latitude: null, longitude: 10), isNull);
    });

    test('returns a populated info object with attribution', () {
      final info = service.forLocation(latitude: 24.7136, longitude: 46.6753);
      expect(info, isNotNull);
      expect(info!.url, isNotEmpty);
      expect(info.provider, AerialImageryService.provider);
      expect(info.attribution, isNotEmpty);
      expect(info.zoom, AerialImageryService.defaultZoom);
    });

    test('withNarrative merges AI text without altering the local URL', () {
      final info = service.forLocation(latitude: 1, longitude: 2)!;
      final merged = info.withNarrative(
        interpretation: 'Cultivated plots',
        landCover: 'Cropland',
        visibleFeatures: const ['Tracks'],
      );
      expect(merged.url, info.url);
      expect(merged.provider, info.provider);
      expect(merged.interpretation, 'Cultivated plots');
      expect(merged.landCover, 'Cropland');
      expect(merged.visibleFeatures, ['Tracks']);
    });
  });
}
