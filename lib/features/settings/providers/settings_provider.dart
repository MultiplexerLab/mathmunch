import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/core/constants/app_constants.dart';
import 'package:mathmunch/data/local/hive_service.dart';
import 'package:mathmunch/shared/services/audio_service.dart';
import 'package:mathmunch/shared/services/narration_service.dart';

class AppSettings {
  final bool sfxEnabled;
  final bool musicEnabled;
  final bool narrationEnabled;
  final bool hintsAlwaysOn;
  final int dailyTimeLimitMinutes;

  const AppSettings({
    this.sfxEnabled = true,
    this.musicEnabled = true,
    this.narrationEnabled = true,
    this.hintsAlwaysOn = false,
    this.dailyTimeLimitMinutes = AppConstants.defaultTimeLimitMinutes,
  });

  AppSettings copyWith({
    bool? sfxEnabled,
    bool? musicEnabled,
    bool? narrationEnabled,
    bool? hintsAlwaysOn,
    int? dailyTimeLimitMinutes,
  }) {
    return AppSettings(
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      narrationEnabled: narrationEnabled ?? this.narrationEnabled,
      hintsAlwaysOn: hintsAlwaysOn ?? this.hintsAlwaysOn,
      dailyTimeLimitMinutes:
          dailyTimeLimitMinutes ?? this.dailyTimeLimitMinutes,
    );
  }

  Map<String, dynamic> toMap() => {
        'sfx': sfxEnabled,
        'music': musicEnabled,
        'narration': narrationEnabled,
        'hints': hintsAlwaysOn,
        'timeLimit': dailyTimeLimitMinutes,
      };

  factory AppSettings.fromMap(Map map) => AppSettings(
        sfxEnabled: map['sfx'] as bool? ?? true,
        musicEnabled: map['music'] as bool? ?? true,
        narrationEnabled: map['narration'] as bool? ?? true,
        hintsAlwaysOn: map['hints'] as bool? ?? false,
        dailyTimeLimitMinutes:
            map['timeLimit'] as int? ?? AppConstants.defaultTimeLimitMinutes,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'app_settings';

  @override
  AppSettings build() {
    final raw = HiveService.settingsBox.get(_key);
    if (raw is Map) return AppSettings.fromMap(raw);
    return const AppSettings();
  }

  Future<void> _save(AppSettings settings) async {
    await HiveService.settingsBox.put(_key, settings.toMap());
    state = settings;
    ref.read(audioServiceProvider).configure(
          sfx: settings.sfxEnabled,
          music: settings.musicEnabled,
        );
    ref.read(narrationServiceProvider).setEnabled(settings.narrationEnabled);
  }

  Future<void> setSfx(bool value) => _save(state.copyWith(sfxEnabled: value));
  Future<void> setMusic(bool value) =>
      _save(state.copyWith(musicEnabled: value));
  Future<void> setNarration(bool value) =>
      _save(state.copyWith(narrationEnabled: value));
  Future<void> setHintsAlwaysOn(bool value) =>
      _save(state.copyWith(hintsAlwaysOn: value));
  Future<void> setTimeLimit(int minutes) =>
      _save(state.copyWith(dailyTimeLimitMinutes: minutes));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
