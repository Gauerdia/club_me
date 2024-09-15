// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// part 'club_me_event_hive.g.dart';
//
// @HiveType(typeId:  2)
// class ClubMeEventHive{
//
//   ClubMeEventHive({
//     required this.eventTitle,
//     required this.djName,
//     required this.eventDate,
//     required this.eventPrice,
//     required this.eventDescription,
//     required this.musicGenres,
//     required this.templateId
//   });
//
//   @HiveField(0)
//   String djName;
//   @HiveField(1)
//   String eventTitle;
//   @HiveField(2)
//   double eventPrice;
//   @HiveField(3)
//   DateTime eventDate;
//   @HiveField(4)
//   String eventDescription;
//   @HiveField(5)
//   String musicGenres;
//   @HiveField(6)
//   String templateId;
//
//   String getTemplateId(){
//     return templateId;
//   }
//
//
//   void setEventTitle(String newValue){
//     eventTitle = newValue;
//   }
//   void setEventDjName(String newValue){
//     djName = newValue;
//   }
//   void setEventDate(DateTime newValue){
//     eventDate = newValue;
//   }
//   void setEventPrice(double newValue){
//     eventPrice = newValue;
//   }
//   void setEventDescription(String newValue){
//     eventDescription = newValue;
//   }
//   void setEventMusicGenres(String newValue){
//     musicGenres = newValue;
//   }
//
//
//   String getMusicGenres(){
//     return musicGenres;
//   }
//
//
//   String getEventTitle(){
//     return eventTitle;
//   }
//
//   String getDjName(){
//     return djName;
//   }
//   DateTime getEventDate(){
//     return eventDate;
//   }
//
//   double getEventPrice(){
//     return eventPrice;
//   }
//   String getEventDescription(){
//     return eventDescription;
//   }
//
//
// }