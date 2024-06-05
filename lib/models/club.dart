class ClubMeClub{

  ClubMeClub({
    required this.clubId,
    required this.clubName,

    required this.news,
    required this.priceList,
    required this.musicGenres,
    required this.storyId,

    required this.bannerId,
    required this.photoPaths,

    required this.geoCoordLat,
    required this.geoCoordLng,

    required this.contactCity,
    required this.contactName,
    required this.contactStreet,
    required this.contactZip,
    required this.eventBannerId,

    required this.instagramLink,
    required this.backgroundColorId,
    required this.websiteLink

  });

  String clubId;
  String clubName;

  String storyId;

  double geoCoordLat;
  double geoCoordLng;

  String bannerId;
  String eventBannerId;
  String musicGenres;

  String news;
  Map<String, dynamic> priceList;
  Map<String, dynamic> photoPaths;

  String contactName;
  String contactStreet;
  String contactCity;
  String contactZip;

  String instagramLink;
  String websiteLink;

  int backgroundColorId;

  String getWebsiteLink(){
    return websiteLink;
  }

  int getBackgroundColorId(){
    return backgroundColorId;
  }

  String getInstagramLink(){
    return instagramLink;
  }

  String getEventBannerId(){
    return eventBannerId;
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
    return storyId;
  }
  void setStoryId(String newStoryId){
    storyId = newStoryId;
  }

  double getGeoCoordLat(){
    return geoCoordLat;
  }
  void setGeoCoordLat(double newCoord){
    geoCoordLat = newCoord;
  }

  double getGeoCoordLng(){
    return geoCoordLng;
  }
  void setGeoCoordLng(double newCoord){
    geoCoordLng = newCoord;
  }

  String getBannerId(){
    return bannerId;
  }
  void setBannerId(String newId){
    bannerId = newId;
  }

  String getMusicGenres(){
    return musicGenres;
  }
  void setMusicGenres(String newGenres){
    musicGenres = newGenres;
  }

  String getNews(){
    return news;
  }
  void setNews(String newNews){
    news = newNews;
  }

  Map<String, dynamic> getPriceList(){
    return priceList;
  }
  void setPriceList(Map<String, dynamic> newPriceList){
    priceList = newPriceList;
  }

  Map<String, dynamic> getPhotoPaths(){
    return photoPaths;
  }
  void setPhotoPaths(Map<String, dynamic> newPhotoPaths){
    photoPaths = newPhotoPaths;
  }

  String getContactName(){
    return contactName;
  }
  void setContactName(String newName){
    contactName = newName;
  }

  String getContactStreet(){
    return contactStreet;
  }
  void setContactStreet(String newStreet){
    contactStreet = newStreet;
  }

  String getContactCity(){
    return contactCity;
  }
  void setContactCity(String newCity){
    contactCity = newCity;
  }

  String getContactZip(){
    return contactZip;
  }
  void setContactZip(String newZip){
    contactZip = newZip;
  }

}