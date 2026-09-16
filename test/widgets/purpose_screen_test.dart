import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/constants/app_constants.dart';
import 'package:plantsense_ai/features/georesearch/application/soil_research_provider.dart';
import 'package:plantsense_ai/features/georesearch/domain/site_survey_model.dart';
import 'package:plantsense_ai/features/home/application/home_provider.dart';
import 'package:plantsense_ai/features/onboarding/application/app_purpose_provider.dart';
import 'package:plantsense_ai/features/onboarding/presentation/purpose_screen.dart';
import 'package:plantsense_ai/l10n/app_localizations.dart';

import '../mocks/mocks.dart';

void main() {
  testWidgets(
    'picking "building" and confirming sets purpose, tab and survey',
    (tester) async {
      final overrides = await defaultOverrides();
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context, listen: false);
              return const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: [Locale('en')],
                home: PurposeScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Not chosen yet.
      expect(container.read(appPurposeProvider), isNull);

      // Tap the "Building" option, then Continue.
      await tester.tap(find.text('Building'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(container.read(appPurposeProvider), SurveyPurpose.building);
      expect(container.read(homeTabProvider), HomeTab.georesearch);
      expect(
        container.read(soilResearchControllerProvider).purpose,
        SurveyPurpose.building,
      );
      // Confirming is what releases the router to Home for this session.
      expect(container.read(purposeConfirmedThisSessionProvider), isTrue);
    },
  );

  testWidgets('the stored choice is pre-selected so re-confirming is one tap', (
    tester,
  ) async {
    // A returning user: a purpose is already persisted from a previous launch.
    final overrides = await defaultOverrides(
      prefs: {AppConstants.prefAppPurpose: SurveyPurpose.wellDrilling.name},
    );
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context, listen: false);
            return const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: [Locale('en')],
              home: PurposeScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The picker still shows (it is not skipped), but pressing Continue without
    // touching anything keeps the previous choice rather than resetting to
    // general — which is the point of persisting it.
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(container.read(appPurposeProvider), SurveyPurpose.wellDrilling);
    expect(container.read(homeTabProvider), HomeTab.georesearch);
    expect(container.read(purposeConfirmedThisSessionProvider), isTrue);
  });

  test(
    'the picker is not skipped on a launch that already has a purpose',
    () async {
      // The regression this guards: gating the router on the persisted purpose
      // would skip the screen for every returning user. A fresh container is what
      // an app launch looks like, so the session flag must start false even when a
      // purpose is stored.
      final container = ProviderContainer(
        overrides: await defaultOverrides(
          prefs: {AppConstants.prefAppPurpose: SurveyPurpose.building.name},
        ),
      );
      addTearDown(container.dispose);

      expect(container.read(appPurposeProvider), SurveyPurpose.building);
      expect(container.read(purposeConfirmedThisSessionProvider), isFalse);
    },
  );
}
