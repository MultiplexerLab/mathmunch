import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/features/gameplay/providers/gameplay_provider.dart';

/// FR-17, FR-18, FR-19 — Large answer tap target with correct/incorrect feedback.
class AnswerChoiceButton extends StatelessWidget {
  final String label;
  final AnswerState? state; // null = unanswered
  final VoidCallback? onTap;

  const AnswerChoiceButton({
    super.key,
    required this.label,
    this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = switch (state) {
      AnswerState.correct => AppColors.correct,
      AnswerState.incorrect => AppColors.incorrect,
      _ => AppColors.surface,
    };
    final Color border = switch (state) {
      AnswerState.correct => AppColors.correct,
      AnswerState.incorrect => AppColors.incorrect,
      _ => AppColors.secondary,
    };

    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        // FR-17 — minimum 60×60 dp tap target
        constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: border.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: state != null ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (state == AnswerState.correct) {
      button = button.animate().shake(hz: 2, rotation: 0.02).scaleXY(end: 1.06, duration: 200.ms);
    } else if (state == AnswerState.incorrect) {
      button = button.animate().shake(hz: 4, rotation: 0.04);
    }

    return button;
  }
}
