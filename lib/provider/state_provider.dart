import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/standalone.dart' as tz;

import '../models/hive_models/1_club_me_discount_template.dart';
import '../models/hive_models/3_club_me_event_template.dart';
import '../services/supabase_service.dart';
import '../shared/logger.util.dart';

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

  bool updatedLastLogInForNow = false;

  bool openEventDetailContentDirectly = false;

  int accessedEventDetailFrom = 0;

  final SupabaseService _supabaseService = SupabaseService();
  final log = getLogger();

  void toggleOpenEventDetailContentDirectly(){
    openEventDetailContentDirectly = true;
  }

  void resetOpenEventDetailContentDirectly(){
    openEventDetailContentDirectly = false;
  }

  void toggleUpdatedLastLogInForNow(){
    updatedLastLogInForNow = true;
  }

  void leaveEventDetailPage(BuildContext context){
    switch(accessedEventDetailFrom){
      case(0): context.go("/user_events");break;
      case(1): context.go("/user_clubs");break;
      case(2): context.go("/club_details");break;
      case(3): context.go("/user_map");break;
      case(4): context.go("/user_upcoming_events");break;
      case(5): context.go("/club_events");break;
      case(6): Navigator.pop(context);break;
      case(7): Navigator.pop(context);break;
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

  void resetDiscountTemplates(){
    discountTemplates = [];
  }

  void setDiscountTemplates(List<ClubMeDiscountTemplate> newClubMeDiscountTemplates){
    try{
      discountTemplates = newClubMeDiscountTemplates;
    }catch(e){
      log.d("StateProvider. Function: setDiscountTemplates. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: setDiscountTemplates. Error: $e");
    }
  }
  List<ClubMeDiscountTemplate> getDiscountTemplates(){
    try{
      return discountTemplates;
    }catch(e){
      log.d("StateProvider. Function: getDiscountTemplates. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: getDiscountTemplates. Error: $e");
      return [];
    }
  }
  void removeDiscountTemplateFromProvider(String templateId){
    discountTemplates.remove(templateId);
    notifyListeners();
  }

  void removeDiscountTemplate(String id){
    discountTemplates.removeWhere((element) => element.templateId == id);
    notifyListeners();
  }

  void setCurrentDiscountTemplate(ClubMeDiscountTemplate newClubMeDiscountTemplate){
    try{
      currentDiscountTemplate = newClubMeDiscountTemplate;
    }catch(e){
      log.d("StateProvider. Function: setCurrentDiscountTemplate. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: setCurrentDiscountTemplate. Error: $e");
    }
  }
  void resetCurrentDiscountTemplate(){
    try{
      currentDiscountTemplate = null;
    }catch(e){
      log.d("StateProvider. Function: resetCurrentDiscountTemplate. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: resetCurrentDiscountTemplate. Error: $e");
    }
  }
  ClubMeDiscountTemplate? getCurrentDiscountTemplate(){
    try{
      return currentDiscountTemplate;
    }catch(e){
      log.d("StateProvider. Function: getCurrentDiscountTemplate. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: getCurrentDiscountTemplate. Error: $e");
      return null;
    }
  }


  void resetEventTemplates(){
    eventTemplates = [];
  }

  void removeEventTemplate(String id){
    eventTemplates.removeWhere((element) => element.templateId == id);
    notifyListeners();
  }

  void setClubMeEventTemplates(List<ClubMeEventTemplate> newClubMeEventTemplates){
    try{
      eventTemplates = newClubMeEventTemplates;
    }catch(e){
      log.d("StateProvider. Function: setClubMeEventTemplates. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: setClubMeEventTemplates. Error: $e");
    }
  }
  List<ClubMeEventTemplate> getClubMeEventTemplates(){
    try{
      return eventTemplates;
    }catch(e){
      log.d("StateProvider. Function: getClubMeEventTemplates. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: getClubMeEventTemplates. Error: $e");
      return [];
    }
  }

  void setCurrentEventTemplate(ClubMeEventTemplate newClubMeEventHive){
    try{
      currentEventTemplate = newClubMeEventHive;
    }catch(e){
      log.d("StateProvider. Function: setCurrentEventTemplate. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: setCurrentEventTemplate. Error: $e");
    }
  }
  void resetCurrentEventTemplate(){

    try{
      currentEventTemplate = null;
    }catch(e){
      log.d("StateProvider. Function: resetCurrentEventTemplate. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: resetCurrentEventTemplate. Error: $e");
    }
  }
  ClubMeEventTemplate? getCurrentEventTemplate(){
    try{
      return currentEventTemplate;
    }catch(e){
      log.d("StateProvider. Function: getCurrentEventTemplate. Error: $e");
      _supabaseService.createErrorLog("StateProvider. Function: getCurrentEventTemplate. Error: $e");
      return null;
    }
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
    // notifyListeners();
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