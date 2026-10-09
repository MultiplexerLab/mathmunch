import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathmunch/data/local/hive_service.dart';
import 'package:mathmunch/data/models/child_profile.dart';
import 'package:mathmunch/data/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

class ChildRepository extends Notifier<List<ChildProfile>> {
  @override
  List<ChildProfile> build() {
    final authState = ref.watch(authStateProvider);
    final account = authState.parentAccount;
    if (account == null) return [];
    return HiveService.childBox.values
        .where((c) => account.childProfileIds.contains(c.id))
        .toList();
  }

  Future<ChildProfile> createChild({
    required String name,
    required int age,
    required String avatarId,
  }) async {
    final account = ref.read(authStateProvider).parentAccount!;
    final child = ChildProfile(
      id: const Uuid().v4(),
      name: name.trim(),
      age: age,
      avatarId: avatarId,
      parentAccountId: account.id,
    );
    await HiveService.childBox.put(child.id, child);
    await ref.read(authStateProvider.notifier).addChildProfile(child.id);
    state = [...state, child];
    return child;
  }

  Future<void> updateChild(ChildProfile updated) async {
    await HiveService.childBox.put(updated.id, updated);
    state = state.map((c) => c.id == updated.id ? updated : c).toList();
  }

  Future<void> recordPlay(String childId) async {
    final child = state.firstWhere((c) => c.id == childId);
    final today = DateTime.now();
    final last = child.lastPlayDate;
    int streak = child.currentStreak;

    if (last != null) {
      final diff = today.difference(last).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    final updated = child.copyWith(
      currentStreak: streak,
      lastPlayDate: today,
    );
    await updateChild(updated);
  }

  Future<void> addStars(String childId, int stars) async {
    final child = state.firstWhere((c) => c.id == childId);
    await updateChild(child.copyWith(totalStars: child.totalStars + stars));
  }

  Future<void> resetProgress(String childId) async {
    final child = state.firstWhere((c) => c.id == childId);
    await updateChild(child.copyWith(totalStars: 0, currentStreak: 0));
  }
}

// Active child selection (persists across sessions)
class ActiveChildNotifier extends Notifier<ChildProfile?> {
  @override
  ChildProfile? build() {
    final children = ref.watch(childListProvider);
    return children.firstOrNull;
  }

  void select(ChildProfile child) => state = child;
}

final childListProvider = NotifierProvider<ChildRepository, List<ChildProfile>>(
  ChildRepository.new,
);

final activeChildProvider =
    NotifierProvider<ActiveChildNotifier, ChildProfile?>(
  ActiveChildNotifier.new,
);
