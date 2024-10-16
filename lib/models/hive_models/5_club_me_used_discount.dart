import 'package:hive/hive.dart';
part '5_club_me_used_discount.g.dart';

@HiveType(typeId:  5)
class ClubMeUsedDiscount{

  ClubMeUsedDiscount({
    required this.usedAt,
    required this.discountId
  });

  @HiveField(0)
  DateTime usedAt;

  @HiveField(2)
  String discountId;


}