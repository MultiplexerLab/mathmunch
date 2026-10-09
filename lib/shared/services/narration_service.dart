import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Reads question prompts and feedback aloud using the device's TTS engine.
///
/// All public methods fail silently — TTS unavailability must never crash
/// gameplay. The service is enabled by default and can be toggled via
/// [setEnabled], which is driven by the narrationEnabled setting.
class NarrationService {
  final FlutterTts _tts = FlutterTts();
  bool _enabled = true;
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    _initialized = true;
    // Child-friendly defaults: slower rate, clear volume, slightly warm pitch.
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45); // standard is ~0.5; 0.45 is gentler
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1); // warmer, friendly pitch for young listeners
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (!value) _tts.stop();
  }

  /// Interrupts any in-progress speech and speaks [text].
  Future<void> speak(String text) async {
    if (!_enabled || text.isEmpty) return;
    try {
      await _ensureInit();
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // TTS engine unavailable — fail silently so gameplay is unaffected.
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  void dispose() => _tts.stop();
}

final narrationServiceProvider = Provider<NarrationService>((ref) {
  final service = NarrationService();
  ref.onDispose(service.dispose);
  return service;
});
