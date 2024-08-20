import 'dart:math';

import 'package:camera/camera.dart';
import 'package:club_me/models/club.dart';
import 'package:club_me/models/club_me_discount_template.dart';
import 'package:club_me/models/club_me_event_hive.dart';
import 'package:club_me/models/club_me_user_data.dart';
import 'package:club_me/models/discount.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/models/event_template.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class StateProvider extends ChangeNotifier{

  StateProvider({required this.camera});

  ClubMeClub userClub = ClubMeClub(
      clubId: "....",
      clubName: "MyClub",
      clubNews: "ewfwfew fwef wefwf wefefw",
      clubPriceList: {"" : ""},
      clubMusicGenres: "musicGenres",
      clubStoryId: "",
      clubBannerId: "img_2.png",
      clubEventBannerId: "img_2.png",
      clubPhotoPaths: {"" : ""},
      clubGeoCoordLat: 10,
      clubGeoCoordLng: 10,
      clubContactCity: "Bochum",
      clubContactName: "MyClub",
      clubContactStreet: "Kortumstraße",
      clubContactStreetNumber: 101,
      clubContactZip: "44787",
      clubInstagramLink: "https://www.instagram.com/hilife.stuttgart",
      clubWebsiteLink: "https://google.de",
      clubFrontpageBackgroundColorId: 0,
    priorityScore: 0
  );

  ClubMeUserData userData = ClubMeUserData(
      firstName: "Max",
      lastName: "Mustermann",
      birthDate: DateTime.now(),
      eMail: "max@mustermann.de",
      gender: 1,
      userId: "000000",
      profileType: 0
  );

  final CameraDescription camera;
  String videoPath = "";

  double latCoord = 0.0;
  double longCoord = 0.0;

  List<ClubMeClub> fetchedClubs = [];
  List<ClubMeEvent> fetchedEvents = [];
  List<ClubMeDiscount> fetchedDiscounts = [];

  List<String> likedClubs = [];
  List<String> likedEvents = [];
  List<String> likedDiscounts = [];

  List<EventTemplate> eventTemplates = [];
  List<ClubMeDiscountTemplate> discountTemplates = [];

  List<String> attendingEvents = [];

  int _pageIndex = 0;
  int get pageIndex => _pageIndex;

  late ClubMeClub _currentClub;
  late ClubMeEvent _currentEvent;
  late ClubMeDiscount _currentDiscount;

  ClubMeEventHive? clubMeEventHive;
  ClubMeDiscountTemplate? currentDiscountTemplate;


  ClubMeClub get clubMeClub => _currentClub;
  ClubMeEvent get clubMeEvent => _currentEvent;
  ClubMeDiscount get clubMeDiscount => _currentDiscount;

  bool _clubUIActive = false;
  bool _clubEventViewNewActive = true;
  bool _wentFromClubDetailToEventDetail = false;

  bool get clubUIActive => _clubUIActive;
  bool get clubEventViewNewActive => _clubEventViewNewActive;
  bool get wentFromClubDetailToEventDetail => _wentFromClubDetailToEventDetail;

  bool eventIsEditable = false;
  bool reviewingANewEvent = false;
  bool isCurrentlyOnlyUpdatingAnEvent = false;

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  bool activeLogOut = false;

  Color getPrimeColor(){
    return primeColor;
  }
  Color getPrimeColorDark(){
    return primeColorDark;
  }

  double getUserLatCoord(){
    return latCoord;
  }
  double getUserLongCoord(){
    return longCoord;
  }


  void setDiscountTemplates(List<ClubMeDiscountTemplate> newClubMeDiscountTemplates){
    discountTemplates = newClubMeDiscountTemplates;
  }
  List<ClubMeDiscountTemplate> getDiscountTemplates(){
    return discountTemplates;
  }


  void setCurrentDiscountTemplate(ClubMeDiscountTemplate newClubMeDiscountTemplate){
    currentDiscountTemplate = newClubMeDiscountTemplate;
  }
  void resetCurrentDiscountTemplate(){
    currentDiscountTemplate = null;
  }
  ClubMeDiscountTemplate? getCurrentDiscountTemplate(){
    return currentDiscountTemplate;
  }


  void setEventTemplates(List<EventTemplate> newEventTemplates){
    eventTemplates = newEventTemplates;
  }
  List<EventTemplate> getEventTemplates(){
    return eventTemplates;
  }

  void setClubMeEventHive(ClubMeEventHive newClubMeEventHive){
    clubMeEventHive = newClubMeEventHive;
  }
  void resetClubMeEventHive(){
    clubMeEventHive = null;
  }
  ClubMeEventHive? getClubMeEventHive(){
    return clubMeEventHive;
  }




  void setUserCoordinates(Position position){
    longCoord = position.longitude;
    latCoord = position.latitude;
    notifyListeners();
    // print("SetPosition: $longCoord, $latCoord");
    // print("Distance:${Geolocator.distanceBetween(latCoord, longCoord, 48.7762112372841, 9.1740412843159)}");
  }




  // Unified text styles
  /// TODO: Check if still necessary. CustomTextStyle is the wiser choice.

  // Fontsizefactors bezogen auf height

  // Größe 14
  double fontSizeFactor1 = 0.03;
  // 12
  double fontSizeFactor2 = 0.027;
  // 11
  double fontSizeFactor3 = 0.024;
  // 10
  double fontSizeFactor4 = 0.021;
  // 9
  double fontSizeFactor5 = 0.018;
  // 8
  double fontSizeFactor6 = 0.015;

  double iconSizeFactor = 0.035;
  double iconSizeFactor2 = 0.02;
  double iconSizeFactor3 = 0.012;

  double numberFieldFontSizeFactor = 0.05;

  double dropDownItemHeightFactor = 0.08;

  double getNumberFieldFontSizeFactor(){
    return numberFieldFontSizeFactor;
  }
  double getDropDownItemHeightFactor(){
    return dropDownItemHeightFactor;
  }
  double getIconSizeFactor(){
    return iconSizeFactor;
  }
  double getIconSizeFactor2(){
    return iconSizeFactor2;
  }
  double getIconSizeFactor3(){
    return iconSizeFactor3;
  }
  double getFontSizeFactor1(){
    return fontSizeFactor1;
  }
  double getFontSizeFactor2(){
    return fontSizeFactor2;
  }
  double getFontSizeFactor3(){
    return fontSizeFactor3;
  }
  double getFontSizeFactor4(){
    return fontSizeFactor4;
  }
  double getFontSizeFactor5(){
    return fontSizeFactor5;
  }
  double getFontSizeFactor6(){
    return fontSizeFactor6;
  }


  // UserData

  void setUserData(ClubMeUserData clubMeUserData){
    userData = clubMeUserData;
  }
  ClubMeUserData getUserData(){
    return userData;
  }

  // Events

  List<String> getLikedEvents(){
    return likedEvents;
  }

  List<String> getAttendingEvents(){
    return attendingEvents;
  }

  List<ClubMeEvent> getFetchedEvents(){
    return fetchedEvents;
  }

  void setFetchedEvents(List<ClubMeEvent> fetchedEvents){
    this.fetchedEvents = fetchedEvents;
  }

  void addEventToFetchedEvents(ClubMeEvent clubMeEvent){
    fetchedEvents.add(clubMeEvent);
    sortFetchedEvents();
  }

  void updateSpecificEvent(String eventId, ClubMeEvent updatedClubMeEvent){
    int index = fetchedEvents.indexWhere((element) => element.getEventId() == eventId);
    fetchedEvents[index] = updatedClubMeEvent;
    notifyListeners();
  }

  void updateCurrentEvent(int index, String newValue){
    switch(index){
      case 0: clubMeEvent.setEventTitle(newValue);
      case 1: clubMeEvent.setEventDjName(newValue);
      case 2: clubMeEvent.setEventMusicGenres(newValue);
      case 3: clubMeEvent.setEventPrice(double.parse(newValue));
      case 4: clubMeEvent.setEventDescription(newValue);
      case 6:

      // case 5: valueToDisplay = stateProvider.clubMeEvent.getEventStartingHours();
    }
    notifyListeners();
  }

  bool getIsCurrentlyOnlyUpdatingAnEvent(){
    return isCurrentlyOnlyUpdatingAnEvent;
  }

  void activateIsCurrentlyOnlyUpdatingAnEvent(){
    isCurrentlyOnlyUpdatingAnEvent = true;
  }

  void deactivateIsCurrentlyOnlyUpdatingAnEvent(){
    isCurrentlyOnlyUpdatingAnEvent = false;
  }

  bool getIsEventEditable(){
    return eventIsEditable;
  }

  void activateEventEditable(){
    eventIsEditable = true;
    notifyListeners();
  }

  void deactivateEventEditable(){
    eventIsEditable = false;
    notifyListeners();
  }

  void sortFetchedEvents(){
    // for(var e in fetchedEvents){
    //   var date = e.getEventDate();
    // }
    fetchedEvents.sort((a,b) =>
        a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
    );
    // for(var e in fetchedEvents){
    //   var date = e.getEventDate();
    // }
  }

  void toggleReviewingANewEvent(){
    reviewingANewEvent = !reviewingANewEvent;
  }

  void resetReviewingANewEvent(){
    reviewingANewEvent = false;
  }

  bool getReviewingANewEvent(){
    return reviewingANewEvent;
  }

  setCurrentEvent(ClubMeEvent clubMeEvent){
    try{
      _currentEvent = clubMeEvent;
      print("setCurrentEvent successful");
    }catch(e){
      print("Error in setCurrentEvent: $e");
    }
  }

  bool checkIfAttendingEvent(String eventId){

    return attendingEvents.contains(eventId);
  }

  bool checkIfCurrentEventIsAlreadyLiked(){
    return likedEvents.contains(_currentEvent.getEventId());
  }

  void setLikedEvents(List<String> likedEvents){
    this.likedEvents = likedEvents;
    notifyListeners();
  }

  void addLikedEvent(String eventId){
    likedEvents.add(eventId);
    notifyListeners();
  }

  void deleteLikedEvent(String eventId){
    likedEvents.remove(eventId);
    notifyListeners();
  }

  // Club

  ClubMeClub getUserClub(){
    return userClub;
  }

  setCurrentClub(ClubMeClub clubMeClub){
    _currentClub = clubMeClub;
  }

  void toggleClubUIActive(){
    _clubUIActive = !_clubUIActive;
    notifyListeners();
  }

  List<String> getLikedClubs(){
    return likedClubs;
  }

  bool checkIfClubIsAlreadyLiked(String clubId){
    return likedClubs.contains(clubId);
  }

  bool checkIfCurrentCLubIsAlreadyLiked(){
    return likedClubs.contains(_currentClub.getClubId());
  }

  bool checkIfSpecificCLubIsAlreadyLiked(String clubId){
    return likedClubs.contains(clubId);
  }

  void addLikedClub(String clubId){
    likedClubs.add(clubId);
    notifyListeners();
  }

  void deleteLikedClub(String clubId){
    likedClubs.remove(clubId);
    notifyListeners();
  }


  List<ClubMeClub> getFetchedClubs(){
    return fetchedClubs;
  }
  void setFetchedClubs(List<ClubMeClub> fetchedClubs){
    this.fetchedClubs = fetchedClubs;
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

  void setClubUiActive(bool value){
    _clubUIActive = value;
    notifyListeners();
  }

  String getUserClubBannerId(){
    return userClub.getBannerId();
  }

  List<String> getUserContact(){

    return [
      userClub.getContactName(),
      userClub.getContactStreet(),
      userClub.getContactStreetNumber().toString(),
      userClub.getContactZip(),
      userClub.getContactCity()
    ];
  }

  void setUserContact(
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
  void setClubNews(String newNews){
    userClub.setNews(newNews);
    notifyListeners();
  }

  String getClubName(){
    return userClub.getClubName();
  }

  double getClubCoordLat(){
    return userClub.getGeoCoordLat();
  }

  double getClubCoordLng(){
    return userClub.getGeoCoordLng();
  }

  void setClubName(String newName){
    userClub.setClubName(newName);
    notifyListeners();
  }

  void setClubStoryId(String uuid){
    userClub.setStoryId(uuid);
    notifyListeners();
  }

  String getCurrentClubStoryId(){
    return clubMeClub.getStoryId();
  }

  String getClubStoryId(){
    return userClub.getStoryId();
  }

  void setClubId(String id){
    userClub.setClubId(id);
    notifyListeners();
  }

  String getClubId(){
    return userClub.getClubId();
  }

  void addClubToFetchedClubs(ClubMeClub clubMeClub){
    fetchedClubs.add(clubMeClub);
  }

  // Discounts

  setCurrentDiscount(ClubMeDiscount clubMeDiscount){
    _currentDiscount = clubMeDiscount;
  }

  void sortFetchedDiscounts(){
    fetchedDiscounts.sort((a,b) =>
        a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
    );
  }

  List<ClubMeDiscount> getFetchedDiscounts(){
    return fetchedDiscounts;
  }

  void setFetchedDiscounts(List<ClubMeDiscount> fetchedDiscounts){
    this.fetchedDiscounts = fetchedDiscounts;
  }

  void addDiscountToFetchedDiscounts(ClubMeDiscount clubMeDiscount){
    fetchedDiscounts.add(clubMeDiscount);
    sortFetchedDiscounts();
  }

  List<String> getLikedDiscounts(){
    return likedDiscounts;
  }

  void setLikedDiscounts(List<String> likedDiscounts){
    this.likedDiscounts = likedDiscounts;
    notifyListeners();
  }

  void addLikedDiscount(String discountId){
    likedDiscounts.add(discountId);
    notifyListeners();
  }

  void deleteLikedDiscount(String discountId){
    likedDiscounts.remove(discountId);
    notifyListeners();
  }

  void updateSpecificDiscount(String discountId, ClubMeDiscount updatedClubMeDiscount){
    int index = fetchedDiscounts.indexWhere((element) => element.getDiscountId() == discountId);
    fetchedDiscounts[index] = updatedClubMeDiscount;
    notifyListeners();
  }

  // MISC

  String getVideoPath(){
    return videoPath;
  }

  CameraDescription getCamera(){
    return camera;
  }

  void toggleClubEventViewNewActive(){
     _clubEventViewNewActive = !_clubEventViewNewActive;
     notifyListeners();
   }

   void toggleWentFromCLubDetailToEventDetail(){
     _wentFromClubDetailToEventDetail = true;
     notifyListeners();
   }

   void resetWentFromCLubDetailToEventDetail(){
     _wentFromClubDetailToEventDetail = false;
     notifyListeners();
   }

  setPageIndex (int newPageIndex){
    _pageIndex = newPageIndex;
    notifyListeners();
  }


}