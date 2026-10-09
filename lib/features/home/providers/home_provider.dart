import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/data/models/world.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/data/repositories/content_repository.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';

class WorldCardData {
  final World world;
  final bool isUnlocked;
  final double completionPercent;
  final Map<String, int> levelStars;

  const WorldCardData({
    required this.world,
    required this.isUnlocked,
    required this.completionPercent,
    required this.levelStars,
  });
}

final homeWorldsProvider = Provider<List<WorldCardData>>((ref) {
  final worlds = ref.watch(worldsProvider);
  final child = ref.watch(activeChildProvider);
  final progress = ref.watch(progressRepositoryProvider);

  if (child == null) return [];

  final levelStarsAll = progress.levelStarsForChild(child.id);

  // Build world completion map
  final worldCompletion = <String, double>{};
  for (final w in worlds) {
    worldCompletion[w.id] = w.completionPercent(levelStarsAll);
  }

  return worlds
      .map((w) => WorldCardData(
            world: w,
            isUnlocked: w.isUnlocked(worldCompletion),
            completionPercent: worldCompletion[w.id] ?? 0,
            levelStars: {
              for (final l in w.levels)
                l.id: levelStarsAll[l.id] ?? 0,
            },
          ))
      .toList()
    ..sort((a, b) => a.world.sortOrder.compareTo(b.world.sortOrder));
});
