import 'package:hive/hive.dart';
import 'package:age_calculator/age_calculator.dart';

part '0_club_me_user_data.g.dart';

@HiveType(typeId:  0)
class ClubMeUserData{

  ClubMeUserData({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.eMail,
    required this.gender,
    required this.userId,
    required this.profileType,
    required this.lastTimeLoggedIn,
    required this.userProfileAsClub,
    required this.clubId
  });

  @HiveField(0)
  String userId;
  @HiveField(1)
  String firstName;
  @HiveField(2)
  String lastName;
  @HiveField(3)
  DateTime birthDate;

  // 0 = male, 1 = female, 2 = diverse
  @HiveField(4)
  int gender;
  @HiveField(5)
  String eMail;

  // 0 = user, 1 = club
  @HiveField(6)
  int profileType;
  @HiveField(7)
  DateTime? lastTimeLoggedIn;
  @HiveField(8)
  bool userProfileAsClub;
  @HiveField(9)
  String clubId;

  String getClubId(){
    return clubId;
  }


  bool getUserProfileAsClub(){
    return userProfileAsClub;
  }

  DateTime? getLastTimeLoggedIn(){
    return lastTimeLoggedIn;
  }

  int getUserAge() {
    var age = AgeCalculator.age(getBirthDate());
    return age.years;
  }

  String getUserId(){
    return userId;
  }
  String getFirstName(){
    return firstName;
  }
  String getLastName(){
    return lastName;
  }
  String getEMail(){
    return eMail;
  }
  DateTime getBirthDate(){
    return birthDate;
  }
  int getGender(){
    return gender;
  }
  int getProfileType(){
    return profileType;
  }

}