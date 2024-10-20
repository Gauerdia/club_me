import 'package:club_me/models/club_offers.dart';
import 'package:club_me/models/club_open_status.dart';
import 'package:club_me/models/front_page_images.dart';
import 'package:club_me/models/opening_times.dart';
import 'package:club_me/models/special_opening_times.dart';
import 'package:timezone/standalone.dart' as tz;

class ClubMeClub{

  ClubMeClub({
    required this.clubId,
    required this.clubName,

    required this.clubNews,
    required this.clubMusicGenres,
    required this.clubStoryId,
    required this.storyCreatedAt,

    // required this.clubBannerId,

    required this.clubGeoCoordLat,
    required this.clubGeoCoordLng,

    required this.clubContactCity,
    required this.clubContactName,
    required this.clubContactStreet,
    required this.clubContactZip,
    required this.clubContactStreetNumber,
    // required this.clubEventBannerId,

    required this.clubWebsiteLink,
    required this.clubInstagramLink,
    // required this.clubFrontpageBackgroundColorId,

    required this.priorityScore,
    required this.openingTimes,
    required this.frontPageGalleryImages,
    required this.clubOffers,

    required this.smallLogoFileName,
    required this.bigLogoFileName,
    required this.frontpageBannerFileName,
    required this.mapPinImageName,
    required this.specialOpeningTimes,

    required this.closePartner

  });

  String clubId;
  String clubName;

  String clubStoryId;
  DateTime? storyCreatedAt;

  double clubGeoCoordLat;
  double clubGeoCoordLng;

  // String clubBannerId;
  // String clubEventBannerId;
  String clubMusicGenres;

  String clubNews;

  String clubContactName;
  String clubContactStreet;
  String clubContactCity;
  String clubContactZip;
  String clubContactStreetNumber;

  String clubInstagramLink;
  String clubWebsiteLink;

  // int clubFrontpageBackgroundColorId;
  int priorityScore;

  OpeningTimes openingTimes;
  FrontPageGalleryImages frontPageGalleryImages;
  ClubOffers clubOffers;

  String smallLogoFileName, bigLogoFileName, frontpageBannerFileName, mapPinImageName;

  SpecialOpeningTimes specialOpeningTimes;

  bool closePartner;


  bool getClosePartner(){
    return closePartner;
  }

  SpecialOpeningTimes getSpecialOpeningTimes(){
    return specialOpeningTimes;
  }

  void setSpecialOpeningTimes(SpecialOpeningTimes newSpecialOpeningTimes){
    specialOpeningTimes = newSpecialOpeningTimes;
  }

  DateTime? getStoryCreatedAt(){
    if(storyCreatedAt != null){
      return storyCreatedAt;
    }else{
      return null;
    }
  }

  String getMapPinImageName(){
    return mapPinImageName;
  }

  void setFrontpageBannerFileName(String newFileName){
    frontpageBannerFileName = newFileName;
  }

  String getSmallLogoFileName(){
    return smallLogoFileName;
  }
  String getBigLogoFileName(){
    return bigLogoFileName;
  }
  String getFrontpageBannerFileName(){
    return frontpageBannerFileName;
  }


