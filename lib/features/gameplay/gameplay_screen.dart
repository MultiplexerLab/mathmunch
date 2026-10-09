import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/core/router/app_router.dart';
import 'package:mathmunch/features/gameplay/providers/gameplay_provider.dart';
import 'package:mathmunch/features/gameplay/widgets/answer_choice_button.dart';
import 'package:mathmunch/features/gameplay/widgets/question_progress_bar.dart';
import 'package:mathmunch/features/gameplay/widgets/question_widget.dart';
import 'package:mathmunch/shared/widgets/mascot_widget.dart';

/// SCR-05 — Gameplay: question + answer interaction. FR-15 to FR-23.
class GameplayScreen extends ConsumerStatefulWidget {
  final String levelId;

  const GameplayScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameplayProvider(widget.levelId).notifier).startQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameplayProvider(widget.levelId));

    ref.listen(gameplayProvider(widget.levelId), (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        final earnedStickers = <String>[];
        context.pushReplacement(
          AppRoutes.reward.replaceFirst(':levelId', widget.levelId),
          extra: {
            'stars': next.starsEarned,
            'stickers': earnedStickers,
          },
        );
      }
    });

    final question = state.currentQuestion;
    if (question == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(state.level?.title ?? ''),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              // FR-21 — Progress bar pinned to top
              QuestionProgressBar(
                current: state.currentIndex + 1,
                total: state.questions.length,
              ),

              // Remaining space: LayoutBuilder gives a real height constraint so
              // mainAxisAlignment.center works; SingleChildScrollView prevents
              // overflow on very small screens when the counting visual is tall.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mascot (FR-20 — hint after 8 s)
                          MascotWidget(
                            mood: state.showHint
                                ? MascotMood.hint
                                : state.answerState == AnswerState.correct
                                    ? MascotMood.happy
                                    : MascotMood.idle,
                            speechText: state.showHint
                                ? 'Hmm… look carefully! 🤔'
                                : state.answerState == AnswerState.correct
                                    ? 'Amazing! Well done! 🎉'
                                    : state.answerState == AnswerState.incorrect
                                        ? 'Oops! Try again! 💪'
                                        : null,
                            size: 80,
                          ),

                          const SizedBox(height: 20),

                          // Animate question + answers together on each new question.
                          // Keyed to currentIndex so the switcher only fires when the
                          // question actually advances, not on answer-state changes.
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.05),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              key: ValueKey(state.currentIndex),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // FR-16 — Question visual + symbol
                                QuestionWidget(question: question),

                                const SizedBox(height: 32),

                                // FR-17, FR-18, FR-19 — Answer choices
                                GridView.count(
                                  crossAxisCount:
                                      question.choices.length <= 2 ? 2 : 3,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.6,
                                  children: List.generate(
                                      question.choices.length, (i) {
                                    AnswerState? buttonState;
                                    if (state.answerState !=
                                        AnswerState.unanswered) {
                                      if (i == question.correctIndex) {
                                        buttonState = AnswerState.correct;
                                      } else if (state.answerState ==
                                          AnswerState.incorrect) {
                                        buttonState = AnswerState.incorrect;
                                      }
                                    }
                                    return AnswerChoiceButton(
                                      label: question.choices[i],
                                      state: buttonState,
                                      onTap: state.answerState ==
                                              AnswerState.unanswered
                                          ? () => ref
                                              .read(gameplayProvider(
                                                      widget.levelId)
                                                  .notifier)
                                              .submitAnswer(i)
                                          : null,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave this level?'),
        content: const Text('Your progress for this level will not be saved.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave',
                  style: TextStyle(color: AppColors.incorrect))),
        ],
      ),
    );
    if (leave == true && context.mounted) context.pop();
  }
}
