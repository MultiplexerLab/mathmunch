import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/data/repositories/content_repository.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';
import 'package:mathmunch/features/level_select/widgets/level_card.dart';

/// SCR-04 — Level list within a World. FR-11 to FR-14.
class LevelSelectScreen extends ConsumerWidget {
  final String worldId;

  const LevelSelectScreen({super.key, required this.worldId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentRepositoryProvider);
    final world = content.worldById(worldId);
    final child = ref.watch(activeChildProvider);
    final progress = ref.watch(progressRepositoryProvider);

    final levelStars = child != null
        ? progress.levelStarsForChild(child.id)
        : <String, int>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(world.name),
        backgroundColor: Color(world.colorValue).withValues(alpha: 0.15),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: world.levels.length,
        itemBuilder: (context, i) {
          final level = world.levels[i];

          // A level is unlocked if it's the first, or the previous has ≥ 1 star
          final previousUnlocked = i == 0 ||
              (levelStars[world.levels[i - 1].id] ?? 0) > 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LevelCard(
              level: level,
              stars: levelStars[level.id] ?? 0,
              isUnlocked: previousUnlocked,
              isCurrent: previousUnlocked &&
                  (levelStars[level.id] ?? 0) == 0,
            )
                .animate()
                .fadeIn(delay: (i * 80).ms, duration: 350.ms)
                .slideX(
                  begin: 0.18,
                  end: 0,
                  delay: (i * 80).ms,
                  duration: 350.ms,
                  curve: Curves.easeOut,
                ),
          );
        },
      ),
    );
  }
}
