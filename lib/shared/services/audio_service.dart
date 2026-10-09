import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _narrationPlayer = AudioPlayer();

  bool _sfxEnabled = true;
  bool _musicEnabled = true;

  void configure({required bool sfx, required bool music}) {
    _sfxEnabled = sfx;
    _musicEnabled = music;
    if (!music) _musicPlayer.stop();
  }

  Future<void> playSfx(String assetPath) async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (_) {
      // audio file missing — ignore silently
    }
  }

  Future<void> playNarration(String assetPath) async {
    await _narrationPlayer.stop();
    await _narrationPlayer.play(AssetSource(assetPath));
  }

  Future<void> playCorrect() => playSfx('audio/sfx/correct.mp3');
  Future<void> playIncorrect() => playSfx('audio/sfx/incorrect.mp3');
  Future<void> playLevelComplete() => playSfx('audio/sfx/level_complete.mp3');
  Future<void> playStickerPop() => playSfx('audio/sfx/sticker_pop.mp3');
  Future<void> playHint() => playSfx('audio/sfx/hint.mp3');

  Future<void> startBackgroundMusic(String assetPath) async {
    if (!_musicEnabled) return;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource(assetPath));
  }

  Future<void> stopBackgroundMusic() => _musicPlayer.stop();

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
    _narrationPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});
