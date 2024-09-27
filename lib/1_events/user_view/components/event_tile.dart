import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/event.dart';
import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../shared/custom_text_style.dart';
import 'package:intl/intl.dart';

class EventTile extends StatelessWidget {
  EventTile({
    Key? key,
    required this.clubMeEvent,
    required this.isLiked,
    required this.clickedOnLike,
    required this.clickedOnShare,
    this.showMaterialButton = false
  }) : super(key: key);

  File? bannerToDisplay;

  bool isLiked;
  ClubMeEvent clubMeEvent;

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  Function () clickedOnShare;
  Function (StateProvider, String) clickedOnLike;

  String eventDjCut = "";
  String eventTitleCut = "";
  String priceFormatted = "";
  String weekDayToDisplay = "";

  double topHeight = 140;
  double bottomHeight = 100;

  bool closedToday = true;
  bool alreadyOpen = false;
  bool lessThanThreeMoreHoursOpen = false;
  int todaysOpeningHour = 0;
  int todaysClosingHour = 0;

  bool showMaterialButton;


  // CLICK
  void clickOnInfo(BuildContext context){
    Widget okButton = TextButton(
      child: Text(
          "OK",
        style: customStyleClass.getFontStyle4(),
      ),
      onPressed: () async {
        final Uri url = Uri.parse(clubMeEvent.getTicketLink());
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      },
    );

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: customStyleClass.backgroundColorEventTile,
            title: Text(
                "Ticketbuchuchung",
              style: customStyleClass.getFontStyle1(),
            ),
            content: Text(
              "Dieser Link führt Sie weiter zu der Seite, wo Sie direkt ein Ticket kaufen können."
                  "Ist das in Ordnung für Sie?",
              style: customStyleClass.getFontStyle4(),
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


    var hourToDisplay = clubMeEvent.getEventDate().hour < 10
        ? "0${clubMeEvent.getEventDate().hour}" : "${clubMeEvent.getEventDate().hour}";

    var minuteToDisplay = clubMeEvent.getEventDate().minute < 10
        ? "0${clubMeEvent.getEventDate().minute}"
        : "${clubMeEvent.getEventDate().minute}";

    weekDayToDisplay = DateFormat('dd.MM.yyyy').format(clubMeEvent.getEventDate());

    var eventDateWeekday = clubMeEvent.getEventDate().weekday;
    switch(eventDateWeekday){
      case(1): weekDayToDisplay = "Montag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(2): weekDayToDisplay = "Dienstag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(3): weekDayToDisplay = "Mittwoch, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(4): weekDayToDisplay = "Donnerstag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(5): weekDayToDisplay = "Freitag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(6): weekDayToDisplay = "Samstag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(7): weekDayToDisplay = "Sonntag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
    }
  }

  // BUILD
  Widget _buildStackView(BuildContext context){

    return Stack(
      children: [

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
                color: customStyleClass.backgroundColorEventTile,
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
        Container(
            height: topHeight,
            decoration: BoxDecoration(
              color: customStyleClass.backgroundColorEventTile,
              border: Border.all(
                color: customStyleClass.backgroundColorEventTile
              ),
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15)
              ),
            ),
            child: Stack(
              children: [

                // Image or loading indicator
                fetchedContentProvider.getFetchedBannerImageIds().contains(clubMeEvent.getBannerId())?
                SizedBox(
                  height: topHeight,
                  width: screenWidth,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15)
                      ),
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${clubMeEvent.getBannerId()}"
                            )
                        ),
                        fit: BoxFit.cover,
                      )
                )):
                SizedBox(
                  width: screenWidth,
                  height: topHeight,
                  child: Center(
                    child: SizedBox(
                      height: topHeight*0.5,
                      width: screenWidth*0.2,
                      child: CircularProgressIndicator(
                        color: customStyleClass.primeColor,
                      ),
                    ),
                  )
                ),

                // Display logo, when content is available
                clubMeEvent.getEventMarketingFileName().isNotEmpty && showMaterialButton ? Container(
                  height: topHeight,
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
        Container(
            height: bottomHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12)
              ),
              color: customStyleClass.backgroundColorEventTile
            ),
            child: Stack(
              children: [

                Column(
                  children: [

                    // Title + Price
                    Row(
                      children: [

                        // Title
                        SizedBox(
                          width: screenWidth*0.7,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth*0.02
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                eventTitleCut,
                                style: customStyleClass.getFontStyle3Bold(),
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
                                  style: customStyleClass.getFontStyle3Bold()
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),

                // Location
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth*0.02,
                        top: 26
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          clubMeEvent.getClubName(),
                          style:customStyleClass.getFontStyle5()
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
                              style: customStyleClass.getFontStyle6Bold()
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth*0.3,
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
                        style: customStyleClass.getFontStyle5BoldPrimeColor(),
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
                          if(clubMeEvent.getTicketLink().isNotEmpty)
                            GestureDetector(
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.ticket,
                                    color: customStyleClass.primeColor,
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
                                  color: customStyleClass.primeColor,
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
                                  color: customStyleClass.primeColor,
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

      ],
    );
  }

  void fetchAndSaveBannerImage() async {

    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String dirPath = appDocumentsDir.path;

    bannerToDisplay =  File("$dirPath/${clubMeEvent.getBannerId()}");

    var test = await File('$dirPath/${clubMeEvent.getBannerId()}').exists();

  }

  void checkIfClosed(){

    for(var element in clubMeEvent.getOpeningTimes().days!){

      // Catching the situation that the user checks the app after midnight.
      // We want him to know that it's open but will close some time.
      if(stateProvider.getBerlinTime().hour < 8){
        if(element.day!-1 == stateProvider.getBerlinTime().weekday){
          todaysClosingHour = element.closingHour!;
          closedToday = false;
          if(stateProvider.getBerlinTime().hour < todaysOpeningHour){
            alreadyOpen = true;
            if(todaysClosingHour - stateProvider.getBerlinTime().hour < 3){
              lessThanThreeMoreHoursOpen = true;
            }
          }
        }
      }else{
        if(element.day == stateProvider.getBerlinTime().weekday){
          todaysOpeningHour = element.openingHour!;
          closedToday = false;
          if(stateProvider.getBerlinTime().hour >= todaysOpeningHour) alreadyOpen = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    formatPrice();
    formatDJName();
    formatEventTitle();
    formatDateToDisplay();

    checkIfClosed();

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
