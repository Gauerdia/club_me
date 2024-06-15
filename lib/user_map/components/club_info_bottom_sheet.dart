import 'dart:math';
import '../../models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/hive_service.dart';
import '../../provider/state_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../shared/custom_text_style.dart';
import '../../user_clubs/components/event_card.dart';

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
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;

  double iconWidthFactor = 0.05;
  double imageHeightFactor = 0.09;
  double headlineHeightFactor = 0.09;

  final HiveService _hiveService = HiveService();

  // CLICK
  void clickOnInfo(){
    /// TODO: Make something with the click
    print("Info");
  }
  void clickOnLike(){
    likeIconClicked(stateProvider.clubMeClub.getClubId());
  }
  void clickOnShare(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Teilen"),
        content: Text(
          "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!",
          textAlign: TextAlign.left,
          style: customTextStyle.size4(),
        ),
      );
    });
  }
  void likeIconClicked(String clubId){
    if(stateProvider.checkIfClubIsAlreadyLiked(clubId)){
      stateProvider.deleteLikedClub(clubId);
      _hiveService.deleteFavoriteClub(clubId);
    }else{
      stateProvider.addLikedClub(clubId);
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

    if(stateProvider.getUserLatCoord() != 0){

      var distance = Geolocator.distanceBetween(
          stateProvider.getUserLatCoord(),
          stateProvider.getUserLongCoord(),
          stateProvider.clubMeClub.getGeoCoordLat(),
          stateProvider.clubMeClub.getGeoCoordLng()
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

    if (stateProvider.clubMeClub.getMusicGenres().contains(",")) {
      var index = stateProvider.clubMeClub.getMusicGenres().indexOf(",");
      genreToReturn = stateProvider.clubMeClub.getMusicGenres().substring(0, index);
    } else {
      genreToReturn = stateProvider.clubMeClub.getMusicGenres();
    }

    if(genreToReturn.length>8){
      genreToReturn = "${genreToReturn.substring(0, 7)}...";
    }
    return genreToReturn;

  }

  @override
  Widget build(BuildContext context) {

    noEventAvailable = widget.noEventAvailable;
    showBottomSheet = widget.showBottomSheet;
    if(widget.clubMeEvent != null){
     clubMeEvent = widget.clubMeEvent;
    }

    stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


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
                      gradient: LinearGradient(
                          colors: [
                            Colors.black,
                            Colors.black
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.2, 0.95]
                      ),
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25)
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight*0.02,
                          left: screenWidth*0.03
                      ),
                      child: Text(
                        stateProvider.clubMeClub.getClubName(),
                        style: customTextStyle.size1MapHeadline(),
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
                child: const Center(
                  child: Text(
                      "Derzeit kein Event geplant!"
                  ),
                ),
              ):GestureDetector(
                child: EventCard(clubMeEvent: clubMeEvent!),
                onTap: (){
                  stateProvider.setCurrentEvent(clubMeEvent!);
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
                    width: screenWidth*0.35,
                    height: screenHeight*0.055,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth*0.03,
                        // vertical: screenHeight*0.01
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
                                padding: const EdgeInsets.all(
                                    4
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
                                    color: stateProvider.getPrimeColor(),
                                    size: screenWidth*iconWidthFactor,
                                  ),
                                  onTap: () => clickOnInfo(),
                                )
                            ),

                            // Spacer
                            const SizedBox(width: 15,),

                            // star
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
                              child: GestureDetector(
                                child: Icon(
                                    stateProvider.checkIfSpecificCLubIsAlreadyLiked(stateProvider.clubMeClub.getClubId())
                                        ? Icons.star_outlined
                                        : Icons.star_border,
                                  color: stateProvider.getPrimeColor(),
                                  size: screenWidth*iconWidthFactor,
                                ),
                                onTap: () => clickOnLike(),
                              ),
                            ),

                            // Spacer
                            const SizedBox(width: 15,),

                            // share
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
                              child: GestureDetector(
                                child: Icon(
                                  Icons.share,
                                  color: stateProvider.getPrimeColor(),
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
                          children: [

                            // Spacer
                            const SizedBox(width: 5,),

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
                                color: stateProvider.getPrimeColor(),
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),

                            // Spacer
                            const SizedBox(width: 7,),

                            // Text distance
                            Text(
                              calculateDistanceToClub().toStringAsFixed(2),
                              style: customTextStyle.size5BoldGrey(),
                            ),

                            // Spacer
                            const SizedBox(width: 7,),

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
                                  color: stateProvider.getPrimeColor(),
                                  size: screenHeight*stateProvider.getIconSizeFactor2()
                              ),
                            ),

                            // Spacer
                            const SizedBox(width: 7,),

                            Text(
                              getRandomNumber(),
                              style: customTextStyle.size5(),
                            ),

                            // Spacer
                            const SizedBox(width: 7,),

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
                                color: stateProvider.getPrimeColor(),
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),

                            // Spacer
                            const SizedBox(width: 7,),

                            // Text Genre
                            Text(
                              getAndFormatMusicGenre(),
                              style: customTextStyle.size5BoldGrey(),
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