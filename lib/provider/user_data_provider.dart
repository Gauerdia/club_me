import 'package:club_me/models/opening_times.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

import '../mock_ups/class_mock_ups.dart';
import '../models/club.dart';
import '../models/hive_models/0_club_me_user_data.dart';

class UserDataProvider extends ChangeNotifier{


  var log = Logger();

  double latCoord = 0.0;
  double longCoord = 0.0;

  DateTime earliestNextDBLocationUpdate = DateTime.now();

  ClubMeUserData userData = mockUpUserData;
  ClubMeClub userClub = mockUpClub;

  void setEarliestNextDBLocationUpdate(DateTime newDateTime){
    earliestNextDBLocationUpdate = newDateTime;
    // notifyListeners();
  }

  DateTime getEarliestNextDBLocationUpdate(){
    return earliestNextDBLocationUpdate;
  }

  double getUserLatCoord(){
    return latCoord;
  }
  double getUserLongCoord(){
    return longCoord;
  }

  void setUserCoordinates(Position position){
    longCoord = position.longitude;
    latCoord = position.latitude;
    log.d("UserDataProvider. Fct: setUserCoordinates. New User Coordinates: Long($longCoord), Lat($latCoord)");
    notifyListeners();
  }

  // UserData

  void setUserData(ClubMeUserData clubMeUserData){
    userData = clubMeUserData;
    notifyListeners();
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
      String contactStreetNumber,
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