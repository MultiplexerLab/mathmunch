import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/data/repositories/content_repository.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';
import 'package:mathmunch/features/progress/widgets/activity_feed_item.dart';
import 'package:mathmunch/features/progress/widgets/topic_progress_bar.dart';

/// SCR-08 — Per-topic progress bars and activity history. FR-32 to FR-34.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    final progress = ref.watch(progressRepositoryProvider);
    final content = ref.read(contentRepositoryProvider);

    if (child == null) return const SizedBox();

    final levelStars = progress.levelStarsForChild(child.id);
    final recentSessions = progress.recentSessions(child.id);
    final worlds = content.worlds;

    // Topic completion: count levels completed per topic
    final topicData = <String, ({int completed, int total})>{};
    for (final world in worlds) {
      final completed =
          world.levels.where((l) => (levelStars[l.id] ?? 0) > 0).length;
      topicData[world.topic] = (
        completed: (topicData[world.topic]?.completed ?? 0) + completed,
        total: (topicData[world.topic]?.total ?? 0) + world.levels.length,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FR-32 — Per-topic progress bars
          Text('Topics', style: Theme.of(context).textTheme.titleLarge)
              .animate()
              .fadeIn(duration: 350.ms),
          const SizedBox(height: 12),
          ...topicData.entries.toList().asMap().entries.map((e) {
            final i = e.key;
            final entry = e.value;
            final data = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TopicProgressBar(
                topic: entry.key,
                completed: data.completed,
                total: data.total,
              )
                  .animate()
                  .fadeIn(delay: (i * 100).ms, duration: 400.ms)
                  .slideX(
                    begin: -0.2,
                    end: 0,
                    delay: (i * 100).ms,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),
            );
          }),

          const SizedBox(height: 24),

          // FR-33 — Recent activity feed
          Text('Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge)
              .animate()
              .fadeIn(delay: 200.ms, duration: 350.ms),
          const SizedBox(height: 12),
          if (recentSessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No sessions yet — start playing!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 300.ms),
              ),
            )
          else
            ...recentSessions.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ActivityFeedItem(session: s)
                    .animate()
                    .fadeIn(delay: (300 + i * 60).ms, duration: 350.ms)
                    .slideX(
                      begin: 0.2,
                      end: 0,
                      delay: (300 + i * 60).ms,
                      duration: 350.ms,
                      curve: Curves.easeOut,
                    ),
              );
            }),
        ],
      ),
    );
  }
}
