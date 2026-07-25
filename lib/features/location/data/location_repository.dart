import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/config/environment.dart';
import '../../../core/errors/app_exception.dart';

/// Wraps geolocator for foreground device location, translating platform states
/// into typed [AppException]s. Never requests location in the background.
class LocationRepository {
  const LocationRepository();

  Future<({double lat, double lon})> currentPosition() async {
    // Demo mode: return a stable sample location (Amman, JO) so the flow works
    // without device hardware or permissions.
    if (Environment.isDemo) {
      return (lat: 31.9539, lon: 35.9106);
    }

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AppException(AppErrorKind.locationServicesDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const AppException(AppErrorKind.permissionPermanentlyDenied);
    }
    if (permission == LocationPermission.denied) {
      throw const AppException(AppErrorKind.permissionDenied);
    }

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
    return (lat: position.latitude, lon: position.longitude);
  }
}

final locationRepositoryProvider =
    Provider<LocationRepository>((ref) => const LocationRepository());
