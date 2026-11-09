import 'package:flutter_test/flutter_test.dart';
import 'package:mathmunch/shared/services/daily_limit_service.dart';

void main() {
  group('computeDailyLimitStatus', () {
    test('not reached when minutes played is below the limit', () {
      final status = computeDailyLimitStatus(
        secondsPlayedToday: 10 * 60,
        limitMinutes: 30,
      );
      expect(status.reached, false);
      expect(status.minutesPlayedToday, 10);
      expect(status.limitMinutes, 30);
    });

    test('reached when minutes played exactly equals the limit', () {
      final status = computeDailyLimitStatus(
        secondsPlayedToday: 30 * 60,
        limitMinutes: 30,
      );
      expect(status.reached, true);
    });

    test('reached when minutes played exceeds the limit', () {
      final status = computeDailyLimitStatus(
        secondsPlayedToday: 45 * 60,
        limitMinutes: 30,
      );
      expect(status.reached, true);
    });

    test('seconds are floored down to whole minutes', () {
      final status = computeDailyLimitStatus(
        secondsPlayedToday: 29 * 60 + 59,
        limitMinutes: 30,
      );
      expect(status.minutesPlayedToday, 29);
      expect(status.reached, false);
    });

    test('zero seconds played is never reached for a positive limit', () {
      final status = computeDailyLimitStatus(
        secondsPlayedToday: 0,
        limitMinutes: 5,
      );
      expect(status.reached, false);
      expect(status.minutesPlayedToday, 0);
    });
  });
}
