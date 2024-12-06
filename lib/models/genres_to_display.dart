class GenresToDisplay {
  List<Genres> genres = [];

  GenresToDisplay();

  GenresToDisplay.fromJson(Map<String, dynamic> json) {
    if (json['genres'] != null) {
      genres = <Genres>[];
      json['genres'].forEach((v) {
        genres.add(new Genres.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.genres != null) {
      data['genres'] = this.genres.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Genres {
  String? filterGenre;
  String? displayGenre;

  Genres({this.filterGenre, this.displayGenre});

  Genres.fromJson(Map<String, dynamic> json) {
    filterGenre = json['filterGenre'];
    displayGenre = json['displayGenre'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filterGenre'] = this.filterGenre;
    data['displayGenre'] = this.displayGenre;
    return data;
  }
}
