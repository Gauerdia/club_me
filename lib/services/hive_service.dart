import 'package:club_me/models/discount.dart';
import 'package:club_me/models/hive_models/5_club_me_used_discount.dart';
import 'package:club_me/models/parser/discount_to_local_discount_parser.dart';
import 'package:club_me/services/supabase_service.dart';
import 'package:hive/hive.dart';
import '../models/hive_models/0_club_me_user_data.dart';
import '../models/hive_models/1_club_me_discount_template.dart';
import '../models/hive_models/2_club_me_local_discount.dart';
import '../models/hive_models/3_club_me_event_template.dart';
import '../models/hive_models/4_temp_geo_location_data.dart';
import '../shared/logger.util.dart';

class HiveService{

  final log = getLogger();

  final SupabaseService _supabaseService = SupabaseService();

  final String _clubMeFavoriteEventsBoxName = "clubMeFavoriteEventsBox";
  final String _clubMeFavoriteClubsBoxName = "clubMeFavoriteClubsBox";
  final String _clubMeFavoriteDiscountsBoxName = "clubMeFavoriteDiscountsBox";
  final String _clubMeAttendingEventsName = "clubMeAttendingEventsBox";

  final String _clubMeEventTemplatesName = "clubMeEventTemplateBox";
  final String _clubMeDiscountTemplatesName = "clubMeDiscountTemplatesBox";
  final String _clubMeLocalDiscountsName = "clubMeLocalDiscountsBox";

  final String _clubMeUserDataBoxName = "clubMeUserDataBox";

  final String _tempGeoLocationDataBoxName ="tempGeoLocationDataBox";

  final String _clubMeUsedDiscountsBoxName = "clubMeUsedDiscountsBox";

  Future<Box<String>> get _clubMeEventBox async => await Hive.openBox<String>(_clubMeFavoriteEventsBoxName);
  Future<Box<String>> get _clubMeClubBox async => await Hive.openBox<String>(_clubMeFavoriteClubsBoxName);
  Future<Box<String>> get _clubMeDiscountBox async => await Hive.openBox<String>(_clubMeFavoriteDiscountsBoxName);
  Future<Box<String>> get _clubMeAttendingEventsBox async => await Hive.openBox<String>(_clubMeAttendingEventsName);
  Future<Box<ClubMeUserData>> get _clubMeUserClubBox async => await Hive.openBox<ClubMeUserData>(_clubMeUserDataBoxName);
  Future<Box<ClubMeEventTemplate>> get _clubMeEventTemplatesBox async => await Hive.openBox<ClubMeEventTemplate>(_clubMeEventTemplatesName);
  Future<Box<ClubMeDiscountTemplate>> get _clubMeDiscountTemplatesBox async => await Hive.openBox<ClubMeDiscountTemplate>(_clubMeDiscountTemplatesName);
  Future<Box<ClubMeLocalDiscount>> get _clubMeLocalDiscountsBox async => await Hive.openBox<ClubMeLocalDiscount>(_clubMeLocalDiscountsName);
  Future<Box<TempGeoLocationData>> get _tempGeoLocationDataBox async => await Hive.openBox<TempGeoLocationData>(_tempGeoLocationDataBoxName);

  Future<Box<ClubMeUsedDiscount>> get _clubMeUsedDiscountsBox async => await Hive.openBox<ClubMeUsedDiscount>(_clubMeUsedDiscountsBoxName);

