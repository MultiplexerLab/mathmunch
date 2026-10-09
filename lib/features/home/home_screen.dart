import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/constants/app_constants.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/features/home/providers/home_provider.dart';
import 'package:mathmunch/features/home/widgets/streak_banner.dart';
import 'package:mathmunch/features/home/widgets/world_card.dart';

/// SCR-03 — Home screen: world selection, streak, star count. FR-06 to FR-10.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    final worlds = ref.watch(homeWorldsProvider);

    if (child == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        _avatarEmoji(child.avatarId),
                        style: const TextStyle(fontSize: 28),
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 300.ms),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${child.name}! 👋',
                            style: Theme.of(context).textTheme.titleLarge,
                          ).animate().fadeIn(delay: 150.ms, duration: 350.ms).slideX(
                                begin: 0.15,
                                end: 0,
                                delay: 150.ms,
                                duration: 350.ms,
                              ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.starFilled, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${child.totalStars} stars',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ).animate().fadeIn(delay: 280.ms, duration: 350.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Streak banner (FR-09: show after ≥ 2 consecutive days)
            if (child.currentStreak >= AppConstants.minStreakDays)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: StreakBanner(streak: child.currentStreak),
                ),
              ),

            // Section title
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Choose a World',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 350.ms, duration: 350.ms),
              ),
            ),

            // World cards (FR-07, FR-08)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: WorldCard(data: worlds[i])
                        .animate()
                        .fadeIn(
                          delay: (420 + i * 100).ms,
                          duration: 400.ms,
                        )
                        .slideY(
                          begin: 0.18,
                          end: 0,
                          delay: (420 + i * 100).ms,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),
                  ),
                  childCount: worlds.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  String _avatarEmoji(String avatarId) {
    const map = {
      'avatar_cat': '🐱',
      'avatar_dog': '🐶',
      'avatar_bunny': '🐰',
      'avatar_bear': '🐻',
      'avatar_fox': '🦊',
      'avatar_penguin': '🐧',
    };
    return map[avatarId] ?? '😊';
  }
}
