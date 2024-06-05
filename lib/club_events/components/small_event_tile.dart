import 'package:club_me/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import 'package:intl/intl.dart';

import '../../provider/state_provider.dart';
import '../../shared/custom_text_style.dart';

class SmallEventTile extends StatelessWidget {
  SmallEventTile({Key? key, required this.clubMeEvent}) : super(key: key);

  ClubMeEvent clubMeEvent;

  late CustomTextStyle customTextStyle;

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String weekDayToDisplay = "";

    var eventDateWeekday = clubMeEvent.getEventDate().weekday;
      switch(eventDateWeekday){
        case(1): weekDayToDisplay = "Montag";
        case(2): weekDayToDisplay = "Dienstag";
        case(3): weekDayToDisplay = "Mittwoch";
        case(4): weekDayToDisplay = "Donnerstag";
        case(5): weekDayToDisplay = "Freitag";
        case(6): weekDayToDisplay = "Samstag";
        case(7): weekDayToDisplay = "Sonntag";
      }

    String eventTitleCut = "";
    String eventDjCut = "";


    if(clubMeEvent.getEventTitle().length >= 22){
      eventTitleCut = "${clubMeEvent.getEventTitle().substring(0, 21)}...";
    }else{
      eventTitleCut = clubMeEvent.getEventTitle().substring(0, clubMeEvent.getEventTitle().length);
    }

    if(clubMeEvent.getDjName().length >= 22){
      eventDjCut = "${clubMeEvent.getDjName().substring(0, 21)}...";
    }else{
      eventDjCut = clubMeEvent.getDjName().substring(0, clubMeEvent.getDjName().length);
    }

    // var howOftenRedeemed = clubMeDiscount.getHowOftenRedeemed();

    return Container
      (
      padding: EdgeInsets.only(bottom: screenHeight*0.02),
      child: Card(
        child: Column(
          children: [


            // Image container
            Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12)
                  ),
                  border: Border(
                    top: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                    left: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                    right: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                  ),
                ),
                child: SizedBox(
                    width: screenWidth*0.8,
                    height: screenHeight*0.15,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12)
                      ),
                      child: Image.asset(
                        "assets/images/${clubMeEvent.getBannerId()}",
                        fit: BoxFit.cover,
                      ),
                    )
                )
            ),

            // Content container
            Container(
                height: screenHeight*0.12,
                width: screenWidth*0.805,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12)
                  ),
                  border: const Border(
                    bottom: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                    left: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                    right: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                  ),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[700]!,
                        Colors.grey[850]!
                      ],
                      stops: const [0.3, 0.8]
                  ),
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
                              eventTitleCut,
                              style: customTextStyle.size2Bold()
                            ),
                          ),
                        ),

                        // Date
                        Padding(
                          padding: const EdgeInsets.only(
                            // top: 5,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              weekDayToDisplay,
                              style: customTextStyle.size5Bold()
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
                              eventDjCut,
                              style: customTextStyle.size6BoldGrey(),
                            ),
                          ),
                        ),

                      ],
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