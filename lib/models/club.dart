import 'package:club_me/models/club_offers.dart';
import 'package:club_me/models/club_open_status.dart';
import 'package:club_me/models/front_page_images.dart';
import 'package:club_me/models/opening_times.dart';
import 'package:club_me/models/special_opening_times.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:timezone/standalone.dart' as tz;

class ClubMeClub{

  ClubMeClub({
    required this.clubId,
    required this.clubName,

    required this.clubNews,
    required this.clubMusicGenres,
    required this.clubStoryId,
    required this.storyCreatedAt,

    required this.clubGeoCoordLat,
    required this.clubGeoCoordLng,

    required this.clubContactCity,
    required this.clubContactName,
    required this.clubContactStreet,
    required this.clubContactZip,
    required this.clubContactStreetNumber,

    required this.clubWebsiteLink,
    required this.clubInstagramLink,

    required this.priorityScore,
    required this.openingTimes,
    required this.frontPageGalleryImages,
    required this.clubOffers,

    required this.smallLogoFileName,
    required this.bigLogoFileName,
    required this.frontpageBannerFileName,
    required this.mapPinImageName,
    required this.specialOpeningTimes,

    required this.closePartner,
    required this.showClubInApp

  });

  String clubId;
  String clubName;

  String clubStoryId;
  DateTime? storyCreatedAt;

  double clubGeoCoordLat;
  double clubGeoCoordLng;

  String clubMusicGenres;

  String clubNews;

  String clubContactName;
  String clubContactStreet;
  String clubContactCity;
  String clubContactZip;
  String clubContactStreetNumber;

  String clubInstagramLink;
  String clubWebsiteLink;

  int priorityScore;

  OpeningTimes openingTimes;
  FrontPageGalleryImages frontPageGalleryImages;
  ClubOffers clubOffers;

  String smallLogoFileName, bigLogoFileName, frontpageBannerFileName, mapPinImageName;

  SpecialOpeningTimes specialOpeningTimes;

  bool closePartner;
  bool showClubInApp;

  bool getShowClubInApp(){
    return showClubInApp;
  }

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


