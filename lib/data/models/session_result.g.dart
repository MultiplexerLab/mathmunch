// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionResultAdapter extends TypeAdapter<SessionResult> {
  @override
  final int typeId = 6;

  @override
  SessionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionResult(
      id: fields[0] as String,
      childId: fields[1] as String,
      levelId: fields[2] as String,
      worldId: fields[3] as String,
      worldName: fields[4] as String,
      levelTitle: fields[5] as String,
      accuracy: fields[6] as double,
      starsEarned: fields[7] as int,
      durationSeconds: fields[8] as int,
      playedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SessionResult obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.childId)
      ..writeByte(2)
      ..write(obj.levelId)
      ..writeByte(3)
      ..write(obj.worldId)
      ..writeByte(4)
      ..write(obj.worldName)
      ..writeByte(5)
      ..write(obj.levelTitle)
      ..writeByte(6)
      ..write(obj.accuracy)
      ..writeByte(7)
      ..write(obj.starsEarned)
      ..writeByte(8)
      ..write(obj.durationSeconds)
      ..writeByte(9)
      ..write(obj.playedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
