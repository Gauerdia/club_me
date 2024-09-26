import 'package:flutter/cupertino.dart';

import '../models/club.dart';
import '../models/discount.dart';
import '../models/event.dart';

class FetchedContentProvider extends ChangeNotifier{

  List<ClubMeClub> fetchedClubs = [];
  List<ClubMeEvent> fetchedEvents = [];
  List<ClubMeDiscount> fetchedDiscounts = [];

  // When the clubEventView is firstly loaded, we put all fetched image ids in an
  // array. This array will be shared with the provider when the user navigates
  // to the pastEvents or upcomingEvents views. Then, the information which
  // images are already fetched can be retrieved from here.
  // List<String> fetchedEventBannerImageIds = [];
  // List<String> fetchedDiscountBannerImageIds = [];

  List<String> fetchedBannerImageIds = [];

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

  void setFetchedEvents(List<ClubMeEvent> fetchedEvents){
    this.fetchedEvents = fetchedEvents;
  }

  void addEventToFetchedEvents(ClubMeEvent clubMeEvent){
    fetchedEvents.add(clubMeEvent);
    sortFetchedEvents();
    notifyListeners();
  }

  void updateSpecificEvent(String eventId, ClubMeEvent updatedClubMeEvent){
    int index = fetchedEvents.indexWhere((element) => element.getEventId() == eventId);
    fetchedEvents[index] = updatedClubMeEvent;
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
  }

  void sortFetchedDiscounts(){
    fetchedDiscounts.sort((a,b) =>
        a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
    );
  }


  // DISCOUNTS: GET,SET,ADD,UPDATE
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

  void updateSpecificDiscount(String discountId, ClubMeDiscount updatedClubMeDiscount){
    int index = fetchedDiscounts.indexWhere((element) => element.getDiscountId() == discountId);
    fetchedDiscounts[index] = updatedClubMeDiscount;
    notifyListeners();
  }

}