  Future<void> addTempGeoLocationData(TempGeoLocationData tempGeoLocationData) async{
    try{
      var box = await _tempGeoLocationDataBox;
      await box.add(tempGeoLocationData);
    }catch(e){
      log.d("HiveService. Function: addTempGeoLocationData. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }

  // We save all discounts locally so that bad internet connection doesn't impede
  // the use of the discounts.
  Future<List<ClubMeLocalDiscount>> getAllLocalDiscounts() async {
    try{
      var box = await _clubMeLocalDiscountsBox;
      return box.values.toList();
    }catch(e){
      log.d("HiveService. Function: getAllLocalDiscounts. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return [];
    }
  }
  Future<void> resetLocalDiscounts() async {
    try{
      var box = await _clubMeLocalDiscountsBox;
      await box.deleteAll(box.keys);
    }catch(e){
      log.d("HiveService. Function: resetLocalDiscounts. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<void> deleteLocalDiscount(String discountId) async {

    try{
      var discounts = await getAllLocalDiscounts();
      var index = discounts.indexWhere((element) => element.discountId == discountId);
      var box = await _clubMeLocalDiscountsBox;
      await box.deleteAt(index);
    }catch(e){
      log.d("HiveService. Function: deleteLocalDiscount. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }

  }

  Future<void> addLocalDiscount(ClubMeDiscount clubMeDiscount) async {
    try{
      ClubMeLocalDiscount clubMeLocalDiscount = discountToLocalDiscountParser(clubMeDiscount);

      var box = await _clubMeLocalDiscountsBox;
      await box.add(clubMeLocalDiscount);
    }catch(e){
      log.d("HiveService. Function: addLocalDiscount. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }

  Future<void> updateLocalDiscount(ClubMeDiscount clubMeDiscount) async{
    try{
      ClubMeLocalDiscount clubMeLocalDiscount = discountToLocalDiscountParser(clubMeDiscount);

      var discounts = await getAllLocalDiscounts();
      var index = discounts.indexWhere((element) => element.discountId == clubMeDiscount.getDiscountId());

      var box = await _clubMeLocalDiscountsBox;
      await box.putAt(index, clubMeLocalDiscount);
    }catch(e){
      log.d("HiveService. Function: updateLocalDiscount. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }

  // DISCOUNT TEMPLATE
  Future<void> addDiscountTemplate(ClubMeDiscountTemplate discountTemplate) async {
    try{
      var box = await _clubMeDiscountTemplatesBox;
      await box.add(discountTemplate);
      log.d("addDiscountTemplate: Finished successfully");
    }catch(e){
      log.d("HiveService. Function: addDiscountTemplate. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<List<ClubMeDiscountTemplate>> getAllDiscountTemplates() async {
    try{
      var box = await _clubMeDiscountTemplatesBox;
      return box.values.toList();
    }catch(e){
      log.d("HiveService. Function: getAllDiscountTemplates. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return [];
    }
  }

  Future<int> deleteClubMeDiscountTemplate(String templateId) async {
    try{
      var discounts = await getAllDiscountTemplates();
      var index = discounts.indexWhere(
              (element) => element.getTemplateId() == templateId
      );

      var box = await _clubMeDiscountTemplatesBox;
      await box.deleteAt(index);
      log.d("deleteClubMeDiscountTemplate: Finished successfully");
      return 0;
    }catch(e){
      log.d("HiveService. Function: deleteClubMeDiscountTemplate. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return 1;
    }
  }



  // Event template
  Future<void> addClubMeEventTemplate(ClubMeEventTemplate clubMeEventTemplate) async {
    try{
      var box = await _clubMeEventTemplatesBox;
      await box.add(clubMeEventTemplate);
    }catch(e){
      log.d("HiveService. Function: addClubMeEventTemplate. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<List<ClubMeEventTemplate>> getAllClubMeEventTemplates() async {
    try{
      var box = await _clubMeEventTemplatesBox;
      return box.values.toList();
    }catch(e){
      log.d("HiveService. Function: getAllClubMeEventTemplates. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return [];
    }
  }
  Future<int> deleteClubMeEventTemplate(String templateId) async {
    try{
      var events = await getAllClubMeEventTemplates();
      var index = events.indexWhere(
              (element) => element.getTemplateId() == templateId
      );

      var box = await _clubMeEventTemplatesBox;
      await box.deleteAt(index);
      return 0;
    }catch(e){
      log.d("HiveService. Function: deleteClubMeEventTemplate. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return 1;
    }
  }



  // USER DATA
  Future<List<ClubMeUserData>> getUserData() async{
    try{
      var box = await _clubMeUserClubBox;
      return box.values.toList();
    }catch(e){
      log.d("HiveService. Function: getUserData. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return [];
    }
  }
  Future<void> addUserData(ClubMeUserData clubMeUserData) async {
    try{
      var box = await _clubMeUserClubBox;
      await box.add(clubMeUserData);

    }catch(e){
      log.d("HiveService. Function: addUserData. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<void> resetUserData() async {


    try{
      var box = await _clubMeUserClubBox;
      await box.deleteAll(box.keys);
    }catch(e){
      log.d("HiveService. Function: resetUserData. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }

  }


  // ATTENDING EVENTS
  Future<List<String>> getAttendingEvents() async{
    try{
      var box = await _clubMeAttendingEventsBox;
      return box.values.toList();
    }catch(e){
      log.d("HiveService. Function: getAttendingEvents. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return [];
    }
  }
  Future<void> insertAttendingEvent(String eventId) async{
    try{
      var box = await _clubMeAttendingEventsBox;
      await box.add(eventId);
    }catch(e){
      log.d("HiveService. Function: insertAttendingEvent. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<void> deleteAttendingEvent(String eventId) async{
    try{
      var events = await getAttendingEvents();
      var index = events.indexWhere((element) => element == eventId);

      var box = await _clubMeAttendingEventsBox;
      await box.deleteAt(index);

    }catch(e){
      log.d("HiveService. Function: deleteAttendingEvent. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }

  // FAVORITE EVENTS
  Future<List<String>> getFavoriteEvents() async {
    try{
      var box = await _clubMeEventBox;
      return box.values.toList();
    }catch(e){
      log.d("HiveService. Function: getFavoriteEvents. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return [];
    }
  }
  Future<void> insertFavoriteEvent(String eventId) async{
    try{
      var box = await _clubMeEventBox;
      await box.add(eventId);
    }catch(e){
      log.d("HiveService. Function: insertFavoriteEvent. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<void> deleteFavoriteEvent(String eventId) async{
    try{
      var events = await getFavoriteEvents();

      var index = events.indexWhere((element) => element == eventId);

      var box = await _clubMeEventBox;
      await box.deleteAt(index);
    }catch(e){
      log.d("HiveService. Function: deleteFavoriteEvent. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }

  }

  // DISCOUNTS
  Future<List<String>> getFavoriteDiscounts() async {

    try{
      var box = await _clubMeDiscountBox;
      return box.values.toList();
    }catch(e){
      log.d("HiveService. Function: getFavoriteDiscounts. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return [];
    }
  }
  Future<void> insertFavoriteDiscount(String discountId) async {
    try{
      var box = await _clubMeDiscountBox;
      await box.add(discountId);
    }catch(e){
      log.d("HiveService. Function: insertFavoriteDiscount. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<void> deleteFavoriteDiscount(String discountId) async {
    try{
      var discounts = await getFavoriteDiscounts();
      var index = discounts.indexWhere((element) => element == discountId);

      var box = await _clubMeDiscountBox;
      await box.deleteAt(index);
    }catch(e){
      log.d("HiveService. Function: deleteFavoriteDiscount. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }

  // CLUBS
  Future<List<String>> getFavoriteClubs() async {
    try{
      var box = await _clubMeClubBox;
      return box.values.toList();
    }catch(e){
      log.d("HiveService. Function: getFavoriteClubs. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return [];
    }
  }
  Future<void> insertFavoriteClub(String clubId) async {
    try{
      var box = await _clubMeClubBox;
      await box.add(clubId);
    }catch(e){
      log.d("HiveService. Function: insertFavoriteClub. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<void> deleteFavoriteClub(String clubId) async {
    try{
      var clubs = await getFavoriteClubs();
      var index = clubs.indexWhere((element) => element == clubId);

      var box = await _clubMeClubBox;
      await box.deleteAt(index);
    }catch(e){
      log.d("HiveService. Function: deleteFavoriteClub. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }


  // Used Discounts
  Future<List<ClubMeUsedDiscount>> getUsedDiscounts() async{
    try{
      var box = await _clubMeUsedDiscountsBox;
      return box.values.toList();
    }catch(e){
      log.d("HiveService. Function: getUsedDiscounts. Error: $e");
      _supabaseService.createErrorLog(e.toString());
      return [];
    }
  }
  Future<void> insertUsedDiscount(ClubMeUsedDiscount clubMeUsedDiscount) async{

    try{

      late ClubMeUsedDiscount updatedDiscount;
      bool updateInsteadOfInsert = false;

      var discounts = await getUsedDiscounts();

      for(var discount in discounts){
        if(discount.discountId == clubMeUsedDiscount.discountId){
          updatedDiscount = discount;
          updatedDiscount.howManyTimes++;
          updateInsteadOfInsert = true;
        }
      }

      if(updateInsteadOfInsert){
        var index = discounts.indexWhere((element) => element.discountId == clubMeUsedDiscount.discountId);
        var box = await _clubMeUsedDiscountsBox;
        await box.putAt(index, updatedDiscount);
      }else{
        var box = await _clubMeUsedDiscountsBox;
        await box.add(clubMeUsedDiscount);
      }

    }catch(e){
      log.d("HiveService. Function: insertUsedDiscount. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<void> deleteUsedDiscount(String discountId) async{
    try{
      var discounts = await getUsedDiscounts();
      var index = discounts.indexWhere((element) => element.discountId == discountId);

      var box = await _clubMeUsedDiscountsBox;
      await box.deleteAt(index);
    }catch(e){
      log.d("HiveService. Function: deleteUsedDiscount. Error: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }

}