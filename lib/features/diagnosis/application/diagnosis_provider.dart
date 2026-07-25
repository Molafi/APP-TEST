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
import '../../profile/application/settings_provider.dart';
import '../../weather/application/ai_context_provider.dart';
import '../data/ai_diagnosis_service.dart';
import '../data/diagnosis_repository.dart';
import '../domain/diagnosis_model.dart';

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (!Environment.isDemo && user != null) {
    return FirestoreDiagnosisRepository(uid: user.uid);
  }
  return LocalDiagnosisRepository(ref.watch(localCacheServiceProvider));
});

/// The steps of the diagnosis flow.
enum DiagnosisStage { capture, confirm, analyzing, result }

@immutable
class DiagnosisState {
  const DiagnosisState({
    this.stage = DiagnosisStage.capture,
    this.imageBytes,
    this.result,
    this.error,
    this.saved = false,
  });

  final DiagnosisStage stage;
  final Uint8List? imageBytes;
  final Diagnosis? result;
  final AppException? error;
  final bool saved;

  DiagnosisState copyWith({
    DiagnosisStage? stage,
    Uint8List? imageBytes,
    Diagnosis? result,
    AppException? error,
    bool? saved,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return DiagnosisState(
      stage: stage ?? this.stage,
      imageBytes: imageBytes ?? this.imageBytes,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      saved: saved ?? this.saved,
    );
  }
}

class DiagnosisController extends StateNotifier<DiagnosisState> {
  DiagnosisController(this._ref) : super(const DiagnosisState());

  final Ref _ref;
  final ImageCompressor _compressor = const ImageCompressor();
  int _seq = 0;
  DateTime? _lastAnalysis;

  /// Called after capture or gallery import — moves to the confirm step.
  void setImage(Uint8List bytes) {
    state = DiagnosisState(stage: DiagnosisStage.confirm, imageBytes: bytes);
  }

  void retake() {
    _seq++; // cancel any in-flight analysis
    state = const DiagnosisState();
  }

  /// Confirms the current image and runs analysis. Prevents duplicate requests
  /// and enforces a minimum interval between analyses.
  Future<void> analyze({String? note}) async {
    final Uint8List? bytes = state.imageBytes;
    if (bytes == null || state.stage == DiagnosisStage.analyzing) return;

    final DateTime now = DateTime.now();
    if (_lastAnalysis != null &&
        now.difference(_lastAnalysis!) < AppConfig.minTimeBetweenDiagnoses) {
      return;
    }
    _lastAnalysis = now;

    final int seq = ++_seq;
    state = state.copyWith(stage: DiagnosisStage.analyzing, clearError: true);

    try {
      final PreparedImage prepared = await _compressor.prepare(bytes);
      final AiContext ctx = _ref.read(aiContextProvider);
      final String locale = _ref.read(localeProvider)?.languageCode ?? 'en';

      final Diagnosis result =
          await _ref.read(aiDiagnosisServiceProvider).analyze(
                locale: locale,
                image: AiImage(
                    base64: prepared.base64, mimeType: prepared.mimeType),
                context: ctx.values,
                userNote: note,
              );

      if (!mounted || seq != _seq) return; // superseded/cancelled

      state = state.copyWith(
        stage: DiagnosisStage.result,
        result: result.withMeta(locationContext: ctx.displayStrip),
        // Keep the compressed bytes so the user can optionally save the image.
        imageBytes: prepared.bytes,
        saved: false,
      );
    } catch (e) {
      if (!mounted || seq != _seq) return;
      state = state.copyWith(
        stage: DiagnosisStage.confirm,
        error: ErrorMapper.fromException(e),
      );
    }
  }

  void cancelAnalysis() {
    if (state.stage != DiagnosisStage.analyzing) return;
    _seq++; // ignore the in-flight response
    state = state.copyWith(stage: DiagnosisStage.confirm);
  }

  Future<void> saveCurrent() async {
    final Diagnosis? result = state.result;
    if (result == null || state.saved) return;
    final bool retain = _ref.read(imageRetentionProvider);
    try {
      final Diagnosis stored =
          await _ref.read(diagnosisRepositoryProvider).save(
                result,
                imageBytes: state.imageBytes,
                retainImage: retain,
              );
      if (!mounted) return;
      state = state.copyWith(result: stored, saved: true);
      // Refresh the history list.
      _ref.invalidate(diagnosisHistoryProvider);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: ErrorMapper.fromException(e));
    }
  }

  void reset() {
    _seq++;
    state = const DiagnosisState();
  }
}

final diagnosisControllerProvider =
    StateNotifierProvider<DiagnosisController, DiagnosisState>((ref) {
  return DiagnosisController(ref);
});

/// Loads saved diagnosis history.
final diagnosisHistoryProvider = FutureProvider<List<Diagnosis>>((ref) {
  return ref.watch(diagnosisRepositoryProvider).load();
});
