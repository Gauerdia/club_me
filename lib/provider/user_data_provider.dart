import 'package:club_me/models/opening_times.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

import '../mock_ups/class_mock_ups.dart';
import '../models/club.dart';
import '../models/hive_models/0_club_me_user_data.dart';

class UserDataProvider extends ChangeNotifier{

  double latCoord = 0.0;
  double longCoord = 0.0;

  ClubMeUserData userData = mockUpUserData;
  ClubMeClub userClub = mockUpClub;

  double getUserLatCoord(){
    return latCoord;
  }
  double getUserLongCoord(){
    return longCoord;
  }

  void setUserCoordinates(Position position){
    longCoord = position.longitude;
    latCoord = position.latitude;
    notifyListeners();
  }

  // UserData

  void setUserData(ClubMeUserData clubMeUserData){
    userData = clubMeUserData;
  }

  ClubMeUserData getUserData(){
    return userData;
  }

  String getUserDataId(){
    return userData.getUserId();
  }

  ClubMeClub getUserClub(){
    return userClub;
  }

  String getUserClubWebsiteLink(){
    return userClub.getWebsiteLink();
  }

  String getUserClubInstaLink(){
    return userClub.getInstagramLink();
  }

  String getUserClubEventBannerId(){
    return userClub.getEventBannerId();
  }

  String getUserClubBannerId(){
    return userClub.getBannerId();
  }

  int getUserClubBackgroundColorId(){
    return userClub.getBackgroundColorId();
  }

  String getUserClubMusicGenres(){
    return userClub.getMusicGenres();
  }

  List<String> getUserClubContact(){

    return [
      userClub.getContactName(),
      userClub.getContactStreet(),
      userClub.getContactStreetNumber().toString(),
      userClub.getContactZip(),
      userClub.getContactCity()
    ];
  }

  void setUserClubContact(
      String contactName,
      String contactStreet,
      int contactStreetNumber,
      String contactZip,
      String contactCity
      ){
    userClub.setContactCity(contactCity);
    userClub.setContactName(contactName);
    userClub.setContactStreet(contactStreet);
    userClub.setContactStreetNumber(contactStreetNumber);
    userClub.setContactZip(contactZip);
    notifyListeners();
  }

  void setUserClub(ClubMeClub clubMeClub){
    userClub = clubMeClub;
    notifyListeners();
  }

  String getUserClubNews(){
    return userClub.getNews();
  }
  void setUserClubNews(String newNews){
    userClub.setNews(newNews);
    notifyListeners();
  }

  String getUserClubName(){
    return userClub.getClubName();
  }

  double getUserClubCoordLat(){
    return userClub.getGeoCoordLat();
  }

  double getUserClubCoordLng(){
    return userClub.getGeoCoordLng();
  }

  void setUserClubName(String newName){
    userClub.setClubName(newName);
    notifyListeners();
  }

  void setUserClubStoryId(String uuid){
    userClub.setStoryId(uuid);
    notifyListeners();
  }

  String getUserClubStoryId(){
    return userClub.getStoryId();
  }

  void setUserClubId(String id){
    userClub.setClubId(id);
    notifyListeners();
  }

  String getUserClubId(){
    return userClub.getClubId();
  }


  OpeningTimes getUserClubOpeningTimes(){
    return userClub.getOpeningTimes();
  }

}