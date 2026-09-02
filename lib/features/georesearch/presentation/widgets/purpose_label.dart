import '../../../../l10n/app_localizations.dart';
import '../../domain/site_survey_model.dart';

/// Localized name for a survey purpose.
///
/// Single source of truth so the chips the user picks from and the purpose shown
/// back in the finished report can never drift apart. The switch is exhaustive
/// with no default, so adding a [SurveyPurpose] is a compile error until it has
/// a label.
String purposeLabel(SurveyPurpose purpose, AppLocalizations l10n) {
  return switch (purpose) {
    SurveyPurpose.general => l10n.georesearchPurposeGeneral,
    SurveyPurpose.agriculture => l10n.georesearchPurposeAgriculture,
    SurveyPurpose.building => l10n.georesearchPurposeBuilding,
    SurveyPurpose.wellDrilling => l10n.georesearchPurposeWellDrilling,
    SurveyPurpose.slopeStability => l10n.georesearchPurposeSlopeStability,
  };
}
