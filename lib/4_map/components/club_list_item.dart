import 'dart:io';
import 'dart:math';

import 'package:club_me/provider/state_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/club.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../shared/custom_text_style.dart';
import '../../shared/map_utils.dart';
import '../../stories/show_story_chewie.dart';

class ClubListItem extends StatelessWidget {
  ClubListItem({
    Key? key,
    required this.currentClub
  }) : super(key: key);

  ClubMeClub currentClub;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenWidth, screenHeight;

  double topHeight = 55;
  double bottomHeight = 55;


  // BUILD
  Widget _buildStackView(BuildContext context){
    return Column(

      children: [

        // Main content
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            // Left box for logo
            SizedBox(
              width: screenWidth*0.17,
              height: screenHeight*0.07,
              child: Container(
                child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                        child: Container(
                          width: screenWidth*0.155,
                          height: screenHeight*0.1,
                          decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                    color: currentClub.getStoryId().isNotEmpty ?
                                    customStyleClass.primeColor: Colors.grey,
                                    width: 2
                                ),
                                right: BorderSide(
                                    color: currentClub.getStoryId().isNotEmpty ?
                                    customStyleClass.primeColor: Colors.grey,
                                    width: 2
                                ),
                                top: BorderSide(
                                    color: currentClub.getStoryId().isNotEmpty ?
                                    customStyleClass.primeColor: Colors.grey,
                                    width: 2
                                ),
                                bottom: BorderSide(
                                    color: currentClub.getStoryId().isNotEmpty ?
                                    customStyleClass.primeColor: Colors.grey,
                                    width: 2
                                ),
                              ),
                              borderRadius: const BorderRadius.all(Radius.circular(45))
                          ),
                          child: CircleAvatar(
                            // radius: 45,
                            backgroundColor: Colors.black,
                            child: currentClub.getStoryId().isNotEmpty?
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image:
                                  FileImage(
                                      File(
                                          "${stateProvider.appDocumentsDir.path}/${currentClub.getSmallLogoFileName()}"
                                      )
                                  ),
                                ),
                              ),
                            ):
                            // rounded image
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                      File(
                                          "${stateProvider.appDocumentsDir.path}/${currentClub.getSmallLogoFileName()}"
                                      )
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        onTap: (){
                          if(currentClub.getStoryId().isNotEmpty){
                            currentAndLikedElementsProvider.setCurrentClub(currentClub);
                            context.push("/show_story");
                          }
                        }
                    )
                ),
              ),
            ),

            // text, distance, music
            InkWell(
              child: SizedBox(
                width: screenWidth*0.7,
                height: screenHeight*0.07,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // TITLE
                    SizedBox(
                      width: screenWidth*0.7,
                      child: Text(
                        currentClub.getClubName(),
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle1Bold(),
                      ),
                    ),

                    // ICONS
                    Container(
                      // color: Colors.red,
                      alignment: Alignment.centerLeft,
                      width: screenWidth*0.9,
                      child: SizedBox(
                        width: screenWidth*0.6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [


                            // Distance
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: customStyleClass.primeColor,
                                    size: customStyleClass.getIconSize2(),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5
                                    ),
                                    child: Text(
                                      "${calculateDistanceToClub().toStringAsFixed(2)} km",
                                      style: customStyleClass.getFontStyle5(),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            // Genre
                            Padding(
                              padding:  const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.library_music_outlined,
                                    color: customStyleClass.primeColor,
                                    size: customStyleClass.getIconSize2(),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5
                                    ),
                                    child: Text(
                                      getAndFormatMusicGenre(),
                                      style:customStyleClass.getFontStyle5(),
                                    ),
                                  )
                                ],
                              ),),

                            InkWell(
                              child: SizedBox(
                                width: screenWidth*0.06,
                                height: screenWidth*0.06,
                                child: Image.asset(
                                  'assets/images/google_maps_3.png',
                                ),
                              ),
                              onTap: ()=> MapUtils.openMap(
                                  currentClub.getGeoCoordLat(),
                                  currentClub.getGeoCoordLng()),
                            )
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              onTap: (){
                currentAndLikedElementsProvider.setCurrentClub(currentClub);
                stateProvider.setAccessedEventDetailFrom(3);
                context.push("/club_details");
              },
            )
          ],
        ),

        // Line
        Divider(
          color: Colors.grey[900],
        )

      ],

    );
  }


  // FORMAT
  String getAndFormatMusicGenre() {

    String genreToReturn = "";

    if (currentClub.getMusicGenres().contains(",")) {
      var index = currentClub.getMusicGenres().indexOf(",");
      genreToReturn = currentClub.getMusicGenres().substring(0, index);
    } else {
      genreToReturn = currentClub.getMusicGenres();
    }

    return genreToReturn;

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
          currentClub.getGeoCoordLat(),
          currentClub.getGeoCoordLng()
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


  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return _buildStackView(context);
  }
}