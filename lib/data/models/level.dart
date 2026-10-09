import 'package:mathmunch/data/models/question.dart';

// Level is seed content served from ContentRepository — not stored in Hive.
class Level {
  final String id;
  final String worldId;
  final String title;
  final List<Question> questions; // 5–8 questions
  final int difficulty; // 1 = easy, 2 = medium, 3 = hard
  final int sortOrder;

  const Level({
    required this.id,
    required this.worldId,
    required this.title,
    required this.questions,
    required this.difficulty,
    required this.sortOrder,
  });

  int starsFor(double accuracy) {
    if (accuracy >= 0.90) return 3;
    if (accuracy >= 0.70) return 2;
    return 1;
  }
}
