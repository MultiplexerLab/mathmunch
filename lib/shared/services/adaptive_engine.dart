import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/core/constants/app_constants.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';

/// Determines whether difficulty should be lowered for a given topic.
/// FR-28: lower difficulty after 2 consecutive levels with < 70% accuracy.
class AdaptiveEngine {
  final ProgressRepository _progress;

  AdaptiveEngine(this._progress);

  bool shouldLowerDifficulty(String childId, String topic) {
    return _progress.consecutiveLowAccuracy(childId, topic) >=
        AppConstants.adaptiveConsecutiveFailures;
  }

  /// Suggested difficulty (1 = easy, 2 = medium, 3 = hard)
  int suggestedDifficulty(String childId, String topic, int currentDifficulty) {
    if (shouldLowerDifficulty(childId, topic)) {
      return (currentDifficulty - 1).clamp(1, 3);
    }
    return currentDifficulty;
  }
}

final adaptiveEngineProvider = Provider<AdaptiveEngine>((ref) {
  return AdaptiveEngine(ref.watch(progressRepositoryProvider));
});
