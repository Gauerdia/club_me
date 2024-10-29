
import 'package:club_me/models/hive_models/7_days.dart';
import 'package:club_me/models/special_opening_times.dart';

Days SpecialDaysToDaysParser(SpecialDays specialDays){

  return Days(
    day: DateTime(specialDays.year!, specialDays.month!, specialDays.day!).weekday,
    openingHour: specialDays.openingHour,
    closingHour: specialDays.closingHour,
    closingHalfAnHour: specialDays.closingHalfAnHour,
    openingHalfAnHour: specialDays.openingHalfAnHour,
  );

}