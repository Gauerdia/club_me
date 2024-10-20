import 'dart:io';
import 'dart:math';

import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../3_clubs/user_view/components/event_card.dart';
import '../../models/club_open_status.dart';
import '../../models/event.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../shared/custom_text_style.dart';

class ClubInfoBottomSheet extends StatefulWidget {
  ClubInfoBottomSheet({
    Key? key,
    required this.showBottomSheet,
    this.clubMeEvent,
    required this.noEventAvailable
  });

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
  late ClubOpenStatus clubOpenStatus;
  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;


  double iconWidthFactor = 0.05;
  double imageHeightFactor = 0.09;
  double headlineHeightFactor = 0.09;

  double topHeight = 145;
  double bottomHeight = 180;

  final HiveService _hiveService = HiveService();

  // BUILD
  Widget _buildStackView(BuildContext context){

    return Stack(
      children: [

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
                      colors: [Colors.grey[900]!, Colors.grey[900]!],
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
                color: customStyleClass.backgroundColorEventTile,
                border: Border.all(
                    color: Colors.grey[900]!
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
                    currentAndLikedElementsProvider.currentClubMeClub.getBigLogoFileName()
                )?
                Container(

                    height: topHeight,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: customStyleClass.backgroundColorMain,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15)
                      ),
                    ),
                    child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15)
                        ),
                        child: Image(
                          image: FileImage(
                              File(
                                  "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getBigLogoFileName()}"
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
                      top: 5,
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
            )
        ),

        // Content container
        SizedBox(
          height: bottomHeight-2,
          child: Column(
            children: [

              // Event Card
              Container(
                height: screenHeight*0.16,
                // color: Colors.green,
                padding: const EdgeInsets.only(
                    top: 15
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
                    backgroundColorIndex: 0,
                  ),
                  onTap: (){
                    currentAndLikedElementsProvider.setCurrentEvent(clubMeEvent!);
                    stateProvider.setAccessedEventDetailFrom(3);
                    context.push("/event_details");
                  },
                ),
              ),

              // BottomSheet
              Container(
                // height: screenHeight*0.01,
                width: screenWidth*0.9,
                padding: const EdgeInsets.only(
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Info, Like, Share
                    Container(

                      decoration: const BoxDecoration(
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
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.info_outline,
                                      color: customStyleClass.primeColor,
                                    ),
                                    onTap: () => clickEventInfo(),
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
                                child: GestureDetector(
                                  child: Icon(
                                    currentAndLikedElementsProvider.checkIfSpecificCLubIsAlreadyLiked(currentAndLikedElementsProvider.currentClubMeClub.getClubId())
                                        ? Icons.star_outlined
                                        : Icons.star_border,
                                    color: customStyleClass.primeColor,
                                  ),
                                  onTap: () => clickEventLike(),
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
                                child: GestureDetector(
                                  child: Icon(
                                    Icons.share,
                                    color: customStyleClass.primeColor,
                                    size: screenWidth*iconWidthFactor,
                                  ),
                                  onTap: () => clickEventShare(),
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
                          right: 50
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: const BoxDecoration(
                            // color: Color(0xff11181f),
                            borderRadius: BorderRadius.all(
                                Radius.circular(12)
                            ),
                          ),
                          child: Row(
                            children: [

                              // Icon distance
                              Container(
                                padding: const EdgeInsets.all(4),
                                child:  Icon(
                                  Icons.location_on_outlined,
                                  color: customStyleClass.primeColor,
                                ),
                              ),

                              // Text distance
                              Container(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  "${calculateDistanceToClub().toStringAsFixed(2)} km",
                                  style: customStyleClass.getFontStyle6BoldGrey(),
                                ),
                              ),

                              // Spacer
                              const SizedBox(width: 2,),

                              // Icon genre
                              Container(
                                padding: const EdgeInsets.all(4),
                                child:  Icon(
                                  Icons.library_music_outlined,
                                  color: customStyleClass.primeColor,
                                ),
                              ),

                              // Text Genre
                              Container(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  getAndFormatMusicGenre(),
                                  style: customStyleClass.getFontStyle6BoldGrey(),
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
        )
      ],
    );
  }


  // CLICK
  void clickEventInfo(){
    /// TODO: Make something with the click
    print("Info");
  }
  void clickEventShare(){
    showDialog(context: context, builder: (BuildContext context){
      return TitleAndContentDialog(
          titleToDisplay: "Club Teilen",
          contentToDisplay: "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!");
    });
  }
  void clickEventLike(){
    if(currentAndLikedElementsProvider.checkIfClubIsAlreadyLiked(currentAndLikedElementsProvider.currentClubMeClub.getClubId())){
      currentAndLikedElementsProvider.deleteLikedClub(currentAndLikedElementsProvider.currentClubMeClub.getClubId());
      _hiveService.deleteFavoriteClub(currentAndLikedElementsProvider.currentClubMeClub.getClubId());
    }else{
      currentAndLikedElementsProvider.addLikedClub(currentAndLikedElementsProvider.currentClubMeClub.getClubId());
      _hiveService.insertFavoriteClub(currentAndLikedElementsProvider.currentClubMeClub.getClubId());
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

    // if(genreToReturn.length>8){
    //   genreToReturn = "${genreToReturn.substring(0, 7)}...";
    // }
    return genreToReturn;

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

    clubOpenStatus = currentAndLikedElementsProvider.currentClubMeClub.getClubOpenStatus();

    return Container(
        padding: EdgeInsets.only(
            bottom: screenHeight*0.06
        ),
        child: _buildStackView(context)
    );
  }
}
