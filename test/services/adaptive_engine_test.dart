import 'package:flutter_test/flutter_test.dart';
import 'package:mathmunch/data/models/session_result.dart';
import 'package:mathmunch/data/repositories/progress_repository.dart';
import 'package:mathmunch/shared/services/adaptive_engine.dart';

// Fake that overrides only the method AdaptiveEngine actually calls,
// bypassing Hive entirely.
class _FakeProgressRepository extends ProgressRepository {
  final int _lowCount;
  _FakeProgressRepository(this._lowCount);

  @override
  int consecutiveLowAccuracy(String childId, String topic) => _lowCount;

  // Unused by AdaptiveEngine — safe to leave unimplemented.
  @override
  int getStars(String childId, String levelId) => 0;

  @override
  List<SessionResult> recentSessions(String childId, {int limit = 10}) => [];

  @override
  List<SessionResult> recentSessionsForTopic(
    String childId,
    String topic, {
    int limit = 5,
  }) =>
      [];
}

void main() {
  group('AdaptiveEngine.shouldLowerDifficulty', () {
    test('returns false when consecutive low-accuracy count is 0', () {
      final engine = AdaptiveEngine(_FakeProgressRepository(0));
      expect(engine.shouldLowerDifficulty('child1', 'counting'), false);
    });

    test('returns false when consecutive low-accuracy count is 1', () {
      final engine = AdaptiveEngine(_FakeProgressRepository(1));
      expect(engine.shouldLowerDifficulty('child1', 'counting'), false);
    });

    test('returns true when consecutive low-accuracy count equals threshold (2)', () {
      final engine = AdaptiveEngine(_FakeProgressRepository(2));
      expect(engine.shouldLowerDifficulty('child1', 'counting'), true);
    });

    test('returns true when consecutive low-accuracy count exceeds threshold', () {
      final engine = AdaptiveEngine(_FakeProgressRepository(5));
      expect(engine.shouldLowerDifficulty('child1', 'addition'), true);
    });
  });

  group('AdaptiveEngine.suggestedDifficulty', () {
    test('returns currentDifficulty when should not lower', () {
      final engine = AdaptiveEngine(_FakeProgressRepository(0));
      expect(engine.suggestedDifficulty('child1', 'counting', 2), 2);
    });

    test('returns currentDifficulty - 1 when should lower', () {
      final engine = AdaptiveEngine(_FakeProgressRepository(2));
      expect(engine.suggestedDifficulty('child1', 'counting', 3), 2);
    });

    test('clamps to minimum 1 when difficulty is already 1', () {
      final engine = AdaptiveEngine(_FakeProgressRepository(2));
      expect(engine.suggestedDifficulty('child1', 'counting', 1), 1);
    });

    test('clamps to minimum 1 when difficulty is 2 and should lower', () {
      final engine = AdaptiveEngine(_FakeProgressRepository(2));
      expect(engine.suggestedDifficulty('child1', 'counting', 2), 1);
    });

    test('does not lower below 1 even with extremely low count', () {
      final engine = AdaptiveEngine(_FakeProgressRepository(99));
      expect(engine.suggestedDifficulty('child1', 'counting', 1), 1);
    });

    test('topic and childId are forwarded to ProgressRepository', () {
      // Verifies the fake receives the correct arguments.
      var capturedChildId = '';
      var capturedTopic = '';

      final fake = _CapturingFakeProgressRepository(
        lowCount: 0,
        onCall: (c, t) {
          capturedChildId = c;
          capturedTopic = t;
        },
      );
      final engine = AdaptiveEngine(fake);
      engine.suggestedDifficulty('alice', 'shapes', 2);
      expect(capturedChildId, 'alice');
      expect(capturedTopic, 'shapes');
    });
  });
}

class _CapturingFakeProgressRepository extends _FakeProgressRepository {
  final void Function(String childId, String topic) onCall;

  _CapturingFakeProgressRepository({
    required int lowCount,
    required this.onCall,
  }) : super(lowCount);

  @override
  int consecutiveLowAccuracy(String childId, String topic) {
    onCall(childId, topic);
    return super.consecutiveLowAccuracy(childId, topic);
  }
}
