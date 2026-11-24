import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';
import 'package:mathmunch/features/settings/providers/settings_provider.dart';

/// FR-41 — status of the active child's parent-configured daily time limit,
/// derived from today's persisted foreground play time.
class DailyLimitStatus {
  final bool reached;
  final int minutesPlayedToday;
  final int limitMinutes;

  const DailyLimitStatus({
    required this.reached,
    required this.minutesPlayedToday,
    required this.limitMinutes,
  });
}

DailyLimitStatus computeDailyLimitStatus({
  required int secondsPlayedToday,
  required int limitMinutes,
}) {
  final minutesPlayedToday = secondsPlayedToday ~/ 60;
  return DailyLimitStatus(
    reached: minutesPlayedToday >= limitMinutes,
    minutesPlayedToday: minutesPlayedToday,
    limitMinutes: limitMinutes,
  );
}

DailyLimitStatus readDailyLimitStatus(Ref ref) {
  final child = ref.read(activeChildProvider);
  final limitMinutes = ref.read(settingsProvider).dailyTimeLimitMinutes;
  if (child == null) {
    return computeDailyLimitStatus(
        secondsPlayedToday: 0, limitMinutes: limitMinutes);
  }
  final progress = ref.read(progressRepositoryProvider);
  return computeDailyLimitStatus(
    secondsPlayedToday: progress.secondsPlayedToday(child.id),
    limitMinutes: limitMinutes,
  );
}
