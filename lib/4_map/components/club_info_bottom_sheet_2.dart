import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../3_clubs/user_view/components/event_card.dart';
import '../../models/event.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../shared/custom_text_style.dart';

class ClubInfoBottomSheet2 extends StatefulWidget {
  ClubInfoBottomSheet2({
    Key? key,
    required this.showBottomSheet,
    this.clubMeEvent,
    required this.noEventAvailable
  });

  late bool showBottomSheet;
  late bool noEventAvailable;
  late ClubMeEvent? clubMeEvent;

  @override
  State<ClubInfoBottomSheet2> createState() => _ClubInfoBottomSheet2State();
}

class _ClubInfoBottomSheet2State extends State<ClubInfoBottomSheet2> {


  late bool showBottomSheet;
  late bool noEventAvailable;

  late ClubMeEvent? clubMeEvent;
  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;


  bool closedToday = true;
  bool alreadyOpen = false;
  bool lessThanThreeMoreHoursOpen = false;
  int todaysOpeningHour = 0;
  int todaysClosingHour = 0;

  double iconWidthFactor = 0.05;
  double imageHeightFactor = 0.09;
  double headlineHeightFactor = 0.09;

  double topHeight = 145;
  double bottomHeight = 180;

  final HiveService _hiveService = HiveService();

