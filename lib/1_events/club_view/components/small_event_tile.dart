import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/event.dart';
import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../shared/custom_text_style.dart';

class SmallEventTile extends StatelessWidget {
  SmallEventTile({Key? key, required this.clubMeEvent}) : super(key: key);

  ClubMeEvent clubMeEvent;
  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late String formattedWeekday, formattedEventTitle, formattedDjName;

  void formatWeekday(){

    String weekDayToDisplay = "";

    // Get current time for germany
    // final berlin = tz.getLocation('Europe/Berlin');
    // final todayGermanTZ = tz.TZDateTime.from(DateTime.now(), berlin);
    final exactlyOneWeekFromNowGermanTZ = stateProvider.getBerlinTime().add(const Duration(days: 7));

    weekDayToDisplay = DateFormat('dd.MM.yyyy').format(clubMeEvent.getEventDate());

    var eventDateWeekday = clubMeEvent.getEventDate().weekday;
    switch(eventDateWeekday){
      case(1): weekDayToDisplay = "Montag, $weekDayToDisplay";
      case(2): weekDayToDisplay = "Dienstag, $weekDayToDisplay";
      case(3): weekDayToDisplay = "Mittwoch, $weekDayToDisplay";
      case(4): weekDayToDisplay = "Donnerstag, $weekDayToDisplay";
      case(5): weekDayToDisplay = "Freitag, $weekDayToDisplay";
      case(6): weekDayToDisplay = "Samstag, $weekDayToDisplay";
      case(7): weekDayToDisplay = "Sonntag, $weekDayToDisplay";
    }

    var startingHour = clubMeEvent.getEventDate().hour;
    var startingMinute = clubMeEvent.getEventDate().minute;

    String startingHourToDisplay = "";
    String startingMinuteToDisplay = "";

    if(startingHour < 10 ){
      startingHourToDisplay = "0$startingHour";
    }else{
      startingHourToDisplay = startingHour.toString();
    }
    if(startingMinute < 10 ){
      startingMinuteToDisplay = "0$startingMinute";
    }else{
      startingMinuteToDisplay = startingMinute.toString();
    }

    formattedWeekday = "$weekDayToDisplay, $startingHourToDisplay:$startingMinuteToDisplay Uhr";
  }
  void formatEventTitle(){

    formattedEventTitle = clubMeEvent.getEventTitle();

    // if(clubMeEvent.getEventTitle().length >= 22){
    //   formattedEventTitle = "${clubMeEvent.getEventTitle().substring(0, 21)}...";
    // }else{
    //   formattedEventTitle = clubMeEvent.getEventTitle().substring(0, clubMeEvent.getEventTitle().length);
    // }
  }
  void formatDjName(){

    formattedDjName = clubMeEvent.getDjName();

    // if(clubMeEvent.getDjName().length >= 22){
    //   formattedDjName = "${clubMeEvent.getDjName().substring(0, 21)}...";
    // }else{
    //   formattedDjName = clubMeEvent.getDjName().substring(0, clubMeEvent.getDjName().length);
    // }
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    customStyleClass = CustomStyleClass(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    formatWeekday();
    formatEventTitle();
    formatDjName();
    formatWeekday();


    return Container(
      padding: EdgeInsets.only(bottom: screenHeight*0.02),
      child: Card(
        color: customStyleClass.backgroundColorEventTile,
        child: Column(
          children: [

            // Image container
            Container(
                decoration: BoxDecoration(
                  color: customStyleClass.backgroundColorMain,
                  border: Border.all(
                      color: customStyleClass.backgroundColorEventTile,
                    width: 2
                  ),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12)
                  ),
                ),
                child: SizedBox(
                    width: screenWidth*0.9,
                    height: screenHeight*0.2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10)
                      ),
                      child:fetchedContentProvider.getFetchedBannerImageIds().contains(clubMeEvent.getBannerImageFileName())?
                      Image(
                        image: FileImage(
                            File("${stateProvider.appDocumentsDir.path}/${clubMeEvent.getBannerImageFileName()}")),
                        fit: BoxFit.cover,
                      ): SizedBox(
                        height: screenHeight*0.1,
                        width: screenWidth*0.5,
                        child: Center(
                          child: CircularProgressIndicator(color: customStyleClass.primeColor,),
                        ),
                      )
                    )
                )
            ),

            // Content container
            Container(
                height: screenHeight*0.12,
                width: screenWidth*0.905,
                decoration: BoxDecoration(
                  color: customStyleClass.backgroundColorEventTile,
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12)
                  ),
                  border: Border.all(
                    color: customStyleClass.backgroundColorEventTile,
                    width: 2
                  )
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [

                        // Title
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                formattedEventTitle,
                                style: customStyleClass.getFontStyle2Bold()
                            ),
                          ),
                        ),
                        // Aufgerufen
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 3,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formattedDjName,
                              style: customStyleClass.getFontStyle6BoldGrey(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Date
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10,
                          bottom: 8
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                            formattedWeekday,
                            style: customStyleClass.getFontStyle5BoldPrimeColor()
                        ),
                      ),
                    ),

                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}