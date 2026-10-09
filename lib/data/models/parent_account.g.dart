// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParentAccountAdapter extends TypeAdapter<ParentAccount> {
  @override
  final int typeId = 0;

  @override
  ParentAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParentAccount(
      id: fields[0] as String,
      email: fields[1] as String,
      passwordHash: fields[2] as String,
      parentPin: fields[3] as String,
      childProfileIds: (fields[4] as List).cast<String>(),
      weeklyEmailEnabled: fields[5] as bool,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ParentAccount obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.passwordHash)
      ..writeByte(3)
      ..write(obj.parentPin)
      ..writeByte(4)
      ..write(obj.childProfileIds)
      ..writeByte(5)
      ..write(obj.weeklyEmailEnabled)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
