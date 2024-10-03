import 'package:hive/hive.dart';
part '5_club_me_used_discount.g.dart';

@HiveType(typeId:  4)
class ClubMeUsedDiscount{

  ClubMeUsedDiscount({
    required this.usedAt,
    required this.howManyTimes,
    required this.discountId
  });

  @HiveField(0)
  List<DateTime> usedAt;

  @HiveField(1)
  int howManyTimes;

  @HiveField(2)
  String discountId;


}