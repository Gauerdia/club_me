

import 'package:hive/hive.dart';

class HiveService{

  final String _clubMeFavoriteEventsBoxName = "clubMeFavoriteEventsBox";
  final String _clubMeFavoriteClubsBoxName = "clubMeFavoriteClubsBox";
  final String _clubMeFavoriteDiscountsBoxName = "clubMeFavoriteDiscountsBox";
  final String _clubMeAttendingEventsName = "clubMeAttendingEventsBox";

  Future<Box<String>> get _clubMeEventBox async => await Hive.openBox<String>(_clubMeFavoriteEventsBoxName);
  Future<Box<String>> get _clubMeClubBox async => await Hive.openBox<String>(_clubMeFavoriteClubsBoxName);
  Future<Box<String>> get _clubMeDiscountBox async => await Hive.openBox<String>(_clubMeFavoriteDiscountsBoxName);

  Future<Box<String>> get _clubMeAttendingEventsBox async => await Hive.openBox<String>(_clubMeAttendingEventsName);

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

}