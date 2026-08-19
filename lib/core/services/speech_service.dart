import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Thin wrapper around speech_to_text for voice dictation in the chat composer.
/// The plugin requests the microphone permission natively on first use, so we
/// never ask for it up front.
class SpeechService {
  SpeechService([SpeechToText? speech]) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _available = false;

  bool get isListening => _speech.isListening;

  Future<bool> init() async {
    if (_available) return true;
    try {
      _available = await _speech.initialize(onError: (_) {}, onStatus: (_) {});
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  /// Starts listening; [onResult] receives the (possibly partial) transcript.
  Future<bool> start({
    required void Function(String text) onResult,
    String localeId = 'en',
  }) async {
    if (!await init()) return false;
    await _speech.listen(
      onResult: (r) => onResult(r.recognizedWords),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        localeId: localeId,
      ),
    );
    return true;
  }

  Future<void> stop() async {
    if (_speech.isListening) await _speech.stop();
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());
