import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech for reading AI answers aloud (accessibility). Language is
/// chosen from the app locale. All calls are guarded so a missing TTS engine
/// never crashes the app.
class TtsService {
  TtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool get isSpeaking => _speaking;
  bool _speaking = false;

  static String _voiceLocale(String appLocale) => switch (appLocale) {
        'ar' => 'ar',
        'fr' => 'fr-FR',
        'es' => 'es-ES',
        _ => 'en-US',
      };

  Future<void> speak(String text, {String locale = 'en'}) async {
    try {
      await _tts.stop();
      await _tts.setLanguage(_voiceLocale(locale));
      await _tts.setSpeechRate(0.5);
      _speaking = true;
      _tts.setCompletionHandler(() => _speaking = false);
      await _tts.speak(text);
    } catch (_) {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    _speaking = false;
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());