  ClubOpenStatus getClubOpenStatus(){

    // The possible cases:
    //
    // event from yesterday, no today:      [0, 6]        and [1,0]
    // event from yesterday, 1 today:       [0,6,23]      and [1,0,1]
    // event from yesterday, 1 today:       [0,6,8,14]    and [1,0,1,0]
    // event from yesterday, 2 today:       [0,6,8,14,22] and [1,0,1,0,1]
    // no event from yesterday, none today: [0]           and [0]
    // no event from yesterday, 1 today:    [0,22]        and [0,1]
    // no event from yesterday, 1 today:    [0,8,14]      and [0,1,0]
    // no event from yesterday, 2 today:    [0,8,12,22]   and [0,1,0,1]

    // Get the current time
    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

    // starting and closing hours along the day
    List<int> timeIntervals = [];
    // the meaning of each entry in timeIntervals
    List<int> intervalMeaning = [];

    OpeningTimes tempOpeningTimes = OpeningTimes(days: []);

    // get all the club's open days
    if(getOpeningTimes().days != null){
      for(var element in getOpeningTimes().days!){
        tempOpeningTimes.days!.add(element);
      }
    }

    // Check if any special day is to be considered
    Days? specialOpeningDays = checkIfSpecialOpeningApplies(tempOpeningTimes);
    if(specialOpeningDays != null){
      tempOpeningTimes.days!.add(specialOpeningDays);
    }

    Iterable<Days> yesterdaysOpeningTimes = tempOpeningTimes.days!
        .where((element) => element.day == (todayTimestamp.weekday-1));

    Iterable<Days> todaysOpeningTimes = tempOpeningTimes.days!
      .where((element) => element.day == todayTimestamp.weekday);

    // Convert to list to enable sorting
    List<Days> yesterDaysOpeningTimesAsList = yesterdaysOpeningTimes.toList();
    List<Days> todaysOpeningTimesAsList = todaysOpeningTimes.toList();

    // Make sure that the opening times are in the correct order
    if(todaysOpeningTimesAsList.length > 1){
      todaysOpeningTimesAsList.sort(
              (a,b) => a.openingHour!.compareTo(b.openingHour!)
      );
    }


    // If there is no event overlapping from yesterday, we start the day with empty space.
    if(yesterDaysOpeningTimesAsList.isEmpty){
      timeIntervals.add(0);
      intervalMeaning.add(0);
    }
    // Check, if any opening times crosses midnight
    else{
      for(Days days in yesterdaysOpeningTimes){
        if(days.openingHour! > days.closingHour!){
          timeIntervals.add(0);
          intervalMeaning.add(1);
          timeIntervals.add(days.closingHour!);
          intervalMeaning.add(0);
        }
      }

      // If none of yesterdays event overlap midnight, we start the day with empty space.
      if(timeIntervals.isEmpty){
        timeIntervals.add(0);
       intervalMeaning.add(0);
      }
    }

    // Each opening time comprises of a start and finish with an active status meanwhile and
    // an empty space afterwards.
    for(var openingTime in todaysOpeningTimesAsList){
      timeIntervals.add(openingTime.openingHour!);
      intervalMeaning.add(1);

      // Only add closing time if the event doesn't surpass midnight.
      if(openingTime.closingHour! > openingTime.openingHour!){
        timeIntervals.add(openingTime.closingHour!);
        intervalMeaning.add(0);
      }
    }

    // Go through the array until we find the correct timeslot
    bool timeSlotFound = false;
    int timeSlotIndex = 0;
    while(!timeSlotFound){

      // Check if we haven't reached the end yet
      if(timeIntervals.length > timeSlotIndex+1){

        // Keep going until we find our time slot
        if(todayTimestamp.hour >= timeIntervals[timeSlotIndex+1]){
          timeSlotIndex++;
        }else{
          timeSlotFound = true;
        }

      }else{
        timeSlotFound = true;
      }
    }

    // Now we differ between empty slot and an active slot
    if(intervalMeaning[timeSlotIndex] == 0){

      // Edge case: There is no entry
      if(intervalMeaning.length == 1){
        return ClubOpenStatus(
            openingStatus: 0, textToDisplay: ""
        );
      }

      // empty slot is the last entry
      if(timeIntervals.length == (timeSlotIndex+1)){
        return ClubOpenStatus(
            openingStatus: 0, textToDisplay: ""
        );
      }

      // if there are elements and our interval is not the last one,
      // we are waiting for the next event. So, we return status 1 and the
      // upcoming time.

      int halfHourIndex  = tempOpeningTimes.days!.firstWhere(
              (element) => element.openingHour! == timeIntervals[timeSlotIndex+1]
      ).openingHalfAnHour!;

      return ClubOpenStatus(
          openingStatus: 1,
          textToDisplay: halfHourIndex == 1 ?
              "${timeIntervals[timeSlotIndex+1]}:30":
              halfHourIndex == 2 ?
              "${timeIntervals[timeSlotIndex+1]}:59":
              "${timeIntervals[timeSlotIndex+1]}:00"
      );
    }

    // Could be if/else but like this, it is easier to understand the code.
    if(intervalMeaning[timeSlotIndex] == 1){

      // First case: there is only one event that started yesterday
      if(timeSlotIndex == 0 && timeIntervals.length == 2){

        // Check if there are less than 2 hours remaining
        if( (timeIntervals[timeSlotIndex+1] - todayTimestamp.hour) <= 2){

          int halfHourIndex  = tempOpeningTimes.days!.firstWhere(
                  (element) => element.closingHour! == timeIntervals[timeSlotIndex+1]
          ).closingHalfAnHour!;

          return ClubOpenStatus(
              openingStatus: 3,
              textToDisplay: halfHourIndex == 1 ?
              "${timeIntervals[timeSlotIndex+1]}:30":
              halfHourIndex == 2 ?
              "${timeIntervals[timeSlotIndex+1]}:59":
              "${timeIntervals[timeSlotIndex+1]}:00"
          );

        }else{
          return ClubOpenStatus(
              openingStatus: 2,
              textToDisplay: ""
          );
        }
      }

      // We are in an active event and it's the last one today
      if(timeSlotIndex+1 == timeIntervals.length){

        // If the hour is the same, we have to check for the minutes
        if(timeIntervals[timeSlotIndex] == todayTimestamp.hour){
          int halfHourIndex  = tempOpeningTimes.days!.firstWhere(
                  (element) => element.openingHour! == timeIntervals[timeSlotIndex+1]
          ).openingHalfAnHour!;

          // It might be that the hour
          switch(halfHourIndex){
            case(0):return ClubOpenStatus(
                openingStatus: 2,
                textToDisplay: ""
            );
            case(1):
              if(todayTimestamp.minute >= 30){
                return ClubOpenStatus(
                    openingStatus: 2,
                    textToDisplay: ""
                );
              }else{
                return ClubOpenStatus(
                    openingStatus: 1,
                    textToDisplay: "${timeIntervals[timeSlotIndex+1]}:30"
                );
              }
            case(2):
              return ClubOpenStatus(
                  openingStatus: 1,
                  textToDisplay: "${timeIntervals[timeSlotIndex+1]}:59"
              );
          }
        }
        // Hour not the same? Has to be open
        else{
          return ClubOpenStatus(
              openingStatus: 2,
              textToDisplay: ""
          );
        }


      }

      // We are in an active event but the day does not end with this event.
      if( (timeIntervals[timeSlotIndex+1] - todayTimestamp.hour) <= 2){

        int halfHourIndex  = tempOpeningTimes.days!.firstWhere(
                (element) => element.closingHour! == timeIntervals[timeSlotIndex+1]
        ).closingHalfAnHour!;

        return ClubOpenStatus(
            openingStatus: 3,
            textToDisplay: halfHourIndex == 1 ?
            "${timeIntervals[timeSlotIndex+1]}:30":
            halfHourIndex == 2 ?
            "${timeIntervals[timeSlotIndex+1]}:59":
            "${timeIntervals[timeSlotIndex+1]}:00"
        );

      }else{
        return ClubOpenStatus(
            openingStatus: 2,
            textToDisplay: ""
        );
      }
    }

    return ClubOpenStatus(
        openingStatus: 0, textToDisplay: ""
    );

  }

