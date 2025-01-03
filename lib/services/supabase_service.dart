import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:club_me/main.dart';
import 'package:club_me/models/hive_models/0_club_me_user_data.dart';
import 'package:club_me/models/club_offers.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/models/front_page_images.dart';
import 'package:club_me/models/info_screen.dart';
import 'package:club_me/models/special_opening_times.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:club_me/shared/logger.util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/club.dart';
import '../models/hive_models/2_club_me_discount.dart';

class SupabaseService{

  final log = getLogger();



  Future<InfoScreenData> getLatestInfoScreenFileName() async{
    try{

      var data = await supabase
          .from('latest_info_screen')
          .select();

      InfoScreenData infoScreenData = InfoScreenData(
          fileName: data.first['file_name'],
          buttonChoice: data.first['button_choice'],
          buttonColor: data.first['button_color']
      );

      return infoScreenData;

    }catch(e){
      log.d("Error in SupabaseService. Function: getLatestInfoScreenFileName. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getLatestInfoScreenFileName. Error: ${e.toString()}");
      return InfoScreenData(fileName: "", buttonChoice: 0, buttonColor: 0);
    }
  }

  Future<List<DateTime>> getLatestInfoScreenDate() async{
    try{
      var data =  await supabase
          .from('latest_info_screen')
          .select();

      // We are sure that there is only one element
      for(var element in data){
        log.d("getEventsOfSpecificClub: Finished successfully.Response: ${element['created_at']}");
        List<DateTime> times = [];
        times.add(DateTime.parse(element['created_at']));
        times.add(DateTime.parse(element['show_until']));
        return times;
      }

      // if we cant fetch anything, we just return something so that at least the
      // current info screen is displayed again.
      return [
        DateTime(
            2000,
            1,
            2
        ),
        DateTime(
          2000,
          1,
          2
        )
      ];

    }catch(e){
      log.d("Error in SupabaseService. Function: getEventsOfSpecificClub. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getEventsOfSpecificClub. Error: ${e.toString()}");
      return [
        DateTime(
            2000,
            1,
            2
        ),
        DateTime(
            2000,
            1,
            2
        )
      ];
    }
  }

