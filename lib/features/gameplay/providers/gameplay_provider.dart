import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/core/constants/app_constants.dart';
import 'package:mathmunch/data/models/level.dart';
import 'package:mathmunch/data/models/question.dart';
import 'package:mathmunch/data/repositories/child_repository.dart';
import 'package:mathmunch/data/repositories/content_repository.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';
import 'package:mathmunch/features/settings/providers/settings_provider.dart';
import 'package:mathmunch/shared/services/audio_service.dart';
import 'package:mathmunch/shared/services/narration_service.dart';

enum AnswerState { unanswered, correct, incorrect }

class GameplayState {
  final Level? level;
  final List<Question> questions;
  final int currentIndex;
  final AnswerState answerState;
  final bool showHint;
  final bool isComplete;
  final int correctCount;
  final int elapsedSeconds;

  const GameplayState({
    this.level,
    this.questions = const [],
    this.currentIndex = 0,
    this.answerState = AnswerState.unanswered,
    this.showHint = false,
    this.isComplete = false,
    this.correctCount = 0,
    this.elapsedSeconds = 0,
  });

  Question? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  double get accuracy =>
      questions.isEmpty ? 0 : correctCount / questions.length;

  int get starsEarned => level?.starsFor(accuracy) ?? 0;

  GameplayState copyWith({
    Level? level,
    List<Question>? questions,
    int? currentIndex,
    AnswerState? answerState,
    bool? showHint,
    bool? isComplete,
    int? correctCount,
    int? elapsedSeconds,
  }) {
    return GameplayState(
      level: level ?? this.level,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answerState: answerState ?? this.answerState,
      showHint: showHint ?? this.showHint,
      isComplete: isComplete ?? this.isComplete,
      correctCount: correctCount ?? this.correctCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class GameplayNotifier extends FamilyNotifier<GameplayState, String> {
  Timer? _hintTimer;
  Timer? _elapsedTimer;

  @override
  GameplayState build(String levelId) {
    ref.onDispose(_cleanup);
    final content = ref.read(contentRepositoryProvider);
    final level = content.levelById(levelId);
    if (level == null) return const GameplayState();

    _startElapsedTimer();
    final questions = level.questions
        .map((q) {
          final choices = List<String>.from(q.choices)..shuffle();
          final correctAnswer = q.choices[q.correctIndex];
          return Question(
            id: q.id,
            type: q.type,
            audioPrompt: q.audioPrompt,
            visualAsset: q.visualAsset,
            displaySymbol: q.displaySymbol,
            choices: choices,
            correctIndex: choices.indexOf(correctAnswer),
            difficulty: q.difficulty,
          );
        })
        .toList()
      ..shuffle();
    return GameplayState(level: level, questions: questions);
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _resetHintTimer() {
    _hintTimer?.cancel();

    // Speak the question prompt — covers both the first question (via
    // startQuestion) and every subsequent one (via _advance).
    final question = state.currentQuestion;
    if (question != null) {
      ref.read(narrationServiceProvider).speak(question.audioPrompt);
    }

    final hintsAlwaysOn = ref.read(settingsProvider).hintsAlwaysOn;
    if (hintsAlwaysOn) {
      state = state.copyWith(showHint: true);
      return;
    }
    _hintTimer = Timer(
      const Duration(seconds: AppConstants.hintDelaySeconds),
      () {
        if (!state.isComplete) {
          state = state.copyWith(showHint: true);
          ref.read(audioServiceProvider).playHint();
          ref.read(narrationServiceProvider).speak('Hmm, look carefully!');
        }
      },
    );
  }

  void startQuestion() {
    state = state.copyWith(
      answerState: AnswerState.unanswered,
      showHint: false,
    );
    _resetHintTimer();
  }

  Future<void> submitAnswer(int choiceIndex) async {
    if (state.answerState != AnswerState.unanswered) return;
    _hintTimer?.cancel();

    final question = state.currentQuestion!;
    final isCorrect = choiceIndex == question.correctIndex;
    final audio = ref.read(audioServiceProvider);

    state = state.copyWith(
      answerState: isCorrect ? AnswerState.correct : AnswerState.incorrect,
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
      showHint: false,
    );

    final narration = ref.read(narrationServiceProvider);
    if (isCorrect) {
      audio.playCorrect();
      narration.speak('Amazing! Well done!');
    } else {
      audio.playIncorrect();
      narration.speak('Oops! Try again!');
    }

    await Future.delayed(const Duration(milliseconds: 1200));
    _advance();
  }

  void _advance() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      _complete();
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        answerState: AnswerState.unanswered,
        showHint: false,
      );
      _resetHintTimer();
    }
  }

  Future<void> _complete() async {
    _cleanup();
    state = state.copyWith(isComplete: true);
    ref.read(audioServiceProvider).playLevelComplete();

    final child = ref.read(activeChildProvider);
    final level = state.level!;
    if (child != null) {
      final content = ref.read(contentRepositoryProvider);
      final world = content.worldForLevel(level.id);
      final progress = ref.read(progressRepositoryProvider);
      await progress.saveStars(child.id, level.id, state.starsEarned);
      await progress.saveSession(
        childId: child.id,
        levelId: level.id,
        worldId: level.worldId,
        worldName: world?.name ?? level.worldId,
        levelTitle: level.title,
        accuracy: state.accuracy,
        starsEarned: state.starsEarned,
        durationSeconds: state.elapsedSeconds,
      );
      await ref.read(childListProvider.notifier).addStars(child.id, state.starsEarned);
      await ref.read(childListProvider.notifier).recordPlay(child.id);
    }
  }

  void _cleanup() {
    _hintTimer?.cancel();
    _elapsedTimer?.cancel();
    try {
      ref.read(narrationServiceProvider).stop();
    } catch (_) {}
  }
}

final gameplayProvider =
    NotifierProviderFamily<GameplayNotifier, GameplayState, String>(
  GameplayNotifier.new,
);
