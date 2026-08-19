import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/constants/app_constants.dart';
import 'package:plantsense_ai/l10n/app_localizations.dart';

/// Pumps [child] inside a localized MaterialApp with the given provider
/// overrides. Optionally forces a locale (e.g. Arabic for RTL tests).
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  Widget Function(Widget)? scaffoldWrap,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppConstants.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: scaffoldWrap != null
            ? scaffoldWrap(child)
            : Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}
