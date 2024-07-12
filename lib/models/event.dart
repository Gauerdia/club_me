import 'package:flutter/material.dart';

class ClubMeEvent{

  ClubMeEvent({
    required this.eventId,
    required this.eventTitle,
    required this.clubName,
    required this.djName,
    required this.eventDate,
    required this.eventPrice,
    required this.bannerId,
    required this.eventDescription,
    required this.musicGenres,
    required this.clubId,
    required this.eventMarketingFileName,
    required this.eventMarketingCreatedAt
  });

  String eventId;
  String clubId;

  String clubName;
  String djName;

  String eventTitle;
  double eventPrice;

  DateTime eventDate;
  String eventDescription;

  String bannerId;
  String musicGenres;

  String eventMarketingFileName;
  DateTime? eventMarketingCreatedAt;

  // howManyAreIn


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
  String getBannerId(){
    return bannerId;
  }
  double getEventPrice(){
    return eventPrice;
  }
  String getEventDescription(){
    return eventDescription;
  }


}