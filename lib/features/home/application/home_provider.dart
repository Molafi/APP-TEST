import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../georesearch/domain/site_survey_model.dart';

/// Bottom-navigation tab indices. The order here must match the IndexedStack
/// children and NavigationBar destinations in home_screen.dart.
class HomeTab {
  const HomeTab._();
  static const int chat = 0;
  static const int diagnose = 1;
  static const int georesearch = 2;
  static const int weather = 3;
  static const int profile = 4;
}

/// Maps the user's chosen [SurveyPurpose] to the Home tab they should land on
/// after picking it. Kept a pure function so it is trivially unit-testable.
///
/// Mapping rationale:
/// - building / wellDrilling / slopeStability are land/site concerns, so they
///   open the GeoResearch tab where the site survey lives.
/// - agriculture / general are plant-care concerns, so they open the Diagnose
///   tab (photograph a leaf/soil issue and get guidance).
int homeTabForPurpose(SurveyPurpose purpose) {
  return switch (purpose) {
    SurveyPurpose.building ||
    SurveyPurpose.wellDrilling ||
    SurveyPurpose.slopeStability => HomeTab.georesearch,
    SurveyPurpose.agriculture || SurveyPurpose.general => HomeTab.diagnose,
  };
}

/// Currently selected bottom-nav tab. Kept in state so tapping the weather chip
/// can switch tabs from anywhere.
final homeTabProvider = StateProvider<int>((ref) => HomeTab.chat);

/// A pending prompt handed from a diagnosis "Ask follow-up" action to the chat
/// tab. Consumed (set back to null) by the chat screen once applied.
final chatFollowUpProvider = StateProvider<String?>((ref) => null);
