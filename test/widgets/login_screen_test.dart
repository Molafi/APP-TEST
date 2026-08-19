import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/auth/presentation/login_screen.dart';

import '../mocks/mocks.dart';
import 'test_app.dart';

void main() {
  testWidgets('renders email, password and login button', (tester) async {
    final overrides = await defaultOverrides();
    await pumpApp(
      tester,
      const LoginScreen(),
      overrides: overrides,
      scaffoldWrap: (c) => c,
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('shows validation errors on empty submit', (tester) async {
    final overrides = await defaultOverrides();
    await pumpApp(
      tester,
      const LoginScreen(),
      overrides: overrides,
      scaffoldWrap: (c) => c,
    );

    // Tap the primary Log in button (the FilledButton).
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
  });

  testWidgets('renders in Arabic (RTL)', (tester) async {
    final overrides = await defaultOverrides();
    await pumpApp(
      tester,
      const LoginScreen(),
      overrides: overrides,
      locale: const Locale('ar'),
      scaffoldWrap: (c) => c,
    );

    expect(find.text('البريد الإلكتروني'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(LoginScreen))),
      TextDirection.rtl,
    );
  });
}
