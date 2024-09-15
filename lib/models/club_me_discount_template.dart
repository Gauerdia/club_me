import 'package:hive/hive.dart';
part 'club_me_discount_template.g.dart';

@HiveType(typeId:  3)
class ClubMeDiscountTemplate{

  ClubMeDiscountTemplate({
    required this.discountTitle,
    required this.numberOfUsages,
    required this.discountDate,
    required this.hasTimeLimit,
    required this.hasUsageLimit,
    required this.discountDescription,
    required this.targetGender,
    required this.hasAgeLimit,
    required this.ageLimitLowerLimit,
    required this.ageLimitUpperLimit,
    required this.isRepeatedDays,
    required this.templateId
  });

  @HiveField(0)
  String discountTitle;
  @HiveField(1)
  DateTime discountDate;
  @HiveField(2)
  String discountDescription;
  @HiveField(3)
  bool hasTimeLimit;
  @HiveField(4)
  bool hasUsageLimit;
  @HiveField(5)
  int numberOfUsages;
  @HiveField(6)
  int targetGender;
  @HiveField(7)
  bool hasAgeLimit;
  @HiveField(9)
  int ageLimitLowerLimit;
  @HiveField(10)
  int ageLimitUpperLimit;
  @HiveField(11)
  int isRepeatedDays;
  @HiveField(12)
  String templateId;

  String getTemplateId(){
    return templateId;
  }

  bool getHasAgeLimit(){
    return hasAgeLimit;
  }
  int getIsRepeatedDays(){
    return isRepeatedDays;
  }
  bool getIsRepeated(){
    return isRepeatedDays != 0 ? true:false;
  }

  int getAgeLimitLowerLimit(){
    return ageLimitLowerLimit;
  }
  int getAgeLimitUpperLimit(){
    return ageLimitUpperLimit;
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
  String getDiscountTitle(){
    return discountTitle;
  }
  void setDiscountTitle(String newValue){
    discountTitle = newValue;
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