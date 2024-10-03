// GENERATED CODE - DO NOT MODIFY BY HAND

part of '5_club_me_used_discount.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClubMeUsedDiscountAdapter extends TypeAdapter<ClubMeUsedDiscount> {
  @override
  final int typeId = 4;

  @override
  ClubMeUsedDiscount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClubMeUsedDiscount(
      usedAt: (fields[0] as List).cast<DateTime>(),
      howManyTimes: fields[1] as int,
      discountId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClubMeUsedDiscount obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.usedAt)
      ..writeByte(1)
      ..write(obj.howManyTimes)
      ..writeByte(2)
      ..write(obj.discountId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClubMeUsedDiscountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
