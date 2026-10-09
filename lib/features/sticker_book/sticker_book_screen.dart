import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/data/repositories/content_repository.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';
import 'package:mathmunch/features/sticker_book/widgets/sticker_item.dart';

/// SCR-07 — Sticker collection browser. FR-29 to FR-31.
class StickerBookScreen extends ConsumerWidget {
  const StickerBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentRepositoryProvider);
    final child = ref.watch(activeChildProvider);
    final progress = ref.watch(progressRepositoryProvider);
    final worlds = content.worlds;

    final levelStars = child != null
        ? progress.levelStarsForChild(child.id)
        : <String, int>{};

    // A sticker group is unlocked when the child has completed at least
    // one level in that world.
    final earnedWorldIds = worlds
        .where((w) => w.levels.any((l) => (levelStars[l.id] ?? 0) > 0))
        .map((w) => w.id)
        .toSet();

    final allStickers = content.stickers;
    final earnedCount =
        allStickers.where((s) => earnedWorldIds.contains(s.worldId)).length;
    final totalCount = allStickers.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Sticker Book')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // FR-31 — Total collection count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$earnedCount of $totalCount stickers collected',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, duration: 400.ms),
          ),

          // FR-29 — Stickers grouped by world.
          // Uses ListView children instead of SliverMainAxisGroup for
          // compatibility with Flutter < 3.12.
          for (final world in worlds) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                world.name,
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(delay: 100.ms, duration: 350.ms).slideX(
                    begin: -0.1,
                    end: 0,
                    delay: 100.ms,
                    duration: 350.ms,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: content.stickersForWorld(world.id).asMap().entries.map((e) {
                  final i = e.key;
                  final s = e.value;
                  final isEarned = earnedWorldIds.contains(s.worldId);
                  return StickerItem(sticker: s, isEarned: isEarned)
                      .animate()
                      .fadeIn(delay: (i * 50).ms, duration: 250.ms)
                      .scaleXY(
                        begin: 0.6,
                        end: 1.0,
                        delay: (i * 50).ms,
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
