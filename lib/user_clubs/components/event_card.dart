import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../provider/state_provider.dart';

import 'package:timezone/standalone.dart' as tz;

import '../../shared/custom_text_style.dart';

class EventCard extends StatelessWidget {

  EventCard({
    Key? key,
    required this.clubMeEvent,
    this.wentFromClubDetailToEventDetail = false
  }) : super(key: key);

  ClubMeEvent clubMeEvent;

  late CustomTextStyle customTextStyle;

  bool wentFromClubDetailToEventDetail;

  List<String> buttonString = ["Erfahre mehr!", "Check it out!"];


  String cropGenres(){

    String eventGenresCut = "";

    // Check and crop the music genres
    if(clubMeEvent.getMusicGenres().length >= 22){
      eventGenresCut = "${clubMeEvent.getMusicGenres().substring(0, 21)}...";
    }else{
      eventGenresCut = clubMeEvent.getMusicGenres().substring(0, clubMeEvent.getMusicGenres().length);
    }

    if(eventGenresCut.substring(eventGenresCut.length -1) == ","){
      eventGenresCut = eventGenresCut.substring(0, eventGenresCut.length-1);
    }

    return eventGenresCut;
  }

  String formatWeekday(){

    String weekdayToDisplay = "";

    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestampGermany = tz.TZDateTime.from(DateTime.now(), berlin);
    final exactlyOneWeekFromNow = todayTimestampGermany.add(const Duration(days: 7));

    if(clubMeEvent.getEventDate().isBefore(exactlyOneWeekFromNow)){
      switch(clubMeEvent.getEventDate().weekday){
        case(1): weekdayToDisplay = "Montag";
        case(2): weekdayToDisplay = "Dienstag";
        case(3): weekdayToDisplay = "Mittwoch";
        case(4): weekdayToDisplay = "Donnerstag";
        case(5): weekdayToDisplay = "Freitag";
        case(6): weekdayToDisplay = "Samstag";
        case(7): weekdayToDisplay = "Sonntag";
        default: weekdayToDisplay = "Montag";
      }
    }else{
      weekdayToDisplay = "${clubMeEvent.getEventDate().day}.${clubMeEvent.getEventDate().month}.${clubMeEvent.getEventDate().year}";
    }

    return weekdayToDisplay;
  }

  String cropEventTitle(){
    String eventTitleCut = "";

    // Check and crop the title
    if(clubMeEvent.getEventTitle().length >= 22){
      eventTitleCut = "${clubMeEvent.getEventTitle().substring(0, 21)}...";
    }else{
      eventTitleCut = clubMeEvent.getEventTitle().substring(0, clubMeEvent.getEventTitle().length);
    }
    return eventTitleCut;
  }

  void clickedOnButton(BuildContext context, StateProvider stateProvider){
    stateProvider.setCurrentEvent(clubMeEvent);
    if(wentFromClubDetailToEventDetail)stateProvider.toggleWentFromCLubDetailToEventDetail();
    context.push("/event_details");
  }

  @override
  Widget build(BuildContext context) {

    customTextStyle = CustomTextStyle(context: context);

    String weekdayToDisplay = formatWeekday();

    String eventTitleCut = cropEventTitle();
    String eventGenresCut = cropGenres();

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight*0.18,
      child: Column(
        children: [

          // Weekday
          Container(
            width: screenWidth,
            padding: EdgeInsets.only(
                left: screenWidth*0.02,
                bottom: screenHeight*0.01
            ),
            child: Text(
              weekdayToDisplay,
              textAlign: TextAlign.left,
              style: customTextStyle.size5BoldDarkGrey(),
            ),
          ),

          Container(
              width: screenWidth*0.9,
              height: screenHeight*0.14,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[900]!,
                    blurRadius: 4,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child:Stack(
                children: [

                  Column(
                    children: [

                      // Event Title container
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth*0.03,
                          top: screenHeight*0.01
                        ),
                        child: Container(
                          // color: Colors.green,
                          width: screenWidth*0.9,
                          height: screenHeight*0.04,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              textAlign: TextAlign.start,
                              eventTitleCut,
                              style: customTextStyle.size3Bold(),
                            ),
                          ),
                        ),
                      ),


                      // eventGenre
                      Container(
                        // color: Colors.red,
                        width: screenWidth,
                        height: screenHeight*0.04,
                        child: Padding(
                          padding: EdgeInsets.only(
                              // top: screenHeight*0.045,
                              left: screenWidth*0.04
                          ),
                          child: Text(
                            eventGenresCut,
                            style: customTextStyle.size4(),
                          ),
                        ),
                      ),

                      // eventWhen
                      Container(
                        // color: Colors.green,
                        width: screenWidth,
                        height: screenHeight*0.05,
                        child: Padding(
                          padding: EdgeInsets.only(
                              // top: screenHeight*0.075,
                              left: screenWidth*0.04
                          ),
                          child: Text(
                            clubMeEvent.getEventStartingHours(),
                            style: customTextStyle.size5(),
                          ),
                        ),
                      ),

                    ],
                  ),


                  // Check it out button
                  Padding(
                    padding: const EdgeInsets.only(right: 7, bottom: 7),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Color(0xff11181f),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              )
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            buttonString[0],
                            style: customTextStyle.size4BoldPrimeColor(),
                          ),
                        ),
                        onTap: () => clickedOnButton(context, stateProvider),
                      ),
                    ),
                  )
                ],
              )
          )
        ],
      ),
    );
  }
}
