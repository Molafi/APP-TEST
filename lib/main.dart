import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/local_cache_service.dart';

/// Entry point.
///
/// Everything runs inside a guarded zone with an [ErrorWidget.builder] that
/// renders the actual error text. In a release build an uncaught Dart error
/// during startup otherwise shows only a blank grey screen with no message,
/// which is indistinguishable from a native crash and impossible to diagnose
/// from a phone. Showing the message on-screen turns "it won't open" into a
/// readable, screenshottable error. (A crash in the native layer, before the
/// Flutter engine starts, is still outside Dart's reach — that is what the
/// debug-vs-release install test in the README distinguishes.)
Future<void> main() async {
  // Render any framework build/layout error as visible text rather than the
  // default blank container in release. Kept lightweight and dependency-free so
  // it cannot itself fail.
  ErrorWidget.builder = (FlutterErrorDetails details) => _StartupErrorView(
    message: details.exceptionAsString(),
  );

  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Load SharedPreferences up front so synchronous preference providers
      // (locale, theme, onboarding) can read persisted values immediately. If
      // it fails for any reason, launch anyway with an in-memory fallback
      // rather than dying with a black screen before the UI ever appears.
      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance();
      } catch (e, st) {
        FlutterError.reportError(
          FlutterErrorDetails(exception: e, stack: st, library: 'startup'),
        );
      }

      // Firebase is initialised lazily in appStartupProvider so demo mode
      // launches without any credentials and never blocks on startup.
      runApp(
        ProviderScope(
          overrides: [
            if (prefs != null)
              localCacheServiceProvider.overrideWithValue(
                LocalCacheService(prefs),
              ),
          ],
          child: const PlantSenseApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      // Last-resort handler for anything that escapes the widget tree. In debug
      // this prints; in release it at least keeps the process from vanishing
      // silently.
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stack, library: 'root'),
      );
      debugPrint('Uncaught zone error: $error');
    },
  );
}

/// Minimal, self-contained error screen. Uses only painting primitives (no
/// theme, no localization, no plugins) so it renders even when the failure is
/// in exactly those layers.
class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFF1B3B2F),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PlantSense could not start',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF5F0E8),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFD9CFC2), fontSize: 13),
              ),
              if (kReleaseMode) ...[
                const SizedBox(height: 16),
                const Text(
                  'Please screenshot this and share it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9DB5A6), fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
