import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/local_cache_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load SharedPreferences up front so synchronous preference providers
  // (locale, theme, onboarding) can read persisted values immediately.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Note: Firebase is initialised lazily in [appStartupProvider] so that demo
  // mode launches without any credentials and never blocks on startup.
  runApp(
    ProviderScope(
      overrides: [
        localCacheServiceProvider.overrideWithValue(LocalCacheService(prefs)),
      ],
      child: const PlantSenseApp(),
    ),
  );
}
