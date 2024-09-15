class OpeningTimes {
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

class Days {
  int? day;
  int? openingHour;
  int? closingHour;

  Days({this.day, this.openingHour, this.closingHour});

  Days.fromJson(Map<String, dynamic> json) {

    day = json['day'];
    openingHour = json['opening_hour'];
    closingHour = json['closing_hour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['opening_hour'] = openingHour;
    data['closing_hour'] = closingHour;
    return data;
  }
}