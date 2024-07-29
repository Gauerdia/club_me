// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_me_event_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClubMeEventHiveAdapter extends TypeAdapter<ClubMeEventHive> {
  @override
  final int typeId = 2;

  @override
  ClubMeEventHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClubMeEventHive(
      eventTitle: fields[1] as String,
      djName: fields[0] as String,
      eventDate: fields[3] as DateTime,
      eventPrice: fields[2] as double,
      eventDescription: fields[4] as String,
      musicGenres: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClubMeEventHive obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.musicGenres);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClubMeEventHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
