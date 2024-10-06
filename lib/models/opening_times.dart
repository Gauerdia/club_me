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
  int? openingHalfAnHour;
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