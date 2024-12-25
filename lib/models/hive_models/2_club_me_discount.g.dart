// GENERATED CODE - DO NOT MODIFY BY HAND

part of '2_club_me_discount.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClubMeDiscountAdapter extends TypeAdapter<ClubMeDiscount> {
  @override
  final int typeId = 2;

  @override
  ClubMeDiscount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClubMeDiscount(
      discountId: fields[2] as String,
      clubId: fields[0] as String,
      clubName: fields[1] as String,
      discountTitle: fields[3] as String,
      numberOfUsages: fields[9] as int,
      discountDate: fields[4] as DateTime,
      howOftenRedeemed: fields[11] as int,
      hasTimeLimit: fields[6] as bool,
      hasUsageLimit: fields[7] as bool,
      discountDescription: fields[5] as String,
      targetGender: fields[12] as int,
      priorityScore: fields[13] as int,
      hasAgeLimit: fields[8] as bool,
      ageLimitUpperLimit: fields[15] as int,
      ageLimitLowerLimit: fields[14] as int,
      isRepeatedDays: fields[16] as int,
      bigBannerFileName: fields[17] as String,
      smallBannerFileName: fields[18] as String,
      openingTimes: fields[19] as OpeningTimes,
      showDiscountInApp: fields[20] as bool,
      specialOccasionActive: fields[21] as bool,
      isRedeemable: fields[22] as bool,
      longTermStartDate: fields[23] as DateTime?,
      longTermEndDate: fields[24] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ClubMeDiscount obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.clubId)
      ..writeByte(1)
      ..write(obj.clubName)
      ..writeByte(2)
      ..write(obj.discountId)
      ..writeByte(3)
      ..write(obj.discountTitle)
      ..writeByte(4)
      ..write(obj.discountDate)
      ..writeByte(5)
      ..write(obj.discountDescription)
      ..writeByte(6)
      ..write(obj.hasTimeLimit)
      ..writeByte(7)
      ..write(obj.hasUsageLimit)
      ..writeByte(8)
      ..write(obj.hasAgeLimit)
      ..writeByte(9)
      ..write(obj.numberOfUsages)
      ..writeByte(11)
      ..write(obj.howOftenRedeemed)
      ..writeByte(12)
      ..write(obj.targetGender)
      ..writeByte(13)
      ..write(obj.priorityScore)
      ..writeByte(14)
      ..write(obj.ageLimitLowerLimit)
      ..writeByte(15)
      ..write(obj.ageLimitUpperLimit)
      ..writeByte(16)
      ..write(obj.isRepeatedDays)
      ..writeByte(17)
      ..write(obj.bigBannerFileName)
      ..writeByte(18)
      ..write(obj.smallBannerFileName)
      ..writeByte(19)
      ..write(obj.openingTimes)
      ..writeByte(20)
      ..write(obj.showDiscountInApp)
      ..writeByte(21)
      ..write(obj.specialOccasionActive)
      ..writeByte(22)
      ..write(obj.isRedeemable)
      ..writeByte(23)
      ..write(obj.longTermStartDate)
      ..writeByte(24)
      ..write(obj.longTermEndDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClubMeDiscountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
