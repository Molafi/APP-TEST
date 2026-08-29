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
  });

  final SoilResearchStage stage;

  /// Optional site/soil photo the user attached before analysis.
  final Uint8List? imageBytes;
  final SoilReport? result;
  final AppException? error;
  final bool saved;

  SoilResearchState copyWith({
    SoilResearchStage? stage,
    Uint8List? imageBytes,
    SoilReport? result,
    AppException? error,
    bool? saved,
    bool clearError = false,
    bool clearResult = false,
    bool clearImage = false,
  }) {
    return SoilResearchState(
      stage: stage ?? this.stage,
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      saved: saved ?? this.saved,
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
      final String locale = _ref.read(localeProvider)?.languageCode ?? 'en';

      final SoilReport result = await _ref
          .read(soilResearchServiceProvider)
          .analyze(
            locale: locale,
            image: image,
            context: ctx.values,
            userNote: note,
            latitude: location?.latitude,
            longitude: location?.longitude,
          );

      if (!mounted || seq != _seq) return; // superseded/cancelled

      state = state.copyWith(
        stage: SoilResearchStage.result,
        result: result.withMeta(locationContext: ctx.displayStrip),
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

  void reset() {
    _seq++;
    state = const SoilResearchState();
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
