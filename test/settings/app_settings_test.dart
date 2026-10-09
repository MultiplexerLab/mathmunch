import 'package:flutter_test/flutter_test.dart';
import 'package:mathmunch/core/constants/app_constants.dart';
import 'package:mathmunch/features/settings/providers/settings_provider.dart';

void main() {
  group('AppSettings defaults', () {
    test('sfxEnabled defaults to true', () {
      expect(const AppSettings().sfxEnabled, true);
    });

    test('musicEnabled defaults to true', () {
      expect(const AppSettings().musicEnabled, true);
    });

    test('hintsAlwaysOn defaults to false', () {
      expect(const AppSettings().hintsAlwaysOn, false);
    });

    test('dailyTimeLimitMinutes defaults to AppConstants value', () {
      expect(
        const AppSettings().dailyTimeLimitMinutes,
        AppConstants.defaultTimeLimitMinutes,
      );
    });
  });

  group('AppSettings.toMap / fromMap roundtrip', () {
    test('default settings survive a roundtrip', () {
      const original = AppSettings();
      final restored = AppSettings.fromMap(original.toMap());
      expect(restored.sfxEnabled, original.sfxEnabled);
      expect(restored.musicEnabled, original.musicEnabled);
      expect(restored.hintsAlwaysOn, original.hintsAlwaysOn);
      expect(restored.dailyTimeLimitMinutes, original.dailyTimeLimitMinutes);
    });

    test('custom settings survive a roundtrip', () {
      const original = AppSettings(
        sfxEnabled: false,
        musicEnabled: false,
        hintsAlwaysOn: true,
        dailyTimeLimitMinutes: 15,
      );
      final restored = AppSettings.fromMap(original.toMap());
      expect(restored.sfxEnabled, false);
      expect(restored.musicEnabled, false);
      expect(restored.hintsAlwaysOn, true);
      expect(restored.dailyTimeLimitMinutes, 15);
    });

    test('toMap produces correct keys', () {
      const settings = AppSettings(
        sfxEnabled: false,
        musicEnabled: true,
        hintsAlwaysOn: true,
        dailyTimeLimitMinutes: 45,
      );
      final map = settings.toMap();
      expect(map['sfx'], false);
      expect(map['music'], true);
      expect(map['hints'], true);
      expect(map['timeLimit'], 45);
    });

    test('fromMap falls back to defaults for missing keys', () {
      final settings = AppSettings.fromMap({});
      expect(settings.sfxEnabled, true);
      expect(settings.musicEnabled, true);
      expect(settings.hintsAlwaysOn, false);
      expect(
        settings.dailyTimeLimitMinutes,
        AppConstants.defaultTimeLimitMinutes,
      );
    });
  });

  group('AppSettings.copyWith', () {
    test('only sfxEnabled changes', () {
      const original = AppSettings();
      final updated = original.copyWith(sfxEnabled: false);
      expect(updated.sfxEnabled, false);
      expect(updated.musicEnabled, original.musicEnabled);
      expect(updated.hintsAlwaysOn, original.hintsAlwaysOn);
      expect(updated.dailyTimeLimitMinutes, original.dailyTimeLimitMinutes);
    });

    test('only musicEnabled changes', () {
      const original = AppSettings();
      final updated = original.copyWith(musicEnabled: false);
      expect(updated.musicEnabled, false);
      expect(updated.sfxEnabled, original.sfxEnabled);
    });

    test('only hintsAlwaysOn changes', () {
      const original = AppSettings();
      final updated = original.copyWith(hintsAlwaysOn: true);
      expect(updated.hintsAlwaysOn, true);
      expect(updated.sfxEnabled, original.sfxEnabled);
    });

    test('only dailyTimeLimitMinutes changes', () {
      const original = AppSettings();
      final updated = original.copyWith(dailyTimeLimitMinutes: 10);
      expect(updated.dailyTimeLimitMinutes, 10);
      expect(updated.sfxEnabled, original.sfxEnabled);
    });

    test('copyWith with no args preserves all values', () {
      const original = AppSettings(
        sfxEnabled: false,
        musicEnabled: false,
        hintsAlwaysOn: true,
        dailyTimeLimitMinutes: 20,
      );
      final copy = original.copyWith();
      expect(copy.sfxEnabled, original.sfxEnabled);
      expect(copy.musicEnabled, original.musicEnabled);
      expect(copy.hintsAlwaysOn, original.hintsAlwaysOn);
      expect(copy.dailyTimeLimitMinutes, original.dailyTimeLimitMinutes);
    });
  });
}
