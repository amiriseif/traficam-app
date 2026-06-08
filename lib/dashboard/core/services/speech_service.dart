import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// ─────────────────────────────────────────────────────────────────
/// SPEECH SERVICE (Fixed for speech_to_text ^7.0.0 API)
/// Uses speech_to_text plugin for real device microphone.
/// Supports Arabic (ar-TN), French (fr-FR), English (en-US).
/// ─────────────────────────────────────────────────────────────────
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  String _currentLocale = 'fr-FR';

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
    return _initialized;
  }

  Future<void> setLocale(SpeechLocale locale) async {
    _currentLocale = locale.bcp47;
  }

  Future<void> startListening({
    required Function(String text) onResult,
    required Function(bool isListening) onStatusChange,
    bool continuous = true,
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) {
        onStatusChange(false);
        return;
      }
    }

    // Dynamic locale verification to prevent errors on uninstalled lang packs
    final locales = await _speech.locales();
    final hasLocale = locales.any((element) => element.localeId == _currentLocale);
    final targetLocale = hasLocale ? _currentLocale : 'en-US';

    // In ^7.0.0, the parameter name is 'listenOptions'
    // Everything else (localeId, listenFor, pauseFor, listenMode) lives inside it.
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        localeId: targetLocale,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 5),
        listenMode: ListenMode.dictation, // Solves your initial error_no_match issue
        partialResults: true,
        cancelOnError: false,
      ),
    );

    onStatusChange(true);
  }

  Future<void> stopListening({
    required Function(bool isListening) onStatusChange,
  }) async {
    await _speech.stop();
    onStatusChange(false);
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }

  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_initialized) await initialize();
    return await _speech.locales();
  }
}

enum SpeechLocale {
  arabic('ar-TN', 'العربية'),
  french('fr-FR', 'Français'),
  english('en-US', 'English');

  final String bcp47;
  final String label;
  const SpeechLocale(this.bcp47, this.label);
}