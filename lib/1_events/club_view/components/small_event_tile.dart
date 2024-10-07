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

  late CustomStyleClass customStyleClass;

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;

  late String formattedWeekday, formattedEventTitle, formattedDjName;

  void formatWeekday(){

    String weekDayToDisplay = "";

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

    // Before, I cut the length to avoid overflow. Now, we have an input limit and that seems to suffice.
    formattedEventTitle = clubMeEvent.getEventTitle();

  }
  void formatDjName(){

    // Before, I cut the length to avoid overflow. Now, we have an input limit and that seems to suffice.
    formattedDjName = clubMeEvent.getDjName();
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

                        //  TITLE
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

                        // DJ NAME
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

                    // WEEKDAY
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