  // CLICK
  void clickOnInfo(){
    /// TODO: Make something with the click
    print("Info");
  }
  void clickOnLike(){
    likeIconClicked(currentAndLikedElementsProvider.currentClubMeClub.getClubId());
  }
  void clickOnShare(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Teilen"),
        content: Text(
          "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!",
          textAlign: TextAlign.left,
          style: customStyleClass.getFontStyle4(),
        ),
      );
    });
  }
  void likeIconClicked(String clubId){
    if(currentAndLikedElementsProvider.checkIfClubIsAlreadyLiked(clubId)){
      currentAndLikedElementsProvider.deleteLikedClub(clubId);
      _hiveService.deleteFavoriteClub(clubId);
    }else{
      currentAndLikedElementsProvider.addLikedClub(clubId);
      _hiveService.insertFavoriteClub(clubId);
    }
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
          currentAndLikedElementsProvider.currentClubMeClub.getGeoCoordLat(),
          currentAndLikedElementsProvider.currentClubMeClub.getGeoCoordLng()
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

  // FORMAT
  String getAndFormatMusicGenre() {

    String genreToReturn = "";

    if (currentAndLikedElementsProvider.currentClubMeClub.getMusicGenres().contains(",")) {
      var index = currentAndLikedElementsProvider.currentClubMeClub.getMusicGenres().indexOf(",");
      genreToReturn = currentAndLikedElementsProvider.currentClubMeClub.getMusicGenres().substring(0, index);
    } else {
      genreToReturn = currentAndLikedElementsProvider.currentClubMeClub.getMusicGenres();
    }

    if(genreToReturn.length>8){
      genreToReturn = "${genreToReturn.substring(0, 7)}...";
    }
    return genreToReturn;

  }

  void checkIfClosed(){
    // final berlin = tz.getLocation('Europe/Berlin');
    // final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

    for(var element in currentAndLikedElementsProvider.currentClubMeClub.getOpeningTimes().days!){

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

  Widget _buildStackView(BuildContext context){

    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.963,
          height:  topHeight+bottomHeight+6,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customStyleClass.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.95,
          height: topHeight+bottomHeight,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customStyleClass.primeColorDark.withOpacity(0.2)
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
          width: screenWidth*0.94,
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
              width: screenWidth*0.95,
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
            width: screenWidth*0.95,
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

                // Image or loading indicator
                fetchedContentProvider.getFetchedBannerImageIds().contains(
                    currentAndLikedElementsProvider.currentClubMeClub.getBannerId()
                )?
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
                                  "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getBannerId()}"
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

                Container(
                  height: screenHeight*headlineHeightFactor,
                  width: screenWidth,
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
                    "Öffnet um $todaysOpeningHour Uhr",
                    style: TextStyle(
                        color: closedToday ? Colors.grey : alreadyOpen ?
                        customStyleClass.primeColor : Colors.white
                    ),
                  ),
                )

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

                      // Event Card
                      Container(
                        padding: const EdgeInsets.only(
                          top: 5
                        ),
                        child: noEventAvailable ?
                        SizedBox(
                          height: bottomHeight-45,
                          child: Center(
                            child: Text(
                              "Derzeit kein Event geplant!",
                              style: customStyleClass.getFontStyle3(),
                            ),
                          ),
                        ):GestureDetector(
                          child: EventCard(
                            clubMeEvent: clubMeEvent!,
                            accessedEventDetailFrom: 3,
                          ),
                          onTap: (){
                            currentAndLikedElementsProvider.setCurrentEvent(clubMeEvent!);
                            stateProvider.setAccessedEventDetailFrom(3);
                            context.push("/event_details");
                          },
                        ),
                      ),

                      // Spacer
                      SizedBox(height: screenHeight*0.01,),

                      // BottomSheet
                      Container(
                        width: screenWidth*0.9,
                        padding: const EdgeInsets.only(
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // Info, Like, Share
                            Container(
                              // width: screenWidth*0.32,
                              // height: screenHeight*0.055,
                              padding: EdgeInsets.symmetric(
                                  // horizontal: screenWidth*0.03,
                                  // vertical: screenHeight*0.012
                              ),

                              decoration: const BoxDecoration(
                                // color: Color(0xff11181f),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(12)
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [

                                      // Info icon
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 4
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(45)
                                            ),
                                          ),
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.info_outline,
                                              color: customStyleClass.primeColor,
                                              size: screenWidth*iconWidthFactor,
                                            ),
                                            onTap: () => clickOnInfo(),
                                          )
                                      ),

                                      // Spacer
                                      const SizedBox(width: 15,),

                                      // star
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 4
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(45)
                                          ),
                                        ),
                                        child: GestureDetector(
                                          child: Icon(
                                            currentAndLikedElementsProvider.checkIfSpecificCLubIsAlreadyLiked(currentAndLikedElementsProvider.currentClubMeClub.getClubId())
                                                ? Icons.star_outlined
                                                : Icons.star_border,
                                            color: customStyleClass.primeColor,
                                            size: screenWidth*iconWidthFactor,
                                          ),
                                          onTap: () => clickOnLike(),
                                        ),
                                      ),

                                      // Spacer
                                      const SizedBox(width: 15,),

                                      // share
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 4
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(45)
                                          ),
                                        ),
                                        child: GestureDetector(
                                          child: Icon(
                                            Icons.share,
                                            color: customStyleClass.primeColor,
                                            size: screenWidth*iconWidthFactor,
                                          ),
                                          onTap: () => clickOnShare(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Icon Row
                            Padding(
                              padding: const EdgeInsets.only(
                              ),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      // horizontal: screenWidth*0.03,
                                      // vertical: screenHeight*0.012
                                  ),

                                  decoration: const BoxDecoration(
                                    // color: Color(0xff11181f),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(12)
                                    ),
                                  ),
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [

                                      // Spacer
                                      // const SizedBox(width: 5,),

                                      // Icon distance
                                      Container(
                                        padding: const EdgeInsets.all(
                                            4
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(45)
                                          ),
                                        ),
                                        child:  Icon(
                                          Icons.location_on_outlined,
                                          color: customStyleClass.primeColor,
                                          size: screenWidth*iconWidthFactor,
                                        ),
                                      ),

                                      // Spacer
                                      // const SizedBox(width: 7,),

                                      // Text distance
                                      Container(
                                        padding: const EdgeInsets.all(
                                            4
                                        ),
                                        child: Text(
                                          calculateDistanceToClub().toStringAsFixed(2),
                                          style: customStyleClass.getFontStyle5BoldGrey(),
                                        ),
                                      ),

                                      // Spacer
                                      const SizedBox(width: 2,),

                                      // Container(
                                      //   padding: const EdgeInsets.all(
                                      //       4
                                      //   ),
                                      //   decoration: const BoxDecoration(
                                      //     color: Colors.black,
                                      //     borderRadius: BorderRadius.all(
                                      //         Radius.circular(45)
                                      //     ),
                                      //   ),
                                      //   child: Icon(
                                      //       Icons.groups,
                                      //       color: customStyleClass.primeColor,
                                      //       size: customStyleClass.getFontSize4()
                                      //   ),
                                      // ),
                                      //
                                      // Container(
                                      //   padding: const EdgeInsets.symmetric(
                                      //       horizontal: 5
                                      //   ),
                                      //   child: Text(
                                      //     getRandomNumber(),
                                      //     style: customStyleClass.getFontStyle5Bold(),
                                      //   ),
                                      // ),

                                      // Spacer
                                      const SizedBox(width: 2,),

                                      // Icon genre
                                      Container(
                                        padding: const EdgeInsets.all(
                                            4
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(45)
                                          ),
                                        ),
                                        child:  Icon(
                                          Icons.library_music_outlined,
                                          color: customStyleClass.primeColor,
                                          size: screenWidth*iconWidthFactor,
                                        ),
                                      ),

                                      // Text Genre
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 5
                                        ),
                                        child: Text(
                                          getAndFormatMusicGenre(),
                                          style: customStyleClass.getFontStyle5BoldGrey(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),


                    ],
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

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    noEventAvailable = widget.noEventAvailable;
    showBottomSheet = widget.showBottomSheet;
    if(widget.clubMeEvent != null){
      clubMeEvent = widget.clubMeEvent;
    }

    userDataProvider = Provider.of<UserDataProvider>(context);
    stateProvider = Provider.of<StateProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    customStyleClass = CustomStyleClass(context: context);

    return Container(
        padding: EdgeInsets.only(
            bottom: screenHeight*0.06
        ),
        child: _buildStackView(context)
    );
  }
}
