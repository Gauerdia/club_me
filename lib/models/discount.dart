class ClubMeDiscount{


  ClubMeDiscount({
    required this.clubName,
    required this.title,
    required this.numberOfUsages,
    required this.validUntil,
    required this.imagePath
  });


  String title;
  String clubName;
  int numberOfUsages;
  String validUntil;
  String imagePath;

  String getTitle(){
    return title;
  }
  String getClubName(){
    return clubName;
  }
  int getNumberOfUsages(){
    return numberOfUsages;
  }
  String getValidUntil(){
    return validUntil;
  }
  String getImagePath(){
    return imagePath;
  }

}