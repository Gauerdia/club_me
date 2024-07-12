class ClubMeDiscount{


  ClubMeDiscount({
    required this.discountId,
    required this.clubId,
    required this.clubName,
    required this.discountTitle,
    required this.numberOfUsages,
    required this.discountDate,
    required this.bannerId,
    required this.howOftenRedeemed,
    required this.hasTimeLimit,
    required this.hasUsageLimit,
    required this.discountDescription,
    required this.targetGender
  });

  String clubId;
  String clubName;

  String discountId;
  String discountTitle;

  DateTime discountDate;

  String discountDescription;

  bool hasTimeLimit;
  bool hasUsageLimit;

  int numberOfUsages;
  String bannerId;
  int howOftenRedeemed;

  int targetGender;

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

  String getBannerId(){
    return bannerId;
  }
  void setBannerId(String newValue){
    bannerId = newValue;
  }

}