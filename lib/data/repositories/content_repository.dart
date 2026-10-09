import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/core/constants/app_colors.dart';
import 'package:mathmunch/data/models/level.dart';
import 'package:mathmunch/data/models/question.dart';
import 'package:mathmunch/data/models/sticker.dart';
import 'package:mathmunch/data/models/world.dart';

/// Seed content — in production this would be served from a CMS.
/// Adding a new world requires no app update (SRS §4.6).
class ContentRepository {
  static final List<World> _worlds = _buildWorlds();
  static final List<Sticker> _stickers = _buildStickers();

  List<World> get worlds => List.unmodifiable(_worlds);
  List<Sticker> get stickers => List.unmodifiable(_stickers);

  World worldById(String id) =>
      _worlds.firstWhere((w) => w.id == id, orElse: () => _worlds.first);

  Level? levelById(String id) {
    for (final world in _worlds) {
      for (final level in world.levels) {
        if (level.id == id) return level;
      }
    }
    return null;
  }

  // Returns the world that contains [levelId], or null.
  World? worldForLevel(String levelId) {
    for (final world in _worlds) {
      if (world.levels.any((l) => l.id == levelId)) return world;
    }
    return null;
  }

  List<Sticker> stickersForWorld(String worldId) =>
      _stickers.where((s) => s.worldId == worldId).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  // ---------------------------------------------------------------------------
  // World definitions
  // ---------------------------------------------------------------------------

