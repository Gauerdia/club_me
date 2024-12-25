import 'dart:io';
import 'package:club_me/provider/current_and_liked_elements_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../shared/custom_text_style.dart';


class AdTile extends StatelessWidget {

  File? bannerToDisplay;


  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;


  String eventDjCut = "";
  String eventTitleCut = "";
  String priceFormatted = "";
  String weekDayToDisplay = "";

  double topHeight = 140;
  double bottomHeight = 100;

  bool closedToday = true;
  bool alreadyOpen = false;
  bool lessThanThreeMoreHoursOpen = false;
  int todaysOpeningHour = 0;
  int todaysClosingHour = 0;


  bool specialOccasionActive = true;


  // BUILD
  Widget _buildMainView(BuildContext context){
    return Stack(
      children: [

        // Main Tile
        Padding(
          padding: const EdgeInsets.only(
              top: 2
          ),
          child: Center(
            child: Container(
                padding: const EdgeInsets.only(
                    left:2,
                    right: 2,
                    top: 2
                ),
                width: screenWidth*0.9,
                decoration: BoxDecoration(
                    color: customStyleClass.backgroundColorEventTile,
                    borderRadius: BorderRadius.circular(
                        15
                    )
                ),
                child: Column(
                  children: [

                    // Image container
                    Container(
                        height: topHeight,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(
                            color: customStyleClass.backgroundColorEventTile,
                            // width: 5
                          ),
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15)
                          ),
                        ),
                        child: Stack(
                          children: [


                            Container(
                              // color: Colors.black,
                                height: topHeight,
                                width: screenWidth,
                                // width: screenWidth*0.9,
                                alignment: Alignment.center,
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        // topRight: Radius.circular(15),
                                        // topLeft: Radius.circular(15)
                                    ),
                                    child: SizedBox(
                                      width: screenWidth*0.5,
                                      child: Image.asset(
                                        "assets/images/runes_logo_1.png",
                                        scale: 0.5,
                                      ),
                                    ),
                                ))

                          ],
                        )
                    ),

                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(12),
                              bottomLeft: Radius.circular(12)
                          ),
                          color: customStyleClass.backgroundColorEventTile
                      ),
                      child: Column(
                        children: [


                          Container(
                            width: screenWidth*0.85,
                            padding: const EdgeInsets.only(
                                top: 24,
                                bottom: 24,
                              left:20,
                              right:20
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "AB SOFORT ERHÄLTLICH! ",
                                      style: customStyleClass.getFontStyle5RedBold()
                                    ),
                                    TextSpan(
                                        text: "DER WELTWEIT ERSTE VEGAN & BIO ZERTIFIZIERTE VODKA",
                                      style: customStyleClass.getFontStyle5Bold()
                                    )
                                  ]
                              )
                            )
                          ),


                        ],
                      ),
                    )

                  ],
                )

            ),
          ),
        )

      ],
    );
  }



  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    customStyleClass = CustomStyleClass(context: context);

    return Container(
        padding: EdgeInsets.only(
          bottom: screenHeight*0.02,
          // top: screenHeight*0.01
        ),
        child: Center(child: _buildMainView(context))
    );
  }
}
