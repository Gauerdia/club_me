import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../provider/state_provider.dart';
import '../../user_clubs/user_clubs_view.dart';

class ClubInfoBottomSheet extends StatelessWidget {

  ClubInfoBottomSheet({
    Key? key,
    required this.showBottomSheet,
    required this.clubMeEvent
  }) : super(key: key);

  late bool showBottomSheet;
  late ClubMeEvent clubMeEvent;

  double imageHeightFactor = 0.09;
  double headlineHeightFactor = 0.09;
  double iconWidthFactor = 0.05;

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    return AnimatedOpacity(
      opacity: showBottomSheet ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 2500),
      child: AnimatedContainer(
        // alignment: Alignment.bottomCenter,
        width: screenWidth,
        height: screenHeight*0.35,
        decoration: BoxDecoration(

            gradient: RadialGradient(
                colors: [
                  Colors.grey[600]!,
                  Colors.grey[850]!
                ],
                stops: [0.1, 0.35],
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
            Stack(
              children: [

                // image
                Container(
                  height: screenHeight*imageHeightFactor,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            stateProvider.clubMeClub.getImagePath()
                          // clubMeEvent.getImagePath()
                        ),
                        fit: BoxFit.cover
                    ),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)
                    ),
                  ),
                ),

                // club name
                Container(
                  height: screenHeight*headlineHeightFactor,
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Colors.transparent
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.4, 0.6]
                    ),
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight*0.015,
                        left: screenWidth*0.03
                    ),
                    child: Text(
                      stateProvider.clubMeClub.getClubName(),
                      // clubMeEvent.getClubName(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        shadows: <Shadow>[
                          Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 5.0,
                              color: Colors.grey
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),

            // Spacer
            SizedBox(height: screenHeight*0.01,),

            // Event Card
            GestureDetector(
              child: EventCard(clubMeEvent: clubMeEvent),
              onTap: (){
                stateProvider.setCurrentEvent(clubMeEvent);
                context.go("/event_details");
              },
            ),

            // Spacer
            SizedBox(height: screenHeight*0.01,),

            // BottomSheet
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.05
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // Info, Like, Share
                  Container(
                    width: screenWidth*0.35,
                    height: screenHeight*0.055,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth*0.03,
                      vertical: screenHeight*0.005
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
                                Icons.info_outline,
                                color: Colors.purpleAccent,
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),


                            SizedBox(width: 15,),

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
                                Icons.star_border,
                                color: Colors.purpleAccent,
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),

                            SizedBox(width: 15,),

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
                                Icons.share,
                                color: Colors.purpleAccent,
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Spacer
                  SizedBox(
                    width: screenWidth*0.01,
                  ),

                  // Icon Row
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: screenWidth*0.55,
                        height: screenHeight*0.055,
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth*0.02,
                            vertical: screenHeight*0.005
                        ),

                        decoration: const BoxDecoration(
                          color: Color(0xff11181f),
                          borderRadius: BorderRadius.all(
                              Radius.circular(12)
                          ),
                        ),
                        child: Row(
                          children: [

                            SizedBox(width: 5,),

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
                                Icons.route,
                                color: Colors.purpleAccent,
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),

                            SizedBox(width: 5,),

                            const Text(
                              "1.2",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),

                            const SizedBox(width: 5,),

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
                                color: Colors.purpleAccent,
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),

                            SizedBox(width: 5,),

                            const Text(
                              "Techno",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),

                            SizedBox(width: 5,),

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
                                Icons.people_alt_outlined,
                                color: Colors.purpleAccent,
                                size: screenWidth*iconWidthFactor,
                              ),
                            ),

                            SizedBox(width: 5,),

                            const Text(
                              "64",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
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