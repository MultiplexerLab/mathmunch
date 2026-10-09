import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/data/models/session_result.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';

class WeeklySummary {
  final int totalMinutes;
  final int starsEarned;
  final int streak;
  final double accuracyPercent;
  final List<SessionResult> recentSessions;

  const WeeklySummary({
    required this.totalMinutes,
    required this.starsEarned,
    required this.streak,
    required this.accuracyPercent,
    required this.recentSessions,
  });
}

final weeklySummaryProvider = Provider<WeeklySummary?>((ref) {
  final child = ref.watch(activeChildProvider);
  if (child == null) return null;

  final progress = ref.watch(progressRepositoryProvider);
  final sessions = progress.recentSessions(child.id);

  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  final weekSessions =
      sessions.where((s) => s.playedAt.isAfter(weekAgo)).toList();

  final totalSeconds =
      weekSessions.fold(0, (sum, s) => sum + s.durationSeconds);
  final stars = weekSessions.fold(0, (sum, s) => sum + s.starsEarned);
  final accuracy = weekSessions.isEmpty
      ? 0.0
      : weekSessions.map((s) => s.accuracy).reduce((a, b) => a + b) /
          weekSessions.length;

  return WeeklySummary(
    totalMinutes: totalSeconds ~/ 60,
    starsEarned: stars,
    streak: child.currentStreak,
    accuracyPercent: accuracy * 100,
    recentSessions: sessions,
  );
});

// PIN gate state
class PinGateNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;
  void lock() => state = false;
}

final parentUnlockedProvider = NotifierProvider<PinGateNotifier, bool>(
  PinGateNotifier.new,
);
