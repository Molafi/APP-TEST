import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_options.dart';
import 'config/environment.dart';

/// Performs one-time async startup: initialises Firebase when enabled, with a
/// timeout so the splash can never hang indefinitely. In demo mode this is a
/// no-op and the app launches immediately with fake services.
final appStartupProvider = FutureProvider<void>((ref) async {
  if (Environment.isDemo || !Environment.useFirebase) {
    // Demo mode: nothing to initialise.
    return;
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 12));
  } catch (e) {
    // Surface a recoverable error to the splash rather than crashing.
    debugPrint('Firebase initialisation failed');
    rethrow;
  }
});
