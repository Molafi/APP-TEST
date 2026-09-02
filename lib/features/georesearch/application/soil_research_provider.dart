import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/environment.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/services/ai_gateway.dart';
import '../../../core/services/local_cache_service.dart';
import '../../../core/theme/locale_provider.dart';
import '../../../core/utils/image_compressor.dart';
import '../../auth/application/auth_provider.dart';
import '../../location/application/location_provider.dart';
import '../../location/domain/location_model.dart';
import '../../profile/application/settings_provider.dart';
import '../../weather/application/ai_context_provider.dart';
import '../data/aerial_imagery_service.dart';
import '../data/rjgc_map_service.dart';
import '../data/soil_report_repository.dart';
import '../data/soil_research_service.dart';
import '../domain/soil_report_model.dart';

final soilReportRepositoryProvider = Provider<SoilReportRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (!Environment.isDemo && user != null) {
    return FirestoreSoilReportRepository(uid: user.uid);
  }
  return LocalSoilReportRepository(ref.watch(localCacheServiceProvider));
});

/// The steps of the soil-research flow.
enum SoilResearchStage { input, analyzing, result }

@immutable
class SoilResearchState {
  const SoilResearchState({
    this.stage = SoilResearchStage.input,
    this.imageBytes,
    this.result,
    this.error,
    this.saved = false,
    this.purpose = SurveyPurpose.general,
    this.requirements,
    this.landRecord = const LandRecordInfo(),
  });

  final SoilResearchStage stage;

  /// Optional site/soil photo the user attached before analysis.
  final Uint8List? imageBytes;
  final SoilReport? result;
  final AppException? error;
  final bool saved;

  /// What the user wants the site for — drives which findings are emphasised.
  final SurveyPurpose purpose;

  /// The user's own free-text requirements for the survey.
  final String? requirements;

  /// Optional official Land Department record. Used when
  /// [LandRecordInfo.available] is true; otherwise the survey relies on
  /// estimates from location and regional context.
  final LandRecordInfo landRecord;

  SoilResearchState copyWith({
    SoilResearchStage? stage,
    Uint8List? imageBytes,
    SoilReport? result,
    AppException? error,
    bool? saved,
    SurveyPurpose? purpose,
    String? requirements,
    LandRecordInfo? landRecord,
    bool clearError = false,
    bool clearResult = false,
    bool clearImage = false,
    bool clearRequirements = false,
  }) {
    return SoilResearchState(
      stage: stage ?? this.stage,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      saved: saved ?? this.saved,
      purpose: purpose ?? this.purpose,
      requirements: clearRequirements
          ? null
          : (requirements ?? this.requirements),
      landRecord: landRecord ?? this.landRecord,
    );
  }
}

class SoilResearchController extends StateNotifier<SoilResearchState> {
  SoilResearchController(this._ref) : super(const SoilResearchState());

  final Ref _ref;
  final ImageCompressor _compressor = const ImageCompressor();
  int _seq = 0;
  DateTime? _lastAnalysis;

  /// Attaches (or replaces) an optional photo for the report.
  void setImage(Uint8List bytes) {
    state = state.copyWith(imageBytes: bytes, clearError: true);
  }

  /// Removes the attached photo.
  void clearImage() {
    state = state.copyWith(clearImage: true);
  }

  /// Sets what the user intends to use the site for.
  void setPurpose(SurveyPurpose purpose) {
    state = state.copyWith(purpose: purpose, clearError: true);
  }

  /// Records the user's free-text requirements for the survey. Clearing the
  /// field genuinely clears the stored value, so stale requirements are never
  /// sent after the user empties the box.
  void setRequirements(String? text) {
    final String trimmed = text?.trim() ?? '';
    if (trimmed.isEmpty) {
      state = state.copyWith(clearRequirements: true);
      return;
    }
    state = state.copyWith(requirements: trimmed);
  }

  /// Stores optional official Land Department data. Passing a record with
  /// [LandRecordInfo.available] false makes the survey fall back to estimates.
  void setLandRecord(LandRecordInfo record) {
    state = state.copyWith(landRecord: record, clearError: true);
  }

  /// Turns the official-data section on/off without discarding typed values.
  void setLandRecordAvailable(bool available) {
    state = state.copyWith(
      landRecord: state.landRecord.copyWith(available: available),
    );
  }

