import 'package:hive/hive.dart';

import '7_days.dart';
part '6_opening_times.g.dart';

@HiveType(typeId: 6)
class OpeningTimes {

  @HiveField(0)
  List<Days>? days;

  OpeningTimes({this.days});

  OpeningTimes.fromJson(Map<String, dynamic> json) {
    if (json['days'] != null) {
      days = <Days>[];
      json['days'].forEach((v) {
        days!.add(Days.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (days != null) {
      data['days'] = days!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}