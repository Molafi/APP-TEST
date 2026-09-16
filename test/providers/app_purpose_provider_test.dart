import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/constants/app_constants.dart';
import 'package:plantsense_ai/features/georesearch/domain/site_survey_model.dart';
import 'package:plantsense_ai/features/onboarding/application/app_purpose_provider.dart';

import '../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> makeContainer({
    Map<String, Object> prefs = const {},
  }) async {
    final overrides = await defaultOverrides(prefs: prefs);
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  test('defaults to null when no purpose is stored (picker shows once)', () async {
    final container = await makeContainer();

    expect(container.read(appPurposeProvider), isNull);
    expect(container.read(purposeChosenProvider), isFalse);
  });

  test('setPurpose persists the choice and updates state', () async {
    final container = await makeContainer();
    final notifier = container.read(appPurposeProvider.notifier);

    await notifier.setPurpose(SurveyPurpose.building);

    expect(container.read(appPurposeProvider), SurveyPurpose.building);
    expect(container.read(purposeChosenProvider), isTrue);
  });

  test('a new container restores the persisted purpose', () async {
    final container = await makeContainer(
      prefs: {AppConstants.prefAppPurpose: SurveyPurpose.wellDrilling.name},
    );

    expect(container.read(appPurposeProvider), SurveyPurpose.wellDrilling);
    expect(container.read(purposeChosenProvider), isTrue);
  });

  test('a deliberately-chosen general is distinct from "not chosen"', () async {
    // Storing general.name must NOT read back as null: the user made a choice.
    final container = await makeContainer(
      prefs: {AppConstants.prefAppPurpose: SurveyPurpose.general.name},
    );

    expect(container.read(appPurposeProvider), SurveyPurpose.general);
    expect(container.read(purposeChosenProvider), isTrue);
  });

  test('an unknown stored value degrades to general via tolerant parsing', () async {
    final container = await makeContainer(
      prefs: {AppConstants.prefAppPurpose: 'not-a-real-purpose'},
    );

    // surveyPurposeFrom maps unknown -> general; still counts as chosen.
    expect(container.read(appPurposeProvider), SurveyPurpose.general);
    expect(container.read(purposeChosenProvider), isTrue);
  });
}
