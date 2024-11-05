import 'package:club_me/models/hive_models/5_club_me_used_discount.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/club.dart';
import '../models/event.dart';
import 'package:timezone/standalone.dart' as tz;

import '../models/hive_models/2_club_me_discount.dart';

class FetchedContentProvider extends ChangeNotifier{

  late BitmapDescriptor clubIcon;
  late BitmapDescriptor closeClubIcon;

  bool eventUpdatedRerenderNeeded = false;

  List<ClubMeClub> fetchedClubs = [];
  List<ClubMeEvent> fetchedEvents = [];
  List<ClubMeDiscount> fetchedDiscounts = [];

  List<ClubMeUsedDiscount> usedDiscounts = [];

  List<String> fetchedBannerImageIds = [];

  void setCustomIcons() async{

    await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(32,32)),
        "assets/images/beispiel_100x100.png"
    ).then((icon) {
      clubIcon = icon;
    });

    await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(32,32)),
        "assets/images/clubme_100x100.png"
    ).then((icon) {
      closeClubIcon = icon;
    });

  }

  // USED DISCOUNTS
  List<ClubMeUsedDiscount> getUsedDiscounts(){
    return usedDiscounts;
  }
  void addUsedDiscount(ClubMeUsedDiscount usedDiscount){
    usedDiscounts.add(usedDiscount);
    notifyListeners();
  }
  void setUsedDiscounts(List<ClubMeUsedDiscount> newUsedDiscounts){
    usedDiscounts = newUsedDiscounts;
    notifyListeners();
  }


  // BANNER IDS
  List<String> getFetchedBannerImageIds(){
    return fetchedBannerImageIds;
  }
  void addFetchedBannerImageId(String newId){
    fetchedBannerImageIds.add(newId);
    notifyListeners();
  }
  void setFetchedBannerImageIds(List<String> newBannerImageIds){
    fetchedBannerImageIds = newBannerImageIds;
    notifyListeners();
  }


  // EVENTS: GET,SET,ADD, UPDATE
  List<ClubMeEvent> getFetchedEvents(){
    return fetchedEvents;
  }
  // List<ClubMeEvent> getFetchedUpcomingEvents(String userClubId){
  //
  //   final berlin = tz.getLocation('Europe/Berlin');
  //   final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);
  //
  //   List<ClubMeEvent> fetchedUpcomingEvents = [];
  //
  //   for(var element in fetchedEvents){
  //     if(element.getEventDate().isAfter(todayTimestamp) && element.getClubId() == userClubId){
  //       fetchedUpcomingEvents.add(element);
  //     }
  //   }
  //   return fetchedUpcomingEvents;
  // }

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
    eventUpdatedRerenderNeeded = true;
    notifyListeners();
  }
  void sortFetchedEvents(){
    fetchedEvents.sort((a,b) =>
        a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
    );
  }


  // CLUBS: GET,SET,ADD
  List<ClubMeClub> getFetchedClubs(){
    return fetchedClubs;
  }
  void setFetchedClubs(List<ClubMeClub> fetchedClubs){
    this.fetchedClubs = fetchedClubs;
  }
  void addClubToFetchedClubs(ClubMeClub clubMeClub){
    fetchedClubs.add(clubMeClub);
    notifyListeners();
  }


  // DISCOUNTS: GET,SET,ADD,UPDATE
  List<ClubMeDiscount> getFetchedDiscounts(){
    return fetchedDiscounts;
  }
  List<ClubMeDiscount> getFetchedUpcomingDiscounts(String userClubId){

    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

    List<ClubMeDiscount> fetchedUpcomingDiscounts = [];

    for(var element in fetchedDiscounts){
      if(element.getDiscountDate().isAfter(todayTimestamp) && element.getClubId() == userClubId){
        fetchedUpcomingDiscounts.add(element);
      }
    }
    return fetchedUpcomingDiscounts;
  }
  void setFetchedDiscounts(List<ClubMeDiscount> fetchedDiscounts){
    this.fetchedDiscounts = fetchedDiscounts;
  }
  void removeFetchedDiscount(ClubMeDiscount clubMeDiscount){
    fetchedDiscounts.remove(clubMeDiscount);
    notifyListeners();
  }
  void removeFetchedDiscountById(String discountId){
    fetchedDiscounts.removeWhere((discount) => discount.getDiscountId() == discountId);
    notifyListeners();
  }
  void addDiscountToFetchedDiscounts(ClubMeDiscount clubMeDiscount){
    fetchedDiscounts.add(clubMeDiscount);
    sortFetchedDiscounts();
  }
  void updateSpecificDiscount(String discountId, ClubMeDiscount updatedClubMeDiscount){
    int index = fetchedDiscounts.indexWhere((element) => element.getDiscountId() == discountId);
    fetchedDiscounts[index] = updatedClubMeDiscount;
    notifyListeners();
  }
  void sortFetchedDiscounts(){
    fetchedDiscounts.sort((a,b) =>
        a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
    );
  }
}