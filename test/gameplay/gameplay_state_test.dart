import 'package:flutter_test/flutter_test.dart';
import 'package:mathmunch/data/models/level.dart';
import 'package:mathmunch/data/models/question.dart';
import 'package:mathmunch/features/gameplay/providers/gameplay_provider.dart';

const _q1 = Question(
  id: 'q1',
  type: 'counting',
  audioPrompt: '',
  displaySymbol: '1',
  choices: ['1', '2', '3'],
  correctIndex: 0,
  difficulty: 1,
);

const _q2 = Question(
  id: 'q2',
  type: 'counting',
  audioPrompt: '',
  displaySymbol: '2',
  choices: ['1', '2', '3'],
  correctIndex: 1,
  difficulty: 1,
);

const _level = Level(
  id: 'l1',
  worldId: 'w1',
  title: 'Test',
  questions: [_q1, _q2],
  difficulty: 1,
  sortOrder: 0,
);

void main() {
  group('GameplayState.accuracy', () {
    test('returns 0 when there are no questions', () {
      const state = GameplayState();
      expect(state.accuracy, 0.0);
    });

    test('returns 0 when no correct answers', () {
      const state = GameplayState(
        questions: [_q1, _q2],
        correctCount: 0,
      );
      expect(state.accuracy, 0.0);
    });

    test('returns 0.5 for 1 correct out of 2', () {
      const state = GameplayState(
        questions: [_q1, _q2],
        correctCount: 1,
      );
      expect(state.accuracy, 0.5);
    });

    test('returns 1.0 for all correct', () {
      const state = GameplayState(
        questions: [_q1, _q2],
        correctCount: 2,
      );
      expect(state.accuracy, 1.0);
    });
  });

  group('GameplayState.starsEarned', () {
    test('returns 0 when level is null', () {
      const state = GameplayState(questions: [_q1, _q2], correctCount: 2);
      expect(state.starsEarned, 0);
    });

    test('returns 3 stars for 100% accuracy', () {
      const state = GameplayState(
        level: _level,
        questions: [_q1, _q2],
        correctCount: 2,
      );
      expect(state.starsEarned, 3);
    });

    test('returns 1 star for 50% accuracy (below 70% threshold)', () {
      const state = GameplayState(
        level: _level,
        questions: [_q1, _q2],
        correctCount: 1,
      );
      expect(state.starsEarned, 1);
    });

    test('returns 1 star for 0% accuracy', () {
      const state = GameplayState(
        level: _level,
        questions: [_q1, _q2],
        correctCount: 0,
      );
      expect(state.starsEarned, 1);
    });
  });

  group('GameplayState.currentQuestion', () {
    test('returns null when questions list is empty', () {
      const state = GameplayState();
      expect(state.currentQuestion, isNull);
    });

    test('returns first question at index 0', () {
      const state = GameplayState(
        questions: [_q1, _q2],
        currentIndex: 0,
      );
      expect(state.currentQuestion, _q1);
    });

    test('returns second question at index 1', () {
      const state = GameplayState(
        questions: [_q1, _q2],
        currentIndex: 1,
      );
      expect(state.currentQuestion, _q2);
    });

    test('returns null when index is out of bounds', () {
      const state = GameplayState(
        questions: [_q1, _q2],
        currentIndex: 5,
      );
      expect(state.currentQuestion, isNull);
    });
  });

  group('GameplayState.copyWith', () {
    test('preserves unchanged fields', () {
      const original = GameplayState(
        level: _level,
        questions: [_q1],
        correctCount: 1,
        isComplete: false,
      );
      final updated = original.copyWith(correctCount: 2);
      expect(updated.level, original.level);
      expect(updated.questions, original.questions);
      expect(updated.isComplete, original.isComplete);
      expect(updated.correctCount, 2);
    });

    test('isComplete can be set to true', () {
      const state = GameplayState();
      final completed = state.copyWith(isComplete: true);
      expect(completed.isComplete, true);
    });
  });
}
