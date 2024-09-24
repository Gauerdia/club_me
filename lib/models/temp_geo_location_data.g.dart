// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_geo_location_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempGeoLocationDataAdapter extends TypeAdapter<TempGeoLocationData> {
  @override
  final int typeId = 6;

  @override
  TempGeoLocationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempGeoLocationData(
      longCoord: fields[1] as double,
      latCoord: fields[0] as double,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TempGeoLocationData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.latCoord)
      ..writeByte(1)
      ..write(obj.longCoord)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempGeoLocationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
