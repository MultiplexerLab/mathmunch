import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/data/models/level.dart';
import 'package:mathmunch/shared/widgets/star_rating.dart';

/// FR-12, FR-13, FR-14 — Level card with completion tick, star rating, highlight, lock.
class LevelCard extends StatelessWidget {
  final Level level;
  final int stars; // 0–3
  final bool isUnlocked;
  final bool isCurrent;

  const LevelCard({
    super.key,
    required this.level,
    required this.stars,
    required this.isUnlocked,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final completed = stars > 0;

    return GestureDetector(
      onTap: isUnlocked
          ? () => context.push(
                AppRoutes.gameplay.replaceFirst(':levelId', level.id),
              )
          : null,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isCurrent
              ? AppColors.secondary.withValues(alpha: 0.15)
              : AppColors.surface,
          border: Border.all(
            color: isCurrent
                ? AppColors.secondary
                : isUnlocked
                    ? Colors.transparent
                    : AppColors.locked,
            width: isCurrent ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Level number / status icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
              ),
              alignment: Alignment.center,
              child: isUnlocked
                  ? completed
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.correct, size: 28)
                      : Text(
                          '${level.sortOrder + 1}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        )
                  : const Icon(Icons.lock_rounded,
                      color: AppColors.locked, size: 24),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${level.questions.length} questions',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (completed) StarRating(stars: stars, size: 22),
            if (!completed && isCurrent)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Play',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(end: 1.08, duration: 700.ms, curve: Curves.easeInOut),
          ],
        ),
      ),
    );
  }
}