  static List<World> _buildWorlds() {
    return [
      World(
        id: 'world_apple_farm',
        name: 'Apple Farm',
        description: 'Count apples, animals, and more!',
        topic: 'counting',
        iconAsset: 'assets/images/worlds/apple_farm_icon.png',
        backgroundAsset: 'assets/images/worlds/apple_farm_bg.png',
        colorValue: AppColors.worldAppleFarm.toARGB32(),
        sortOrder: 0,
        levels: [
          Level(
            id: 'af_level_1',
            worldId: 'world_apple_farm',
            title: 'Count to 3',
            difficulty: 1,
            sortOrder: 0,
            questions: _countingQuestions(max: 3, difficulty: 1),
          ),
          Level(
            id: 'af_level_2',
            worldId: 'world_apple_farm',
            title: 'Count to 5',
            difficulty: 1,
            sortOrder: 1,
            questions: _countingQuestions(max: 5, difficulty: 1),
          ),
          Level(
            id: 'af_level_3',
            worldId: 'world_apple_farm',
            title: 'Count to 10',
            difficulty: 2,
            sortOrder: 2,
            questions: _countingQuestions(max: 10, difficulty: 2),
          ),
          Level(
            id: 'af_level_4',
            worldId: 'world_apple_farm',
            title: 'Which is more?',
            difficulty: 2,
            sortOrder: 3,
            questions: _countingCompareQuestions(difficulty: 2),
          ),
        ],
      ),

      World(
        id: 'world_ocean',
        name: 'Ocean Count',
        description: 'Add fish, shells, and treasure!',
        topic: 'addition',
        iconAsset: 'assets/images/worlds/ocean_icon.png',
        backgroundAsset: 'assets/images/worlds/ocean_bg.png',
        colorValue: AppColors.worldOceanCount.toARGB32(),
        sortOrder: 1,
        prerequisiteWorldId: 'world_apple_farm',
        levels: [
          Level(
            id: 'oc_level_1',
            worldId: 'world_ocean',
            title: 'Add to 5',
            difficulty: 1,
            sortOrder: 0,
            questions: _additionQuestions(maxSum: 5, difficulty: 1),
          ),
          Level(
            id: 'oc_level_2',
            worldId: 'world_ocean',
            title: 'Add to 10',
            difficulty: 2,
            sortOrder: 1,
            questions: _additionQuestions(maxSum: 10, difficulty: 2),
          ),
          Level(
            id: 'oc_level_3',
            worldId: 'world_ocean',
            title: 'Missing number',
            difficulty: 2,
            sortOrder: 2,
            questions: _missingNumberQuestions(difficulty: 2),
          ),
        ],
      ),

      World(
        id: 'world_space',
        name: 'Space Shapes',
        description: 'Find circles, squares, and triangles in space!',
        topic: 'shapes',
        iconAsset: 'assets/images/worlds/space_icon.png',
        backgroundAsset: 'assets/images/worlds/space_bg.png',
        colorValue: AppColors.worldSpaceShapes.toARGB32(),
        sortOrder: 2,
        prerequisiteWorldId: 'world_apple_farm',
        levels: [
          Level(
            id: 'sp_level_1',
            worldId: 'world_space',
            title: 'Basic Shapes',
            difficulty: 1,
            sortOrder: 0,
            questions: _shapeQuestions(difficulty: 1),
          ),
          Level(
            id: 'sp_level_2',
            worldId: 'world_space',
            title: 'Shapes Around Us',
            difficulty: 2,
            sortOrder: 1,
            questions: _shapeQuestions(difficulty: 2),
          ),
        ],
      ),

      World(
        id: 'world_jungle',
        name: 'Jungle Math',
        description: 'Take away bananas and bugs in the jungle!',
        topic: 'subtraction',
        iconAsset: 'assets/images/worlds/jungle_icon.png',
        backgroundAsset: 'assets/images/worlds/jungle_bg.png',
        colorValue: AppColors.worldJungleMath.toARGB32(),
        sortOrder: 3,
        prerequisiteWorldId: 'world_ocean',
        levels: [
          Level(
            id: 'jm_level_1',
            worldId: 'world_jungle',
            title: 'Take away to 5',
            difficulty: 1,
            sortOrder: 0,
            questions: _subtractionQuestions(maxStart: 5, difficulty: 1),
          ),
          Level(
            id: 'jm_level_2',
            worldId: 'world_jungle',
            title: 'Take away to 10',
            difficulty: 2,
            sortOrder: 1,
            questions: _subtractionQuestions(maxStart: 10, difficulty: 2),
          ),
        ],
      ),

      World(
        id: 'world_star_factory',
        name: 'Star Factory',
        description: 'Multiply stars and rockets!',
        topic: 'multiplication',
        iconAsset: 'assets/images/worlds/star_factory_icon.png',
        backgroundAsset: 'assets/images/worlds/star_factory_bg.png',
        colorValue: AppColors.worldStarFactory.toARGB32(),
        sortOrder: 4,
        prerequisiteWorldId: 'world_jungle',
        levels: [
          Level(
            id: 'sf_level_1',
            worldId: 'world_star_factory',
            title: 'Multiply by 2',
            difficulty: 2,
            sortOrder: 0,
            questions: _multiplicationQuestions(multiplier: 2, difficulty: 2),
          ),
          Level(
            id: 'sf_level_2',
            worldId: 'world_star_factory',
            title: 'Multiply by 3',
            difficulty: 2,
            sortOrder: 1,
            questions: _multiplicationQuestions(multiplier: 3, difficulty: 2),
          ),
          Level(
            id: 'sf_level_3',
            worldId: 'world_star_factory',
            title: 'Multiply by 5',
            difficulty: 3,
            sortOrder: 2,
            questions: _multiplicationQuestions(multiplier: 5, difficulty: 3),
          ),
        ],
      ),

      World(
        id: 'world_treasure_island',
        name: 'Treasure Island',
        description: 'Share treasure equally with friends!',
        topic: 'division',
        iconAsset: 'assets/images/worlds/treasure_island_icon.png',
        backgroundAsset: 'assets/images/worlds/treasure_island_bg.png',
        colorValue: AppColors.worldTreasureIsland.toARGB32(),
        sortOrder: 5,
        prerequisiteWorldId: 'world_star_factory',
        levels: [
          Level(
            id: 'ti_level_1',
            worldId: 'world_treasure_island',
            title: 'Share by 2',
            difficulty: 2,
            sortOrder: 0,
            questions: _divisionQuestions(divisor: 2, difficulty: 2),
          ),
          Level(
            id: 'ti_level_2',
            worldId: 'world_treasure_island',
            title: 'Share by 3',
            difficulty: 3,
            sortOrder: 1,
            questions: _divisionQuestions(divisor: 3, difficulty: 3),
          ),
          Level(
            id: 'ti_level_3',
            worldId: 'world_treasure_island',
            title: 'Share by 5',
            difficulty: 3,
            sortOrder: 2,
            questions: _divisionQuestions(divisor: 5, difficulty: 3),
          ),
        ],
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Question builders — choices are in a FIXED order; correctIndex is stable.
  // The gameplay layer may shuffle choices at display time if needed.
  // ---------------------------------------------------------------------------

  static List<Question> _countingQuestions({
    required int max,
    required int difficulty,
  }) {
    return List.generate(6, (i) {
      final n = (i % max) + 1;
      final below = n - 1 < 1 ? n + 2 : n - 1;
      final above = n + 1 > max ? (n - 2 < 1 ? n + 2 : n - 2) : n + 1;
      // Choices: [wrong, CORRECT, wrong] — correctIndex is always 1.
      return Question(
        id: 'cnt_${max}_$i',
        type: 'counting',
        audioPrompt: 'How many apples do you see?',
        displaySymbol: '$n',
        choices: ['$below', '$n', '$above'],
        correctIndex: 1,
        difficulty: difficulty,
      );
    });
  }

  static List<Question> _countingCompareQuestions({required int difficulty}) {
    return List.generate(5, (i) {
      final a = i + 2;
      final b = a + 2;
      // Choices: [smaller, LARGER] — correctIndex is always 1.
      return Question(
        id: 'cmp_$i',
        type: 'counting',
        audioPrompt: 'Which group has more?',
        displaySymbol: '$a  vs  $b',
        choices: ['$a', '$b'],
        correctIndex: 1,
        difficulty: difficulty,
      );
    });
  }

  static List<Question> _additionQuestions({
    required int maxSum,
    required int difficulty,
  }) {
    // Build all unique pairs (a, b) where a >= 1, b >= 1, a + b <= maxSum
    final pairs = <(int, int)>[];
    for (int a = 1; a < maxSum; a++) {
      for (int b = 1; a + b <= maxSum; b++) {
        pairs.add((a, b));
      }
    }
    // Sample 6 evenly across the full range for variety
    final take = pairs.length.clamp(1, 6);
    final indices = List.generate(take, (i) => (i * pairs.length / take).floor());
    return indices.asMap().entries.map((entry) {
      final qi = entry.key;
      final (a, b) = pairs[entry.value];
      final sum = a + b;
      final wrong1 = sum > 1 ? sum - 1 : sum + 2;
      return Question(
        id: 'add_${maxSum}_$qi',
        type: 'addition',
        audioPrompt: 'What is $a plus $b?',
        displaySymbol: '$a + $b = ?',
        choices: ['$wrong1', '$sum', '${sum + 1}'],
        correctIndex: 1,
        difficulty: difficulty,
      );
    }).toList();
  }

  static List<Question> _missingNumberQuestions({required int difficulty}) {
    return List.generate(5, (i) {
      final a = i + 1;
      const missing = 3;
      final sum = a + missing;
      // Choices: [wrong, CORRECT, wrong] — correctIndex is always 1.
      return Question(
        id: 'miss_$i',
        type: 'addition',
        audioPrompt: '$a plus what equals $sum?',
        displaySymbol: '$a + ? = $sum',
        choices: ['${missing - 1}', '$missing', '${missing + 1}'],
        correctIndex: 1,
        difficulty: difficulty,
      );
    });
  }

  static List<Question> _multiplicationQuestions({
    required int multiplier,
    required int difficulty,
  }) {
    return List.generate(6, (i) {
      final other = i + 1;
      final product = multiplier * other;
      final wrong1 = product - multiplier;
      final wrong2 = product + multiplier;
      return Question(
        id: 'mul_${multiplier}_$i',
        type: 'multiplication',
        audioPrompt: 'What is $multiplier times $other?',
        displaySymbol: '$multiplier × $other = ?',
        choices: ['$wrong1', '$product', '$wrong2'],
        correctIndex: 1,
        difficulty: difficulty,
      );
    });
  }

  static List<Question> _divisionQuestions({
    required int divisor,
    required int difficulty,
  }) {
    return List.generate(6, (i) {
      final quotient = i + 1;
      final dividend = divisor * quotient;
      final wrong1 = (quotient - 1).clamp(0, 99);
      final wrong2 = quotient + 1;
      return Question(
        id: 'div_${divisor}_$i',
        type: 'division',
        audioPrompt: 'What is $dividend shared between $divisor?',
        displaySymbol: '$dividend ÷ $divisor = ?',
        choices: ['$wrong1', '$quotient', '$wrong2'],
        correctIndex: 1,
        difficulty: difficulty,
      );
    });
  }

  static List<Question> _shapeQuestions({required int difficulty}) {
    // Each question shows one shape; choices are 3 options.
    const shapes = [
      ('circle', 'Circle', '⭕'),
      ('square', 'Square', '🟥'),
      ('triangle', 'Triangle', '🔺'),
      ('rectangle', 'Rectangle', '▬'),
      ('star', 'Star', '⭐'),
    ];
    return List.generate(shapes.length, (i) {
      final correct = shapes[i];
      // Pick two wrong answers (previous and next, wrapping).
      final wrong1 = shapes[(i + 1) % shapes.length].$2;
      final wrong2 = shapes[(i + 2) % shapes.length].$2;
      // Choices: [CORRECT, wrong, wrong] — correctIndex is always 0.
      return Question(
        id: 'shape_${correct.$1}_$difficulty',
        type: 'shapes',
        audioPrompt: 'What shape is this?',
        displaySymbol: correct.$3,
        choices: [correct.$2, wrong1, wrong2],
        correctIndex: 0,
        difficulty: difficulty,
      );
    });
  }

  static List<Question> _subtractionQuestions({
    required int maxStart,
    required int difficulty,
  }) {
    // Build all unique pairs (a, b) where a >= 2, b >= 1, b < a, a <= maxStart
    final pairs = <(int, int)>[];
    for (int a = 2; a <= maxStart; a++) {
      for (int b = 1; b < a; b++) {
        pairs.add((a, b));
      }
    }
    final take = pairs.length.clamp(1, 6);
    final indices = List.generate(take, (i) => (i * pairs.length / take).floor());
    return indices.asMap().entries.map((entry) {
      final qi = entry.key;
      final (a, b) = pairs[entry.value];
      final result = a - b;
      final wrong1 = result > 0 ? result - 1 : result + 2;
      return Question(
        id: 'sub_${maxStart}_$qi',
        type: 'subtraction',
        audioPrompt: 'What is $a take away $b?',
        displaySymbol: '$a - $b = ?',
        choices: ['$wrong1', '$result', '${result + 1}'],
        correctIndex: 1,
        difficulty: difficulty,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Sticker definitions
  // ---------------------------------------------------------------------------

  static List<Sticker> _buildStickers() {
    final stickers = <Sticker>[];
    const worldStickers = {
      'world_apple_farm': ['Apple', 'Cow', 'Tractor', 'Sunflower', 'Barn', 'Chicken', 'Hay Bale', 'Scarecrow'],
      'world_ocean': ['Fish', 'Crab', 'Starfish', 'Shell', 'Whale', 'Seahorse', 'Octopus', 'Pearl'],
      'world_space': ['Rocket', 'Star', 'Planet', 'Astronaut', 'Moon', 'Alien', 'UFO', 'Comet'],
      'world_jungle': ['Monkey', 'Tiger', 'Parrot', 'Frog', 'Snake', 'Elephant', 'Lion', 'Butterfly'],
      'world_star_factory': ['Star', 'Rocket', 'Robot', 'Gear', 'Diamond', 'Crystal', 'Lightning', 'Crown'],
      'world_treasure_island': ['Chest', 'Coin', 'Map', 'Compass', 'Anchor', 'Ship', 'Parrot', 'Gem'],
    };

    int sort = 0;
    for (final entry in worldStickers.entries) {
      for (final name in entry.value) {
        final id =
            '${entry.key}_sticker_${name.toLowerCase().replaceAll(' ', '_')}';
        stickers.add(Sticker(
          id: id,
          worldId: entry.key,
          name: name,
          imagePath: 'assets/images/stickers/$id.png',
          soundPath: 'assets/audio/sfx/sticker_pop.mp3',
          sortOrder: sort++,
        ));
      }
    }
    return stickers;
  }
}

final contentRepositoryProvider = Provider<ContentRepository>(
  (_) => ContentRepository(),
);

final worldsProvider = Provider<List<World>>((ref) {
  return ref.watch(contentRepositoryProvider).worlds;
});
