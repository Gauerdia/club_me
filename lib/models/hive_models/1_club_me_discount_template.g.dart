// GENERATED CODE - DO NOT MODIFY BY HAND

part of '1_club_me_discount_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClubMeDiscountTemplateAdapter
    extends TypeAdapter<ClubMeDiscountTemplate> {
  @override
  final int typeId = 1;

  @override
  ClubMeDiscountTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClubMeDiscountTemplate(
      discountTitle: fields[0] as String,
      numberOfUsages: fields[5] as int,
      discountDate: fields[1] as DateTime,
      hasTimeLimit: fields[3] as bool,
      hasUsageLimit: fields[4] as bool,
      discountDescription: fields[2] as String,
      targetGender: fields[6] as int,
      hasAgeLimit: fields[7] as bool,
      ageLimitLowerLimit: fields[9] as int,
      ageLimitUpperLimit: fields[10] as int,
      isRepeatedDays: fields[11] as int,
      templateId: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClubMeDiscountTemplate obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.discountTitle)
      ..writeByte(1)
      ..write(obj.discountDate)
      ..writeByte(2)
      ..write(obj.discountDescription)
      ..writeByte(3)
      ..write(obj.hasTimeLimit)
      ..writeByte(4)
      ..write(obj.hasUsageLimit)
      ..writeByte(5)
      ..write(obj.numberOfUsages)
      ..writeByte(6)
      ..write(obj.targetGender)
      ..writeByte(7)
      ..write(obj.hasAgeLimit)
      ..writeByte(9)
      ..write(obj.ageLimitLowerLimit)
      ..writeByte(10)
      ..write(obj.ageLimitUpperLimit)
      ..writeByte(11)
      ..write(obj.isRepeatedDays)
      ..writeByte(12)
      ..write(obj.templateId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClubMeDiscountTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
