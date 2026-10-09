import 'package:flutter_test/flutter_test.dart';

// Mirrors the streak calculation in ChildRepository.recordPlay() so we can
// test the pure logic without Hive or Riverpod.
int calculateStreak(int currentStreak, DateTime? lastPlayDate, DateTime today) {
  if (lastPlayDate == null) return 1;
  final diff = today.difference(lastPlayDate).inDays;
  if (diff == 1) return currentStreak + 1;
  if (diff > 1) return 1;
  return currentStreak; // same day — streak unchanged
}

void main() {
  final today = DateTime(2025, 6, 15);

  group('Streak calculation', () {
    test('first play with no lastPlayDate sets streak to 1', () {
      expect(calculateStreak(0, null, today), 1);
    });

    test('first play even if currentStreak was non-zero resets to 1', () {
      expect(calculateStreak(5, null, today), 1);
    });

    test('playing the day after lastPlayDate increments streak', () {
      final yesterday = DateTime(2025, 6, 14);
      expect(calculateStreak(3, yesterday, today), 4);
    });

    test('playing two days after lastPlayDate resets streak to 1', () {
      final twoDaysAgo = DateTime(2025, 6, 13);
      expect(calculateStreak(5, twoDaysAgo, today), 1);
    });

    test('playing a week after lastPlayDate resets streak to 1', () {
      final weekAgo = DateTime(2025, 6, 8);
      expect(calculateStreak(7, weekAgo, today), 1);
    });

    test('playing same day as lastPlayDate leaves streak unchanged', () {
      expect(calculateStreak(3, today, today), 3);
    });

    test('streak increment builds correctly over multiple consecutive days', () {
      int streak = 0;
      DateTime? last;
      final days = [
        DateTime(2025, 6, 10),
        DateTime(2025, 6, 11),
        DateTime(2025, 6, 12),
        DateTime(2025, 6, 13),
      ];
      for (final day in days) {
        streak = calculateStreak(streak, last, day);
        last = day;
      }
      expect(streak, 4);
    });

    test('streak resets after missing a day', () {
      int streak = calculateStreak(0, null, DateTime(2025, 6, 10));
      streak = calculateStreak(streak, DateTime(2025, 6, 10), DateTime(2025, 6, 11));
      // miss June 12
      streak = calculateStreak(streak, DateTime(2025, 6, 11), DateTime(2025, 6, 13));
      expect(streak, 1);
    });
  });
}
