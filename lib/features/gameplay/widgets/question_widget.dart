import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/data/models/question.dart';

/// FR-16 — Visual + numeral/symbol presentation of a question.
class QuestionWidget extends StatelessWidget {
  final Question question;

  const QuestionWidget({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (question.visualAsset != null)
            Image.asset(
              question.visualAsset!,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => question.type == 'shapes'
                  ? const SizedBox.shrink()
                  : Text(_typeEmoji(question.type),
                      style: const TextStyle(fontSize: 56)),
            )
          else if (question.type == 'counting')
            _CountingVisual(
              count: int.tryParse(question.displaySymbol) ?? 1,
              emoji: '🍎',
            )
          // Shape questions show the shape itself as displaySymbol below —
          // showing the generic category icon here too (e.g. 🔷) displays a
          // second, unrelated shape alongside the real answer and confuses
          // the "what shape is this?" question.
          else if (question.type != 'shapes')
            Text(
              _typeEmoji(question.type),
              style: const TextStyle(fontSize: 56),
            ),
          // For counting questions the visual already IS the question —
          // showing the number would give the answer away.
          if (question.type != 'counting') ...[
            const SizedBox(height: 12),
            Text(
              question.displaySymbol,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ).animate().fadeIn(duration: 250.ms).scaleXY(
                  begin: 0.88,
                  end: 1.0,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ],
      ),
    );
  }

  // 'counting' and 'shapes' never reach this -- counting uses _CountingVisual,
  // and shapes shows displaySymbol alone (the generic icon would otherwise
  // render a second, unrelated shape next to the real answer).
  String _typeEmoji(String type) {
    return switch (type) {
      'addition' => '➕',
      'subtraction' => '➖',
      'multiplication' => '✖️',
      'division' => '➗',
      _ => '❓',
    };
  }
}

class _CountingVisual extends StatelessWidget {
  final int count;
  final String emoji;

  const _CountingVisual({required this.count, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final capped = count.clamp(1, 10);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: List.generate(
        capped,
        (i) => Text(emoji, style: const TextStyle(fontSize: 48))
            .animate()
            .fadeIn(delay: (i * 55).ms, duration: 200.ms)
            .scaleXY(
              begin: 0.5,
              end: 1.0,
              delay: (i * 55).ms,
              duration: 300.ms,
              curve: Curves.elasticOut,
            ),
      ),
    );
  }
}
