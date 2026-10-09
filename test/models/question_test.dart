import 'package:flutter_test/flutter_test.dart';
import 'package:mathmunch/data/models/question.dart';

void main() {
  group('Question.correctAnswer', () {
    test('returns the choice at correctIndex', () {
      const q = Question(
        id: 'q1',
        type: 'counting',
        audioPrompt: 'How many?',
        displaySymbol: '3',
        choices: ['1', '2', '3', '4'],
        correctIndex: 2,
        difficulty: 1,
      );
      expect(q.correctAnswer, '3');
    });

    test('works when correct answer is the first choice', () {
      const q = Question(
        id: 'q2',
        type: 'addition',
        audioPrompt: '1 + 1 = ?',
        displaySymbol: '1 + 1',
        choices: ['2', '3', '4', '5'],
        correctIndex: 0,
        difficulty: 1,
      );
      expect(q.correctAnswer, '2');
    });

    test('works when correct answer is the last choice', () {
      const q = Question(
        id: 'q3',
        type: 'shapes',
        audioPrompt: 'Which is a circle?',
        displaySymbol: '?',
        choices: ['square', 'triangle', 'rectangle', 'circle'],
        correctIndex: 3,
        difficulty: 1,
      );
      expect(q.correctAnswer, 'circle');
    });

    test('correctAnswer matches choices at correctIndex', () {
      const choices = ['apple', 'banana', 'cherry'];
      const q = Question(
        id: 'q4',
        type: 'counting',
        audioPrompt: '',
        displaySymbol: '',
        choices: choices,
        correctIndex: 1,
        difficulty: 2,
      );
      expect(q.correctAnswer, choices[q.correctIndex]);
    });
  });
}
