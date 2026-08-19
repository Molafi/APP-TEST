import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Normalised permission result the UI can switch on to render rationale,
/// denied, permanently-denied (with Open Settings) and granted states.
enum PermissionOutcome { granted, denied, permanentlyDenied, restricted }

/// Wraps permission_handler so features can request permissions contextually
/// (only when the feature is first used) and never at startup.
class PermissionService {
  const PermissionService();

  Future<PermissionOutcome> requestCamera() => _request(Permission.camera);

  Future<PermissionOutcome> requestLocation() =>
      _request(Permission.locationWhenInUse);

  Future<PermissionOutcome> requestNotifications() =>
      _request(Permission.notification);

  Future<PermissionOutcome> _request(Permission permission) async {
    final PermissionStatus status = await permission.request();
    if (status.isGranted || status.isLimited) return PermissionOutcome.granted;
    if (status.isPermanentlyDenied) return PermissionOutcome.permanentlyDenied;
    if (status.isRestricted) return PermissionOutcome.restricted;
    return PermissionOutcome.denied;
  }

  Future<bool> openSettings() => openAppSettings();
}

final permissionServiceProvider = Provider<PermissionService>(
  (ref) => const PermissionService(),
);
