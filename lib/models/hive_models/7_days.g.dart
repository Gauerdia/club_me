// GENERATED CODE - DO NOT MODIFY BY HAND

part of '7_days.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DaysAdapter extends TypeAdapter<Days> {
  @override
  final int typeId = 7;

  @override
  Days read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Days(
      day: fields[0] as int?,
      openingHour: fields[1] as int?,
      closingHour: fields[2] as int?,
      openingHalfAnHour: fields[3] as int?,
      closingHalfAnHour: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Days obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.openingHour)
      ..writeByte(2)
      ..write(obj.closingHour)
      ..writeByte(3)
      ..write(obj.openingHalfAnHour)
      ..writeByte(4)
      ..write(obj.closingHalfAnHour);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DaysAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