  // returns a status, (0: closed, 1: going to open, 2: open, 3: open, but closes soon) and the time to display.
  ClubOpenStatus getClubOpenStatus(){

    // Get the current time
    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

    checkIfSpecialOpeningApplies();

    for(var element in openingTimes.days!){
      print("Logic: $clubName, ${element.day}");
    }



    int openingStatus = 0;
    String textToDisplay = "";
    Days? currentDay, nextDay, pastDay;

    // Checking the app before midnight. 10 am as a limit is arbitrary.
    if(todayTimestamp.hour >= 10) {

      // Get today and tomorrow. Tomorrow, because some clubs start at 0 am.
      var firstResult = getOpeningTimes().days!.where((element) => element.day == todayTimestamp.weekday);

      if(firstResult.isNotEmpty){
        currentDay = firstResult.first;
      }

      var secondResult = getOpeningTimes().days!.where((element) => element.day == todayTimestamp.weekday+1);

      if(secondResult.isNotEmpty){
        nextDay = secondResult.first;
      }

      // Check if the club is open today. That means everything between 10:00 and 23:59
      if(currentDay != null){


        // Sometimes, a club starts at 0 am and the next event starts at 11:30 pm.
        // For this logic, I assume that 10:00 means that the first event has
        // definitely already ended.
        if(firstResult.length > 1){

          Days currentDay2 = firstResult.toList()[1];

          // Open yet?
          if(todayTimestamp.hour > currentDay2.openingHour!){
            openingStatus = 2;
          }
          // Not open but this hour it'll happen? When?
          else if(todayTimestamp.hour == currentDay2.openingHour!){
            if(currentDay2.openingHalfAnHour == 1){
              if(todayTimestamp.minute >= 30){
                openingStatus = 2;
              }else{
                openingStatus = 1;
                textToDisplay = "${currentDay2.openingHour}:30";
              }
            }else{
              openingStatus = 2;
            }
          }
          // Not open nor same hour. When will it open?
          else{
            openingStatus = 1;

            if(currentDay2.openingHalfAnHour == 1){
              textToDisplay = "${currentDay2.openingHour}:30";
            }else{
              textToDisplay = "${currentDay2.openingHour}:00";
            }
          }
        }

        // Might be that the event started at 0 am and tomorrow happens the same.
        // else if(nextDay != null){
        //
        //   // Check if the club opens early. 10 am is arbitrary.
        //   if(nextDay.openingHour! < 10){
        //     openingStatus = 1;
        //     if(nextDay.openingHalfAnHour == 1){
        //       textToDisplay = "0${nextDay.openingHour}:30";
        //     }else{
        //       textToDisplay = "0${nextDay.openingHour}:00";
        //     }
        //   }else{
        //     openingStatus = 0;
        //   }
        // }

        // Just one event today. Easier logic
        else{

          // If the hour is ahead, that's a dead giveaway for openness.
          if(todayTimestamp.hour > currentDay.openingHour!){

            // We dont need to check for still ongoing events because at 10 we assume everything is finished.
            openingStatus = 2;



            // Events that started at 0 am could already be finished.
            // if(todayTimestamp.hour > currentDay.closingHour!){
            //   openingStatus = 0;
            // }else{
            //   openingStatus = 2;
            // }
          }
          // Some clubs open at :30, so we need to check for that.
          else if(todayTimestamp.hour == currentDay.openingHour!){

            // Does this club actually start at :30?
            if(currentDay.openingHalfAnHour == 1){
              // Are we beyond :30 already?
              if(todayTimestamp.minute >= 30){
                openingStatus = 2;
              }else{
                openingStatus = 1;
                textToDisplay = "${currentDay.openingHour}:30";
              }
            }else{
              openingStatus = 2;
            }
          }

          // We are before the opening hour
          else {
            openingStatus = 1;
            if(currentDay.openingHalfAnHour == 1){
              textToDisplay = "${currentDay.openingHour}:30";
            }else{
              textToDisplay = "${currentDay.openingHour}:00";
            }
          }

        }
      }

      // If that's not the case, it could still open at 0 am, i.e. the next day.
      else if(nextDay != null){

        // Check if the club opens early. 10 am is arbitrary.
        if(nextDay.openingHour! < 10){
          openingStatus = 1;
          if(nextDay.openingHalfAnHour == 1){
            textToDisplay = "0${nextDay.openingHour}:30";
          }else{
            textToDisplay = "0${nextDay.openingHour}:00";
          }
        }else{
          openingStatus = 0;
        }
      }
      // Neither today nor tomorrow an event?
      else{
        openingStatus = 0;
      }
    }

    // checking the app after midnight
    else{

      // Get today and yesterday. Tomorrow, because the club might still be open.
      var firstResult = getOpeningTimes().days!.where((element) => element.day == todayTimestamp.weekday);
      if(firstResult.isNotEmpty){
        currentDay = firstResult.first;
      }

      var thirdResult = getOpeningTimes().days!.where((element) => element.day == todayTimestamp.weekday-1);
      if(thirdResult.isNotEmpty){
        pastDay = thirdResult.first;
      }

      // Yesterday started a party. So let's see if it's still on.
      if(pastDay != null){

        // It is possible that yesterday the event started 'the day before'.
        // Make sure that it indeed started yesterday.
        if(pastDay.openingHour! > 10){
          // We are past the closing hour
          if(todayTimestamp.hour > pastDay.closingHour!){
            openingStatus = 0;
          }
          // It is exactly the hour of closing
          else if(todayTimestamp.hour == pastDay.closingHour!){

            // Is the club open for half an hour extra?
            if(pastDay.closingHalfAnHour == 1){
              if(todayTimestamp.minute >= 30){
                openingStatus = 0;
              }else{
                openingStatus  = 3;
                textToDisplay = "0${pastDay.closingHour}:30";
              }
            }
            else{
              openingStatus = 0;
            }

            // We are before the closing hour
          }
          else{
            // Let's see if it is still worth it to go there
            if(pastDay.closingHour! - todayTimestamp.hour < 2){
              openingStatus = 3;
              if(pastDay.closingHalfAnHour == 1){
                textToDisplay = "0${pastDay.closingHour}:30";
              }else{
                textToDisplay = "0${pastDay.closingHour}:00";
              }
            }else{
              openingStatus = 2;
            }
          }
        }
        // It started the day before
        else{

        }
      }

      // A club might be closed already, but opens later that day
      else if(currentDay != null){
        openingStatus = 1;
        if(currentDay.openingHalfAnHour == 1){
          textToDisplay = "${currentDay.openingHour}:30";
        }else{
          textToDisplay = "${currentDay.openingHour}:00";
        }
      }
      // Neither yesterday nor today?
      else{
        openingStatus = 0;
      }
    }

    return ClubOpenStatus(openingStatus: openingStatus, textToDisplay: textToDisplay);
  }