  Future<int> insertInfoScreen(
      var content, String fileName
      ) async {
    try{
      var data = await supabase.storage.from('info_screen').upload(
        fileName,
        content,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      log.d("insertInfoScreen: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: insertInfoScreen. Error: ${e.toString()}. Vars: fileName, $fileName");
      createErrorLog("Error in SupabaseService. Function: insertInfoScreen. Error: ${e.toString()}");
      return 1;
    }
  }

  Future<int> updateInfoScreen(
      String fileName, int buttonChoice, int buttonColor
      ) async{
    try{
      var data = await supabase
          .from('latest_info_screen')
          .update({
            'file_name': fileName,
            'button_choice': buttonChoice,
            'button_color': buttonColor
          }).match({
        'id' : 1
      });
      log.d("updateInfoScreen: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateInfoScreen. Error: ${e.toString()}. Vars: fileName, $fileName");
      createErrorLog("Error in SupabaseService. Function: updateInfoScreen. Error: ${e.toString()}");
      return 1;
    }
  }


  // GEO LOCATION

  Future<int> saveUsersGeoLocation(String userId, double latCoord, double longCoord) async{
    try{
      final data = await supabase
          .from("club_me_user_location")
          .insert({
            "lat_coord": latCoord,
            'long_coord': longCoord,
            'user_id': userId
      });
      log.d("saveUsersGeoLocation: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: saveUsersGeoLocation. Error: $e");
      createErrorLog("Error in SupabaseService. Function: saveUsersGeoLocation. Error: ${e.toString()}");
      return 1;
    }
  }


  // EVENTS
  Future<PostgrestList> getAllEvents() async{
    try{
      var data = await supabase
          .from('club_me_events')
          .select();
      List<String> titles = [];
      for(var element in data){
        titles.add(element['event_title']);
      }
      log.d("getAllEvents: Finished successfully.Response: $titles");
      return data;
    }
    catch(e){
      log.d("Error in SupabaseService. Function: getAllEvents. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getAllEvents. Error: ${e.toString()}");
      return [];
    }
  }

  Future<PostgrestList> getAllEventsAfterYesterday() async{
    try{

      var todayDay = DateTime.now().day;
      var todayMonth = DateTime.now().month;
      var todayYear = DateTime.now().year;

      // I am paranoid with dates. Surely, there is a more elegant way to do this.
      var yesterday = DateTime(
        todayYear,
        todayMonth,
        todayDay-1
      );
      var inTwoWeeks = DateTime(
        todayYear,
        todayMonth,
        todayDay+14
      );

      var concatYesterday = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
      // var concatInTwoWeeks = '${inTwoWeeks.year}-${inTwoWeeks.month}-${inTwoWeeks.day}';

      var data = await supabase
          .from('club_me_events')
          .select('*')
          .gte('event_date', concatYesterday);

      // We thought about 14 days but maybe a few people would like to plan
      // their clubbing ahead of time.
      // var data = await supabase
      //     .from('club_me_events')
      //     .select('*')
      //     .lte('event_date', concatInTwoWeeks)
      //     .gte('event_date', concatYesterday);
      List<String> titles = [];
      for(var element in data){
        titles.add(element['event_title']);
      }
      log.d("getAllEventsAfterYesterday: Finished successfully.Response: $titles");
      return data;
    }
    catch(e){
      log.d("Error in SupabaseService. Function: getAllEventsAfterYesterday. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getAllEventsAfterYesterday. Error: ${e.toString()}");
      return [];
    }
  }

  Future<PostgrestList> getEventsOfSpecificClub(String clubId) async{
    try{
      var data =  await supabase
          .from('club_me_events')
          .select()
          .match({
            'club_id': clubId
          });

      List<String> titles = [];
      for(var element in data){
        titles.add(element['event_title']);
      }
      log.d("getEventsOfSpecificClub: Finished successfully.Response: $titles");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getEventsOfSpecificClub. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getEventsOfSpecificClub. Error: ${e.toString()}");
      return [];
    }
  }
  Future<int> insertEvent(ClubMeEvent clubMeEvent, UserDataProvider userDataProvider) async {

    try{
      final data = await supabase
          .from("club_me_events")
          .insert({
        "event_id": clubMeEvent.getEventId(),
        "event_title" : clubMeEvent.getEventTitle(),

        "club_name" : clubMeEvent.getClubName(),
        "club_id" : clubMeEvent.getClubId(),
        "dj_name" : clubMeEvent.getDjName(),

        "event_date" : clubMeEvent.getEventDate().toString(),
        "event_description" : clubMeEvent.getEventDescription(),
        "event_price" : clubMeEvent.getEventPrice(),

        'banner_image_file_name': clubMeEvent.getBannerImageFileName(),
        "music_genres" : clubMeEvent.getMusicGenres(),
        'music_genres_to_filter': clubMeEvent.getMusicGenresToFilter(),
        'music_genres_to_display': clubMeEvent.getMusicGenresToDisplay(),

        "event_marketing_file_name": clubMeEvent.getEventMarketingFileName(),
        "event_marketing_created_at": clubMeEvent.getEventMarketingFileName().isNotEmpty ? DateTime.now().toString() : null,
        "priority_score": clubMeEvent.getPriorityScore(),
        "opening_times": clubMeEvent.getOpeningTimes().toJson(),

        "is_repeated_days": clubMeEvent.getIsRepeatedDays(),
        "ticket_link": clubMeEvent.getTicketLink(),
        "closing_date": clubMeEvent.getClosingDate()?.toString(),
        'show_event_in_app': clubMeEvent.getShowEventInApp()

      });
      log.d("insertEvent: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: insertEvent. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: insertEvent. Error: ${e.toString()}");
      return 1;
    }

  }
  void updateEvent(String eventId,int elementId, var newValue) async{

    String fieldName = "";

    switch(elementId){
      case(0): fieldName = "event_title";break;
      case(1): fieldName = "event_description";break;
      case(2): fieldName = "dj_name";break;
      case(3): fieldName = "music_genres";break;
      case(4): fieldName = "event_price";break;
    }

    try{
      var data = await supabase
          .from('club_me_events')
          .update({
        fieldName : newValue
      }).match({
        'event_id' : eventId
      });
      log.d("updateEvent: Finished successfully. Response: $data");
    }catch(e){
      log.d("Error in SupabaseService. Function: updateEvent. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateEvent. Error: ${e.toString()}");
    }
  }
  Future<int> updateCompleteEvent(ClubMeEvent updatedEvent) async{
    try{
      var data = await supabase
        .from('club_me_events')
        .update({
          'event_title': updatedEvent.getEventTitle(),
          'dj_name': updatedEvent.getDjName(),
          'event_date': updatedEvent.getEventDate().toString(),
          'event_description': updatedEvent.getEventDescription(),
          'event_price': updatedEvent.getEventPrice(),

          'music_genres': updatedEvent.getMusicGenres(),
          'music_genres_to_filter': updatedEvent.getMusicGenresToFilter(),
          'music_genres_to_display': updatedEvent.getMusicGenresToDisplay(),

          'event_marketing_file_name': updatedEvent.getEventMarketingFileName(),
          'event_marketing_created_at': updatedEvent.getEventMarketingFileName().isNotEmpty ? DateTime.now().toString() : null,

          'ticket_link': updatedEvent.getTicketLink(),
          'is_repeated_days': updatedEvent.getIsRepeatedDays(),

        'closing_date': updatedEvent.getClosingDate() != null ? updatedEvent.getClosingDate().toString() : null

        }).match({
        'event_id' : updatedEvent.getEventId()
      });
      log.d("updateCompleteEvent: Finished successfully. Response: $data");
      return 0;
    }catch(e){

      log.d("Error in SupabaseService. Function: updateCompleteEvent. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateCompleteEvent. Error: ${e.toString()}");

      return 1;
    }
  }
  Future<int> deleteEvent(String eventId) async {
    try{
      var data = await supabase
        .from('club_me_events')
        .delete().match(({
          'event_id': eventId
      }));
      log.d("deleteEvent: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: deleteEvent. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: deleteEvent. Error: ${e.toString()}");
      return 1;
    }
  }


  // CLUBS
  Future<int> updateClubOffers(ClubOffers newClubOffers, String clubId) async{
    try{
      var data = await supabase
          .from('club_me_clubs')
          .update({
        "club_offers" : newClubOffers
      }).match({
        'club_id' :clubId
      });
      log.d("updateClub: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateClubOffers. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateClubOffers. Error: ${e.toString()}");
      return 1;
    }
  }

  Future<int> updateSpecialOpeningTimes(SpecialOpeningTimes specialOpeningTimes, String clubId) async{
    try{
      var data = await supabase
          .from('club_me_clubs')
          .update({
        "special_opening_times" : specialOpeningTimes
      }).match({
        'club_id' :clubId
      });
      log.d("updateSpecialOpeningTimes: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateSpecialOpeningTimes. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateSpecialOpeningTimes. Error: ${e.toString()}");
      return 1;
    }
  }

  Future<PostgrestList> checkIfClubPwIsLegit(String pw) async {
    try{
      var data = await supabase
          .from('club_passwords')
          .select()
          .match({
            'password':pw
          });
      log.d("checkIfClubPwIsLegit: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: checkIfClubPwIsLegit. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: checkIfClubPwIsLegit. Error: ${e.toString()}");
      return [];
    }
  }
  Future<PostgrestList> getAllClubs() async{
    try{
      var data = await supabase
          .from('club_me_clubs')
          .select();
      log.d("getAllClubs: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getAllClubs. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getAllClubs. Error: ${e.toString()}");
      return [];
    }
  }
  Future<PostgrestList> getSpecificClub(String clubId) async{
    try{
      var data = await supabase
          .from('club_me_clubs')
          .select()
          .match({
        'club_id' : clubId
      });
      String fetchedClubId = data[0]['club_id'].toString();
      log.d("getSpecificClub: Finished successfully. Fetched Club with Id: $fetchedClubId");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getSpecificClub. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getSpecificClub. Error: ${e.toString()}");
      return [];
    }
  }
  void insertClub(ClubMeClub clubMeClub) async{

    Map<String, dynamic> dataJson = {};

    try{
      final data = await supabase
          .from('club_me_clubs')
          .insert({
        'club_id':clubMeClub.getClubId(),
        'club_name':clubMeClub.getClubName(),
        'geo_coord_lat':clubMeClub.getGeoCoordLat(),
        'geo_coord_lng':clubMeClub.getGeoCoordLng(),
        'music_genres':clubMeClub.getMusicGenres(),
        'news':clubMeClub.getNews(),
        'price_list':dataJson,
        'contact_name':clubMeClub.getContactName(),
        'contact_street':clubMeClub.getContactStreet(),
        'contact_city':clubMeClub.getContactCity(),
        'contact_zip_code':clubMeClub.getContactZip(),
        'story_path': "",
        'front_page_images': dataJson
      }).select();
      log.d("insertClub: Finished successfully. Response: $data");
    }catch(e){
      log.d("Error in SupabaseService. Function: insertClub. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: insertClub. Error: ${e.toString()}");
    }
  }
  Future<int> updateClub(String clubId, int elementId, var newValue) async{

    String fieldName = "";

    switch(elementId){
      case(0): fieldName = "club_name";break;
      case(1): fieldName = "news";break;
      case(2): fieldName = "price_list";break;
      case(3): fieldName = "music_genres";break;
    }

    try{
      var data = await supabase
          .from('club_me_clubs')
          .update({
        fieldName : newValue
      }).match({
        'club_id' :clubId
      });
      log.d("updateClub: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateClub. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateClub. Error: ${e.toString()}");
      return 1;
    }
  }
  void addVideoPathToClub(String uuid, UserDataProvider userDataProvider, StateProvider stateProvider) async{


    try{
      var data = await supabase
          .from('club_me_clubs')
          .update({
        'story_id' : uuid,
        'story_created_at' : stateProvider.getBerlinTime().toString()
      }).match({
        'club_id': userDataProvider.getUserClubId()
      });
      userDataProvider.setUserClubStoryId(uuid);
      log.d("addVideoPathToClub: Finished successfully. Response: $data");
    }catch(e){
      log.d("Error in SupabaseService. Function: addVideoPathToClub. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: addVideoPathToClub. Error: ${e.toString()}");
    }
  }
  void addContentPathToEvent(String eventId, String fileName) async {
    try{
      var data = await supabase
          .from('club_me_events')
          .update({
        'event_marketing_file_name' : fileName,
        'event_marketing_created_at' : DateTime.now().toString()
      }).match({
        'event_id': eventId
      });
      log.d("addContentPathToEvent: Finished successfully. Response: $data");
    }catch(e){
      log.d("Error in SupabaseService. Function: addContentPathToEvent. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: addContentPathToEvent. Error: ${e.toString()}");
    }
  }
  void addEventMarketingToEvent(String eventId, String fileName, StateProvider stateProvider) async {

    try{
      var data = await supabase
          .from('club_me_events')
          .update({
            'event_marketing_file_name' : fileName,
            'event_marketing_created_at': DateTime.now().toString()
          }).match({
            'event_id': eventId
          });
      log.d("addEventMarketingToEvent: Finished successfully. Response: $data");
    }catch(e){
      log.d("Error in SupabaseService. Function: addEventMarketingToEvent. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: addEventMarketingToEvent. Error: ${e.toString()}");
    }

  }
  Future<int> updateClubContactInfo(
      String clubId,
      String contactName,
      String contactStreet,
      String contactStreetNumber,
      String contactZip,
      String contactCity
      ) async{
    try{
      var data = await supabase
          .from('club_me_clubs')
          .update({
        "contact_name" : contactName,
        "contact_street": contactStreet,
        "contact_street_number": contactStreetNumber,
        "contact_zip_code" : contactZip,
        "contact_city": contactCity
      }).match({
        'club_id' :clubId
      });
      log.d("updateClubContactInfo: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateClubContactInfo. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateClubContactInfo. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<int> updateClubLastLogInApp(String clubId, bool loggedInAsAdmin) async{
    try{

      var data;

      if(loggedInAsAdmin){
        data = await supabase
            .from('club_me_clubs')
            .update({
          "last_log_in_app_admin" : DateTime.now().toString(),
        }).match({
          'club_id' :clubId
        });
      }else{
        data = await supabase
            .from('club_me_clubs')
            .update({
          "last_log_in_app" : DateTime.now().toString(),
        }).match({
          'club_id' :clubId
        });
      }

      log.d("updateLastLogInApp: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateLastLogInApp. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateLastLogInApp. Error: ${e.toString()}");
      return 1;
    }
  }


  // DISCOUNTS
  Future<int> deleteDiscount(String discountId) async {
    try{
      var data = await supabase
          .from('club_me_discounts')
          .delete().match(({
        'discount_id': discountId
      }));
      log.d("deleteDiscount: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: deleteDiscount. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: deleteDiscount. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<PostgrestList> getAllDiscounts() async{
    try{
      var data = await supabase
          .from('club_me_discounts')
          .select();

      List<String> titles = [];
      for(var element in data){
        titles.add(element['discount_title']);
      }

      log.d("getAllDiscounts: Finished successfully. Response: $titles");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getAllDiscounts. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getAllDiscounts. Error: ${e.toString()}");
      return [];
    }
  }

  Future<PostgrestList> getAllDiscountsFromYesterday() async{
    try{

      var todayDay = DateTime.now().day;
      var todayMonth = DateTime.now().month;
      var todayYear = DateTime.now().year;

      // I am paranoid with dates. Surely, there is a more elegant way to do this.
      var yesterday = DateTime(
          todayYear,
          todayMonth,
          todayDay-1
      );

      var concat = '${yesterday.year}-${yesterday.month}-${yesterday.day}';

      var data = await supabase
          .from('club_me_discounts')
          .select()
          .gte('discount_date', concat);

      List<String> titles = [];
      for(var element in data){
        titles.add(element['discount_title']);
      }

      log.d("getAllDiscountsFromYesterday: Finished successfully. Response: $titles");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getAllDiscountsFromYesterday. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getAllDiscountsFromYesterday. Error: ${e.toString()}");
      return [];
    }
  }

  Future<int> insertDiscount(ClubMeDiscount clubMeDiscount) async{

    try{
      var data = await supabase
          .from('club_me_discounts')
          .insert({

        'club_id':clubMeDiscount.getClubId(),
        'club_name':clubMeDiscount.getClubName(),

        'discount_id':clubMeDiscount.getDiscountId(),
        'discount_title':clubMeDiscount.getDiscountTitle(),
        'discount_date':clubMeDiscount.getDiscountDate().toString(),
        'discount_description': clubMeDiscount.getDiscountDescription(),

        'has_usage_limit': clubMeDiscount.getHasUsageLimit(),
        'number_of_usages':clubMeDiscount.getNumberOfUsages(),

        'how_often_redeemed':clubMeDiscount.getHowOftenRedeemed(),

        'has_time_limit': clubMeDiscount.getHasTimeLimit(),

        'target_gender': clubMeDiscount.getTargetGender(),

        'has_age_limit': clubMeDiscount.getHasAgeLimit(),
        'age_limit_lower_limit': clubMeDiscount.getAgeLimitLowerLimit(),
        'age_limit_upper_limit': clubMeDiscount.getAgeLimitUpperLimit(),

        'is_repeated_days': clubMeDiscount.getIsRepeatedDays(),
        'big_banner_file_name': clubMeDiscount.getBigBannerFileName(),
        'small_banner_file_name': clubMeDiscount.getSmallBannerFileName(),
        'show_discount_in_app': clubMeDiscount.getShowDiscountInApp(),
        'is_redeemable': clubMeDiscount.getIsRedeemable(),

        'longterm_start_date': clubMeDiscount.getLongTermStartDate() != null ? clubMeDiscount.getLongTermStartDate().toString() : null,
        'longterm_end_date': clubMeDiscount.getLongTermEndDate() != null ? clubMeDiscount.getLongTermEndDate().toString() : null,

      }).select();
      log.d("insertDiscount: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: insertDiscount. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: insertDiscount. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<PostgrestList> getDiscountsOfSpecificClub(String clubId) async{
    try{
      var data = await supabase
          .from('club_me_discounts')
          .select()
          .match({
            'club_id' : clubId
          });
      log.d("getDiscountsOfSpecificClub: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getDiscountsOfSpecificClub. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getDiscountsOfSpecificClub. Error: ${e.toString()}");
      return [];
    }
  }
  void updateDiscount(String discountId, int elementId, var newValue) async {
    try{
      var data = supabase
          .from('club_me_discounts')
          .update({
        '...' : newValue
      }).match({
        'discount_id':discountId
      });
      log.d("updateDiscount: Finished successfully. Response: $data");
    }catch(e){
      log.d("Error in SupabaseService. Function: updateDiscount. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateDiscount. Error: ${e.toString()}");
    }
  }
  Future<int> updateCompleteDiscount(ClubMeDiscount clubMeDiscount) async{

    try{
      var data = await supabase
          .from("club_me_discounts")
          .update({

        'discount_title':clubMeDiscount.getDiscountTitle(),
        'discount_date':clubMeDiscount.getDiscountDate().toString(),
        'discount_description': clubMeDiscount.getDiscountDescription(),

        'has_usage_limit': clubMeDiscount.getHasUsageLimit(),
        'number_of_usages':clubMeDiscount.getNumberOfUsages(),

        'how_often_redeemed':clubMeDiscount.getHowOftenRedeemed(),

        'has_time_limit': clubMeDiscount.getHasTimeLimit(),

        'target_gender': clubMeDiscount.getTargetGender(),

        'has_age_limit': clubMeDiscount.getHasAgeLimit(),
        'age_limit_lower_limit': clubMeDiscount.getAgeLimitLowerLimit(),
        'age_limit_upper_limit': clubMeDiscount.getAgeLimitUpperLimit(),

        'is_repeated_days': clubMeDiscount.getIsRepeatedDays(),
        'big_banner_file_name': clubMeDiscount.getBigBannerFileName(),
        'is_redeemable': clubMeDiscount.getIsRedeemable(),

        'longterm_start_date': clubMeDiscount.getLongTermStartDate() != null ? clubMeDiscount.getLongTermStartDate().toString() : null,
        'longterm_end_date': clubMeDiscount.getLongTermEndDate() != null ? clubMeDiscount.getLongTermEndDate().toString() : null,


      }).match({
        'discount_id' : clubMeDiscount.getDiscountId()
      });
      log.d("updateCompleteDiscount: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateCompleteDiscount. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateCompleteDiscount. Error: ${e.toString()}");
      return 1;
    }
  }

  Future<int> insertDiscountUsage(String discountId, String userId) async{
    try{
      var data = await supabase
          .from("club_me_discount_usages")
          .insert({
            'discount_id': discountId,
            'user_id': userId
      }).select();
      log.d("insertDiscountUsage: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: insertDiscountUsage. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: insertDiscountUsage. Error: ${e.toString()}");
      return 1;
    }
  }


  // FRONTPAGE IMAGES
  Future<Uint8List> getFrontPageGalleryImage(String fileName) async {

    try{
      var data = await supabase
          .storage
          .from('club_me_banner_images')
          .download("frontpage_gallery_images/$fileName");
      log.d("getFrontPageImage: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getFrontPageImage. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getFrontPageImage. Error: ${e.toString()}");
      return Uint8List(0);
    }
  }
  Future<int> uploadFrontPageGalleryImage(
      var content,
      String fileName,
      String clubId,
      FrontPageGalleryImages frontPageGalleryImages
      ) async {
    try{
      var data = await supabase.storage.from('club_me_banner_images').upload(
        "frontpage_gallery_images/$fileName",
        content,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      updateFrontPageGalleryImageInClub(clubId, frontPageGalleryImages);
      log.d("uploadEventContent: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: uploadFrontPageImage. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: uploadFrontPageImage. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<int> updateFrontPageGalleryImageInClub(String clubId, FrontPageGalleryImages frontPageGalleryImages) async{
    try{
      var data = await supabase
          .from('club_me_clubs')
          .update({
        'front_page_images' : frontPageGalleryImages.toJson(),
      }).match({
        'club_id': clubId
      });
      log.d("updateFrontPageImageInClub: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateFrontPageImageInClub. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateFrontPageImageInClub. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<int> updateFrontPageBannerImageInClub(String clubId, String fileName) async{
    try{
      var data = await supabase
          .from('club_me_clubs')
          .update({
        'frontpage_banner_file_name' : fileName,
      }).match({
        'club_id': clubId
      });
      log.d("updateFrontPageBannerImageInClub: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateFrontPageBannerImageInClub. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateFrontPageImageInClub. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<int> deleteFrontPageFromStorage(String fileName) async{
    try{
      var data = await supabase
        .storage
        .from('club_me_banner_images')
        .remove(["frontpage_banner_images/$fileName"]);
      log.d("deleteFrontPageFromStorage: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: deleteFrontPageFromStorage. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: deleteFrontPageFromStorage. Error: ${e.toString()}");
      return 1;
    }
  }

  // FRONTPAGE BANNER
  Future<int> uploadFrontpageBannerImage(String clubId, String fileName, var content) async{
    try{
      var data = await supabase.storage.from('club_me_banner_images').upload(
        "frontpage_banner_images/$fileName",
        content,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      await updateFrontPageBannerImageInClub(clubId, fileName);
      log.d("uploadFrontpageBannerImage: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: uploadFrontpageBannerImage. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: uploadFrontpageBannerImage. Error: ${e.toString()}");
      return 1;
    }
  }


  // USERS
  Future<int> insertUserData(ClubMeUserData userData) async{

    try{
      var data = await supabase
          .from('club_me_users')
          .insert({
        'first_name': userData.getFirstName(),
        'last_name': userData.getLastName(),
        'e_mail': userData.getEMail(),
        'gender': userData.getGender(),
        'birth_date': userData.getBirthDate().toString(),
        'user_id': userData.getUserId(),
        'last_time_logged_in': DateTime.now().toString(),
        'platform': Platform.isAndroid ? "Android" : "iOS"
      }).select();
      log.d("insertUserData: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: insertUserData. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: insertUserData. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<int> updateUserData(ClubMeUserData userData) async{

    try{
      var data = await supabase
        .from('club_me_users')
        .update({
        'first_name': userData.getFirstName(),
        'last_name': userData.getLastName(),
        'e_mail': userData.getEMail(),
        'gender': userData.getGender(),
        'birth_date': userData.getBirthDate().toString(),
        'last_time_logged_in': userData.getLastTimeLoggedIn().toString()
      })
      .eq('user_id', userData.getUserId());
      log.d("updateUserData: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateUserData. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateUserData. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<int> markToDeleteUserData(String userId) async{
    try{
      var data = await supabase
          .from('club_me_users')
          .update({
        'account_shall_be_deleted': true,
      }).eq('user_id', userId);
      log.d("markToDeleteUserData: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: markToDeleteUserData. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: markToDeleteUserData. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<int> updateUserLastTimeLoggedIn(String userId) async {
    try{
      var data = await supabase
          .from('club_me_users')
          .update({
        'last_time_logged_in': DateTime.now().toString(),
      }).eq('user_id', userId);
      log.d("updateUserLastLoggedIn: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: updateUserLastLoggedIn. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: updateUserLastLoggedIn. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<PostgrestList> getUserByEMail(String eMail) async{
    try{
      var data = await supabase
          .from('club_me_users')
          .select()
          .match({'e_mail':eMail});
      log.d("getUserByEMail: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getUserByEMail. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getUserByEMail. Error: ${e.toString()}");
      return [];
    }
  }


  // EVENT CONTENT: PHOTOS/VIDEOS
  Future<Uint8List> getEventContent(String fileName) async {

    String path = 'event_content/$fileName';

    try{
      var data = await supabase.storage.from('club_me_stories').download(path);
      log.d("getVideo: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getEventContent. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getEventContent. Error: ${e.toString()}. path: $path");
      return Uint8List(0);
    }

  }
  Future<Uint8List> getClubImagesByFolder(String fileName, String folder) async{
    String finalPath = "";

      finalPath = "$folder/$fileName";

    try{
      var data = await supabase.storage.from('club_me_banner_images').download(finalPath);
      log.d("getClubImagesByFolder: Finished successfully. File: $folder/$fileName");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getClubImagesByFolder. Error: ${e.toString()}. finalPath: $finalPath");
      createErrorLog("Error in SupabaseService. Function: getClubImagesByFolder. Error: ${e.toString()}. finalPath: $finalPath");
      return Uint8List(0);
    }
  }

  Future<Uint8List?> getInfoScreenImage(String fileName) async{
    try{
      var data = await supabase.storage.from('info_screen').download(fileName);
      log.d("getInfoScreenImage: Finished successfully. File: $fileName");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getInfoScreenImage. Error: ${e.toString()}. finalPath: $fileName");
      createErrorLog("Error in SupabaseService. Function: getInfoScreenImage. Error: ${e.toString()}. finalPath: $fileName");
      return null;
    }
  }

  Future<Uint8List?> getBannerImage(String fileName, String folder) async {

    String finalPath = "";

    if(folder.isEmpty){
      finalPath = fileName;
    }else{
      finalPath = "$folder/$fileName";
    }

    try{
      var data = await supabase.storage.from('club_me_banner_images').download(finalPath);
      log.d("getBannerImage: Finished successfully. File: $folder/$fileName");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getBannerImage. Error: ${e.toString()}. finalPath: $finalPath");
      createErrorLog("Error in SupabaseService. Function: getBannerImage. Error: ${e.toString()}. finalPath: $finalPath");
      return null;
    }
  }
  Future<Uint8List> getClubVideo(String uuid) async {

    String path = 'club_stories/$uuid.mp4';

    try{
      var data = await supabase.storage.from('club_me_stories').download(path);
      log.d("getVideo: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in SupabaseService. Function: getClubVideo. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: getClubVideo. Error: ${e.toString()}. path: $path");
      return Uint8List(0);
    }
  }
  Future<int> uploadEventContent(var content, String fileName, String eventId) async {
    try{
      var data = await supabase.storage.from('club_me_stories').upload(
        'event_content/$fileName',
        content,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      addContentPathToEvent(eventId, fileName);
      log.d("uploadEventContent: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: uploadEventContent. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: uploadEventContent. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<int> insertClubStory(
      var video,
      String uuid,
      UserDataProvider userDataProvider,
      StateProvider stateProvider
      ) async {
    try{
      var data = await supabase.storage.from('club_me_stories').upload(
        'club_stories/$uuid.mp4',
        video,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      addVideoPathToClub(uuid, userDataProvider, stateProvider);
      log.d("insertVideo: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: insertClubVideo. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: insertClubVideo. Error: ${e.toString()}");
      return 1;
    }
  }

  Future<int> deleteOldClubStory(
      String storyId
      ) async{
    try{
      var data = await supabase.storage.from('club_me_stories').remove(
        ['club_stories/$storyId.mp4']
      );
      log.d("deleteOldClubStory: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: deleteOldClubStory. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: deleteOldClubStory. Error: ${e.toString()}");
      return 1;
    }
  }

  Future<int> insertEventContent(
      var content, String fileName, String eventId, StateProvider stateProvider
      ) async {
    try{
      var data = await supabase.storage.from('club_me_stories').upload(
        'event_content/$fileName',
        content,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      log.d("insertEventContent: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: insertEventContent. Error: ${e.toString()}. Vars: fileName, $fileName, eventId, $eventId");
      createErrorLog("Error in SupabaseService. Function: insertEventContent. Error: ${e.toString()}");
      return 1;
    }
  }


  Future<int> insertStoryWatch(String fileName, String userId) async{
    try{
      var data = await supabase
          .from("club_me_story_watches")
          .insert({
        'file_name': fileName,
        'user_id': userId
      }).select();
      log.d("insertStoryWatch: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: insertStoryWatch. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: insertStoryWatch. Error: ${e.toString()}");
      return 1;
    }
  }


  // MISC


  Future<PostgrestList> checkIfEMailExists(String eMail) async{
    try{
      var data = await supabase
          .from('club_me_users')
          .select()
          .eq("e_mail", eMail);
      log.d("checkIfEMailExists: Finished successfully.Response: $data");
      if(data.isNotEmpty){
        return data;
      }else{
        return [];
      }
    }
    catch(e){
      log.d("Error in SupabaseService. Function: checkIfEMailExists. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: checkIfEMailExists. Error: ${e.toString()}");
      return [];
    }
  }

  Future<int> saveForgotPassword(String email, String name) async{

    var uuid = const Uuid();
    var uuidV4 = uuid.v4();

    try{
      final data = await supabase
          .from("forgot_password_logs")
          .insert({
        "e_mail": email,
        "name": name,
        "one_time_password": uuidV4.substring(0, 8)
      });
      log.d("saveForgotPassword: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in SupabaseService. Function: saveForgotPassword. Error: $e");
      createErrorLog("Error in SupabaseService. Function: saveForgotPassword. Error: ${e.toString()}");
      return 1;
    }
  }
  Future<PostgrestList> checkOneTimePassword(String oneTimePassword) async{
    try{
      var data = await supabase
          .from('forgot_password_logs')
          .select()
          .eq("one_time_password", oneTimePassword);
      log.d("checkOneTimePassword: Finished successfully.Response: $data");
      if(data.isNotEmpty){
        print("test: ${data.first['e_mail']}");
        return await getUserByEMail(data.first['e_mail']);
      }else{
        return [];
      }
    }
    catch(e){
      log.d("Error in SupabaseService. Function: checkOneTimePassword. Error: ${e.toString()}");
      createErrorLog("Error in SupabaseService. Function: checkOneTimePassword. Error: ${e.toString()}");
      return [];
    }
  }


  // ERROR

  void createErrorLog(String e) async{
    try{
      await supabase.from('error_log').insert({
        'error_message': e
      }).select();
    }catch(e){
      print("Error in createErrorLog: $e");
      /// TODO: If error log fails, save to local until it could be transfered successfully.
    }
  }



}

