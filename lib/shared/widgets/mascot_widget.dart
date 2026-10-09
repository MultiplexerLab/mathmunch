import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mathmunch/core/constants/app_colors.dart';

enum MascotMood { idle, happy, thinking, hint }

class MascotWidget extends StatelessWidget {
  final MascotMood mood;
  final String? speechText;
  final double size;

  const MascotWidget({
    super.key,
    this.mood = MascotMood.idle,
    this.speechText,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Placeholder mascot — replace with actual Munch asset
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _emoji,
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
        )
            .animate(
              key: ValueKey(mood),
              onPlay: (c) {
                if (mood == MascotMood.idle ||
                    mood == MascotMood.thinking ||
                    mood == MascotMood.hint) {
                  c.repeat(reverse: true);
                }
              },
            )
            .scaleXY(
              begin: 1.0,
              end: switch (mood) {
                MascotMood.idle => 1.06,
                MascotMood.happy => 1.15,
                MascotMood.thinking => 1.03,
                MascotMood.hint => 1.08,
              },
              duration: switch (mood) {
                MascotMood.idle => 900.ms,
                MascotMood.happy => 300.ms,
                MascotMood.thinking => 700.ms,
                MascotMood.hint => 500.ms,
              },
              curve: switch (mood) {
                MascotMood.idle || MascotMood.thinking => Curves.easeInOut,
                _ => Curves.elasticOut,
              },
            ),
        if (speechText != null) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Text(
              speechText!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0),
        ],
      ],
    );
  }

  String get _emoji => switch (mood) {
        MascotMood.idle => '😸',
        MascotMood.happy => '🎉',
        MascotMood.thinking => '🤔',
        MascotMood.hint => '💡',
      };
}
