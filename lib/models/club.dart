class ClubMeClub{

  ClubMeClub({
    required this.clubName,
    required this.NOfPeople,
    required this.distance,
    required this.imagePath,
    required this.genre,
    required this.price
  });

  String clubName;
  String imagePath;
  String distance;
  String genre;
  String NOfPeople;
  String price;

  String getImagePath(){
    return imagePath;
  }

  String getDistance(){
    return distance;
  }
  String getNOfPeople(){
    return NOfPeople;
  }
  String getGenre(){
    return genre;
  }
  String getClubName(){
    return clubName;
  }
  String getPrice(){
    return price;
  }

}