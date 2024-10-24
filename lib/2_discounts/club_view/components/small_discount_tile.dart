import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/discount.dart';
import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../shared/custom_text_style.dart';

class SmallDiscountTile extends StatelessWidget {
  SmallDiscountTile({Key? key, required this.clubMeDiscount}) : super(key: key);

  ClubMeDiscount clubMeDiscount;
  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late String formattedWeekday;

  void formatWeekday(){

    String weekDayToDisplay = "";

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

    weekDayToDisplay = "$weekDayToDisplay, ${DateFormat('dd.MM.yyyy').format(clubMeDiscount.getDiscountDate())}";

    if(clubMeDiscount.getHasTimeLimit()){
      var hourToDisplay = clubMeDiscount.getDiscountDate().hour < 10 ?
      "0${clubMeDiscount.getDiscountDate().hour}" : clubMeDiscount.getDiscountDate().hour.toString();
      var minuteToDisplay = clubMeDiscount.getDiscountDate().minute < 10 ?
      "0${clubMeDiscount.getDiscountDate().minute}" : clubMeDiscount.getDiscountDate().minute.toString();

      weekDayToDisplay = "$weekDayToDisplay, bis $hourToDisplay:$minuteToDisplay Uhr";
    }

    formattedWeekday = weekDayToDisplay;
  }

  Widget _buildMainColumn(){
    return Column(
      children: [

        // Image container
        Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12)
              ),
              border: Border.all(
                color: customStyleClass.backgroundColorEventTile,
                width: 2
              ),
            ),
            child: SizedBox(
                width: screenWidth*0.9,
                height: screenHeight*0.2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12)
                  ),
                  child:

                  fetchedContentProvider.getFetchedBannerImageIds().contains(clubMeDiscount.getSmallBannerFileName())?
                  Image(
                    image: FileImage(
                        File("${stateProvider.appDocumentsDir.path}/${clubMeDiscount.getSmallBannerFileName()}")),
                    fit: BoxFit.cover,
                  )

                      : SizedBox(
                    height: screenHeight*0.1,
                    width: screenWidth*0.5,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: customStyleClass.primeColor,
                      ),
                    ),
                  )
                )
            )
        ),

        // Content container
        Container(
            width: screenWidth*0.905,
            height: screenHeight*0.12,

            padding: const EdgeInsets.only(
                bottom: 10
            ),
            decoration: BoxDecoration(
              color: customStyleClass.backgroundColorEventTile,
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12)
              ),
              border: Border.all(
                color: customStyleClass.backgroundColorEventTile,
                width: 2
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [

                    // Title
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10,
                          left: 10
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            clubMeDiscount.getDiscountTitle(),
                            style: customStyleClass.getFontStyle2Bold()
                        ),
                      ),
                    ),

                    // Aufgerufen
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 3,
                          left: 10
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "${clubMeDiscount.getHowOftenRedeemed()} Mal aufgerufen",
                            style: customStyleClass.getFontStyle6BoldGrey()
                        ),
                      ),
                    ),
                  ],
                ),

                // Date
                Container(
                  padding: const EdgeInsets.only(
                      left: 10
                  ),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                      formattedWeekday,
                      style: customStyleClass.getFontStyle5BoldPrimeColor()
                  ),
                ),

                if(clubMeDiscount.hasUsageLimit && clubMeDiscount.getNumberOfUsages() > 1)
                  Container(
                    padding: const EdgeInsets.only(
                        right: 10,
                      top: 10
                    ),
                    alignment: Alignment.topRight,
                    child: Text(
                        "${clubMeDiscount.getNumberOfUsages()}x einlösbar",
                        style: customStyleClass.getFontStyle5Bold()
                    ),
                  )
              ],
            )
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    formatWeekday();


    return Container(
      padding: EdgeInsets.only(bottom: screenHeight*0.02),
      child: Card(
        color: customStyleClass.backgroundColorEventTile,
        child: _buildMainColumn()
      ),
    );
  }
}
