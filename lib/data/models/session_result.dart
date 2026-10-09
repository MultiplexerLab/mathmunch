import 'package:hive_flutter/hive_flutter.dart';

part 'session_result.g.dart';

@HiveType(typeId: 6)
class SessionResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String childId;

  @HiveField(2)
  final String levelId;

  @HiveField(3)
  final String worldId;

  @HiveField(4)
  final String worldName;

  @HiveField(5)
  final String levelTitle;

  /// 0.0 – 1.0
  @HiveField(6)
  final double accuracy;

  @HiveField(7)
  final int starsEarned; // 1–3

  @HiveField(8)
  final int durationSeconds;

  @HiveField(9)
  final DateTime playedAt;

  SessionResult({
    required this.id,
    required this.childId,
    required this.levelId,
    required this.worldId,
    required this.worldName,
    required this.levelTitle,
    required this.accuracy,
    required this.starsEarned,
    required this.durationSeconds,
    required this.playedAt,
  });
}
