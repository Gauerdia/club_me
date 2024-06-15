import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/discount.dart';
import '../../provider/state_provider.dart';
import '../../shared/custom_text_style.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';

class SmallDiscountTile extends StatelessWidget {
  SmallDiscountTile({Key? key, required this.clubMeDiscount}) : super(key: key);

  ClubMeDiscount clubMeDiscount;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;
  late String formattedWeekday;

  void formatWeekday(){

    String weekDayToDisplay = "";

    // Get current time for germany
    final berlin = tz.getLocation('Europe/Berlin');
    final todayGermanTZ = tz.TZDateTime.from(DateTime.now(), berlin);
    final exactlyOneWeekFromNowGermanTZ = todayGermanTZ.add(const Duration(days: 7));

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

  Widget _buildMainColumn(){
    return Column(
      children: [

        // Image container
        Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12)
              ),
              border: Border(
                top: BorderSide(
                    width: 1, color: Colors.white60
                ),
                left: BorderSide(
                    width: 1, color: Colors.white60
                ),
                right: BorderSide(
                    width: 1, color: Colors.white60
                ),
              ),
            ),
            child: SizedBox(
                width: screenWidth*0.8,
                height: screenHeight*0.15,
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
            width: screenWidth*0.805,
            padding: const EdgeInsets.only(
                bottom: 10
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12)
              ),
              border: const Border(
                bottom: BorderSide(
                    width: 1, color: Colors.white60
                ),
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
                            clubMeDiscount.getDiscountTitle(),
                            style: customTextStyle.size2Bold()
                        ),
                      ),
                    ),

                    // Date
                    Padding(
                      padding: const EdgeInsets.only(
                        // top: 5,
                          left: 10
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            formattedWeekday,
                            style: customTextStyle.size5Bold()
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
                            style: customTextStyle.size6BoldGrey()
                        ),
                      ),
                    ),
                  ],
                ),
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
    customTextStyle = CustomTextStyle(context: context);

    formatWeekday();


    return Container(
      padding: EdgeInsets.only(bottom: screenHeight*0.02),
      child: Card(
        child: _buildMainColumn()
      ),
    );
  }
}
