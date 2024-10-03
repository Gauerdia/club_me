import 'package:club_me/models/opening_times.dart';
import 'package:flutter/material.dart';

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
    required this.clubId,
    required this.eventMarketingFileName,
    required this.eventMarketingCreatedAt,
    required this.priorityScore,
    required this.openingTimes,
    required this.ticketLink,
    required this.isRepeatedDays
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

  String eventMarketingFileName;
  DateTime? eventMarketingCreatedAt;

  double priorityScore;

  // Default is 0. Everything except 0 will be recreated x days after the event
  // date automatically by the cron job.
  int isRepeatedDays;

  // Originally, we wanted to display the opening hours of the club directly on
  // the event. Due to this no longer being a requirement, we don't need this
  // information anymore. Nonetheless, I keep it here because it doesn't harm and
  // maybe we'll find a new application.
  OpeningTimes openingTimes;

  String ticketLink;

  // howManyAreIn

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