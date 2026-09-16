import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/features/georesearch/domain/site_survey_model.dart';
import 'package:plantsense_ai/features/home/application/home_provider.dart';

void main() {
  group('homeTabForPurpose', () {
    test('site/land purposes open the GeoResearch tab', () {
      expect(homeTabForPurpose(SurveyPurpose.building), HomeTab.georesearch);
      expect(
        homeTabForPurpose(SurveyPurpose.wellDrilling),
        HomeTab.georesearch,
      );
      expect(
        homeTabForPurpose(SurveyPurpose.slopeStability),
        HomeTab.georesearch,
      );
    });

    test('plant-care purposes open the Diagnose tab', () {
      expect(homeTabForPurpose(SurveyPurpose.agriculture), HomeTab.diagnose);
      expect(homeTabForPurpose(SurveyPurpose.general), HomeTab.diagnose);
    });

    test('every SurveyPurpose maps to a valid tab index', () {
      const validTabs = {
        HomeTab.chat,
        HomeTab.diagnose,
        HomeTab.georesearch,
        HomeTab.weather,
        HomeTab.profile,
      };
      for (final p in SurveyPurpose.values) {
        expect(validTabs.contains(homeTabForPurpose(p)), isTrue);
      }
    });
  });
}