  void checkIfSpecialOpeningApplies(){

    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

    if(getSpecialOpeningTimes().specialDays!.isNotEmpty){




      for(var specialDay in getSpecialOpeningTimes().specialDays!){

        if(
            todayTimestamp.day == specialDay.day &&
            todayTimestamp.month == specialDay.month &&
            todayTimestamp.year == specialDay.year
        ){
          Days newDay = Days(
              day: DateTime(specialDay.year!, specialDay.day!, specialDay.month!).weekday,
              openingHour: specialDay.openingHour,
              openingHalfAnHour: specialDay.openingHalfAnHour,
              closingHour: specialDay.closingHour,
              closingHalfAnHour: specialDay.closingHalfAnHour
          );
          addOpeningTime(newDay);
        }
      }
    }
  }

  void setClubOffers(ClubOffers newClubOffers){
    clubOffers = newClubOffers;
  }

  ClubOffers getClubOffers(){
    return clubOffers;
  }

  FrontPageGalleryImages getFrontPageGalleryImages(){
    return frontPageGalleryImages;
  }
  void setFrontPageImages(FrontPageGalleryImages newFrontPageGalleryImages){
    frontPageGalleryImages = newFrontPageGalleryImages;
  }


  OpeningTimes getOpeningTimes(){
    return openingTimes;
  }
  void addOpeningTime(Days newDay){
    openingTimes.days?.add(newDay);
  }

  void setContactStreetNumber(String newNumber){
    clubContactStreetNumber = newNumber;
  }

  String getContactStreetNumber(){
    return clubContactStreetNumber;
  }

  int getPriorityScore(){
    return priorityScore;
  }

  String getWebsiteLink(){
    return clubWebsiteLink;
  }

  // int getBackgroundColorId(){
  //   return clubFrontpageBackgroundColorId;
  // }

  String getInstagramLink(){
    return clubInstagramLink;
  }

  // String getEventBannerId(){
  //   return clubEventBannerId;
  // }

  String getClubId(){
    return clubId;
  }
  void setClubId(String newId){
    clubId = newId;
  }

  String getClubName(){
    return clubName;
  }
  void setClubName(String newName){
    clubName = newName;
  }

  String getStoryId(){
    return clubStoryId;
  }
  void setStoryId(String newStoryId){
    clubStoryId = newStoryId;
  }

  double getGeoCoordLat(){
    return clubGeoCoordLat;
  }
  void setGeoCoordLat(double newCoord){
    clubGeoCoordLat = newCoord;
  }

  double getGeoCoordLng(){
    return clubGeoCoordLng;
  }
  void setGeoCoordLng(double newCoord){
    clubGeoCoordLng = newCoord;
  }

  // String getBannerId(){
  //   return clubBannerId;
  // }
  // void setBannerId(String newId){
  //   clubBannerId = newId;
  // }

  String getMusicGenres(){
    return clubMusicGenres;
  }
  void setMusicGenres(String newGenres){
    clubMusicGenres = newGenres;
  }

  String getNews(){
    return clubNews;
  }
  void setNews(String newNews){
    clubNews = newNews;
  }

  String getContactName(){
    return clubContactName;
  }
  void setContactName(String newName){
    clubContactName = newName;
  }

  String getContactStreet(){
    return clubContactStreet;
  }
  void setContactStreet(String newStreet){
    clubContactStreet = newStreet;
  }

  String getContactCity(){
    return clubContactCity;
  }
  void setContactCity(String newCity){
    clubContactCity = newCity;
  }

  String getContactZip(){
    return clubContactZip;
  }
  void setContactZip(String newZip){
    clubContactZip = newZip;
  }

}