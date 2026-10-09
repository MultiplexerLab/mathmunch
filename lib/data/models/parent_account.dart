import 'package:hive_flutter/hive_flutter.dart';

part 'parent_account.g.dart';

@HiveType(typeId: 0)
class ParentAccount extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String passwordHash; // AES-256 at rest via Hive encryption

  @HiveField(3)
  final String parentPin; // 4-digit PIN, stored hashed

  @HiveField(4)
  final List<String> childProfileIds;

  @HiveField(5)
  final bool weeklyEmailEnabled;

  @HiveField(6)
  final DateTime createdAt;

  ParentAccount({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.parentPin,
    required this.childProfileIds,
    this.weeklyEmailEnabled = false,
    required this.createdAt,
  });

  ParentAccount copyWith({
    String? email,
    String? passwordHash,
    String? parentPin,
    List<String>? childProfileIds,
    bool? weeklyEmailEnabled,
  }) {
    return ParentAccount(
      id: id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      parentPin: parentPin ?? this.parentPin,
      childProfileIds: childProfileIds ?? this.childProfileIds,
      weeklyEmailEnabled: weeklyEmailEnabled ?? this.weeklyEmailEnabled,
      createdAt: createdAt,
    );
  }
}
