class ClubMeClub{

  ClubMeClub({
    required this.clubId,
    required this.clubName,

    required this.clubNews,
    required this.clubPriceList,
    required this.clubMusicGenres,
    required this.clubStoryId,

    required this.clubBannerId,
    required this.clubPhotoPaths,

    required this.clubGeoCoordLat,
    required this.clubGeoCoordLng,

    required this.clubContactCity,
    required this.clubContactName,
    required this.clubContactStreet,
    required this.clubContactZip,
    required this.clubEventBannerId,

    required this.clubWebsiteLink,
    required this.clubInstagramLink,
    required this.clubFrontpageBackgroundColorId,


  });

  String clubId;
  String clubName;

  String clubStoryId;

  double clubGeoCoordLat;
  double clubGeoCoordLng;

  String clubBannerId;
  String clubEventBannerId;
  String clubMusicGenres;

  String clubNews;
  Map<String, dynamic> clubPriceList;
  Map<String, dynamic> clubPhotoPaths;

  String clubContactName;
  String clubContactStreet;
  String clubContactCity;
  String clubContactZip;

  String clubInstagramLink;
  String clubWebsiteLink;

  int clubFrontpageBackgroundColorId;

  String getWebsiteLink(){
    return clubWebsiteLink;
  }

  int getBackgroundColorId(){
    return clubFrontpageBackgroundColorId;
  }

  String getInstagramLink(){
    return clubInstagramLink;
  }

  String getEventBannerId(){
    return clubEventBannerId;
  }

  String getClubId(){
    return clubId;
  }
  void setClubId(String newId){
    clubId = newId;
  }

  String getClubName(){
    return clubName;
  }
  void setClubName(String newName){
    clubName = newName;
  }

  String getStoryId(){
    return clubStoryId;
  }
  void setStoryId(String newStoryId){
    clubStoryId = newStoryId;
  }

  double getGeoCoordLat(){
    return clubGeoCoordLat;
  }
  void setGeoCoordLat(double newCoord){
    clubGeoCoordLat = newCoord;
  }

  double getGeoCoordLng(){
    return clubGeoCoordLng;
  }
  void setGeoCoordLng(double newCoord){
    clubGeoCoordLng = newCoord;
  }

  String getBannerId(){
    return clubBannerId;
  }
  void setBannerId(String newId){
    clubBannerId = newId;
  }

  String getMusicGenres(){
    return clubMusicGenres;
  }
  void setMusicGenres(String newGenres){
    clubMusicGenres = newGenres;
  }

  String getNews(){
    return clubNews;
  }
  void setNews(String newNews){
    clubNews = newNews;
  }

  Map<String, dynamic> getPriceList(){
    return clubPriceList;
  }
  void setPriceList(Map<String, dynamic> newPriceList){
    clubPriceList = newPriceList;
  }

  Map<String, dynamic> getPhotoPaths(){
    return clubPhotoPaths;
  }
  void setPhotoPaths(Map<String, dynamic> newPhotoPaths){
    clubPhotoPaths = newPhotoPaths;
  }

  String getContactName(){
    return clubContactName;
  }
  void setContactName(String newName){
    clubContactName = newName;
  }

  String getContactStreet(){
    return clubContactStreet;
  }
  void setContactStreet(String newStreet){
    clubContactStreet = newStreet;
  }

  String getContactCity(){
    return clubContactCity;
  }
  void setContactCity(String newCity){
    clubContactCity = newCity;
  }

  String getContactZip(){
    return clubContactZip;
  }
  void setContactZip(String newZip){
    clubContactZip = newZip;
  }

}