// GENERATED CODE - DO NOT MODIFY BY HAND

part of '5_club_me_used_discount.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClubMeUsedDiscountAdapter extends TypeAdapter<ClubMeUsedDiscount> {
  @override
  final int typeId = 5;

  @override
  ClubMeUsedDiscount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClubMeUsedDiscount(
      usedAt: fields[0] as DateTime,
      discountId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClubMeUsedDiscount obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.usedAt)
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
