// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_me_user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClubMeUserDataAdapter extends TypeAdapter<ClubMeUserData> {
  @override
  final int typeId = 0;

  @override
  ClubMeUserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClubMeUserData(
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      birthDate: fields[3] as DateTime,
      eMail: fields[5] as String,
      gender: fields[4] as int,
      userId: fields[0] as String,
      profileType: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ClubMeUserData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.birthDate)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.eMail)
      ..writeByte(6)
      ..write(obj.profileType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClubMeUserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
