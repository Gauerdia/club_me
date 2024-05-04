class ClubsInProximity{

  ClubsInProximity({
    required this.clubName,
    required this.price,
    required this.distance,
    required this.NOfPeople
  });

  String distance;
  String NOfPeople;
  String price;
  String clubName;

  String getDistance(){
    return distance;
  }
  String getNOfPeople(){
    return NOfPeople;
  }
  String getPrice(){
    return price;
  }
  String getClubName(){
    return clubName;
  }

}