  // returns a status, (0: closed, 1: going to open, 2: open, 3: open, but closes soon) and the time to display.
  ClubOpenStatus oldGetClubOpenStatus(){

    // Get the current time
    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

    OpeningTimes tempOpeningTimes = OpeningTimes(days: []);

    if(getOpeningTimes().days != null){
      for(var element in getOpeningTimes().days!){
        tempOpeningTimes.days!.add(element);
      }
    }

    Days? specialOpeningDays = checkIfSpecialOpeningApplies(tempOpeningTimes);

    if(specialOpeningDays != null){
      tempOpeningTimes.days!.add(specialOpeningDays);
    }


    int openingStatus = 0;
    String textToDisplay = "";
    Days? currentDay, nextDay, pastDay;

    // Checking the app before midnight. 10 am as a limit is arbitrary.
    if(todayTimestamp.hour >= 10) {

      // Get today and tomorrow. Tomorrow, because some clubs start at 0 am.
      var firstResult = tempOpeningTimes.days!.where((element) => element.day == todayTimestamp.weekday);

      if(firstResult.isNotEmpty){
        currentDay = firstResult.first;
      }

      var secondResult = tempOpeningTimes.days!.where((element) => element.day == todayTimestamp.weekday+1);

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

        // Just one event today. Easier logic
        else{

          // Might be that the currentDay is just the past night
          if(currentDay.openingHour! < 10 && currentDay.closingHour! < 10 ){
            openingStatus = 0;
          }

          // The event starts today
          else{

            // If the hour is ahead, that's a dead giveaway for openness.
            if(todayTimestamp.hour > currentDay.openingHour!){

              openingStatus = 2;
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
      var firstResult = tempOpeningTimes.days!.where((element) => element.day == todayTimestamp.weekday);
      if(firstResult.isNotEmpty){
        currentDay = firstResult.first;
      }

      var thirdResult = tempOpeningTimes.days!.where((element) => element.day == todayTimestamp.weekday-1);
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

          // If yesterday there was an event that started before 10 and today
          // there is another one
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

            // Today's event might still be on
            if(currentDay.openingHour! < 10){

              // We are past the closing hour
              if(todayTimestamp.hour > currentDay.closingHour!){
                openingStatus = 0;
              }
              // It is exactly the hour of closing
              else if(todayTimestamp.hour == currentDay.closingHour!){

                // Is the club open for half an hour extra?
                if(currentDay.closingHalfAnHour == 1){
                  if(todayTimestamp.minute >= 30){
                    openingStatus = 0;
                  }else{
                    openingStatus  = 3;
                    textToDisplay = "0${currentDay.closingHour}:30";
                  }
                }
                else{
                  openingStatus = 0;
                }
              }
              // We are before the closing hour
              else{
                // Let's see if it is still worth it to go there
                if(currentDay.closingHour! - todayTimestamp.hour < 2){
                  openingStatus = 3;
                  if(currentDay.closingHalfAnHour == 1){
                    textToDisplay = "0${currentDay.closingHour}:30";
                  }else{
                    textToDisplay = "0${currentDay.closingHour}:00";
                  }
                }else{
                  openingStatus = 2;
                }
              }


            }else{

            }



          }

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

  Days? checkIfSpecialOpeningApplies(OpeningTimes tempOpeningTimes){

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
              day: DateTime(specialDay.year!, specialDay.month!, specialDay.day!, ).weekday,
              openingHour: specialDay.openingHour,
              openingHalfAnHour: specialDay.openingHalfAnHour,
              closingHour: specialDay.closingHour,
              closingHalfAnHour: specialDay.closingHalfAnHour
          );
          return newDay;
          // tempOpeningTimes.days?.add(newDay);
          // addOpeningTime(newDay);
        }
      }
    }
    return null;
    // return tempOpeningTimes;
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