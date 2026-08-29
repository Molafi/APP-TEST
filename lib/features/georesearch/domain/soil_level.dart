/// A qualitative low/medium/high level shared across the GeoResearch models
/// (salinity, sodium, nutrients, substance concern, flood/erosion risk,
/// groundwater yield and building suitability).
///
/// Lives in its own file so both `soil_report_model.dart` and
/// `site_survey_model.dart` can depend on it without an import cycle.
/// `soil_report_model.dart` re-exports it, so existing imports keep working.
enum SoilLevel { low, medium, high }

/// Tolerant parser: anything unrecognised (including null) degrades to
/// [SoilLevel.low].
///
/// Only use this where "low" is a safe default (nutrient abundance, substance
/// concern). For RISK fields prefer [soilLevelOrNull], which refuses to guess —
/// silently rendering an unrecognised "severe" as a reassuring "Low" chip would
/// understate a hazard.
SoilLevel soilLevelFrom(String? s) =>
    soilLevelOrNull(s) ?? SoilLevel.low;

/// Strict parser: returns null for anything it does not recognise, so callers
/// can hide the field rather than display a misleading level.
///
/// Accepts a few common synonyms the model may emit instead of the canonical
/// three values.
SoilLevel? soilLevelOrNull(String? s) => switch (s?.trim().toLowerCase()) {
  'high' || 'severe' || 'very high' || 'elevated' => SoilLevel.high,
  'medium' || 'moderate' || 'mid' => SoilLevel.medium,
  'low' || 'minimal' || 'negligible' || 'none' || 'very low' => SoilLevel.low,
  _ => null,
};
