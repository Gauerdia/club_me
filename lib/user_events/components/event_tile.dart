import 'package:club_me/models/parser/club_me_club_parser.dart';
import 'package:club_me/models/parser/club_me_event_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../provider/state_provider.dart';
import 'package:intl/intl.dart';
import '../../shared/custom_text_style.dart';

import 'package:timezone/standalone.dart' as tz;

class EventTile extends StatelessWidget {
  EventTile({
    Key? key,
    required this.clubMeEvent,
    required this.isLiked,
    required this.clickedOnLike,
    required this.clickedOnShare
  }) : super(key: key);

  bool isLiked;
  ClubMeEvent clubMeEvent;

  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

  Function () clickedOnShare;
  Function (StateProvider, String) clickedOnLike;

  String eventDjCut = "";
  String eventTitleCut = "";
  String priceFormatted = "";
  String weekDayToDisplay = "";

  double topHeight = 170;
  double bottomHeight = 170;


  // CLICK
  void clickOnInfo(BuildContext context){
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Event-Informationen"),
            content: Text(
              clubMeEvent.getEventDescription(),
            ),
            actions: [
              okButton
            ],
          );
        }
    );
  }

  // FORMAT TEXTS
  void formatPrice(){

    var priceDecimalPosition = clubMeEvent.getEventPrice().toString().indexOf(".");

    if(priceDecimalPosition + 2 == clubMeEvent.getEventPrice().toString().length){
      priceFormatted = "${clubMeEvent.getEventPrice().toString().replaceFirst(".", ",")}0 €";
    }else{
      priceFormatted = "${clubMeEvent.getEventPrice().toString().replaceFirst(".", ",")} €";
    }
  }
  void formatDJName(){
    if(clubMeEvent.getDjName().length >= 42){
      eventDjCut = "${clubMeEvent.getDjName().substring(0, 45)}...";
    }else{
      eventDjCut = clubMeEvent.getDjName().substring(0, clubMeEvent.getDjName().length);
    }
  }
  void formatEventTitle(){
    if(clubMeEvent.getEventTitle().length >= 49){
      eventTitleCut = "${clubMeEvent.getEventTitle().substring(0, 47)}...";
    }else{
      eventTitleCut = clubMeEvent.getEventTitle().substring(0, clubMeEvent.getEventTitle().length);
    }
  }
  void formatDateToDisplay(){

    var exactOneWeekFromNow = DateTime.now().add(const Duration(days: 7));

    // Get current time for germany
    final berlin = tz.getLocation('Europe/Berlin');
    final todayGermanTZ = tz.TZDateTime.from(DateTime.now(), berlin);

    final exactlyOneWeekFromNowGermanTZ = todayGermanTZ.add(Duration(days: 7));

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

    // if(clubMeEvent.getEventDate().isAfter(exactlyOneWeekFromNowGermanTZ)){
    //   weekDayToDisplay = DateFormat('dd.MM.yyyy').format(clubMeEvent.getEventDate());
    // }else{
    //   var eventDateWeekday = clubMeEvent.getEventDate().weekday;
    //   switch(eventDateWeekday){
    //     case(1): weekDayToDisplay = "Montag";
    //     case(2): weekDayToDisplay = "Dienstag";
    //     case(3): weekDayToDisplay = "Mittwoch";
    //     case(4): weekDayToDisplay = "Donnerstag";
    //     case(5): weekDayToDisplay = "Freitag";
    //     case(6): weekDayToDisplay = "Samstag";
    //     case(7): weekDayToDisplay = "Sonntag";
    //   }
    // }
  }

  // BUILD
  Widget _buildStackView(BuildContext context){

    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height:  topHeight+bottomHeight+6,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: topHeight+bottomHeight,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: topHeight+bottomHeight,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[900]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: topHeight+bottomHeight,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: topHeight+bottomHeight,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: const [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: _buildStackViewContent(context),
          ),
        )

      ],
    );
  }
  Widget _buildStackViewContent(BuildContext context){
    return Column(
      children: [

        // Image container
        SizedBox(
            height: topHeight,
            child: Stack(
              children: [

                SizedBox(
                  height: topHeight, //screenHeight*0.15,
                  width: screenWidth,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)
                    ),
                    child: Image.asset(
                      "assets/images/${clubMeEvent.getBannerId()}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                clubMeEvent.getEventMarketingFileName().isNotEmpty ? Container(
                  height: topHeight, //screenHeight*0.15,
                  width: screenWidth,
                  alignment: Alignment.topRight,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)
                    ),
                    child: Image.asset(
                      "assets/images/club_me_icon_round.png",
                      scale: 15,
                      // fit: BoxFit.cover,
                    ),
                  ),
                ): Container(),

              ],
            )
        ),

        // Content container
        SizedBox(
          height: bottomHeight,
          child: Container(
              height: bottomHeight,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12)
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

                      // Title + Price
                      Row(
                        children: [

                          // Title
                          Padding(
                            padding: EdgeInsets.only(
                              top: screenHeight*0.01,
                            ),
                            child: SizedBox(
                              width: screenWidth*0.7,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth*0.02
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    eventTitleCut,
                                    style: customTextStyle.getFontStyle1Bold(),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Price
                          SizedBox(
                            width: screenWidth*0.2,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: screenHeight*0.01
                              ),
                              child: Align(
                                child: Text(
                                    priceFormatted,
                                    textAlign: TextAlign.center,
                                    style: customTextStyle.getFontStyle2BoldLightGrey()
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),

                      // Location
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth*0.02
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                clubMeEvent.getClubName(),
                                style:customTextStyle.getFontStyle3Bold()
                            ),
                          ),
                        ),
                      ),

                      // DJ
                      Row(
                        children: [
                          Container(
                            width: screenWidth*0.6,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: screenWidth*0.02
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    eventDjCut,
                                    textAlign: TextAlign.left,
                                    style: customTextStyle.size4BoldGrey2()
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: screenWidth*0.3,
                          )
                        ],
                      )

                    ],
                  ),

                  // When
                  Container(
                    height: bottomHeight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth*0.02,
                          bottom: screenHeight*0.01
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          weekDayToDisplay,
                          style: customTextStyle.size5BoldGrey(),
                        ),
                      ),
                    ),
                  ),

                  // Icons
                  Container(
                    height: bottomHeight,
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.only(
                        bottom: screenHeight*0.01,
                        right: screenWidth*0.02
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            // Info
                            GestureDetector(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: stateProvider.getPrimeColor(),
                                  ),
                                  Text(
                                    "Info",
                                    style: customTextStyle.size5(),
                                  ),
                                ],
                              ),
                              onTap: () => clickOnInfo(context),
                            ),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),

                            // Like
                            GestureDetector(
                              child: Column(
                                children: [
                                  Icon(
                                    isLiked ? Icons.star_outlined : Icons.star_border,
                                    color: stateProvider.getPrimeColor(),
                                  ),
                                  Text(
                                    "Like",
                                    style: customTextStyle.size5(),
                                  ),
                                ],
                              ),
                              onTap: () => clickedOnLike(stateProvider, clubMeEvent.getEventId()),
                            ),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),

                            // Share
                            GestureDetector(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.share,
                                    color: stateProvider.getPrimeColor(),
                                  ),
                                  Text(
                                    "Share",
                                    style: customTextStyle.size5(),
                                  ),
                                ],
                              ),
                              onTap: () => clickedOnShare(),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
          ),
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    formatPrice();
    formatDJName();
    formatEventTitle();
    formatDateToDisplay();

    return Container(
      padding: EdgeInsets.only(
          bottom: screenHeight*0.02
      ),
      child: Center(
        child:
        _buildStackView(context),
      )
    );
  }
}
