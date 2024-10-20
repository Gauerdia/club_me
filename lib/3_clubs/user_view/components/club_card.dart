import 'dart:io';

import 'package:club_me/models/club_open_status.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    required this.clickEventShare,
  }) : super(key: key);

  late UserDataProvider userDataProvider;
  ClubMeClub clubMeClub;
  List<ClubMeEvent> events;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  Function () clickEventShare;
  Function () triggerSetState;

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;

  late double topHeight, bottomHeight;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late ClubOpenStatus clubOpenStatus;

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


  // BUILD
  Widget _buildMainView(BuildContext context){
    return SizedBox(
        width: screenWidth*0.95,
        height: screenHeight*0.74,
        child: Stack(
          children: [

            // Back background for the bottom part
            Center(
              child: Container(
                width: screenWidth*widthFactor,
                height: topHeight+bottomHeight,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        15
                    ),
                    border: Border.all(
                        color: Colors.grey[900]!,
                        width: 2.0
                    )
                ),
              ),
            ),

            // Main background
            Center(
              child: Container(
                alignment: Alignment.topCenter,
                width: screenWidth*widthFactor,
                height: topHeight+bottomHeight-100,
                decoration: BoxDecoration(
                  color: Colors.grey[900]!,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)
                  ),

                ),
              ),
            ),

            // Content
            Center(
                child: SizedBox(
                  width: screenWidth*widthFactor,
                  height: topHeight+bottomHeight,
                  child: Column(
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
                                        ),
                                        color: Colors.black,
                                      ),
                                      child: fetchedContentProvider
                                          .getFetchedBannerImageIds()
                                          .contains(clubMeClub.getBigLogoFileName()) ?
                                      ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(12),
                                              topLeft: Radius.circular(12)
                                          ),
                                          child: Image(
                                            image:
                                            FileImage(File("${stateProvider.appDocumentsDir.path}/${clubMeClub.getBigLogoFileName()}")),
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
                                  padding: const EdgeInsets.only(
                                      top: 10,
                                      left: 10
                                  ),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    clubOpenStatus.openingStatus == 0 ?
                                    "Geschlossen" :
                                    clubOpenStatus.openingStatus == 1 ?
                                    "Öffnet um ${clubOpenStatus.textToDisplay} Uhr":
                                    clubOpenStatus.openingStatus == 2 ?
                                    "Geöffnet":
                                    clubOpenStatus.openingStatus == 3 ?
                                    "Geöffnet, schließt um ${clubOpenStatus.textToDisplay} Uhr":
                                    "Geschlossen.",
                                    style: GoogleFonts.inter(
                                      textStyle: TextStyle(
                                              color: clubOpenStatus.openingStatus == 0 ?
                                              Colors.grey : clubOpenStatus.openingStatus == 2 ?
                                              customStyleClass.primeColor : Colors.white,
                                              fontWeight: FontWeight.bold
                                          )
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
                      SizedBox(
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

                            SizedBox(
                              width: screenWidth*0.2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [

                                  // INFO
                                  InkWell(
                                    child: Icon(
                                      Icons.info_outline,
                                      color: customStyleClass.primeColor,
                                    ),
                                    onTap: () => clickEventInfo(context),
                                  ),

                                  // STAR
                                  InkWell(
                                    child: Icon(
                                      currentAndLikedElementsProvider.checkIfSpecificCLubIsAlreadyLiked(clubMeClub.getClubId()) ? Icons.star_outlined : Icons.star_border,
                                      color: customStyleClass.primeColor,
                                    ),
                                    onTap: () => clickEventFavorite(context, clubMeClub.getClubId()),
                                  ),

                                  // SHARE
                                  InkWell(
                                    child: Icon(
                                      Icons.share,
                                      color: customStyleClass.primeColor,
                                    ),
                                    onTap: () => clickEventShare(),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // EVENTCARD: First Event
                      if( events.isNotEmpty)
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
                        ),

                      // TEXT: NO EVENTS AVAILABLE
                      if(events.isEmpty)
                        SizedBox(
                          width: screenWidth*widthFactor,
                          height: screenHeight*0.3,
                          child: Center(
                            child: Text(
                              "Leider sind derzeit keine Events verfügbar.",
                              style: customStyleClass.getFontStyle3(),
                            ),
                          ),
                        ),

                      // EVENTCARD: SECOND EVENT
                      if(events.length > 1)
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
                        ),
                    ],
                  ),
                )
            ),

            // Bottom part: Distance, Genre
            Center(
              child: Container(
                  height: screenHeight*0.685,
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            // Distance to club
                            calculateDistanceToClub() == 0 ?
                            CircularProgressIndicator(color: customStyleClass.primeColor,):
                            Row(
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

                                // DISTANCE
                                Text(
                                  "${calculateDistanceToClub().toStringAsFixed(2)} km",
                                  style: customStyleClass.getFontStyle3(),
                                ),
                              ],
                            ),

                            // Music Genre
                            Align(
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

                                  // GENRE TEXT
                                  Text(
                                    getAndFormatMusicGenre(),
                                    style: customStyleClass.getFontStyle3(),
                                  ),

                                ],
                              ),
                            ),
                          ]
                      )
                    ],
                  )
              ),
            )
          ],
        )
    );
  }


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


  // CLICK EVENTS
  void clickEventInfo(BuildContext context){
    currentAndLikedElementsProvider.setCurrentClub(clubMeClub);
    context.push("/club_details");
  }
  void clickEventFavorite(BuildContext context, String clubId){
    if(currentAndLikedElementsProvider.checkIfClubIsAlreadyLiked(clubId)){
      currentAndLikedElementsProvider.deleteLikedClub(clubId);
      _hiveService.deleteFavoriteClub(clubId);
    }else{
      currentAndLikedElementsProvider.addLikedClub(clubId);
      _hiveService.insertFavoriteClub(clubId);
    }
  }

  // FORMAT
  String getAndFormatMusicGenre() {
    if (clubMeClub.getMusicGenres().contains(",")) {
      var index = clubMeClub.getMusicGenres().indexOf(",");
      return clubMeClub.getMusicGenres().substring(0, index);
    } else {
      return clubMeClub.getMusicGenres();
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

    clubOpenStatus = clubMeClub.getClubOpenStatus();

    return _buildMainView(context);
  }
}