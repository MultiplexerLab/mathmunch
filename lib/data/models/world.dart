import 'package:mathmunch/data/models/level.dart';

// World is seed content served from ContentRepository — not stored in Hive.
class World {
  final String id;
  final String name;
  final String description;
  final String topic;
  final String iconAsset;
  final String backgroundAsset;
  final int colorValue;
  final List<Level> levels;
  final String? prerequisiteWorldId;
  final int sortOrder;

  const World({
    required this.id,
    required this.name,
    required this.description,
    required this.topic,
    required this.iconAsset,
    required this.backgroundAsset,
    required this.colorValue,
    required this.levels,
    this.prerequisiteWorldId,
    required this.sortOrder,
  });

  double completionPercent(Map<String, int> levelStars) {
    if (levels.isEmpty) return 0;
    final completed = levels.where((l) => (levelStars[l.id] ?? 0) > 0).length;
    return completed / levels.length;
  }

  bool isUnlocked(Map<String, double> worldCompletion) {
    if (prerequisiteWorldId == null) return true;
    return (worldCompletion[prerequisiteWorldId] ?? 0) >= 0.60;
  }
}
