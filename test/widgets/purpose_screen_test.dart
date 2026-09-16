import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
    },
  );
}
