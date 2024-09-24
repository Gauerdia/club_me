import 'dart:math';
import '../../3_clubs/user_view/components/event_card.dart';
import '../../models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../provider/state_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../shared/custom_text_style.dart';

class ClubInfoBottomSheet extends StatefulWidget {
  ClubInfoBottomSheet({
    Key? key,
    required this.showBottomSheet,
    this.clubMeEvent,
    required this.noEventAvailable
  }) : super(key: key);

  late bool showBottomSheet;
  late bool noEventAvailable;
  late ClubMeEvent? clubMeEvent;


  @override
  State<ClubInfoBottomSheet> createState() => _ClubInfoBottomSheetState();
}

class _ClubInfoBottomSheetState extends State<ClubInfoBottomSheet> {

  late bool showBottomSheet;
  late bool noEventAvailable;
  late ClubMeEvent? clubMeEvent;
  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;

  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  double iconWidthFactor = 0.05;
  double imageHeightFactor = 0.09;
  double headlineHeightFactor = 0.09;

  bool closedToday = true;
  bool alreadyOpen = false;
  bool lessThanThreeMoreHoursOpen = false;
  int todaysOpeningHour = 0;
  int todaysClosingHour = 0;

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


  @override
  Widget build(BuildContext context) {

    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    noEventAvailable = widget.noEventAvailable;
    showBottomSheet = widget.showBottomSheet;
    if(widget.clubMeEvent != null){
     clubMeEvent = widget.clubMeEvent;
    }

    userDataProvider = Provider.of<UserDataProvider>(context);
    stateProvider = Provider.of<StateProvider>(context);

    customStyleClass = CustomStyleClass(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    checkIfClosed();


    return AnimatedOpacity(
      opacity: showBottomSheet ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 2500),
      child: AnimatedContainer(
        width: screenWidth,
        height: screenHeight*0.4,
        decoration: BoxDecoration(

            gradient: RadialGradient(
                colors: [
                  Colors.grey[600]!,
                  Colors.grey[850]!
                ],
                stops: const [0.1, 0.35],
                center: Alignment.topLeft,
                radius: 3
            ),

            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25)
            )
        ),
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
        child: Column(
          children: [

            // Header
            Container(
              height: screenHeight*imageHeightFactor,
              child: Stack(
                children: [

                  // club name
                  Container(
                    height: screenHeight*headlineHeightFactor,
                    width: screenWidth,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25)
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight*0.025,
                          left: screenWidth*0.03
                      ),
                      child: Text(
                        currentAndLikedElementsProvider.currentClubMeClub.getClubName(),
                        style: customStyleClass.getFontStyleHeadline1Bold(),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
              ),
            ),

            // Spacer
            SizedBox(height: screenHeight*0.01,),

            // Event Card
            SizedBox(
              height: screenHeight*0.17,
              child: noEventAvailable ?
              SizedBox(
                height: screenHeight*0.17,
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
                  backgroundColorIndex: 0,
                ),
                onTap: (){
                  currentAndLikedElementsProvider.setCurrentEvent(clubMeEvent!);
                  context.push("/event_details");
                },
              ),
            ),

            // Spacer
            SizedBox(height: screenHeight*0.01,),

            // BottomSheet
            Padding(
              padding: const EdgeInsets.only(
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // Info, Like, Share
                  Container(
                    // width: screenWidth*0.32,
                    // height: screenHeight*0.055,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth*0.03,
                        vertical: screenHeight*0.012
                    ),

                    decoration: const BoxDecoration(
                      color: Color(0xff11181f),
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
                                    horizontal: 2,
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
                                  horizontal: 2,
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
                                  horizontal: 2,
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
                            horizontal: screenWidth*0.03,
                            vertical: screenHeight*0.012
                        ),

                        decoration: const BoxDecoration(
                          color: Color(0xff11181f),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5
                              ),
                              child: Text(
                                calculateDistanceToClub().toStringAsFixed(2),
                                style: customStyleClass.getFontStyle5BoldGrey(),
                              ),
                            ),

                            // Spacer
                            const SizedBox(width: 2,),

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
                              child: Icon(
                                  Icons.groups,
                                  color: customStyleClass.primeColor,
                                  size:
                                  customStyleClass.getFontSize4()
                                //screenHeight*stateProvider.getIconSizeFactor2()

                              ),
                            ),

                            // Spacer
                            // const SizedBox(width: 2,),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5
                              ),
                              child: Text(
                                getRandomNumber(),
                                style: customStyleClass.getFontStyle5Bold(),
                              ),
                            ),

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
            )
          ],
        ),
      ),
    );
  }
}