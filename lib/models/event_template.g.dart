// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventTemplateAdapter extends TypeAdapter<EventTemplate> {
  @override
  final int typeId = 1;

  @override
  EventTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventTemplate(
      clubMeEventHive: fields[0] as ClubMeEventHive,
    );
  }

  @override
  void write(BinaryWriter writer, EventTemplate obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.clubMeEventHive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
