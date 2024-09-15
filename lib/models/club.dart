import 'package:club_me/models/club_offers.dart';
import 'package:club_me/models/front_page_images.dart';
import 'package:club_me/models/opening_times.dart';
import 'package:timezone/standalone.dart' as tz;

class ClubMeClub{

  ClubMeClub({
    required this.clubId,
    required this.clubName,

    required this.clubNews,
    required this.clubMusicGenres,
    required this.clubStoryId,

    required this.clubBannerId,

    required this.clubGeoCoordLat,
    required this.clubGeoCoordLng,

    required this.clubContactCity,
    required this.clubContactName,
    required this.clubContactStreet,
    required this.clubContactZip,
    required this.clubContactStreetNumber,
    required this.clubEventBannerId,

    required this.clubWebsiteLink,
    required this.clubInstagramLink,
    required this.clubFrontpageBackgroundColorId,

    required this.priorityScore,
    required this.openingTimes,
    required this.frontPageImages,
    required this.clubOffers
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

  String clubContactName;
  String clubContactStreet;
  String clubContactCity;
  String clubContactZip;
  int clubContactStreetNumber;

  String clubInstagramLink;
  String clubWebsiteLink;

  int clubFrontpageBackgroundColorId;
  int priorityScore;

  OpeningTimes openingTimes;
  FrontPageImages frontPageImages;
  ClubOffers clubOffers;


  bool clubIsOpen(){
    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

    bool closedToday = false, alreadyOpen = false, lessThanThreeMoreHoursOpen = false;
    var todaysClosingHour, todaysOpeningHour;

    for(var element in getOpeningTimes().days!){

      // Catching the situation that the user checks the app after midnight.
      // We want him to know that it's open but will close some time.
      if(todayTimestamp.hour < 8){
        if(element.day!-1 == todayTimestamp.weekday){
          todaysClosingHour = element.closingHour!;
          closedToday = false;
          if(todayTimestamp.hour < todaysOpeningHour){
            alreadyOpen = true;
            if(todaysClosingHour - todayTimestamp.hour < 3){
              lessThanThreeMoreHoursOpen = true;
            }
          }
        }
      }else{
        if(element.day == todayTimestamp.weekday){
          todaysOpeningHour = element.openingHour!;
          closedToday = false;
          if(todayTimestamp.hour >= todaysOpeningHour) alreadyOpen = true;
        }
      }
    }
    return alreadyOpen;
  }

  void setClubOffers(ClubOffers newClubOffers){
    clubOffers = newClubOffers;
  }

  ClubOffers getClubOffers(){
    return clubOffers;
  }

  FrontPageImages getFrontPageImages(){
    return frontPageImages;
  }
  void setFrontPageImages(FrontPageImages newFrontPageImages){
    frontPageImages = newFrontPageImages;
  }


  OpeningTimes getOpeningTimes(){
    return openingTimes;
  }

  setContactStreetNumber(int newNumber){
    clubContactStreetNumber = newNumber;
  }

  int getContactStreetNumber(){
    return clubContactStreetNumber;
  }

  int getPriorityScore(){
    return priorityScore;
  }

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