import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/club.dart';
import '../../../models/event.dart';
import '../../../provider/current_and_liked_elements_provider.dart';
import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../provider/user_data_provider.dart';
import '../../../services/hive_service.dart';
import '../../../shared/custom_text_style.dart';
import 'event_card.dart';
import 'dart:math';



class ClubCard extends StatelessWidget {

  ClubCard({
    Key? key,
    required this.events,
    required this.clubMeClub,
    required this.triggerSetState,
    required this.clickedOnShare,
  }) : super(key: key);

  late UserDataProvider userDataProvider;
  ClubMeClub clubMeClub;
  List<ClubMeEvent> events;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  Function () clickedOnShare;
  Function () triggerSetState;

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;

  late double topHeight, bottomHeight;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  double widthFactor = 0.95;

  double contentHeightFactor = 0.52;
  double headerContainerFactor = 0.07;
  double eventsContainerFactor = 0.33;
  double bottomContainerFactor = 0.08;

  final HiveService _hiveService = HiveService();

  bool tempLiked = false;

  List<String> noEventsPlanned = ["Derzeit kein Event geplant!"];

  bool closedToday = true;
  bool alreadyOpen = false;
  bool lessThanThreeMoreHoursOpen = false;
  int todaysOpeningHour = 0;
  int todaysClosingHour = 0;


