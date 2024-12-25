import 'dart:io';

import 'package:club_me/models/hive_models/5_club_me_used_discount.dart';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:club_me/services/supabase_service.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_two_buttons_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/hive_models/2_club_me_discount.dart';
import '../../../provider/current_and_liked_elements_provider.dart';
import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../shared/custom_text_style.dart';
import 'package:intl/intl.dart';

class CouponCard extends StatelessWidget {
  CouponCard({
    Key? key,
    required this.isLiked,
    required this.clickedOnLike,
    required this.clubMeDiscount,
    required this.clickedOnShare,
  }) : super(key: key);

  ClubMeDiscount clubMeDiscount;
  late FetchedContentProvider fetchedContentProvider;
  late UserDataProvider userDataProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  SupabaseService _supabaseService = SupabaseService();
  HiveService _hiveService = HiveService();

  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenWidth, screenHeight;
  late String weekDayToDisplay, titleToDisplay;

  Function () clickedOnShare;
  Function (String) clickedOnLike;

  bool isLiked;
  String timeLimitToDisplay = "";

  bool specialOccasionActive = true;


  // BUILD
  Widget _buildStackView(BuildContext context){

    return Stack(
      children: [

        if(clubMeDiscount.getSpecialOccasionActive())
        Container(
            width: screenWidth*0.91,
            height: screenHeight*0.56,
            decoration:const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                  0.1,
                  0.9
                ], colors: [
                  Colors.pinkAccent,
                  Colors.blueAccent
                ]),
              border: Border(
              ),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15)
              ),
            )

        ),

        if(clubMeDiscount.getIsRedeemable())
          Container(
              width: screenWidth*0.91,
              height: screenHeight*0.565,
              decoration:const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      0.1,
                      0.9
                    ], colors: [
                  Color(0xffa67c00),
                  Color(0xffffdc73),
                ]),
                border: Border(
                ),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)
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
            height: screenHeight*0.56, //0.555,
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
                ),
                border: Border.all(
                    color: Colors.grey[900]!,
                    width: 2
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
            height: screenHeight*0.35,
            child: Stack(
              children: [

                fetchedContentProvider.getFetchedBannerImageIds()
                    .contains(clubMeDiscount.getBigBannerFileName()) ?
                Container(
                  height: screenHeight*0.35,
                  width: screenWidth,
                  decoration: specialOccasionActive ?
                  const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)
                    ),
                  ):
                  const BoxDecoration(),
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

              if(clubMeDiscount.getNumberOfUsages() != 0)
              Container(
                height: screenHeight*0.35,
                width: screenWidth,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(45)),
                    color: customStyleClass.backgroundColorEventTile,
                    border: Border.all(
                      color: Colors.black
                    )
                  ),
                  child: Text(
                      "${clubMeDiscount.getNumberOfUsages()}x",
                    style: customStyleClass.getFontStyle3Bold(),
                  ),
                ),
              )

              ],
            )
        ),

        // Content container
        SizedBox(
          height: screenHeight*0.2,
          child: Container(
              height: screenHeight*0.2,
              width: screenWidth,
              decoration: specialOccasionActive ?

              BoxDecoration(
                color: customStyleClass.backgroundColorEventTile,
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12)
                ),
              ):
              BoxDecoration(
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
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth*0.02
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    titleToDisplay,
                                    style: customStyleClass.getFontStyle2Bold(),
                                  ),
                                  if(clubMeDiscount.getIsRedeemable())
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
                      ),

                      // Location
                      Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth*0.02,
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
                            top: 10
                            // bottom: 7
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              child: Text(
                                "Angebot gütig bis $timeLimitToDisplay Uhr!",
                                style: customStyleClass.getFontStyle3Bold(),
                              ),
                              onTap: (){},
                            ),
                          ),
                        ),
                      // if(clubMeDiscount.getHasUsageLimit())
                      //   Padding(
                      //     padding: const EdgeInsets.only(
                      //         left: 10,
                      //         top: 5
                      //     ),
                      //     child: Align(
                      //       alignment: Alignment.bottomLeft,
                      //       child: GestureDetector(
                      //         child: Text(
                      //           "${clubMeDiscount.getNumberOfUsages()}x einlösbar",
                      //           style: customStyleClass.getFontStyle5(),
                      //         ),
                      //         onTap: (){},
                      //       ),
                      //     ),
                      //   ),

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

                          if(clubMeDiscount.getIsRedeemable())
                          InkWell(
                            child: Row(
                              children: [
                                Text(
                                  "Einlösen",
                                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                                ),
                                Icon(
                                  Icons.arrow_forward_outlined,
                                  color: customStyleClass.primeColor,
                                )
                              ],
                            ),
                            onTap: () => showRedeemDialog(context, stateProvider, clubMeDiscount),
                          )
                        ],
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
              titleToDisplay: "Coupon-Beschreibung",
              contentToDisplay: clubMeDiscount.getDiscountDescription(),
              buttonToDisplay: okButton);
        }
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

    titleToDisplay = clubMeDiscount.getDiscountTitle();

    // if(clubMeDiscount.getDiscountTitle().length > 26){
    //   titleToDisplay = "${clubMeDiscount.getDiscountTitle().substring(0,25)}...";
    // }else{
    //   titleToDisplay = clubMeDiscount.getDiscountTitle();
    // }
  }
  void formatDateToDisplay(){


    DateTime dateToUse;
    int eventDateWeekday;

    if(clubMeDiscount.hasTimeLimit && clubMeDiscount.getDiscountDate().hour < 6){
      eventDateWeekday = clubMeDiscount.getDiscountDate().weekday-1;
      dateToUse = DateTime(
          clubMeDiscount.getDiscountDate().year,
          clubMeDiscount.getDiscountDate().month,
          clubMeDiscount.getDiscountDate().day-1,
          clubMeDiscount.getDiscountDate().hour,
          clubMeDiscount.getDiscountDate().minute
      );
    }else{
      eventDateWeekday = clubMeDiscount.getDiscountDate().weekday;
      dateToUse = clubMeDiscount.getDiscountDate();
    }

    String weekDayToDisplayWorkingString = DateFormat('dd.MM.yyyy').format(dateToUse);

    switch(eventDateWeekday){
      case(0): weekDayToDisplay = "Sonntag, $weekDayToDisplayWorkingString";
      case(1): weekDayToDisplay = "Montag, $weekDayToDisplayWorkingString";
      case(2): weekDayToDisplay = "Dienstag, $weekDayToDisplayWorkingString";
      case(3): weekDayToDisplay = "Mittwoch, $weekDayToDisplayWorkingString";
      case(4): weekDayToDisplay = "Donnerstag, $weekDayToDisplayWorkingString";
      case(5): weekDayToDisplay = "Freitag, $weekDayToDisplayWorkingString";
      case(6): weekDayToDisplay = "Samstag, $weekDayToDisplayWorkingString";
      case(7): weekDayToDisplay = "Sonntag, $weekDayToDisplayWorkingString";
    }
  }


  // DIALOGS
  void showInformationDialog(){

  }
  void showRedeemDialog(BuildContext context, StateProvider stateProvider, ClubMeDiscount clubMeDiscount){

    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    showDialog(context: context,
        builder: (BuildContext context){
          return TitleContentAndTwoButtonsDialog(
                titleToDisplay: "Coupon einlösen",
                contentToDisplay: "Bitte löse das Angebot in Anwesenheit des Personals ein!",
                firstButtonToDisplay: TextButton(
                    onPressed: () {
                      currentAndLikedElementsProvider.setCurrentDiscount(clubMeDiscount);
                      saveAsUsedDiscount();
                      context.go('/coupon_active');
                    },
                    child: Text(
                      "Einlösen",
                      style: customStyleClass.getFontStyle4BoldPrimeColor(),
                    )
                ),
            secondButtonToDisplay: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Abbrechen",
                  style: customStyleClass.getFontStyle4Bold(),
                )
            ),
          );
        }
    );
  }

  void saveAsUsedDiscount(){
    _supabaseService.insertDiscountUsage(
        clubMeDiscount.getDiscountId(),
        userDataProvider.getUserDataId()
    ).then((response){
      if(response == 0){

        ClubMeUsedDiscount clubMeUsedDiscount = ClubMeUsedDiscount(
            usedAt: DateTime.now(),
            discountId: clubMeDiscount.getDiscountId()
        );

        _hiveService.insertUsedDiscount(clubMeUsedDiscount);
      }else{

      }
    });
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

    return _buildStackView(context);
  }

}