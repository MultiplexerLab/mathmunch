import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/core/constants/app_constants.dart';
import 'package:mathmunch/data/local/hive_service.dart';
import 'package:mathmunch/data/models/session_result.dart';
import 'package:uuid/uuid.dart';

class ProgressRepository {
  int getStars(String childId, String levelId) {
    return HiveService.progressBox.get(
          '${childId}_$levelId',
          defaultValue: 0,
        ) as int;
  }

  Future<void> saveStars(String childId, String levelId, int stars) async {
    final key = '${childId}_$levelId';
    final existing = getStars(childId, levelId);
    if (stars > existing) {
      await HiveService.progressBox.put(key, stars);
    }
  }

  /// Returns up to [limit] most-recent sessions for a child, newest first.
  List<SessionResult> recentSessions(
    String childId, {
    int limit = AppConstants.activityFeedSize,
  }) {
    final all = HiveService.sessionsBox.values
        .where((s) => s.childId == childId)
        .toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
    // Bug fix: ..take() is a cascade that discards the iterable; call it
    // as a regular method on the sorted list and convert to List.
    return all.take(limit).toList();
  }

  List<SessionResult> recentSessionsForTopic(
    String childId,
    String topic, {
    int limit = 5,
  }) {
    return HiveService.sessionsBox.values
        .where((s) => s.childId == childId && s.worldId.contains(topic))
        .toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  Future<SessionResult> saveSession({
    required String childId,
    required String levelId,
    required String worldId,
    required String worldName,
    required String levelTitle,
    required double accuracy,
    required int starsEarned,
    required int durationSeconds,
  }) async {
    final session = SessionResult(
      id: const Uuid().v4(),
      childId: childId,
      levelId: levelId,
      worldId: worldId,
      worldName: worldName,
      levelTitle: levelTitle,
      accuracy: accuracy,
      starsEarned: starsEarned,
      durationSeconds: durationSeconds,
      playedAt: DateTime.now(),
    );
    await HiveService.sessionsBox.put(session.id, session);
    return session;
  }

  /// Counts consecutive recent sessions for a topic with accuracy below threshold.
  int consecutiveLowAccuracy(String childId, String topic) {
    final sessions = recentSessionsForTopic(childId, topic, limit: AppConstants.adaptiveConsecutiveFailures + 1);
    int count = 0;
    for (final s in sessions) {
      if (s.accuracy < AppConstants.adaptiveAccuracyThreshold) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  Map<String, int> levelStarsForChild(String childId) {
    final result = <String, int>{};
    for (final key in HiveService.progressBox.keys) {
      final keyStr = key.toString();
      if (keyStr.startsWith('${childId}_')) {
        final levelId = keyStr.substring('${childId}_'.length);
        result[levelId] =
            HiveService.progressBox.get(key, defaultValue: 0) as int;
      }
    }
    return result;
  }

  Future<void> resetAllProgress(String childId) async {
    final progressKeys = HiveService.progressBox.keys
        .where((k) => k.toString().startsWith('${childId}_'))
        .toList();
    await HiveService.progressBox.deleteAll(progressKeys);

    final sessionKeys = HiveService.sessionsBox.values
        .where((s) => s.childId == childId)
        .map((s) => s.id)
        .toList();
    await HiveService.sessionsBox.deleteAll(sessionKeys);
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>(
  (_) => ProgressRepository(),
);
