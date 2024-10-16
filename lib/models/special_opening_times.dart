class SpecialOpeningTimes {
  List<SpecialDays>? specialDays;

  SpecialOpeningTimes({this.specialDays});

  SpecialOpeningTimes.fromJson(Map<String, dynamic> json) {
    if (json['special_days'] != null) {
      specialDays = <SpecialDays>[];
      json['special_days'].forEach((v) {
        specialDays!.add(new SpecialDays.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.specialDays != null) {
      data['special_days'] = this.specialDays!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SpecialDays {
  int? day;
  int? month;
  int? year;
  int? openingHour;
  int? closingHour;
  int? openingHalfAnHour;
  int? closingHalfAnHour;

  SpecialDays(
      {this.day,
        this.month,
        this.year,
        this.openingHour,
        this.closingHour,
        this.openingHalfAnHour,
        this.closingHalfAnHour});

  SpecialDays.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    month = json['month'];
    year = json['year'];
    openingHour = json['opening_hour'];
    closingHour = json['closing_hour'];
    openingHalfAnHour = json['opening_half_an_hour'];
    closingHalfAnHour = json['closing_half_an_hour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['month'] = this.month;
    data['year'] = this.year;
    data['opening_hour'] = this.openingHour;
    data['closing_hour'] = this.closingHour;
    data['opening_half_an_hour'] = this.openingHalfAnHour;
    data['closing_half_an_hour'] = this.closingHalfAnHour;
    return data;
  }
}