import 'dart:io';
import 'package:club_me/models/discount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../provider/state_provider.dart';
import '../../../shared/custom_text_style.dart';

class DiscountTile2 extends StatelessWidget {
  DiscountTile2({
    super.key,
    required this.clubMeDiscount,
  });

  double topHeight = 170;
  double bottomHeight = 170;

  ClubMeDiscount clubMeDiscount;

  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late String formattedWeekday, formattedEventTitle;




  // BUILD
  Widget _buildStackView(BuildContext context){

    return Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight*0.01
        ),
      child: Center(
        child: Stack(
          children: [

            // Colorful accent
            Container(
              width: screenWidth*0.91,
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
              width: screenWidth*0.91,
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
              width: screenWidth*0.89,
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
                  width: screenWidth*0.9,
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
                width: screenWidth*0.9,
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
        ),
      ),
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

                SizedBox(
                  height: topHeight,
                  width: screenWidth,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)
                    ),
                    child:
                    Image(
                      image: FileImage(
                          File(
                              "${stateProvider.appDocumentsDir.path}/${clubMeDiscount.getBannerId()}"
                          )
                      ),
                      fit: BoxFit.cover,
                    )

                    // Image.asset(
                    //   "assets/images/${clubMeDiscount.getBannerId()}",
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
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

                      // Title + Price
                      Row(
                        children: [
                          // Title
                          Padding(
                            padding: EdgeInsets.only(
                              top: screenHeight*0.01,
                            ),
                            child: SizedBox(
                              width: screenWidth*0.7,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: screenWidth*0.02
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    formattedEventTitle,
                                    style: customStyleClass.getFontStyle1Bold(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Location
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth*0.02
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              clubMeDiscount.getClubName(),
                              style:customStyleClass.getFontStyle3Bold()
                          ),
                        ),
                      ),

                    ],
                  ),

                  // When
                  SizedBox(
                    height: bottomHeight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: screenWidth*0.02,
                          bottom: screenHeight*0.01
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          formattedWeekday,
                          style: customStyleClass.getFontStyle5BoldGrey(),
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ),
        )

      ],
    );
  }

  // FORMAT
  void formatEventTitle(){
    if(clubMeDiscount.getDiscountTitle().length >= 37){
      formattedEventTitle = "${clubMeDiscount.getDiscountTitle().substring(0, 35)}...";
    }else{
      formattedEventTitle = clubMeDiscount.getDiscountTitle().substring(0, clubMeDiscount.getDiscountTitle().length);
    }
  }
  void formatDateToDisplay(){

    String weekDayToDisplay = "";

    var exactOneWeekFromNow = DateTime.now().add(const Duration(days: 7));

    // Get current time for germany
    // final berlin = tz.getLocation('Europe/Berlin');
    // final todayGermanTZ = tz.TZDateTime.from(DateTime.now(), berlin);

    final exactlyOneWeekFromNowGermanTZ = stateProvider.getBerlinTime().add(Duration(days: 7));

    if(clubMeDiscount.getDiscountDate().isAfter(exactlyOneWeekFromNowGermanTZ)){
      weekDayToDisplay = DateFormat('dd.MM.yyyy').format(clubMeDiscount.getDiscountDate());
    }else{
      var eventDateWeekday = clubMeDiscount.getDiscountDate().weekday;
      switch(eventDateWeekday){
        case(1): weekDayToDisplay = "Montag";
        case(2): weekDayToDisplay = "Dienstag";
        case(3): weekDayToDisplay = "Mittwoch";
        case(4): weekDayToDisplay = "Donnerstag";
        case(5): weekDayToDisplay = "Freitag";
        case(6): weekDayToDisplay = "Samstag";
        case(7): weekDayToDisplay = "Sonntag";
      }
    }
    formattedWeekday = weekDayToDisplay;
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    formatEventTitle();
    formatDateToDisplay();

    return _buildStackView(context);
  }
}
