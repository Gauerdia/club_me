import 'package:hive/hive.dart';

import '6_opening_times.dart';
part '2_club_me_discount.g.dart';

@HiveType(typeId:  2)
class ClubMeDiscount{


  ClubMeDiscount({
    required this.discountId,
    required this.clubId,
    required this.clubName,
    required this.discountTitle,
    required this.numberOfUsages,
    required this.discountDate,
    required this.howOftenRedeemed,
    required this.hasTimeLimit,
    required this.hasUsageLimit,
    required this.discountDescription,
    required this.targetGender,
    required this.priorityScore,
    required this.hasAgeLimit,
    required this.ageLimitUpperLimit,
    required this.ageLimitLowerLimit,
    required this.isRepeatedDays,
    required this.bigBannerFileName,
    required this.smallBannerFileName,
    required this.openingTimes,
    required this.showDiscountInApp,
    required this.specialOccasionActive,
    required this.isRedeemable,
    required this.longTermStartDate,
    required this.longTermEndDate
  });

  @HiveField(0)
  String clubId;
  @HiveField(1)
  String clubName;
  @HiveField(2)
  String discountId;

  @HiveField(3)
  String discountTitle;
  @HiveField(4)
  DateTime discountDate;
  @HiveField(5)
  String discountDescription;

  @HiveField(6)
  bool hasTimeLimit;
  @HiveField(7)
  bool hasUsageLimit;
  @HiveField(8)
  bool hasAgeLimit;

  @HiveField(9)
  int numberOfUsages;
  @HiveField(11)
  int howOftenRedeemed;

  @HiveField(12)
  int targetGender;
  @HiveField(13)
  int priorityScore;

  @HiveField(14)
  int ageLimitLowerLimit;
  @HiveField(15)
  int ageLimitUpperLimit;

  @HiveField(16)
  int isRepeatedDays;

  @HiveField(17)
  String bigBannerFileName;

  @HiveField(18)
  String smallBannerFileName;

  @HiveField(19)
  OpeningTimes openingTimes;

  @HiveField(20)
  bool showDiscountInApp;

  @HiveField(21)
  bool specialOccasionActive;

  @HiveField(22)
  bool isRedeemable;

  // Nach 1.1.143
  @HiveField(23)
  DateTime? longTermStartDate;

  // Nach 1.1.143
  @HiveField(24)
  DateTime? longTermEndDate;

  DateTime? getLongTermStartDate(){
    return longTermStartDate;
  }

  DateTime? getLongTermEndDate(){
    return longTermEndDate;
  }

  bool getIsRedeemable(){
    return isRedeemable;
  }

  bool getSpecialOccasionActive(){
    return specialOccasionActive;
  }

  bool getShowDiscountInApp(){
    return showDiscountInApp;
  }

  OpeningTimes getOpeningTimes(){
    return openingTimes;
  }

  String getSmallBannerFileName(){
    return smallBannerFileName;
  }

  String getBigBannerFileName(){
    return bigBannerFileName;
  }

  bool getIsRepeated(){
    return isRepeatedDays != 0 ? true : false;
  }

  int getIsRepeatedDays(){
    return isRepeatedDays;
  }


  int getAgeLimitLowerLimit(){
    return ageLimitLowerLimit;
  }
  int getAgeLimitUpperLimit(){
    return ageLimitUpperLimit;
  }

  bool getHasAgeLimit(){
    return hasAgeLimit;
  }

  int getPriorityScore(){
    return priorityScore;
  }

  int getTargetGender(){
    return targetGender;
  }

  String getDiscountDescription(){
    return discountDescription;
  }
  void setDiscountDescription(String newValue){
    discountDescription = newValue;
  }

  bool getHasUsageLimit(){
    return hasUsageLimit;
  }
  void setHasUsageLimit(bool newValue){
    hasUsageLimit = newValue;
  }

  bool getHasTimeLimit(){
    return hasTimeLimit;
  }
  void setHasTimeLimit(bool newValue){
    hasTimeLimit = newValue;
  }

  String getClubId(){
    return clubId;
  }
  void setClubId(String newValue){
    clubName = newValue;
  }

  int getHowOftenRedeemed(){
    return howOftenRedeemed;
  }
  void setHowOftenRedeemed(int newValue){
    howOftenRedeemed = newValue;
  }

  String getDiscountId(){
    return discountId;
  }
  void setDiscountId(String newValue){
    discountId = newValue;
  }

  String getDiscountTitle(){
    return discountTitle;
  }
  void setDiscountTitle(String newValue){
    discountTitle = newValue;
  }

  String getClubName(){
    return clubName;
  }
  void setClubName(String newValue){
    clubName = newValue;
  }

  int getNumberOfUsages(){
    return numberOfUsages;
  }
  void setNumberOfUsages(int newValue){
    numberOfUsages = newValue;
  }

  DateTime getDiscountDate(){
    return discountDate;
  }
  void setDiscountDate(DateTime newValue){
    discountDate = newValue;
  }



}