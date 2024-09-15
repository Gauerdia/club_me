import 'package:club_me/models/discount.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../provider/state_provider.dart';


class DiscountCard extends StatelessWidget {
  DiscountCard({
    Key? key,
    required this.clubMeDiscount
  }) : super(key: key);

  ClubMeDiscount clubMeDiscount;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late String formattedDiscountTitle, formattedWeekday;

  void formatDateToDisplay(){

    // final berlin = tz.getLocation('Europe/Berlin');
    // final localizedDt = tz.TZDateTime.from(DateTime.now(), berlin);
    DateTime normalizedCurrentTime = DateTime.parse(stateProvider.getBerlinTime().toString());

    String weekDayToDisplay = "";

    // Check if past discount
    if (normalizedCurrentTime.isAfter(clubMeDiscount.getDiscountDate())){
      weekDayToDisplay = DateFormat('dd.MM.yyyy').format(clubMeDiscount.getDiscountDate());
      formattedWeekday = weekDayToDisplay;
    }else{
      var exactOneWeekFromNow = DateTime.now().add(const Duration(days: 7));
      if(clubMeDiscount.getDiscountDate().isAfter(exactOneWeekFromNow)){
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
  }
  void formatDiscountTitle(){
    String eventTitleCut = "";

    if(clubMeDiscount.getDiscountTitle().length >= 22){
      eventTitleCut = "${clubMeDiscount.getDiscountTitle().substring(0, 21)}...";
    }else{
      eventTitleCut = clubMeDiscount.getDiscountTitle().substring(0, clubMeDiscount.getDiscountTitle().length);
    }
    formattedDiscountTitle = eventTitleCut;
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    formatDateToDisplay();
    formatDiscountTitle();


    return Container(
      padding: EdgeInsets.only(bottom: screenHeight*0.02),
      child: Card(
        child: Column(
          children: [

            // Image container
            Container(
                width: screenWidth,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12)
                  ),
                  border: Border(
                    left: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                    right: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                  ),
                ),
                child: SizedBox(
                    height: screenHeight*0.17,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12)
                      ),
                      child: Image.asset(
                        "assets/images/${clubMeDiscount.getBannerId()}",
                        fit: BoxFit.cover,
                      ),
                    )
                )
            ),

            // Content container
            Container(
                height: screenHeight*0.19,
                width: screenWidth,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12)
                  ),
                  border: const Border(
                    left: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                    right: BorderSide(
                        width: 1, color: Colors.white60
                    ),
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
                          padding: const EdgeInsets.only(
                              top: 10,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formattedDiscountTitle,
                              style: customStyleClass.getFontStyle1Bold()
                            ),
                          ),
                        ),

                        // Location
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              clubMeDiscount.getClubName(),
                              style: customStyleClass.getFontStyle5Bold()
                            ),
                          ),
                        ),

                        // When
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 3,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formattedWeekday,
                              style: customStyleClass.getFontStyle5BoldDarkGrey()
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
