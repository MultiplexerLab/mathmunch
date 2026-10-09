import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/data/repositories/content_repository.dart';
import 'package:mathmunch/features/gameplay/providers/gameplay_provider.dart';
import 'package:mathmunch/shared/widgets/mascot_widget.dart';
import 'package:mathmunch/shared/widgets/star_rating.dart';

/// SCR-06 — Level completion celebration with stars and stickers. FR-24 to FR-27.
class RewardScreen extends ConsumerWidget {
  final String levelId;
  final int starsEarned;
  final List<String> newStickerIds;

  const RewardScreen({
    super.key,
    required this.levelId,
    required this.starsEarned,
    required this.newStickerIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentRepositoryProvider);
    final level = content.levelById(levelId);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              // minHeight ensures mainAxisAlignment.center has space to work;
              // scroll activates only when content is taller than the viewport.
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mascot celebrating
                  const MascotWidget(mood: MascotMood.happy, size: 100)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  Text(
                    starsEarned == 3 ? 'Perfect! 🎉' : 'Well done! 👏',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ).animate().fadeIn(delay: 200.ms),

                  if (level != null)
                    Text(
                      level.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 24),

                  // Stars (FR-25)
                  StarRating(stars: starsEarned, size: 52)
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .scale(delay: 400.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 32),

                  // New stickers (FR-27)
                  if (newStickerIds.isNotEmpty) ...[
                    Text(
                      'New stickers unlocked!',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: newStickerIds.take(4).map((id) {
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text('⭐', style: TextStyle(fontSize: 36)),
                        ).animate().scale(
                              delay: (700 + newStickerIds.indexOf(id) * 150).ms,
                              curve: Curves.elasticOut,
                            );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Actions
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('Back to Worlds 🏠'),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 12),

                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    onPressed: () {
                      ref.invalidate(gameplayProvider(levelId));
                      context.pushReplacement(
                        AppRoutes.gameplay.replaceFirst(':levelId', levelId),
                      );
                    },
                    child: const Text('Play Again'),
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
