import 'package:flutter/material.dart';

class ClubMeEvent{

  ClubMeEvent({
   required this.title,
    required this.clubName,
    required this.DjName,
    required this.date,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.musicGenres,
    required this.hours
  });

  String title;
  String clubName;
  String DjName;
  String date;
  String description;
  String imagePath;
  String price;
  String musicGenres;
  String hours;

  String getMusicGenres(){
    return musicGenres;
  }
  String getHours(){
    return hours;
  }

  String getTitle(){
    return title;
  }
  String getClubName(){
    return clubName;
  }
  String getDjName(){
    return DjName;
  }
  String getDate(){
    return date;
  }
  String getImagePath(){
    return imagePath;
  }
  String getPrice(){
    return price;
  }
  String getDescription(){
    return description;
  }


}