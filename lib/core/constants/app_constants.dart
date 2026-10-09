class AppConstants {
  AppConstants._();

  // Gameplay
  static const int minQuestionsPerLevel = 5;
  static const int maxQuestionsPerLevel = 8;
  static const int hintDelaySeconds = 8;
  static const int minChildAge = 3;
  static const int maxChildAge = 6;
  static const int maxChildProfiles = 4;

  // Stars thresholds (accuracy %)
  static const double threeStarThreshold = 0.90;
  static const double twoStarThreshold = 0.70;

  // World unlock: prerequisite world must reach this % completion
  static const double worldUnlockThreshold = 0.60;

  // Adaptive difficulty: lower after this many consecutive under-threshold levels
  static const int adaptiveConsecutiveFailures = 2;
  static const double adaptiveAccuracyThreshold = 0.70;

  // Time limit defaults
  static const int defaultTimeLimitMinutes = 30;
  static const int minTimeLimitMinutes = 5;
  static const int maxTimeLimitMinutes = 60;

  // Streak: consecutive days minimum
  static const int minStreakDays = 2;

  // Parent PIN length
  static const int parentPinLength = 4;

  // Recent activity feed size
  static const int activityFeedSize = 10;

  // Hive box names
  static const String parentBoxName = 'parent_accounts';
  static const String childBoxName = 'child_profiles';
  static const String progressBoxName = 'progress';
  static const String sessionsBoxName = 'sessions';
  static const String settingsBoxName = 'settings';
}
