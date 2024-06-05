import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/club.dart';
import '../../models/event.dart';
import '../../provider/state_provider.dart';
import '../../services/hive_service.dart';
import '../../shared/custom_text_style.dart';
import 'event_card.dart';
import 'dart:math';

class ClubCard extends StatelessWidget {

  ClubCard({
    Key? key,
    required this.events,
    required this.clubMeClub,
    required this.triggerSetState,
    required this.clickedOnShare
  }) : super(key: key);

  List<ClubMeEvent> events;
  ClubMeClub clubMeClub;

  late CustomTextStyle customTextStyle;
  late StateProvider stateProvider;

  Function () triggerSetState;
  Function () clickedOnShare;

  bool tempLiked = false;

  List<String> noEventsPlanned = ["Derzeit kein Event geplant!"];

  final HiveService _hiveService = HiveService();

  void likeIconClicked(StateProvider stateProvider, String clubId){
    if(stateProvider.checkIfClubIsAlreadyLiked(clubId)){
      stateProvider.deleteLikedClub(clubId);
      _hiveService.deleteFavoriteClub(clubId);
    }else{
      stateProvider.addLikedClub(clubId);
      _hiveService.insertFavoriteClub(clubId);
    }
  }

  String getAndFormatMusicGenre() {
    if (clubMeClub.getMusicGenres().contains(",")) {
      var index = clubMeClub.getMusicGenres().indexOf(",");
      return clubMeClub.getMusicGenres().substring(0, index);
    } else {
      return clubMeClub.getMusicGenres();
    }
  }

  double calculateDistanceToClub(){

    if(stateProvider.getUserLatCoord() != 0){

      var distance = Geolocator.distanceBetween(
          stateProvider.getUserLatCoord(),
          stateProvider.getUserLongCoord(),
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

  String getRandomNumber(){

    final _random = new Random();
    int next(int min, int max) => min + _random.nextInt(max - min);

    return next(20, 50).toString();

  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    return Container(

        width: screenWidth*0.95,
        height: screenHeight*0.752,

        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
                width: 1, color: Colors.white60
            ),
            right: BorderSide(
                width: 1, color: Colors.white60
            ),
            bottom: BorderSide(
                width: 1, color: Colors.white60
            ),
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),

        child: Column(
          children: [

            // Image part
            GestureDetector(
              child: SizedBox(
                height: screenHeight*0.2,
                child: Stack(
                  children: [

                    Container(
                      // Image background
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.grey[700]!,
                              Colors.grey[850]!
                            ],
                            stops: const [0.3, 0.8]
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
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                topLeft: Radius.circular(12)
                            ),
                            child: Image.asset(
                              "assets/images/${clubMeClub.getBannerId()}",
                              fit: BoxFit.cover,
                            ),
                          )
                      ),

                    )
                  ],
                ),
              ),
              onTap: (){
                stateProvider.setCurrentClub(clubMeClub);
                context.push("/club_details");
              },
            ),

            // Content
            Container(
              height: screenHeight*0.55,
              width: screenWidth*0.95,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
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
              child: Column(
                children: [

                  // Spacer
                  SizedBox(
                    height: screenHeight*0.01,
                  ),

                  // Header: name, icons
                  SizedBox(
                    height: screenHeight*0.08,
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
                                    style: customTextStyle.size1Bold(),
                                  ),
                                )
                            ),
                          ),
                          onTap: (){
                            stateProvider.setCurrentClub(clubMeClub);
                            context.push("/club_details");
                          },
                        ),

                        // Icon row
                        SizedBox(
                          height: screenHeight*0.08,
                          child: Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Icons
                                  Row(
                                    children: [

                                      GestureDetector(
                                          child:Column(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: stateProvider.getPrimeColor(),
                                                size: screenHeight*stateProvider.getIconSizeFactor(),
                                              ),
                                              Text(
                                                "Info",
                                                style: customTextStyle.size5(),
                                              ),
                                            ],
                                          ),
                                          onTap: (){
                                            stateProvider.setCurrentClub(clubMeClub);
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
                                                stateProvider.checkIfSpecificCLubIsAlreadyLiked(clubMeClub.getClubId()) ? Icons.star_outlined : Icons.star_border,
                                                color: stateProvider.getPrimeColor(),
                                                size: screenHeight*stateProvider.getIconSizeFactor(),
                                              ),
                                              Text(
                                                "Like",
                                                style: customTextStyle.size5(),
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
                                                color: stateProvider.getPrimeColor(),
                                                size: screenHeight*stateProvider.getIconSizeFactor(),
                                              ),
                                              Text(
                                                "Share",
                                                style:customTextStyle.size5(),
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
                    indent: 20,
                    endIndent: 20,
                  ),

                  // Middle part: next two events
                  SizedBox(
                      height: screenHeight*0.33,
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
                                  clubMeEvent: events[0]
                              ),
                              onTap: (){
                                stateProvider.setCurrentEvent(events[0]);
                                context.push('/event_details');
                              },
                            ):SizedBox(
                              height: screenHeight*0.3,
                              child: Center(
                                child: Text(noEventsPlanned[0]),
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
                                  clubMeEvent: events[1]
                              ),
                              onTap: (){
                                stateProvider.setCurrentEvent(events[1]);
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
                    indent: 20,
                    endIndent: 20,
                  ),

                  // Bottom part
                  SizedBox(
                    height: screenHeight*0.1,
                    width: screenWidth*0.85,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // Distance to club
                        calculateDistanceToClub() == 0 ?
                        const CircularProgressIndicator():
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight*0.01,
                              horizontal: screenWidth*0.03
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xff11181f),
                            borderRadius: BorderRadius.all(
                                Radius.circular(12)
                            ),
                          ),
                          child: Row(
                            children: [

                              // Genres icon
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
                                    Icons.location_on_outlined,
                                    color: stateProvider.getPrimeColor(),
                                    size: screenHeight*stateProvider.getIconSizeFactor2()
                                ),
                              ),

                              // Spacer
                              SizedBox(
                                width: screenWidth*0.01,
                              ),

                              Text(
                                calculateDistanceToClub().toStringAsFixed(2),
                                style: customTextStyle.size5(),
                              ),

                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight*0.01,
                              horizontal: screenWidth*0.03
                          ),

                          decoration: const BoxDecoration(
                            color: Color(0xff11181f),
                            borderRadius: BorderRadius.all(
                                Radius.circular(12)
                            ),
                          ),
                          child: Row(
                            children: [
                              // Genres icon
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
                              SizedBox(
                                width: screenWidth*0.01,
                              ),

                              Text(
                                getRandomNumber(),
                                style: customTextStyle.size5(),
                              ),

                            ],
                          ),
                        ),

                        // Music Genre
                        Align(
                          child: Container(
                            // width: screenWidth*0.5,
                            // height: screenHeight*0.05,
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight*0.01,
                                horizontal: screenWidth*0.03
                            ),

                            decoration: const BoxDecoration(
                              color: Color(0xff11181f),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(12)
                              ),
                            ),
                            child: Row(
                              children: [
                                // Genres icon
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
                                      Icons.library_music_outlined,
                                      color: stateProvider.getPrimeColor(),
                                      size: screenHeight*stateProvider.getIconSizeFactor2()
                                  ),
                                ),

                                // Spacer
                                SizedBox(
                                  width: screenWidth*0.01,
                                ),

                                Text(
                                  getAndFormatMusicGenre(),
                                  style: customTextStyle.size5(),
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
        )
    );
  }
}