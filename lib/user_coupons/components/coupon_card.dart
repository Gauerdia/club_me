import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/discount.dart';
import '../../provider/state_provider.dart';
import 'package:intl/intl.dart';
import '../../shared/custom_text_style.dart';
import 'package:timezone/standalone.dart' as tz;

class CouponCard extends StatelessWidget {
  CouponCard({
    Key? key,
    required this.isLiked,
    required this.clickedOnLike,
    required this.clubMeDiscount,
    required this.clickedOnShare,

  }) : super(key: key);

  ClubMeDiscount clubMeDiscount;

  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenWidth, screenHeight;
  late String weekDayToDisplay, titleToDisplay;

  Function () clickedOnShare;
  Function (String) clickedOnLike;

  bool isLiked;
  String timeLimitToDisplay = "";


 // CLICK
  void clickOnInfo(BuildContext context){

    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Coupon-Informationen"),
            content: Text(
              clubMeDiscount.getDiscountDescription(),
            ),
            actions: [
              okButton
            ],
          );
        }
    );
  }


  // BUILD
  Widget _buildStackView(BuildContext context){

    double newDiscountContainerHeightFactor = 0.6;

    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(newDiscountContainerHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*newDiscountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
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
          height: screenHeight*newDiscountContainerHeightFactor,
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
              height: screenHeight*newDiscountContainerHeightFactor,
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
            height: screenHeight*newDiscountContainerHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
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
            height: screenHeight*0.3,
            child: Stack(
              children: [

                SizedBox(
                  height: screenHeight*0.3,
                  width: screenWidth,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)
                    ),
                    child: Image.asset(
                      "assets/images/${clubMeDiscount.getBannerId()}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Shadow to highlight icons
                Container(
                  height: screenHeight*0.15,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent]
                    ),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12)
                    ),
                  ),
                ),

                // Icons
                Container(
                  height: screenHeight*0.2,
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.02,
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
                                  color: stateProvider.getPrimeColor(),
                                ),
                                Text(
                                  "Info",
                                  style: customTextStyle.size5(),
                                ),
                              ],
                            ),
                            onTap: () => clickOnInfo(context),
                          ),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          GestureDetector(
                            child: Column(
                              children: [
                                Icon(
                                  isLiked ? Icons.star_outlined : Icons.star_border,
                                  color: stateProvider.getPrimeColor(),
                                ),
                                Text(
                                  "Like",
                                  style: customTextStyle.size5(),
                                ),
                              ],
                            ),
                            onTap: () => clickedOnLike(clubMeDiscount.getDiscountId()),
                          ),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          GestureDetector(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.share,
                                  color: stateProvider.getPrimeColor(),
                                ),
                                Text(
                                  "Share",
                                  style: customTextStyle.size5(),
                                ),
                              ],
                            ),
                            onTap: () => clickedOnShare(),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )
        ),

        // Content container
        SizedBox(
          height: screenHeight*0.3,
          child: Container(
              height: screenHeight*0.3,
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

                      // Title
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight*0.01,
                        ),
                        child: Container(
                          // color: Colors.red,
                          height: screenHeight*0.04,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth*0.02
                              // top: 10,
                              // left: 10
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                titleToDisplay,
                                style: customTextStyle.size2Bold(),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Location
                      Container(
                        // color: Colors.red,
                        height: screenHeight*0.04,
                        child: Padding(
                          padding: EdgeInsets.only(
                            // top: 5,
                              left: screenWidth*0.02
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              clubMeDiscount.getClubName(),
                              style: customTextStyle.size4(),
                            ),
                          ),
                        ),
                      ),

                      // When
                      Container(
                        // color: Colors.red,
                        height: screenHeight*0.03,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth*0.02
                            // top: 3,
                            // left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              weekDayToDisplay,
                              style: customTextStyle.size5BoldGrey(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),


                  clubMeDiscount.hasTimeLimit?
                  Padding(
                    padding: const EdgeInsets.only(left: 7, bottom: 7),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: GestureDetector(
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Color(0xff11181f),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              )
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Bis $timeLimitToDisplay",
                            style: customTextStyle.size4BoldGrey(),
                          ),
                        ),
                        onTap: (){

                        },
                      ),
                    ),
                  ):Container(),

                  // Button
                  Padding(
                    padding: const EdgeInsets.only(right: 7, bottom: 7),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Color(0xff11181f),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              )
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Einlösen!",
                            style: customTextStyle.size3BoldPrimeColor(),
                          ),
                        ),
                        onTap: (){
                          showRedeemDialog(context, stateProvider, clubMeDiscount);
                        },
                      ),
                    ),
                  )
                ],
              )
          ),
        )

      ],
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

    // Get current time for germany
    final berlin = tz.getLocation('Europe/Berlin');
    final oneWeekFromNowGermanTZ = tz.TZDateTime.from(DateTime.now(), berlin).add(const Duration(days: 7));
    // var exactOneWeekFromNow = DateTime.now().add(const Duration(days: 7));

    if(clubMeDiscount.getDiscountDate().isAfter(oneWeekFromNowGermanTZ)){
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
  }


  // DIALOGS
  void showInformationDialog(){

  }
  void showRedeemDialog(BuildContext context, StateProvider stateProvider, ClubMeDiscount clubMeDiscount){
    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Coupon einlösen"),
            content: Text("Bist du sicher, dass du den Coupon einlösen möchtest? Du kannst ihn danach womöglich nicht noch einmal einlösen"),
            actions: [
              TextButton(
                  onPressed: () {
                    stateProvider.setCurrentDiscount(clubMeDiscount);
                    context.go('/coupon_active');
                  },
                  child: Text("Einlösen")
              )
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    formatTimeLimit();
    formatDiscountTitle();
    formatDateToDisplay();

    return _buildStackView(context);
  }

}