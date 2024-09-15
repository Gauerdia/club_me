import 'package:club_me/models/club_me_discount_template.dart';
import 'package:club_me/models/club_me_event_template.dart';
import 'package:club_me/models/club_me_local_discount.dart';
import 'package:club_me/models/discount.dart';
import 'package:club_me/models/event_template.dart';
import 'package:club_me/models/parser/discount_to_local_discount_parser.dart';
import 'package:club_me/services/supabase_service.dart';
import 'package:hive/hive.dart';
import '../models/club_me_user_data.dart';
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

  Future<Box<String>> get _clubMeEventBox async => await Hive.openBox<String>(_clubMeFavoriteEventsBoxName);
  Future<Box<String>> get _clubMeClubBox async => await Hive.openBox<String>(_clubMeFavoriteClubsBoxName);
  Future<Box<String>> get _clubMeDiscountBox async => await Hive.openBox<String>(_clubMeFavoriteDiscountsBoxName);
  Future<Box<String>> get _clubMeAttendingEventsBox async => await Hive.openBox<String>(_clubMeAttendingEventsName);
  Future<Box<ClubMeUserData>> get _clubMeUserClubBox async => await Hive.openBox<ClubMeUserData>(_clubMeUserDataBoxName);
  Future<Box<ClubMeEventTemplate>> get _clubMeEventTemplatesBox async => await Hive.openBox<ClubMeEventTemplate>(_clubMeEventTemplatesName);
  Future<Box<ClubMeDiscountTemplate>> get _clubMeDiscountTemplatesBox async => await Hive.openBox<ClubMeDiscountTemplate>(_clubMeDiscountTemplatesName);
  Future<Box<ClubMeLocalDiscount>> get _clubMeLocalDiscountsBox async => await Hive.openBox<ClubMeLocalDiscount>(_clubMeLocalDiscountsName);

  // We save all discounts locally so that bad internet connection doesn't impede
  // the use of the discounts.
  Future<List<ClubMeLocalDiscount>> getAllLocalDiscounts() async {
    var box = await _clubMeLocalDiscountsBox;
    return box.values.toList();
  }
  Future<void> resetLocalDiscounts() async {
    var box = await _clubMeLocalDiscountsBox;
    await box.deleteAll(box.keys);
  }
  Future<void> deleteLocalDiscount(String discountId) async {
    var discounts = await getAllLocalDiscounts();
    var index = discounts.indexWhere((element) => element.discountId == discountId);

    var box = await _clubMeLocalDiscountsBox;
    await box.deleteAt(index);
  }
  Future<void> addLocalDiscount(ClubMeDiscount clubMeDiscount) async {

    ClubMeLocalDiscount clubMeLocalDiscount = discountToLocalDiscountParser(clubMeDiscount);

    var box = await _clubMeLocalDiscountsBox;
    await box.add(clubMeLocalDiscount);
  }
  Future<void> updateLocalDiscount(ClubMeDiscount clubMeDiscount) async{

    ClubMeLocalDiscount clubMeLocalDiscount = discountToLocalDiscountParser(clubMeDiscount);

    var discounts = await getAllLocalDiscounts();
    var index = discounts.indexWhere((element) => element.discountId == clubMeDiscount.getDiscountId());

    var box = await _clubMeLocalDiscountsBox;
    await box.putAt(index, clubMeLocalDiscount);
  }


  Future<void> addDiscountTemplate(ClubMeDiscountTemplate discountTemplate) async {
    try{
      var box = await _clubMeDiscountTemplatesBox;
      await box.add(discountTemplate);
      log.d("addDiscountTemplate: Finished successfully");
    }catch(e){
      log.d("Error in addDiscountTemplate: $e");
      _supabaseService.createErrorLog(e.toString());
    }
  }
  Future<List<ClubMeDiscountTemplate>> getAllDiscountTemplates() async {
    var box = await _clubMeDiscountTemplatesBox;
    return box.values.toList();
  }
  Future<void> deleteTemplateDiscount(String templateId) async {

    var discounts = await getAllDiscountTemplates();
    var index = discounts.indexWhere((element) => element.getTemplateId() == templateId);

    var box = await _clubMeDiscountBox;
    await box.deleteAt(index);
  }

  // Event template
  Future<void> addClubMeEventTemplate(ClubMeEventTemplate clubMeEventTemplate) async {
    var box = await _clubMeEventTemplatesBox;
    await box.add(clubMeEventTemplate);
  }
  Future<List<ClubMeEventTemplate>> getAllClubMeEventTemplates() async {
    var box = await _clubMeEventTemplatesBox;
    return box.values.toList();
  }
  Future<void> deleteClubMeEventTemplate(String templateId) async {

    var events = await getAllClubMeEventTemplates();
    var index = events.indexWhere((element) => element.getTemplateId() == templateId);

    var box = await _clubMeDiscountBox;
    await box.deleteAt(index);
  }

  // USER DATA
  Future<List<ClubMeUserData>> getUserData() async{
    var box = await _clubMeUserClubBox;
    return box.values.toList();
  }
  Future<void> addUserData(ClubMeUserData clubMeUserData) async {
    var box = await _clubMeUserClubBox;
    await box.add(clubMeUserData);
  }

  Future<void> resetUserData() async {
    var box = await _clubMeUserClubBox;
    await box.deleteAll(box.keys);
  }


  // ATTENDING EVENTS
  Future<List<String>> getAttendingEvents() async{
    var box = await _clubMeAttendingEventsBox;
    return box.values.toList();
  }
  Future<void> insertAttendingEvent(String eventId) async{
    var box = await _clubMeAttendingEventsBox;
    await box.add(eventId);
  }
  Future<void> deleteAttendingEvent(String eventId) async{

    var events = await getAttendingEvents();
    var index = events.indexWhere((element) => element == eventId);

    var box = await _clubMeAttendingEventsBox;
    await box.deleteAt(index);

  }

  // FAVORITE EVENTS
  Future<List<String>> getFavoriteEvents() async {
    var box = await _clubMeEventBox;
    return box.values.toList();
  }
  Future<void> insertFavoriteEvent(String eventId) async{
    var box = await _clubMeEventBox;
    await box.add(eventId);
  }
  Future<void> deleteFavoriteEvent(String eventId) async{

    var events = await getFavoriteEvents();

    var index = events.indexWhere((element) => element == eventId);

    var box = await _clubMeEventBox;
    await box.deleteAt(index);
  }

  // DISCOUNTS
  Future<List<String>> getFavoriteDiscounts() async {
    var box = await _clubMeDiscountBox;
    return box.values.toList();
  }
  Future<void> insertFavoriteDiscount(String discountId) async {
    var box = await _clubMeDiscountBox;
    await box.add(discountId);
  }
  Future<void> deleteFavoriteDiscount(String discountId) async {

    var discounts = await getFavoriteDiscounts();
    var index = discounts.indexWhere((element) => element == discountId);

    var box = await _clubMeDiscountBox;
    await box.deleteAt(index);
  }

  // CLUBS
  Future<List<String>> getFavoriteClubs() async {
    var box = await _clubMeClubBox;
    return box.values.toList();
  }
  Future<void> insertFavoriteClub(String clubId) async {
    var box = await _clubMeClubBox;
    await box.add(clubId);
  }
  Future<void> deleteFavoriteClub(String clubId) async {

    var clubs = await getFavoriteClubs();
    var index = clubs.indexWhere((element) => element == clubId);

    var box = await _clubMeClubBox;
    await box.deleteAt(index);
  }




}