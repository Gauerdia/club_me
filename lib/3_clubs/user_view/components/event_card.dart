import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/event.dart';
import '../../../provider/current_and_liked_elements_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../shared/custom_text_style.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {

  EventCard({
    Key? key,
    required this.clubMeEvent,
    required this.accessedEventDetailFrom,
    this.wentFromClubDetailToEventDetail = false
  }) : super(key: key);

  int accessedEventDetailFrom;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  ClubMeEvent clubMeEvent;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  bool wentFromClubDetailToEventDetail;
  late String formattedEventTitle, formattedEventGenres, formattedWeekDay;

  String startingHoursFormatted = "";
  List<String> buttonString = ["Erfahre mehr!", "Check it out!"];


  // FORMAT
  void formatWeekday(){

    String weekDayToDisplay = "";

    // final berlin = tz.getLocation('Europe/Berlin');
    // final todayTimestampGermany = tz.TZDateTime.from(DateTime.now(), berlin);
    final exactlyOneWeekFromNow = stateProvider.getBerlinTime().add(const Duration(days: 7));

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

    formattedWeekDay = weekDayToDisplay;
  }
  void formatEventTitle(){
    String eventTitleCut = "";

    // Check and crop the title
    if(clubMeEvent.getEventTitle().length >= 32){
      eventTitleCut = "${clubMeEvent.getEventTitle().substring(0, 31)}...";
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

    if(clubMeEvent.getEventDate().hour < 10){
      if(clubMeEvent.getEventDate().minute < 10){
        startingHoursFormatted = "0${clubMeEvent.getEventDate().hour}:0${clubMeEvent.getEventDate().minute}";
      }else{
        startingHoursFormatted = "0${clubMeEvent.getEventDate().hour}:${clubMeEvent.getEventDate().minute}";
      }
    }else{
      if(clubMeEvent.getEventDate().minute < 10){
        startingHoursFormatted = "${clubMeEvent.getEventDate().hour}:0${clubMeEvent.getEventDate().minute}";
      }else{
        startingHoursFormatted = "${clubMeEvent.getEventDate().hour}:${clubMeEvent.getEventDate().minute}";
      }
    }
  }

  // CLICK
  void clickedOnButton(BuildContext context){
    stateProvider.setAccessedEventDetailFrom(accessedEventDetailFrom);
    currentAndLikedElementsProvider.setCurrentEvent(clubMeEvent);
    if(wentFromClubDetailToEventDetail)stateProvider.toggleWentFromCLubDetailToEventDetail();
    context.push("/event_details");
  }

  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    stateProvider = Provider.of<StateProvider>(context);

    formatWeekday();
    formatEventTitle();
    formatEventGenres();
    formatStartingHour();

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
              style: customStyleClass.getFontStyle5BoldLightGrey(),
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
                              style: customStyleClass.getFontStyle3Bold(),
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
                            style: customStyleClass.getFontStyle4(),
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
                            style: customStyleClass.getFontStyle5(),
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
                              color: customStyleClass.primeColor,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        onTap: () => clickedOnButton(context),
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
