import 'dart:io';

import 'package:club_me/services/supabase_service.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/discount.dart';
import '../../../models/hive_models/2_club_me_discount.dart';
import '../../../provider/current_and_liked_elements_provider.dart';
import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../shared/custom_text_style.dart';
import 'package:intl/intl.dart';

class CouponCardClub extends StatelessWidget {
  CouponCardClub({
    Key? key,
    required this.isLiked,
    required this.clickedOnLike,
    required this.clubMeDiscount,
    required this.clickedOnShare,
    required this.isEditable
  }) : super(key: key);

  final SupabaseService _supabaseService = SupabaseService();

  ClubMeDiscount clubMeDiscount;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenWidth, screenHeight;
  late String weekDayToDisplay, titleToDisplay;

  Function () clickedOnShare;
  Function (String) clickedOnLike;

  bool isEditable;
  bool isLiked;
  String timeLimitToDisplay = "";


  // CLICK
  void clickEventInfo(BuildContext context){

    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: customStyleClass.getFontStyle4BoldPrimeColor(),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleContentAndButtonDialog(
              titleToDisplay: "Coupon-Informationen",
              contentToDisplay: clubMeDiscount.getDiscountDescription(),
              buttonToDisplay: okButton);

        }
    );
  }
  void clickEventEditDiscount(BuildContext context, ClubMeDiscount discount){
    currentAndLikedElementsProvider.setCurrentDiscount(discount);
    context.push("/discount_details");
  }
  void clickEventDeleteDiscount(BuildContext context, ClubMeDiscount discount){
    showDialog(context: context, builder: (BuildContext context){
      return
        TitleContentAndButtonDialog(
            titleToDisplay:  "Achtung",
            contentToDisplay: "Bist du sicher, dass du diesen Coupon löschen möchtest?",
            buttonToDisplay: TextButton(
                onPressed: () => _supabaseService.deleteDiscount(discount.getDiscountId()).then((value){
                  if(value == 0){
                    fetchedContentProvider.removeFetchedDiscount(discount);
                    Navigator.pop(context);
                  }else{
                    Navigator.pop(context);
                  }
                }),
                child:  Text(
                  "Löschen",
                  style: customStyleClass.getFontStyle4BoldPrimeColor(),
                )
            ));
    });
  }

  // BUILD
  Widget _buildMainView(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(
          left:2,
          top: 2
      ),
      child: Container(
        width: screenWidth*0.9,
        height: screenHeight*0.555,
        decoration: BoxDecoration(
            color: customStyleClass.backgroundColorEventTile,
            borderRadius: BorderRadius.circular(
                15
            ),
            border: Border.all(
                color: Colors.grey[900]!,
                width: 2
            )
        ),
        child: Column(
          children: [

            // Image container
            SizedBox(
                height: screenHeight*0.35,
                child: Stack(
                  children: [

                    fetchedContentProvider.getFetchedBannerImageIds()
                        .contains(clubMeDiscount.getBigBannerFileName()) ?
                    SizedBox(
                      height: screenHeight*0.35,
                      width: screenWidth,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15)
                          ),
                          child: Image(
                            image: FileImage(
                                File("${stateProvider.appDocumentsDir.path}/${clubMeDiscount.getBigBannerFileName()}")
                            ),
                            fit: BoxFit.cover,
                          )

                      ),
                    ):SizedBox(
                        height: screenHeight*0.3,
                        width: screenWidth,
                        child: Center(
                          child: SizedBox(
                            child: CircularProgressIndicator(
                              color: customStyleClass.primeColor,
                            ),
                          ),
                        )
                    ),

                    if(isEditable)
                      Container(
                          height: screenHeight*0.35,
                          width: screenWidth,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(
                              right: 10,
                              top: 10
                          ),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [

                              InkWell(
                                child: Icon(
                                    Icons.edit,
                                    color: customStyleClass.primeColor,
                                    size: screenWidth*0.06
                                ),
                                onTap: () => clickEventEditDiscount(context, clubMeDiscount),
                              ),

                              InkWell(
                                child: Icon(
                                    Icons.close,
                                    color: customStyleClass.primeColor,
                                    size: screenWidth*0.06
                                ),
                                onTap: () => clickEventDeleteDiscount(context, clubMeDiscount),
                              )

                            ],
                          )
                      )

                  ],
                )
            ),

            // Content container
            Container(
              color: customStyleClass.backgroundColorEventTile,
              height: screenHeight*0.2,
              child: Container(
                  height: screenHeight*0.2,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: customStyleClass.backgroundColorEventTile,
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12)
                    ),

                  ),
                  child: Stack(
                    children: [

                      // Title, Location, When
                      Column(
                        children: [

                          // Title
                          Padding(
                            padding: EdgeInsets.only(
                              top: screenHeight*0.01,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: screenWidth*0.02
                                // top: 10,
                                // left: 10
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      titleToDisplay,
                                      style: customStyleClass.getFontStyle3Bold(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 15
                                      ),
                                      child: Text(
                                        "VIP",
                                        style: customStyleClass.getFontStyleVIPGold(),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Location
                          Padding(
                            padding: EdgeInsets.only(
                              // top: 5,
                              left: screenWidth*0.02,
                              // top: screenHeight*0.005
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                clubMeDiscount.getClubName(),
                                style: customStyleClass.getFontStyle5(),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // Time limit, if set
                          if(clubMeDiscount.getHasTimeLimit())
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                // bottom: 7
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: GestureDetector(
                                  child: Text(
                                    "Bis $timeLimitToDisplay Uhr",
                                    style: customStyleClass.getFontStyle5(),
                                  ),
                                  onTap: (){

                                  },
                                ),
                              ),
                            ),
                          if(clubMeDiscount.getHasUsageLimit())
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10,
                                  top: 5
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: GestureDetector(
                                  child: Text(
                                    "${clubMeDiscount.getNumberOfUsages()}x einlösbar",
                                    style: customStyleClass.getFontStyle5(),
                                  ),
                                  onTap: (){

                                  },
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 10,
                                top: 3
                            ),
                            width: screenWidth*0.9,
                            child: Text(
                              textAlign: TextAlign.left,
                              "${clubMeDiscount.getHowOftenRedeemed()} mal aufgerufen",
                              style: customStyleClass.getFontStyle5(),
                            ),
                          )

                        ],
                      ),


                      // Icons
                      Container(
                        // height: screenHeight*0.2,
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(
                            top: screenHeight*0.01,
                            right: screenWidth*0.02
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: customStyleClass.primeColor,
                                      )
                                    ],
                                  ),
                                  onTap: () => clickEventInfo(context),
                                ),
                                SizedBox(
                                  width: screenWidth*0.02,
                                ),
                                GestureDetector(
                                  child: Column(
                                    children: [
                                      Icon(
                                        isLiked ? Icons.star_outlined : Icons.star_border,
                                        color:customStyleClass.primeColor,
                                      )
                                    ],
                                  ),
                                  onTap: () => clickedOnLike(clubMeDiscount.getDiscountId()),
                                ),
                                SizedBox(
                                  width: screenWidth*0.02,
                                ),
                                // GestureDetector(
                                //   child: Column(
                                //     children: [
                                //       Icon(
                                //         Icons.share,
                                //         color: customStyleClass.primeColor,
                                //       )
                                //     ],
                                //   ),
                                //   onTap: () => clickedOnShare(),
                                // )
                              ],
                            )
                          ],
                        ),
                      ),

                      Center(
                        child: Container(
                          width: screenWidth*0.83,
                          padding: const EdgeInsets.only(
                              bottom: 10
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                weekDayToDisplay,
                                style: customStyleClass.getFontStyle5BoldPrimeColor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
              ),
            )
          ],
        ),
      ),
    );
  }


  // FORMAT
  void formatTimeLimit(){

    if(clubMeDiscount.getDiscountDate().minute < 10){
      if(clubMeDiscount.getDiscountDate().hour < 10){
        timeLimitToDisplay = "0${clubMeDiscount.getDiscountDate().hour}:0${clubMeDiscount.getDiscountDate().minute}";
      }else{
        timeLimitToDisplay = "${clubMeDiscount.getDiscountDate().hour}:0${clubMeDiscount.getDiscountDate().minute}";
      }
    }else{
      if(clubMeDiscount.getDiscountDate().hour < 10){
        timeLimitToDisplay = "0${clubMeDiscount.getDiscountDate().hour}:${clubMeDiscount.getDiscountDate().minute}";
      }else{
        timeLimitToDisplay = "${clubMeDiscount.getDiscountDate().hour}:${clubMeDiscount.getDiscountDate().minute}";
      }
    }

  }
  void formatDiscountTitle(){
    if(clubMeDiscount.getDiscountTitle().length > 26){
      titleToDisplay = "${clubMeDiscount.getDiscountTitle().substring(0,25)}...";
    }else{
      titleToDisplay = clubMeDiscount.getDiscountTitle();
    }
  }
  void formatDateToDisplay(){

    DateTime dateToUse;
    if(clubMeDiscount.getHasTimeLimit() && clubMeDiscount.getDiscountDate().hour < 6){
      dateToUse = DateTime(
          clubMeDiscount.getDiscountDate().year,
          clubMeDiscount.getDiscountDate().month,
          clubMeDiscount.getDiscountDate().day-1,
          clubMeDiscount.getDiscountDate().hour,
          clubMeDiscount.getDiscountDate().minute
      );
    }else{
      dateToUse = clubMeDiscount.getDiscountDate();
    }

    weekDayToDisplay = DateFormat('dd.MM.yyyy').format(dateToUse);

    var eventDateWeekday = dateToUse.weekday;

    switch(eventDateWeekday){
      case(0): weekDayToDisplay = "Sonntag, $weekDayToDisplay";
      case(1): weekDayToDisplay = "Montag, $weekDayToDisplay";
      case(2): weekDayToDisplay = "Dienstag, $weekDayToDisplay";
      case(3): weekDayToDisplay = "Mittwoch, $weekDayToDisplay";
      case(4): weekDayToDisplay = "Donnerstag, $weekDayToDisplay";
      case(5): weekDayToDisplay = "Freitag, $weekDayToDisplay";
      case(6): weekDayToDisplay = "Samstag, $weekDayToDisplay";
      case(7): weekDayToDisplay = "Sonntag, $weekDayToDisplay";
    }

  }


  // DIALOGS
  void showRedeemDialog(BuildContext context, StateProvider stateProvider, ClubMeDiscount clubMeDiscount){
    showDialog(context: context,
        builder: (BuildContext context){
          return TitleContentAndButtonDialog(
              titleToDisplay: "Coupon einlösen",
              contentToDisplay: "Bist du sicher, dass du den Coupon einlösen möchtest? Du kannst ihn danach womöglich nicht noch einmal einlösen.",
              buttonToDisplay: TextButton(
                  onPressed: () {
                    currentAndLikedElementsProvider.setCurrentDiscount(clubMeDiscount);
                    context.go('/coupon_active');
                  },
                  child: Text(
                    "Einlösen",
                    style: customStyleClass.getFontStyle4BoldPrimeColor(),
                  )
              ));
        }
    );
  }


  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    customStyleClass = CustomStyleClass(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    formatTimeLimit();
    formatDiscountTitle();
    formatDateToDisplay();

    return _buildMainView(context);
  }

}