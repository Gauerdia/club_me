import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/standalone.dart' as tz;

import '../models/hive_models/1_club_me_discount_template.dart';
import '../models/hive_models/3_club_me_event_template.dart';

class StateProvider extends ChangeNotifier{

  StateProvider({
    required this.camera,
    required this.appDocumentsDir
  });

  Directory appDocumentsDir;
  final CameraDescription camera;
  String videoPath = "";

  List<ClubMeEventTemplate> eventTemplates = [];
  List<ClubMeDiscountTemplate> discountTemplates = [];

  List<String> attendingEvents = [];

  int _pageIndex = 0;
  int get pageIndex => _pageIndex;

  ClubMeEventTemplate? currentEventTemplate;
  ClubMeDiscountTemplate? currentDiscountTemplate;

  bool _clubUIActive = false;
  bool _clubEventViewNewActive = true;
  bool _wentFromClubDetailToEventDetail = false;

  bool get clubUIActive => _clubUIActive;
  bool get clubEventViewNewActive => _clubEventViewNewActive;
  bool get wentFromClubDetailToEventDetail => _wentFromClubDetailToEventDetail;

  bool eventIsEditable = false;
  bool reviewingANewEvent = false;
  bool isCurrentlyOnlyUpdatingAnEvent = false;

  bool activeLogOut = false;

  // 0: user_events, 1: user_clubs, 2:club_details. 3: user_upcoming_events,
  // 4: map,
  int accessedEventDetailFrom = 0;

  void leaveEventDetailPage(BuildContext context){
    switch(accessedEventDetailFrom){
      case(0): context.go("/user_events");break;
      case(1): context.go("/user_clubs");break;
      case(2): context.go("/club_details");break;
      case(3): context.go("/user_map");break;
      case(4): context.go("/user_upcoming_events");break;
      case(5): context.go("/club_events");break;
      case(6): context.go("/club_upcoming_events");break;
      case(7): context.go("/club_past_events");break;
      case(8): context.go("/club_frontpage");break;

    }
  }
  void setAccessedEventDetailFrom(int index){
    accessedEventDetailFrom = index;
  }

  DateTime getBerlinTime(){
    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

    return todayTimestamp;
  }



  // TEMPLATES

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


  void setClubMeEventTemplates(List<ClubMeEventTemplate> newClubMeEventTemplates){
    eventTemplates = newClubMeEventTemplates;
  }
  List<ClubMeEventTemplate> getClubMeEventTemplates(){
    return eventTemplates;
  }

  void setCurrentEventTemplate(ClubMeEventTemplate newClubMeEventHive){
    currentEventTemplate = newClubMeEventHive;
  }
  void resetCurrentEventTemplate(){
    currentEventTemplate = null;
  }
  ClubMeEventTemplate? getCurrentEventTemplate(){
    return currentEventTemplate;
  }



  // ATTENDING

  List<String> getAttendingEvents(){
    return attendingEvents;
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



  void toggleReviewingANewEvent(){
    reviewingANewEvent = !reviewingANewEvent;
  }

  void resetReviewingANewEvent(){
    reviewingANewEvent = false;
  }

  bool getReviewingANewEvent(){
    return reviewingANewEvent;
  }

  bool checkIfAttendingEvent(String eventId){

    return attendingEvents.contains(eventId);
  }

  void toggleClubUIActive(){
    _clubUIActive = !_clubUIActive;
    notifyListeners();
  }


  void setClubUiActive(bool value){
    _clubUIActive = value;
    notifyListeners();
  }


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