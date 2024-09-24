import 'dart:async';
import 'dart:typed_data';
import 'package:club_me/main.dart';
import 'package:club_me/models/club_me_user_data.dart';
import 'package:club_me/models/club_offers.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/models/front_page_images.dart';
import 'package:club_me/models/price_list.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:club_me/shared/logger.util.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/club.dart';
import '../models/discount.dart';
import 'package:logging/logging.dart';

class SupabaseService{

  final log = getLogger();


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
      log.d("Error in saveUsersGeoLocation: $e");
      createErrorLog(e.toString());
      return 1;
    }
  }


  // EVENTS

  Future<PostgrestList> getAllEvents() async{
    try{
      var data = await supabase
          .from('club_me_events')
          .select();
      return data;
    }
    catch(e){
      log.d("Error in getAllEvents: $e");
      createErrorLog(e.toString());
      return [];
    }
  }

  Future<PostgrestList> getEventsOfSpecificClub(String clubId) async{
    try{
      return await supabase
          .from('club_me_events')
          .select()
          .match({
            'club_id': clubId
          });
    }catch(e){
      log.d("Error in getEventsOfSpecificClub: $e");
      createErrorLog(e.toString());
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

        "banner_id" : userDataProvider.getUserClubEventBannerId(),
        "music_genres" : clubMeEvent.getMusicGenres(),

        "event_marketing_file_name": clubMeEvent.getEventMarketingFileName(),
        "event_marketing_created_at": clubMeEvent.getEventMarketingFileName().isNotEmpty ? DateTime.now().toString() : null,
        "priority_score": clubMeEvent.getPriorityScore(),
        "opening_times": clubMeEvent.getOpeningTimes().toJson(),

        "is_repeated_days": clubMeEvent.getIsRepeatedDays(),
        "ticket_link": clubMeEvent.getTicketLink()

      });
      log.d("insertEvent: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in insertEvent: $e");
      createErrorLog(e.toString());
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
      log.d("Error in updateEvent: $e");
      createErrorLog(e.toString());
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
          'music_genres': updatedEvent.getMusicGenres(),
          'event_price': updatedEvent.getEventPrice(),
          'event_description': updatedEvent.getEventDescription(),
          'event_marketing_file_name': updatedEvent.getEventMarketingFileName(),
          'event_marketing_created_at': updatedEvent.getEventMarketingFileName().isNotEmpty ? DateTime.now().toString() : null,
          'ticket_link': updatedEvent.getTicketLink(),
          'is_repeated': updatedEvent.getIsRepeated()
        }).match({
        'event_id' : updatedEvent.getEventId()
      });
      log.d("updateCompleteEvent: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in updateCompleteEvent: $e");
      createErrorLog(e.toString());
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
      log.d("Error in deleteEvent: $e");
      createErrorLog(e.toString());
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
      log.d("Error in updateClubOffers: $e");
      createErrorLog(e.toString());
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
      log.d("Error in checkIfClubPwIsLegit: $e");
      createErrorLog(e.toString());
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
      log.d("Error in getAllClubs: $e");
      createErrorLog(e.toString());
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
      log.d("Error in getSpecificClub: $e");
      createErrorLog(e.toString());
      return [];
    }
  }

  void insertClub(ClubMeClub clubMeClub) async{

    PriceList testPrices = PriceList(
        groups: ["Cocktails, Alkoholfreies"],
        elements: [
          ["Mojito"],
          ["Fanta"]
        ],
        prices: [
          ["12"],
          ["5"]
        ]
    );

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
        'banner_id':clubMeClub.getBannerId(),
        'story_path': "",
        'front_page_images': dataJson
      }).select();
      log.d("insertClub: Finished successfully. Response: $data");
    }catch(e){
      log.d("Error in insertClub: $e");
      createErrorLog(e.toString());
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
      log.d("Error in updateClub: $e");
      createErrorLog(e.toString());
      return 1;
    }
  }

  void addVideoPathToClub(String uuid, UserDataProvider userDataProvider) async{
    try{
      var data = await supabase
          .from('club_me_clubs')
          .update({
        'story_id' : uuid,
        'story_created_at' : DateTime.now().toString()
      }).match({
        'club_id': userDataProvider.getUserClubId()
      });
      userDataProvider.setUserClubStoryId(uuid);
      log.d("addVideoPathToClub: Finished successfully. Response: $data");
    }catch(e){
      log.d("Error in addVideoPathToClub: $e");
      createErrorLog(e.toString());
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
      log.d("Error in addContentPathToEvent: $e");
      createErrorLog(e.toString());
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
      log.d("Error in addEventMarketingToEvent: $e");
      createErrorLog(e.toString());
    }

  }

  Future<int> updateClubContactInfo(
      String clubId,
      String contactName,
      String contactStreet,
      int contactStreetNumber,
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
      log.d("Error in updateClubContactInfo: $e");
      createErrorLog(e.toString());
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
      log.d("Error in deleteDiscount: $e");
      createErrorLog(e.toString());
      return 1;
    }
  }

  Future<PostgrestList> getAllDiscounts() async{
    try{
      var data = await supabase
          .from('club_me_discounts')
          .select();
      log.d("getAllDiscounts: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in getAllDiscounts: $e");
      createErrorLog(e.toString());
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
        'banner_id':clubMeDiscount.getBannerId(),

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

        'is_repeated_days': clubMeDiscount.getIsRepeatedDays()

      }).select();
      log.d("insertDiscount: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in insertDiscount: $e");
      createErrorLog(e.toString());
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
      log.d("Error in getDiscountsOfSpecificClub: $e");
      createErrorLog(e.toString());
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
      log.d("Error in updateDiscount: $e");
      createErrorLog(e.toString());
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

        'is_repeated_days': clubMeDiscount.getIsRepeatedDays()

      }).match({
        'discount_id' : clubMeDiscount.getDiscountId()
      });
      log.d("updateCompleteDiscount: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in updateCompleteDiscount: $e");
      createErrorLog(e.toString());
      return 1;
    }
  }

  // FRONTPAGE IMAGES

  Future<Uint8List> getFrontPageImage(String fileName) async {

    try{
      var data = await supabase
          .storage
          .from('club_me_frontpage_images')
          .download(fileName);
      log.d("getFrontPageImage: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in getFrontPageImage: $e");
      createErrorLog(e.toString());
      return Uint8List(0);
    }
  }

  Future<int> uploadFrontPageImage(
      var content,
      String fileName,
      String clubId,
      FrontPageImages frontPageImages
      ) async {
    try{
      var data = await supabase.storage.from('club_me_frontpage_images').upload(
        fileName,
        content,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      updateFrontPageImageInClub(clubId, frontPageImages);
      log.d("uploadEventContent: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in uploadFrontPageImage: $e");
      createErrorLog(e.toString());
      return 1;
    }
  }

  Future<int> updateFrontPageImageInClub(String clubId, FrontPageImages frontPageImages) async{
    try{
      var data = await supabase
          .from('club_me_clubs')
          .update({
        'front_page_images' : frontPageImages.toJson(),
      }).match({
        'club_id': clubId
      });
      log.d("updateFrontPageImageInClub: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in updateFrontPageImageInClub: $e");
      createErrorLog(e.toString());
      return 1;
    }
  }

  Future<int> deleteFrontPageFromStorage(String fileName) async{
    try{
      var data = await supabase
        .storage
        .from('club_me_frontpage_images')
        .remove([fileName]);
      log.d("deleteFrontPageFromStorage: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in deleteFrontPageFromStorage: $e");
      createErrorLog(e.toString());
      return 1;
    }
  }

  // USERS

  Future<int> insertUserDate(ClubMeUserData userData) async{

    try{
      var data = await supabase
          .from('club_me_users')
          .insert({
        'first_name': userData.getFirstName(),
        'last_name': userData.getLastName(),
        'e_mail': userData.getEMail(),
        'gender': userData.getGender(),
        'birth_date': userData.getBirthDate().toString(),
        'user_id': userData.getUserId()
      }).select();
      log.d("insertUserDate: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in insertUserDate: $e");
      createErrorLog(e.toString());
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
      })
      .eq('user_id', userData.getUserId());
      log.d("updateUserData: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in updateUserData: $e");
      createErrorLog(e.toString());
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
      log.d("Error in markToDeleteUserData: $e");
      createErrorLog(e.toString());
      return 1;
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
      log.d("Error in getVideo: $e");
      createErrorLog(e.toString());
      return Uint8List(0);
    }

  }

  Future<Uint8List> getBannerImage(String fileName) async {

    try{
      var data = await supabase.storage.from('club_me_banner_images').download(fileName);
      log.d("getBannerImage: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in getBannerImage: $e");
      createErrorLog(e.toString());
      return Uint8List(0);
    }
  }

  Future<Uint8List> getClubVideo(String uuid) async {

    String path = 'club_stories/$uuid.mp4';

    try{
      var data = await supabase.storage.from('club_me_stories').download(path);
      log.d("getVideo: Finished successfully. Response: $data");
      return data;
    }catch(e){
      log.d("Error in getVideo: $e");
      createErrorLog(e.toString());
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
      log.d("Error in uploadEventContent: $e");
      createErrorLog(e.toString());
      return 1;
    }
  }

  Future<int> insertClubVideo(var video, String uuid, UserDataProvider userDataProvider) async {
    try{
      var data = await supabase.storage.from('club_me_stories').upload(
        'club_stories/$uuid.mp4',
        video,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      addVideoPathToClub(uuid, userDataProvider);
      log.d("insertVideo: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in insertVideo: $e");
      createErrorLog(e.toString());
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
      // addEventMarketingToEvent(eventId, fileName, stateProvider);
      log.d("insertEventContent: Finished successfully. Response: $data");
      return 0;
    }catch(e){
      log.d("Error in insertEventContent: $e");
      createErrorLog(e.toString());
      return 1;
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

