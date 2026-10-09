import 'package:flutter_test/flutter_test.dart';
import 'package:mathmunch/data/models/level.dart';

void main() {
  group('Level star thresholds', () {
    const level = Level(
      id: 'test',
      worldId: 'w1',
      title: 'Test Level',
      questions: [],
      difficulty: 1,
      sortOrder: 0,
    );

    test('3 stars at ≥ 90% accuracy', () {
      expect(level.starsFor(0.90), 3);
      expect(level.starsFor(1.0), 3);
    });

    test('2 stars at ≥ 70% accuracy', () {
      expect(level.starsFor(0.70), 2);
      expect(level.starsFor(0.89), 2);
    });

    test('1 star below 70% accuracy', () {
      expect(level.starsFor(0.0), 1);
      expect(level.starsFor(0.69), 1);
    });

    test('exactly 90% accuracy gives 3 stars', () {
      expect(level.starsFor(0.90), 3);
    });

    test('exactly 70% accuracy gives 2 stars', () {
      expect(level.starsFor(0.70), 2);
    });

    test('accuracy just below 90% gives 2 stars', () {
      expect(level.starsFor(0.899), 2);
    });

    test('accuracy just below 70% gives 1 star', () {
      expect(level.starsFor(0.699), 1);
    });
  });
}
