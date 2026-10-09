import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/features/parent_dashboard/providers/parent_dashboard_provider.dart';
import 'package:mathmunch/features/parent_dashboard/widgets/weekly_summary_card.dart';

/// SCR-09 — Parent dashboard: weekly summary, multi-child. FR-35 to FR-39.
class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(weeklySummaryProvider);
    final children = ref.watch(childListProvider);
    final activeChild = ref.watch(activeChildProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Lock',
            onPressed: () {
              ref.read(parentUnlockedProvider.notifier).lock();
              context.go(AppRoutes.home);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FR-37 — Multi-child profile switcher
          if (children.length > 1) ...[
            Text('Profiles', style: Theme.of(context).textTheme.titleLarge)
                .animate()
                .fadeIn(duration: 350.ms),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: children.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final child = children[i];
                  final isActive = child.id == activeChild?.id;
                  return GestureDetector(
                    onTap: () => ref
                        .read(activeChildProvider.notifier)
                        .select(child),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isActive
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          child: Text(
                            _avatarEmoji(child.avatarId),
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          child.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (i * 80).ms, duration: 300.ms)
                      .scaleXY(
                        begin: 0.7,
                        end: 1.0,
                        delay: (i * 80).ms,
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Active child name
          if (activeChild != null)
            Text(
              "${activeChild.name}'s Week",
              style: Theme.of(context).textTheme.displayMedium,
            ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

          const SizedBox(height: 16),

          // FR-36 — Weekly summary card
          if (summary != null)
            WeeklySummaryCard(summary: summary)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 400.ms)
          else
            const Center(child: Text('No activity yet this week.')),

          const SizedBox(height: 24),

          // FR-38 — Curriculum alignment note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.secondary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_outlined,
                        color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text('Curriculum Alignment',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${activeChild?.name ?? "Your child"} is currently working on counting and early addition — aligned with EYFS (UK), Common Core Kindergarten (US), and equivalent EU frameworks.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }

  String _avatarEmoji(String id) {
    const map = {
      'avatar_cat': '🐱',
      'avatar_dog': '🐶',
      'avatar_bunny': '🐰',
      'avatar_bear': '🐻',
      'avatar_fox': '🦊',
      'avatar_penguin': '🐧',
    };
    return map[id] ?? '😊';
  }
}
