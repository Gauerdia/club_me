import 'package:club_me/models/genres_to_display.dart';
import 'hive_models/6_opening_times.dart';

class ClubMeEvent{

  ClubMeEvent({
    required this.eventId,
    required this.eventTitle,
    required this.clubName,
    required this.djName,
    required this.eventDate,
    required this.eventPrice,

    // required this.bannerId,
    required this.bannerImageFileName,

    required this.eventDescription,
    required this.musicGenres,
    required this.musicGenresToDisplay,
    required this.musicGenresToFilter,

    required this.clubId,
    required this.eventMarketingFileName,
    required this.eventMarketingCreatedAt,
    required this.priorityScore,
    required this.openingTimes,
    required this.ticketLink,
    required this.isRepeatedDays,
    required this.closingDate,
    required this.showEventInApp,
    required this.specialOccasionActive,
    required this.specialOccasionIndex
  });

  String eventId;
  String clubId;

  String clubName;
  String djName;

  String eventTitle;
  double eventPrice;

  DateTime eventDate;
  String eventDescription;

  // String bannerId;

  String bannerImageFileName;

  String musicGenres;
  String musicGenresToFilter;
  GenresToDisplay musicGenresToDisplay;

  String eventMarketingFileName;
  DateTime? eventMarketingCreatedAt;

  double priorityScore;

  // Default is 0. Everything except 0 will be recreated x days after the event
  // date automatically by the cron job.
  int isRepeatedDays;

  OpeningTimes openingTimes;

  String ticketLink;

  DateTime? closingDate;

  bool showEventInApp;

  bool specialOccasionActive;

  int specialOccasionIndex;


  String getMusicGenresToFilter(){
    return musicGenresToFilter;
  }

  GenresToDisplay getMusicGenresToDisplay(){
    return musicGenresToDisplay;
  }

  int getSpecialOccasionIndex(){
    return specialOccasionIndex;
  }

  bool getSpecialOccasionActive(){
    return specialOccasionActive;
  }

  bool getShowEventInApp(){
    return showEventInApp;
  }

  DateTime? getClosingDate(){
    return closingDate;
  }


  int getIsRepeatedDays(){
    return isRepeatedDays;
  }

  bool getIsRepeated(){
    return isRepeatedDays != 0 ? true:false;
  }

  void setIsRepeatedDays(int newIsRepeatedDays){
    isRepeatedDays = newIsRepeatedDays;
  }

  String getTicketLink(){
    return ticketLink;
  }

  OpeningTimes getOpeningTimes(){
    return openingTimes;
  }

  double getPriorityScore(){
    return priorityScore;
  }

  String getEventMarketingFileName(){
    return eventMarketingFileName;
  }
  DateTime? getEventMarketingCreatedAt(){
    return eventMarketingCreatedAt;
  }

  void setEventTitle(String newValue){
    eventTitle = newValue;
  }
  void setEventDjName(String newValue){
    djName = newValue;
  }
  void setEventDate(DateTime newValue){
    eventDate = newValue;
  }
  void setEventPrice(double newValue){
    eventPrice = newValue;
  }
  void setEventDescription(String newValue){
    eventDescription = newValue;
  }
  void setEventMusicGenres(String newValue){
    musicGenres = newValue;
  }


  String getEventId(){
    return eventId;
  }

  String getMusicGenres(){
    return musicGenres;
  }

  String getClubId(){
    return clubId;
  }

  String getEventTitle(){
    return eventTitle;
  }
  String getClubName(){
    return clubName;
  }
  String getDjName(){
    return djName;
  }
  DateTime getEventDate(){
    return eventDate;
  }
  String getBannerImageFileName(){
    return bannerImageFileName;
  }
  double getEventPrice(){
    return eventPrice;
  }
  String getEventDescription(){
    return eventDescription;
  }


}