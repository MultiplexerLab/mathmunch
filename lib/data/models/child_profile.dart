import 'package:hive_flutter/hive_flutter.dart';

part 'child_profile.g.dart';

@HiveType(typeId: 1)
class ChildProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int age; // 3–6

  @HiveField(3)
  final String avatarId;

  @HiveField(4)
  final int totalStars;

  @HiveField(5)
  final int currentStreak; // consecutive play days

  @HiveField(6)
  final DateTime? lastPlayDate;

  @HiveField(7)
  final String parentAccountId;

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.avatarId,
    this.totalStars = 0,
    this.currentStreak = 0,
    this.lastPlayDate,
    required this.parentAccountId,
  });

  ChildProfile copyWith({
    String? name,
    int? age,
    String? avatarId,
    int? totalStars,
    int? currentStreak,
    DateTime? lastPlayDate,
  }) {
    return ChildProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      avatarId: avatarId ?? this.avatarId,
      totalStars: totalStars ?? this.totalStars,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      parentAccountId: parentAccountId,
    );
  }
}
