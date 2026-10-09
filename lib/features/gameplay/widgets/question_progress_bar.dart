import 'package:flutter/material.dart';
import 'package:mathmunch/core/constants/app_colors.dart';

/// FR-21 — Progress indicator showing current question position.
class QuestionProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const QuestionProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question $current of $total',
                style: Theme.of(context).textTheme.bodyMedium),
            Text('${(current / total * 100).toInt()}%',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: current / total),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder: (context, value, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primary,
              minHeight: 10,
            ),
          ),
        ),
      ],
    );
  }
}
