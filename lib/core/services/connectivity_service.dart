import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes a simple online/offline stream used to drive the non-blocking
/// offline banner and cache-fallback behaviour.
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map(_isOnline)
      .distinct();

  Future<bool> isOnline() async =>
      _isOnline(await _connectivity.checkConnectivity());

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}

final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => ConnectivityService());

/// Boolean online state. Defaults to online (`true`) until the first event so
/// the UI does not flash an offline banner on cold start.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final ConnectivityService service = ref.watch(connectivityServiceProvider);
  return service.onStatusChange;
});
