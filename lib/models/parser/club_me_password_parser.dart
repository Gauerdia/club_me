import 'package:club_me/models/club_password.dart';

ClubMePassword parseClubMePassword(var data){
  return ClubMePassword(
    clubId: data['club_id'],
    password: data['password']
  );
}