import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:plantsense_ai/app.dart';
import 'package:plantsense_ai/core/services/local_cache_service.dart';
import 'package:plantsense_ai/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration test running the app in DEMO mode end-to-end. No real Groq,
/// Open-Meteo, Nominatim or production Firebase services are contacted — demo
/// fakes back everything. Run with:
///   flutter test integration_test/app_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo login then send a chat message', (tester) async {
    SharedPreferences.setMockInitialValues({
      // Skip onboarding so we land on the login screen.
      AppConstants.prefOnboardingComplete: true,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCacheServiceProvider
              .overrideWithValue(LocalCacheService(prefs)),
        ],
        child: const PlantSenseApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Log in with demo credentials (any valid email + 8+ char password).
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email').first, 'demo@plant.example');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // We should now be on the Home shell (Chat tab).
    expect(find.text('Ask your first question'), findsOneWidget);

    // Send a message.
    await tester.enterText(
        find.byType(TextField).last, 'Why are my leaves yellow?');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // A demo assistant reply should appear.
    expect(find.textContaining('Assessment'), findsWidgets);
  });
}
