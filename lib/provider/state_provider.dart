import 'package:club_me/models/club.dart';
import 'package:club_me/models/discount.dart';
import 'package:club_me/models/event.dart';
import 'package:flutter/cupertino.dart';

class StateProvider extends ChangeNotifier{

  int _pageIndex = 0;
  int get pageIndex => _pageIndex;

  late ClubMeClub _currentClub;
  late ClubMeEvent _currentEvent;
  late ClubMeDiscount _currentDiscount;

  ClubMeClub get clubMeClub => _currentClub;
  ClubMeEvent get clubMeEvent => _currentEvent;
  ClubMeDiscount get clubMeDiscount => _currentDiscount;

  bool _clubUIActive = false;
  bool _clubEventViewNewActive = true;
  bool _wentFromClubDetailToEventDetail = false;

  bool get clubUIActive => _clubUIActive;
  bool get wentFromClubDetailToEventDetail => _wentFromClubDetailToEventDetail;
  bool get clubEventViewNewActive => _clubEventViewNewActive;


  void toggleClubUIActive(){
    _clubUIActive = !_clubUIActive;
    notifyListeners();
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

  setCurrentEvent(ClubMeEvent clubMeEvent){
    _currentEvent = clubMeEvent;
  }
  setCurrentDiscount(ClubMeDiscount clubMeDiscount){
    _currentDiscount = clubMeDiscount;
  }

  setCurrentClub(ClubMeClub clubMeClub){
     _currentClub = clubMeClub;
  }



}