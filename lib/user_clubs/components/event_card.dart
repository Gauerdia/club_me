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
  late String formattedEventTitle, formattedEventGenres, formattedWeekDay;

  String startingHoursFormatted = "";
  List<String> buttonString = ["Erfahre mehr!", "Check it out!"];


  // FORMAT
  void formatWeekday(){

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

      String dayToDisplay = "";
      String monthToDisplay = "";

      if(clubMeEvent.getEventDate().day < 10){
        dayToDisplay = "0${clubMeEvent.getEventDate().day}";
      }else{
        dayToDisplay = clubMeEvent.getEventDate().day.toString();
      }

      if(clubMeEvent.getEventDate().month < 10){
        monthToDisplay = "0${clubMeEvent.getEventDate().month}";
      }else{
        monthToDisplay = clubMeEvent.getEventDate().month.toString();
      }

      weekdayToDisplay = "$dayToDisplay.$monthToDisplay.${clubMeEvent.getEventDate().year}";
    }

    formattedWeekDay = weekdayToDisplay;
  }
  void formatEventTitle(){
    String eventTitleCut = "";

    // Check and crop the title
    if(clubMeEvent.getEventTitle().length >= 22){
      eventTitleCut = "${clubMeEvent.getEventTitle().substring(0, 21)}...";
    }else{
      eventTitleCut = clubMeEvent.getEventTitle().substring(0, clubMeEvent.getEventTitle().length);
    }
    formattedEventTitle = eventTitleCut;
  }
  void formatEventGenres(){

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

    formattedEventGenres = eventGenresCut;
  }
  void formatStartingHour(){

    var colonPosition = clubMeEvent.getEventStartingHours().indexOf(":");

    if(colonPosition + 2 == clubMeEvent.getEventStartingHours().length){
      startingHoursFormatted = "${clubMeEvent.getEventStartingHours()}0";
    }else{
      startingHoursFormatted = clubMeEvent.getEventStartingHours();
    }
  }

  // CLICK
  void clickedOnButton(BuildContext context, StateProvider stateProvider){
    stateProvider.setCurrentEvent(clubMeEvent);
    if(wentFromClubDetailToEventDetail)stateProvider.toggleWentFromCLubDetailToEventDetail();
    context.push("/event_details");
  }

  @override
  Widget build(BuildContext context) {

    customTextStyle = CustomTextStyle(context: context);

    formatWeekday();
    formatEventTitle();
    formatEventGenres();
    formatStartingHour();

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: 130,
      child: Column(
        children: [

          // Weekday
          Container(
            width: screenWidth,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                bottom: screenHeight*0.01
            ),
            child: Text(
              formattedWeekDay,
              textAlign: TextAlign.left,
              style: customTextStyle.size5BoldDarkGrey(),
            ),
          ),

          // Main card
          Container(
              width: screenWidth*0.9,
              padding: const EdgeInsets.only(
                bottom: 5
              ),
              // height: screenHeight*0.14,
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

                  // Content column
                  Column(
                    children: [

                      // Event Title container
                      Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth*0.03,
                          top: screenHeight*0.01
                        ),
                        child: SizedBox(
                          width: screenWidth*0.9,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              textAlign: TextAlign.start,
                              formattedEventTitle,
                              style: customTextStyle.size3Bold(),
                            ),
                          ),
                        ),
                      ),


                      // eventGenre
                      SizedBox(
                        width: screenWidth,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth*0.03
                          ),
                          child: Text(
                            formattedEventGenres,
                            style: customTextStyle.size4(),
                          ),
                        ),
                      ),

                      // eventWhen
                      SizedBox(
                        width: screenWidth,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth*0.03
                          ),
                          child: Text(
                            startingHoursFormatted,
                            style: customTextStyle.size5(),
                          ),
                        ),
                      ),

                    ],
                  ),

                  // Check it out button
                  Padding(
                    padding: const EdgeInsets.only(right: 7, bottom: 7),
                    child: Container(
                      height: 80,
                      // width: screenWidth*0.92,
                      alignment: Alignment.bottomRight,
                      // color: Colors.red,
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
                            style: TextStyle(
                              color: customTextStyle.primeColor,
                              fontWeight: FontWeight.bold
                            ),
                            // style: customTextStyle.size4BoldPrimeColor(),
                          ),
                        ),
                        onTap: () => clickedOnButton(context, stateProvider),
                      ),
                    )
                  )

                ],
              )
          )
        ],
      ),
    );
  }
}