  /// Runs the soil-research analysis. Prevents duplicate/superseded requests
  /// and enforces a minimum interval between analyses.
  Future<void> analyze({String? note}) async {
    if (state.stage == SoilResearchStage.analyzing) return;

    final DateTime now = DateTime.now();
    if (_lastAnalysis != null &&
        now.difference(_lastAnalysis!) < AppConfig.minTimeBetweenDiagnoses) {
      return;
    }
    _lastAnalysis = now;

    final int seq = ++_seq;
    state = state.copyWith(
      stage: SoilResearchStage.analyzing,
      clearError: true,
    );

    try {
      AiImage? image;
      Uint8List? preparedBytes = state.imageBytes;
      if (state.imageBytes != null) {
        final PreparedImage prepared = await _compressor.prepare(
          state.imageBytes!,
        );
        image = AiImage(base64: prepared.base64, mimeType: prepared.mimeType);
        preparedBytes = prepared.bytes;
      }

      final AiContext ctx = _ref.read(aiContextProvider);
      final PlantLocation? location = _ref.read(selectedLocationProvider);
      final String locale = _ref.read(appLocaleCodeProvider);

      final SoilReport result = await _ref
          .read(soilResearchServiceProvider)
          .analyze(
            locale: locale,
            image: image,
            context: ctx.values,
            // Requirements are passed as delimited CONTEXT only (below), never
            // in instruction position, so user free text cannot compete with
            // the JSON schema instruction.
            userNote: note,
            latitude: location?.latitude,
            longitude: location?.longitude,
            purpose: state.purpose,
            requirements: state.requirements,
            landRecord: state.landRecord,
          );

      if (!mounted || seq != _seq) return; // superseded/cancelled

      // The aerial tile URL is built locally from the coordinates; the model
      // only supplies the narrative fields, which we merge onto it. When there
      // are no coordinates this stays null, which CLEARS any imagery stub the
      // model volunteered — we must not caption an image that was never fetched.
      final AerialImageryInfo? aerial = const AerialImageryService()
          .forLocation(
            latitude: location?.latitude,
            longitude: location?.longitude,
          );
      final AerialImageryInfo? merged = aerial?.withNarrative(
        interpretation: result.aerialImagery?.interpretation,
        landCover: result.aerialImagery?.landCover,
        visibleFeatures: result.aerialImagery?.visibleFeatures,
      );

      // National mapping-authority reference (RJGC / JTM grid). Computed
      // locally from the coordinates for the same reason as the aerial tile:
      // an official-looking grid reference must never originate in model
      // output. Null without coordinates, or outside Jordan's coverage.
      final OfficialMapReference? officialMap = const RjgcMapService()
          .forLocation(
            latitude: location?.latitude,
            longitude: location?.longitude,
          );

      // The official land record shown in the report is the one the USER
      // entered — never the model's echo of it.
      final LandRecordInfo? officialRecord =
          state.landRecord.available && state.landRecord.hasData
          ? state.landRecord
          : null;

      state = state.copyWith(
        stage: SoilResearchStage.result,
        result: result
            .withUserInputs(
              landRecord: officialRecord,
              aerialImagery: merged,
              officialMap: officialMap,
              purpose: state.purpose,
              userRequirements: state.requirements,
            )
            .withMeta(locationContext: ctx.displayStrip),
        imageBytes: preparedBytes,
        clearImage: preparedBytes == null,
        saved: false,
      );
    } catch (e) {
      if (!mounted || seq != _seq) return;
      state = state.copyWith(
        stage: SoilResearchStage.input,
        error: ErrorMapper.fromException(e),
      );
    }
  }

  void cancelAnalysis() {
    if (state.stage != SoilResearchStage.analyzing) return;
    _seq++; // ignore the in-flight response
    state = state.copyWith(stage: SoilResearchStage.input);
  }

  Future<void> saveCurrent() async {
    final SoilReport? result = state.result;
    if (result == null || state.saved) return;
    final bool retain = _ref.read(imageRetentionProvider);
    try {
      final SoilReport stored = await _ref
          .read(soilReportRepositoryProvider)
          .save(result, imageBytes: state.imageBytes, retainImage: retain);
      if (!mounted) return;
      state = state.copyWith(result: stored, saved: true);
      _ref.invalidate(soilReportHistoryProvider);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: ErrorMapper.fromException(e));
    }
  }

  /// Returns to the input stage. The user's requirements, purpose and any
  /// entered Land Department data are intentionally preserved so they do not
  /// have to be re-typed for another run.
  void reset() {
    _seq++;
    state = SoilResearchState(
      purpose: state.purpose,
      requirements: state.requirements,
      landRecord: state.landRecord,
    );
  }
}

final soilResearchControllerProvider =
    StateNotifierProvider<SoilResearchController, SoilResearchState>((ref) {
      return SoilResearchController(ref);
    });

/// Loads saved soil-report history.
final soilReportHistoryProvider = FutureProvider<List<SoilReport>>((ref) {
  return ref.watch(soilReportRepositoryProvider).load();
});
