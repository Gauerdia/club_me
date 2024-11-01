// GENERATED CODE - DO NOT MODIFY BY HAND

part of '3_club_me_event_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClubMeEventTemplateAdapter extends TypeAdapter<ClubMeEventTemplate> {
  @override
  final int typeId = 3;

  @override
  ClubMeEventTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClubMeEventTemplate(
      eventTitle: fields[1] as String,
      djName: fields[0] as String,
      eventPrice: fields[2] as double,
      eventDate: fields[3] as DateTime,
      eventDescription: fields[4] as String,
      musicGenres: fields[5] as String,
      templateId: fields[6] as String,
      ticketLink: fields[7] as String,
      isRepeatedDays: fields[8] as int,
      closingDate: fields[9] as DateTime?,
      fileName: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClubMeEventTemplate obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.djName)
      ..writeByte(1)
      ..write(obj.eventTitle)
      ..writeByte(2)
      ..write(obj.eventPrice)
      ..writeByte(3)
      ..write(obj.eventDate)
      ..writeByte(4)
      ..write(obj.eventDescription)
      ..writeByte(5)
      ..write(obj.musicGenres)
      ..writeByte(6)
      ..write(obj.templateId)
      ..writeByte(7)
      ..write(obj.ticketLink)
      ..writeByte(8)
      ..write(obj.isRepeatedDays)
      ..writeByte(9)
      ..write(obj.closingDate)
      ..writeByte(10)
      ..write(obj.fileName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClubMeEventTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
