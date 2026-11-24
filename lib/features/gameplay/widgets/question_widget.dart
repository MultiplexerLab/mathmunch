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
          // Shown large and alone in its own card -- a small inline glyph
          // next to the generic category icon wasn't eye-catching enough
          // for kids to engage with, and showing displaySymbol again below
          // would just repeat the same shape a second time.
          else if (question.type == 'shapes')
            _ShapeVisual(glyph: question.displaySymbol)
          else
            Text(
              _typeEmoji(question.type),
              style: const TextStyle(fontSize: 56),
            ),
          // For counting and shapes questions the visual already IS the
          // question -- showing displaySymbol again would be redundant
          // (counting) or give the answer away a second time (shapes).
          if (question.type != 'counting' && question.type != 'shapes') ...[
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

/// Large, eye-catching presentation of a shape for "what shape is this?"
/// questions -- a plain inline glyph was too small to grab a young child's
/// attention, so the shape is shown big and alone on a bright card.
class _ShapeVisual extends StatelessWidget {
  final String glyph;

  const _ShapeVisual({required this.glyph});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 190,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Text(glyph, style: const TextStyle(fontSize: 130)),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .scaleXY(begin: 0.7, end: 1.0, duration: 400.ms, curve: Curves.elasticOut);
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
