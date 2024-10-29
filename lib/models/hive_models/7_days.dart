import 'package:hive/hive.dart';

part '7_days.g.dart';

@HiveType(typeId: 7)
class Days {

  @HiveField(0)
  int? day;
  @HiveField(1)
  int? openingHour;
  @HiveField(2)
  int? closingHour;
  @HiveField(3)
  int? openingHalfAnHour;
  @HiveField(4)
  int? closingHalfAnHour;

  Days({this.day, this.openingHour, this.closingHour, this.openingHalfAnHour, this.closingHalfAnHour});

  Days.fromJson(Map<String, dynamic> json) {

    day = json['day'];
    openingHour = json['opening_hour'];
    closingHour = json['closing_hour'];
    openingHalfAnHour = json['opening_half_an_hour'];
    closingHalfAnHour = json['closing_half_an_hour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['opening_hour'] = openingHour;
    data['closing_hour'] = closingHour;
    data['opening_half_an_hour'] = openingHalfAnHour;
    data['closing_half_an_hour'] = closingHalfAnHour;
    return data;
  }
}