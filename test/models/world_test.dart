import 'package:flutter_test/flutter_test.dart';
import 'package:mathmunch/data/models/level.dart';
import 'package:mathmunch/data/models/world.dart';

Level _makeLevel(String id) => Level(
      id: id,
      worldId: 'w1',
      title: id,
      questions: const [],
      difficulty: 1,
      sortOrder: 0,
    );

World _makeWorld({String? prerequisiteWorldId}) => World(
      id: 'w1',
      name: 'Test World',
      description: '',
      topic: 'counting',
      iconAsset: '',
      backgroundAsset: '',
      colorValue: 0xFF000000,
      levels: [_makeLevel('l1'), _makeLevel('l2'), _makeLevel('l3')],
      prerequisiteWorldId: prerequisiteWorldId,
      sortOrder: 0,
    );

void main() {
  group('World.completionPercent', () {
    test('returns 0 when no levels have stars', () {
      final world = _makeWorld();
      expect(world.completionPercent({}), 0.0);
    });

    test('returns 0 for empty world with no stars', () {
      const emptyWorld = World(
        id: 'w0',
        name: 'Empty',
        description: '',
        topic: 'counting',
        iconAsset: '',
        backgroundAsset: '',
        colorValue: 0,
        levels: [],
        sortOrder: 0,
      );
      expect(emptyWorld.completionPercent({}), 0.0);
    });

    test('returns 1/3 when one of three levels has stars', () {
      final world = _makeWorld();
      expect(world.completionPercent({'l1': 2}), closeTo(1 / 3, 0.001));
    });

    test('returns 2/3 when two of three levels have stars', () {
      final world = _makeWorld();
      expect(
        world.completionPercent({'l1': 1, 'l2': 3}),
        closeTo(2 / 3, 0.001),
      );
    });

    test('returns 1.0 when all levels have stars', () {
      final world = _makeWorld();
      expect(
        world.completionPercent({'l1': 1, 'l2': 2, 'l3': 3}),
        1.0,
      );
    });

    test('levels with 0 stars count as incomplete', () {
      final world = _makeWorld();
      expect(world.completionPercent({'l1': 0, 'l2': 0, 'l3': 0}), 0.0);
    });

    test('ignores unrelated level ids', () {
      final world = _makeWorld();
      expect(world.completionPercent({'other_level': 3}), 0.0);
    });
  });

  group('World.isUnlocked', () {
    test('world with no prerequisite is always unlocked', () {
      final world = _makeWorld();
      expect(world.isUnlocked({}), true);
      expect(world.isUnlocked({'w2': 0.0}), true);
    });

    test('world with prerequisite at 0% is locked', () {
      final world = _makeWorld(prerequisiteWorldId: 'w0');
      expect(world.isUnlocked({'w0': 0.0}), false);
    });

    test('world with prerequisite below 60% is locked', () {
      final world = _makeWorld(prerequisiteWorldId: 'w0');
      expect(world.isUnlocked({'w0': 0.59}), false);
    });

    test('world with prerequisite at exactly 60% is unlocked', () {
      final world = _makeWorld(prerequisiteWorldId: 'w0');
      expect(world.isUnlocked({'w0': 0.60}), true);
    });

    test('world with prerequisite above 60% is unlocked', () {
      final world = _makeWorld(prerequisiteWorldId: 'w0');
      expect(world.isUnlocked({'w0': 1.0}), true);
    });

    test('missing prerequisite completion defaults to locked', () {
      final world = _makeWorld(prerequisiteWorldId: 'w0');
      expect(world.isUnlocked({}), false);
    });
  });
}
