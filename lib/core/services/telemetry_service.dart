import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';
import '../../features/profile/application/settings_provider.dart';

/// Analytics + crash reporting abstraction. Disabled by default; the concrete
/// Firebase implementation is only used when the user has explicitly opted in
/// AND Firebase is enabled. Never records private message text, images or exact
/// location.
abstract class TelemetryService {
  Future<void> logEvent(String name, [Map<String, Object>? params]);
  Future<void> recordError(Object error, StackTrace? stack, {bool fatal});
  Future<void> setEnabled(bool enabled);
}

/// Default no-op used in demo mode and whenever analytics is off.
class NoopTelemetry implements TelemetryService {
  const NoopTelemetry();
  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {}
  @override
  Future<void> recordError(Object error, StackTrace? stack,
      {bool fatal = false}) async {}
  @override
  Future<void> setEnabled(bool enabled) async {}
}

class FirebaseTelemetry implements TelemetryService {
  FirebaseTelemetry({FirebaseAnalytics? analytics, FirebaseCrashlytics? crashlytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance,
        _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics.logEvent(name: name, parameters: params);
    } catch (_) {}
  }

  @override
  Future<void> recordError(Object error, StackTrace? stack,
      {bool fatal = false}) async {
    try {
      await _crashlytics.recordError(error, stack, fatal: fatal);
    } catch (_) {}
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    } catch (_) {}
  }
}

/// Selects the telemetry backend. Only real when the user opted in and Firebase
/// is configured; otherwise a no-op.
final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  final bool enabled = ref.watch(analyticsEnabledProvider);
  if (!Environment.isDemo && Environment.useFirebase && enabled && !kIsWeb) {
    return FirebaseTelemetry();
  }
  return const NoopTelemetry();
});
