import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mathmunch/core/constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final int stars; // 0–3
  final double size;

  const StarRating({super.key, required this.stars, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(
          i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
          color: i < stars ? AppColors.starFilled : AppColors.starEmpty,
          size: size,
        )
            .animate()
            .scaleXY(
              begin: 0.4,
              end: 1.0,
              delay: (i * 90).ms,
              duration: 400.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(delay: (i * 90).ms, duration: 200.ms);
      }),
    );
  }
}