  // CALCULATE
  String getRandomNumber(){

    final random = Random();
    int next(int min, int max) => min + random.nextInt(max - min);

    return next(20, 50).toString();

  }
  double calculateDistanceToClub(){

    if(userDataProvider.getUserLatCoord() != 0){

      var distance = Geolocator.distanceBetween(
          userDataProvider.getUserLatCoord(),
          userDataProvider.getUserLongCoord(),
          clubMeClub.getGeoCoordLat(),
          clubMeClub.getGeoCoordLng()
      );

      if(distance/1000 > 1000){
        return 999;
      }else{
        return distance/1000;
      }
    }else{
      return 0;
    }
  }
  void checkIfClosed(){
    for(var element in clubMeClub.getOpeningTimes().days!){

      // Catching the situation that the user checks the app after midnight.
      // We want him to know that it's open but will close some time.
      if(stateProvider.getBerlinTime().hour < 8){
        if(element.day!-1 == stateProvider.getBerlinTime().weekday){
          todaysClosingHour = element.closingHour!;
          closedToday = false;
          if(stateProvider.getBerlinTime().hour < element.closingHour!){
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


  void clickEventInfoButtonClicked(BuildContext context){
    currentAndLikedElementsProvider.setCurrentClub(clubMeClub);
    context.push("/club_details");
  }
  void clickEventFavoriteButtonClicked(BuildContext context, String clubId){
    if(currentAndLikedElementsProvider.checkIfClubIsAlreadyLiked(clubId)){
      currentAndLikedElementsProvider.deleteLikedClub(clubId);
      _hiveService.deleteFavoriteClub(clubId);
    }else{
      currentAndLikedElementsProvider.addLikedClub(clubId);
      _hiveService.insertFavoriteClub(clubId);
    }
  }
  void clickEventShareButtonClicked(BuildContext context){

  }


  // BUILD
  Widget _buildStackView(BuildContext context){

    return Stack(
      children: [

        Container(
          width: screenWidth*(widthFactor - 0.01),
          height: topHeight+bottomHeight,
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(
                  15
              ),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[900]!
              )
            )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*(widthFactor - 0.01),
          height: topHeight+bottomHeight-70,
          decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*(widthFactor-0.02),
            height: topHeight+bottomHeight,
            decoration: BoxDecoration(
                color: const Color(0xff222222),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: _buildNewContentView(context)
          ),
        )

      ],
    );
  }
  Widget _buildNewContentView(BuildContext context){
    return Column(
      children: [

        // Image part
        GestureDetector(
          child: SizedBox(
            height: screenHeight*0.2,
            child: Stack(
              children: [

                Container(

                  // Image background
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                    ),
                  ),

                  // Image + its sides
                  child: Container(
                      width: screenWidth*0.95,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        color: Colors.white,
                      ),
                      // height: screenHeight*0.17,
                      child:
                      fetchedContentProvider.getFetchedBannerImageIds().contains(clubMeClub.getBannerId())?
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12)
                        ),
                        child: Image(
                          image: FileImage(File("${stateProvider.appDocumentsDir.path}/${clubMeClub.getBannerId()}")),
                          fit: BoxFit.cover,
                        )
                      ) :
                      SizedBox(
                        height: screenHeight*0.2,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: customStyleClass.primeColor,
                          ),
                        ),
                      )
                  ),
                ),

                Container(
                  width: screenWidth*0.95,
                  // color: Colors.red,
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 10
                  ),
                  alignment: Alignment.topLeft,
                  child: Text(
                    closedToday ?
                    "Geschlossen" :
                    alreadyOpen ?
                    lessThanThreeMoreHoursOpen ?
                    "Geöffnet, schließt um $todaysClosingHour" :
                    "Geöffnet" :
                    "Öffnet um $todaysOpeningHour:00 Uhr",
                    style: TextStyle(
                        color: closedToday ?
                        Colors.grey : alreadyOpen ?
                        customStyleClass.primeColor : Colors.white,
                      fontSize: customStyleClass.getFontSize6()
                    ),
                  ),
                )

              ],
            ),
          ),
          onTap: (){
            currentAndLikedElementsProvider.setCurrentClub(clubMeClub);
            context.push("/club_details");
          },
        ),

        // Content
        Container(
          height: screenHeight*contentHeightFactor,
          width: screenWidth*0.95,
          // color: Colors.red,
          child: Column(
            children: [

              // Spacer
              SizedBox(
                height: screenHeight*0.01,
              ),

              // Header: name, icons
              Container(
                color: Colors.red,
                height: screenHeight*headerContainerFactor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Title
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10,
                            left: 10,
                            bottom: 10
                        ),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: screenWidth*0.5,
                              height: screenHeight*0.05,
                              child: Text(
                                clubMeClub.getClubName().length > 20 ?
                                "${clubMeClub.getClubName().substring(0,18)}...":
                                clubMeClub.getClubName(),
                                style: customStyleClass.getFontStyleHeadline1Bold(),
                              ),
                            )
                        ),
                      ),
                      onTap: (){
                        currentAndLikedElementsProvider.setCurrentClub(clubMeClub);
                        context.push("/club_details");
                      },
                    ),

                    // Icon row
                    SizedBox(
                      height: screenHeight*0.08,
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icons
                              Row(
                                children: [

                                  GestureDetector(
                                      child:Column(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: customStyleClass.primeColor,
                                          ),
                                        ],
                                      ),
                                      onTap: (){
                                        currentAndLikedElementsProvider.setCurrentClub(clubMeClub);
                                        context.push("/club_details");
                                      }
                                  ),
                                  SizedBox(
                                    width: screenWidth*0.02,
                                  ),

                                  GestureDetector(
                                      child:Column(
                                        children: [
                                          Icon(
                                            currentAndLikedElementsProvider.checkIfSpecificCLubIsAlreadyLiked(clubMeClub.getClubId()) ? Icons.star_outlined : Icons.star_border,
                                            color: customStyleClass.primeColor,
                                          ),
                                        ],
                                      ),
                                      onTap: () => likeIconClicked(stateProvider, clubMeClub.getClubId())
                                  ),

                                  SizedBox(
                                    width: screenWidth*0.02,
                                  ),

                                  GestureDetector(
                                      child:Column(
                                        children: [
                                          Icon(
                                            Icons.share,
                                            color: customStyleClass.primeColor,
                                          ),
                                        ],
                                      ),
                                      onTap: () => clickedOnShare()
                                  ),

                                  SizedBox(
                                    width: screenWidth*0.02,
                                  ),


                                ],
                              ),
                              // Spacer
                              SizedBox(
                                height: screenHeight*0.01,
                              ),
                            ],
                          )
                      ),
                    )

                  ],
                ),
              ),

              // White line
              const Divider(
                height:10 ,
                thickness: 1,
                color: Colors.white,
                indent: 10,
                endIndent: 10,
              ),

              // Middle part: next two events
              SizedBox(
                  height: screenHeight*eventsContainerFactor,
                  // color: Colors.red,
                  child: SingleChildScrollView(
                    child:Column(
                      children: [

                        // Spacer
                        SizedBox(
                          height: screenHeight*0.01,
                        ),

                        // Card
                        events.isNotEmpty ?
                        GestureDetector(
                          child: EventCard(
                              clubMeEvent: events[0],
                            accessedEventDetailFrom: 1,
                            backgroundColorIndex: 0,
                          ),
                          onTap: (){
                            currentAndLikedElementsProvider.setCurrentEvent(events[0]);
                            stateProvider.setAccessedEventDetailFrom(1);
                            context.push('/event_details');
                          },
                        ):SizedBox(
                          height: screenHeight*0.3,
                          child: Center(
                            child: Text(
                                noEventsPlanned[0],
                              style: customStyleClass.getFontStyle3(),
                            ),
                          ),
                        ),

                        // Spacer
                        SizedBox(
                          height: screenHeight*0.01,
                        ),

                        // Card
                        events.length > 1 ?
                        GestureDetector(
                          child: EventCard(
                              clubMeEvent: events[1],
                            accessedEventDetailFrom: 1,
                            backgroundColorIndex: 0,
                          ),
                          onTap: (){
                            currentAndLikedElementsProvider.setCurrentEvent(events[1]);
                            stateProvider.setAccessedEventDetailFrom(1);
                            context.push('/event_details');
                          },
                        ):Container(),

                      ],
                    ),
                  )
              ),

              // White line
              const Divider(
                height:10,
                thickness: 1,
                color: Colors.white,
                indent: 10,
                endIndent: 10,
              ),

              // Bottom part
              Container(
                  // color: Colors.black,
                  height: screenHeight*bottomContainerFactor,
                  // width: screenWidth*0.85,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        // Distance to club
                        calculateDistanceToClub() == 0 ?
                        const CircularProgressIndicator():
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight*0.01,
                              horizontal: screenWidth*0.03
                          ),
                          child: Row(
                            children: [

                              // Genres icon
                              Container(
                                padding: const EdgeInsets.all(
                                    4
                                ),
                                child: Icon(
                                    Icons.location_on_outlined,
                                    color: customStyleClass.primeColor,

                                ),
                              ),

                              // Spacer
                              SizedBox(
                                width: screenWidth*0.01,
                              ),

                              Text(
                                calculateDistanceToClub().toStringAsFixed(2),
                                style: customStyleClass.getFontStyle3(),
                              ),

                            ],
                          ),
                        ),

                        // Music Genre
                        Align(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight*0.01,
                                horizontal: screenWidth*0.03
                            ),
                            child: Row(
                              children: [
                                // Genres icon
                                Container(
                                  padding: const EdgeInsets.all(
                                      4
                                  ),
                                  child: Icon(
                                      Icons.music_note,
                                      color: customStyleClass.primeColor,
                                  ),
                                ),

                                // Spacer
                                SizedBox(
                                  width: screenWidth*0.01,
                                ),

                                Text(
                                  getAndFormatMusicGenre(),
                                  style: customStyleClass.getFontStyle3(),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ]
                  )
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStackView2(BuildContext context){
    return Stack(
      children: [

        // Back background for the bottom part
        Container(
          width: screenWidth*widthFactor,
          height: topHeight+bottomHeight,
          decoration: BoxDecoration(
              // color: Colors.red,
              borderRadius: BorderRadius.circular(
                  15
              ),
              border: Border.all(
                  color: Colors.grey[900]!,
                  width: 2.0
              )
          ),
        ),

        // Main background
        Container(
          height: topHeight+bottomHeight-60,
          decoration: BoxDecoration(
            color: Colors.grey[900]!,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                topRight: Radius.circular(15)
              ),

          ),
        ),

        // Content
        Column(
          children: [

            // Image part
            GestureDetector(
              child:Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(
                    top: 2
                ),
                child:  Container(
                  width:screenWidth*(widthFactor - 0.01) ,
                  alignment: Alignment.center,
                  height: screenHeight*0.2,
                  child: Stack(
                    children: [

                      // Image
                      Container(

                        // Image background
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                        ),

                        // Image + its sides
                        child: Container(
                            width: screenWidth*0.95,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              color: Colors.white,
                            ),
                            // height: screenHeight*0.17,
                            child:
                            fetchedContentProvider.getFetchedBannerImageIds().contains(clubMeClub.getBannerId())?
                            ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    topLeft: Radius.circular(12)
                                ),
                                child: Image(
                                  image: FileImage(File("${stateProvider.appDocumentsDir.path}/${clubMeClub.getBannerId()}")),
                                  fit: BoxFit.cover,
                                )
                            ) :
                            SizedBox(
                              height: screenHeight*0.2,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: customStyleClass.primeColor,
                                ),
                              ),
                            )
                        ),
                      ),

                      // Open/Closed Text
                      Container(
                        width: screenWidth*0.95,
                        // color: Colors.red,
                        padding: const EdgeInsets.only(
                            top: 10,
                            left: 10
                        ),
                        alignment: Alignment.topLeft,
                        child: Text(
                          closedToday ?
                          "Geschlossen" :
                          alreadyOpen ?
                          lessThanThreeMoreHoursOpen ?
                          "Geöffnet, schließt um $todaysClosingHour" :
                          "Geöffnet" :
                          "Öffnet um $todaysOpeningHour:00 Uhr",
                          style: TextStyle(
                              color: closedToday ?
                              Colors.grey : alreadyOpen ?
                              customStyleClass.primeColor : Colors.white
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              ),
              onTap: (){
                currentAndLikedElementsProvider.setCurrentClub(clubMeClub);
                context.push("/club_details");
              },
            ),

            // Title + Icons
            Container(
              height: screenHeight*0.1,
              width: screenWidth*0.9,
              // color: Colors.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [


                  // Title
                  GestureDetector(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(

                        left: 10,

                      ),
                      width: screenWidth*0.5,
                      child: Text(
                        clubMeClub.getClubName().length > 20 ?
                        "${clubMeClub.getClubName().substring(0,18)}...":
                        clubMeClub.getClubName(),
                        style: customStyleClass.getFontStyle1Bold(),
                      ),
                    ),
                    onTap: (){
                      currentAndLikedElementsProvider.setCurrentClub(clubMeClub);
                      context.push("/club_details");
                    },
                  ),


                  Container(
                    // color: Colors.grey,
                    width: screenWidth*0.2,
                    // alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        InkWell(
                          child: Icon(
                            Icons.info_outline,
                            color: customStyleClass.primeColor,
                          ),
                          onTap: () => clickEventInfoButtonClicked(context),
                        ),

                        InkWell(
                          child: Icon(
                            currentAndLikedElementsProvider.checkIfSpecificCLubIsAlreadyLiked(clubMeClub.getClubId()) ? Icons.star_outlined : Icons.star_border,
                            color: customStyleClass.primeColor,
                          ),
                          onTap: () => clickEventFavoriteButtonClicked(context, clubMeClub.getClubId()),
                        ),

                        InkWell(
                          child: Icon(
                            Icons.share,
                            color: customStyleClass.primeColor,
                          ),
                          onTap: () => clickedOnShare(),
                        ),

                      ],
                    ),
                  )
                ],
              ),
            ),

            events.isNotEmpty ?
            GestureDetector(
              child: EventCard(
                clubMeEvent: events[0],
                accessedEventDetailFrom: 1,
                backgroundColorIndex: 0,
              ),
              onTap: (){
                currentAndLikedElementsProvider.setCurrentEvent(events[0]);
                stateProvider.setAccessedEventDetailFrom(1);
                context.push('/event_details');
              },
            ):SizedBox(
              height: screenHeight*0.3,
              child: Center(
                child: Text(
                  noEventsPlanned[0],
                  style: customStyleClass.getFontStyle3(),
                ),
              ),
            ),

            // Card
            events.length > 1 ?
            GestureDetector(
              child: EventCard(
                clubMeEvent: events[1],
                accessedEventDetailFrom: 1,
                backgroundColorIndex: 0,
              ),
              onTap: (){
                currentAndLikedElementsProvider.setCurrentEvent(events[1]);
                stateProvider.setAccessedEventDetailFrom(1);
                context.push('/event_details');
              },
            ):Container(),

            events.length > 1 ? Container(
              height: screenHeight*0.035,
            ) : events.length == 1 ?
            Container(height: screenHeight*0.18) :
            Container(height: screenHeight*0.024),

            // Bottom part
            Container(
              // color: Colors.blue,
                // alignment: Alignment.bottomCenter,
                height: screenHeight*bottomContainerFactor,
                // width: screenWidth*0.85,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      // Distance to club
                      calculateDistanceToClub() == 0 ?
                      const CircularProgressIndicator():
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight*0.01,
                            horizontal: screenWidth*0.03
                        ),
                        child: Row(
                          children: [

                            // Genres icon
                            Container(
                              padding: const EdgeInsets.all(
                                  4
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: customStyleClass.primeColor,

                              ),
                            ),

                            // Spacer
                            SizedBox(
                              width: screenWidth*0.01,
                            ),

                            Text(
                              calculateDistanceToClub().toStringAsFixed(2),
                              style: customStyleClass.getFontStyle3(),
                            ),

                          ],
                        ),
                      ),

                      // Music Genre
                      Align(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight*0.01,
                              horizontal: screenWidth*0.03
                          ),
                          child: Row(
                            children: [
                              // Genres icon
                              Container(
                                padding: const EdgeInsets.all(
                                    4
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  color: customStyleClass.primeColor,
                                ),
                              ),

                              // Spacer
                              SizedBox(
                                width: screenWidth*0.01,
                              ),

                              Text(
                                getAndFormatMusicGenre(),
                                style: customStyleClass.getFontStyle3(),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ]
                )
            )

          ],
        )

      ],
    );
  }

  // CLICK + FORMAT
  String getAndFormatMusicGenre() {
    if (clubMeClub.getMusicGenres().contains(",")) {
      var index = clubMeClub.getMusicGenres().indexOf(",");
      return clubMeClub.getMusicGenres().substring(0, index);
    } else {
      return clubMeClub.getMusicGenres();
    }
  }
  void likeIconClicked(StateProvider stateProvider, String clubId){
    if(currentAndLikedElementsProvider.checkIfClubIsAlreadyLiked(clubId)){
      currentAndLikedElementsProvider.deleteLikedClub(clubId);
      _hiveService.deleteFavoriteClub(clubId);
    }else{
      currentAndLikedElementsProvider.addLikedClub(clubId);
      _hiveService.insertFavoriteClub(clubId);
    }
  }



  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    topHeight = screenHeight*0.2;
    bottomHeight = screenHeight*0.5;

    customStyleClass = CustomStyleClass(context: context);

    checkIfClosed();

    return SizedBox(

        width: screenWidth*0.95,
        height: screenHeight*0.74, //76

        child: _buildStackView2(context)
    );
  }
}