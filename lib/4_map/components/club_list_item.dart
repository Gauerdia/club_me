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


  // FORMAT
  String getAndFormatMusicGenre() {

    String genreToReturn = "";

    if (currentClub.getMusicGenres().contains(",")) {
      var index = currentClub.getMusicGenres().indexOf(",");
      genreToReturn = currentClub.getMusicGenres().substring(0, index);
    } else {
      genreToReturn = currentClub.getMusicGenres();
    }

    if(genreToReturn.length>6){
      genreToReturn = "${genreToReturn.substring(0, 5)}...";
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

  // BUILD


  Widget _buildStackView2(BuildContext context){
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
                            Stack(
                              children: [

                                // rounded image
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      opacity: 0.5,
                                      image:
                                      FileImage(
                                          File(
                                              "${stateProvider.appDocumentsDir.path}/${currentClub.getBannerId()}"
                                          )
                                      ),
                                    ),
                                  ),
                                ),

                                // arrow
                                Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(45)
                                        ),
                                        border: Border.all(
                                            color: Colors.white
                                        )
                                    ),
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: customStyleClass.getIconSize1(),
                                      color: customStyleClass.primeColor,
                                    ),
                                  ),
                                )
                              ],
                            ):
                                // rounded image
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                      File(
                                          "${stateProvider.appDocumentsDir.path}/${currentClub.getBannerId()}"
                                      )
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        onTap: (){
                          if(currentClub.getStoryId().isNotEmpty){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ShowStoryChewie(storyUUID: currentClub.getStoryId(), clubName: currentClub.getClubName(),),
                              ),
                            );
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
                        style: customStyleClass.getFontStyle1(),
                      ),
                    ),

                    // ICONS
                    SizedBox(
                      width: screenWidth*0.7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [


                          // Distance
                          Padding(
                            padding: EdgeInsets.only(right: 10),
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
                                    calculateDistanceToClub().toStringAsFixed(2),
                                    style: customStyleClass.getFontStyle5(),
                                  ),
                                )
                              ],
                            ),
                          ),

                          // Genre
                          Row(
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
                          )
                        ],
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

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return _buildStackView2(context);
  }
}