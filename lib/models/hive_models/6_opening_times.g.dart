// GENERATED CODE - DO NOT MODIFY BY HAND

part of '6_opening_times.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OpeningTimesAdapter extends TypeAdapter<OpeningTimes> {
  @override
  final int typeId = 6;

  @override
  OpeningTimes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OpeningTimes(
      days: (fields[0] as List?)?.cast<Days>(),
    );
  }

  @override
  void write(BinaryWriter writer, OpeningTimes obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpeningTimesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
