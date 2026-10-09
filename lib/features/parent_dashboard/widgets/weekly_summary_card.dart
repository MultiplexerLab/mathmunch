import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/features/parent_dashboard/providers/parent_dashboard_provider.dart';

/// FR-36 — Weekly summary: time, stars, streak, accuracy.
class WeeklySummaryCard extends StatelessWidget {
  final WeeklySummary summary;

  const WeeklySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
        children: [
          _Tile(
            emoji: '⏱️',
            value: '${summary.totalMinutes}m',
            label: 'Play time',
          ).animate().fadeIn(duration: 300.ms).scaleXY(begin: 0.82, end: 1.0, duration: 350.ms, curve: Curves.easeOut),
          _Tile(
            emoji: '⭐',
            value: '${summary.starsEarned}',
            label: 'Stars earned',
            color: AppColors.starFilled,
          ).animate().fadeIn(delay: 80.ms, duration: 300.ms).scaleXY(begin: 0.82, end: 1.0, delay: 80.ms, duration: 350.ms, curve: Curves.easeOut),
          _Tile(
            emoji: '🔥',
            value: '${summary.streak}d',
            label: 'Streak',
            color: AppColors.primaryLight,
          ).animate().fadeIn(delay: 160.ms, duration: 300.ms).scaleXY(begin: 0.82, end: 1.0, delay: 160.ms, duration: 350.ms, curve: Curves.easeOut),
          _Tile(
            emoji: '🎯',
            value: '${summary.accuracyPercent.toInt()}%',
            label: 'Accuracy',
            color: AppColors.correct,
          ).animate().fadeIn(delay: 240.ms, duration: 300.ms).scaleXY(begin: 0.82, end: 1.0, delay: 240.ms, duration: 350.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color? color;

  const _Tile({
    required this.emoji,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color ?? AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
