import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/services/local_cache_service.dart';
import 'package:plantsense_ai/features/location/application/location_provider.dart';
import 'package:plantsense_ai/features/location/data/nominatim_service.dart';
import 'package:plantsense_ai/features/location/domain/location_model.dart';

import '../mocks/mocks.dart';

/// Exercises the map picker's confirm flow (reverse-geocode-then-selectManual,
/// including the null fallback) through [LocationController.selectPinnedLocation]
/// without pumping a map widget.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Pinned coordinates the user "dropped" on the map.
  const double lat = 31.9539;
  const double lon = 35.9106;

  Future<ProviderContainer> makeContainer(
    FakeNominatimService Function(LocalCacheService cache) buildGeocoder,
  ) async {
    final overrides = await defaultOverrides();
    final cache = await makeTestCache();
    final container = ProviderContainer(
      overrides: [
        ...overrides,
        nominatimServiceProvider.overrideWith(
          (ref) => buildGeocoder(cache),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('successful reverse geocode applies the geocoded location', () async {
    const geocoded = PlantLocation(
      latitude: lat,
      longitude: lon,
      city: 'Amman',
      country: 'Jordan',
      countryCode: 'JO',
    );
    final container = await makeContainer(
      (cache) => FakeNominatimService(cache, reverseResult: geocoded),
    );

    final controller = container.read(locationControllerProvider.notifier);
    await controller.selectPinnedLocation(
      lat: lat,
      lon: lon,
      fallbackCity: 'Dropped pin',
    );

    final state = container.read(locationControllerProvider);
    expect(state.status, LocationStatus.ready);
    expect(state.location, isNotNull);
    expect(state.location!.city, 'Amman');
    expect(state.location!.country, 'Jordan');
    expect(state.location!.latitude, lat);
    expect(state.location!.longitude, lon);
  });

  test('null reverse geocode falls back to the pinned coordinates', () async {
    final container = await makeContainer(
      (cache) => FakeNominatimService(cache, reverseResult: null),
    );

    final controller = container.read(locationControllerProvider.notifier);
    await controller.selectPinnedLocation(
      lat: lat,
      lon: lon,
      fallbackCity: 'Dropped pin',
    );

    final state = container.read(locationControllerProvider);
    expect(state.status, LocationStatus.ready);
    expect(state.location, isNotNull);
    expect(state.location!.latitude, lat);
    expect(state.location!.longitude, lon);
    expect(state.location!.city, 'Dropped pin');
    expect(state.location!.isManual, isTrue);
  });
}
