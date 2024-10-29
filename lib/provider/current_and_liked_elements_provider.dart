import 'package:flutter/cupertino.dart';

import '../models/club.dart';
import '../models/discount.dart';
import '../models/event.dart';
import '../models/hive_models/2_club_me_discount.dart';

class CurrentAndLikedElementsProvider extends ChangeNotifier{

  late ClubMeClub _currentClub;
  late ClubMeEvent _currentEvent;
  late ClubMeDiscount _currentDiscount;

  List<String> likedClubs = [];
  List<String> likedEvents = [];
  List<String> likedDiscounts = [];

  ClubMeClub get currentClubMeClub => _currentClub;
  ClubMeEvent get currentClubMeEvent => _currentEvent;
  ClubMeDiscount get currentClubMeDiscount => _currentDiscount;

  void updateCurrentEvent(int index, String newValue){
    switch(index){
      case 0: currentClubMeEvent.setEventTitle(newValue);
      case 1: currentClubMeEvent.setEventDjName(newValue);
      case 2: currentClubMeEvent.setEventMusicGenres(newValue);
      case 3: currentClubMeEvent.setEventPrice(double.parse(newValue));
      case 4: currentClubMeEvent.setEventDescription(newValue);
      case 6:
    }
    notifyListeners();
  }

  setCurrentEvent(ClubMeEvent clubMeEvent){
    try{
      _currentEvent = clubMeEvent;
      print("setCurrentEvent successful");
    }catch(e){
      print("Error in setCurrentEvent: $e");
    }
  }

  bool checkIfCurrentEventIsAlreadyLiked(){
    return likedEvents.contains(_currentEvent.getEventId());
  }


  setCurrentClub(ClubMeClub clubMeClub){
    _currentClub = clubMeClub;
  }

  bool checkIfCurrentCLubIsAlreadyLiked(){
    return likedClubs.contains(_currentClub.getClubId());
  }

  String getCurrentClubStoryId(){
    return currentClubMeClub.getStoryId();
  }

  setCurrentDiscount(ClubMeDiscount clubMeDiscount){
    _currentDiscount = clubMeDiscount;
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

  List<String> getLikedClubs(){
    return likedClubs;
  }

  bool checkIfClubIsAlreadyLiked(String clubId){
    return likedClubs.contains(clubId);
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

  List<String> getLikedEvents(){
    return likedEvents;
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


}