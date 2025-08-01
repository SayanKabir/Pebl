// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitGroupAdapter extends TypeAdapter<HabitGroup> {
  @override
  final int typeId = 0;

  @override
  HabitGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HabitGroup obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
