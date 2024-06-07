import 'package:hive/hive.dart';
part 'club_me_user_data.g.dart';

@HiveType(typeId:  0)
class ClubMeUserData{

  ClubMeUserData({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.eMail,
    required this.gender,
    required this.userId,
    required this.profileType
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