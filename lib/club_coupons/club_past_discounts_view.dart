import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/discount.dart';
import '../provider/state_provider.dart';
import 'package:intl/intl.dart';

import '../shared/custom_bottom_navigation_bar.dart';
import '../shared/custom_text_style.dart';
import 'components/discount_card.dart';
import 'package:timezone/standalone.dart' as tz;


class ClubPastDiscountsView extends StatefulWidget {
  const ClubPastDiscountsView({Key? key}) : super(key: key);

  @override
  State<ClubPastDiscountsView> createState() => _ClubPastDiscountsViewState();
}

class _ClubPastDiscountsViewState extends State<ClubPastDiscountsView> {

  String headline = "Vergangene Coupons";

  late CustomTextStyle customTextStyle;

  late double screenHeight, screenWidth;
  late StateProvider stateProvider;

  List<ClubMeDiscount> pastDbDiscounts = [];
  List<ClubMeDiscount> discountsToDisplay = [];

  Widget _buildMainView(StateProvider stateProvider, double screenHeight){

    // get today in correct format to check which events are upcoming
    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    final berlin = tz.getLocation('Europe/Berlin');
    final todayTimestampGermany = tz.TZDateTime.from(DateTime.now(), berlin);


    if(pastDbDiscounts.isEmpty){
      for(var currentDiscount in stateProvider.getFetchedDiscounts()){
        if( currentDiscount.getClubId() == stateProvider.userClub.getClubId() &&
            currentDiscount.getDiscountDate().isBefore(todayTimestampGermany)){
          pastDbDiscounts.add(currentDiscount);
        }
      }
    }

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: pastDbDiscounts.length,
        itemBuilder: ((context, index){

          ClubMeDiscount currentDiscount = pastDbDiscounts[index];

          return GestureDetector(
            child: DiscountCard(
              clubMeDiscount: currentDiscount,
            ),
            onTap: (){
            },
          );
        })
    );
  }


  @override
  Widget build(BuildContext context) {
    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    return Scaffold(

        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBar(),
        appBar:

        AppBar(

            backgroundColor: Colors.transparent,

            title: Text(headline,
              style: customTextStyle.size1Bold()
            ),

            leading: GestureDetector(
              child: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.grey,
                // size: 20,
              ),
              onTap: () => context.go("/club_discounts"),
            )

        ),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Color(0xff11181f),
                    Color(0xff2b353d),
                    Color(0xff11181f)
                  ],
                  stops: [0.15, 0.6]
              ),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: Column(
                      children: [

                        _buildMainView(stateProvider, screenHeight),

                        // Spacer
                        SizedBox(height: screenHeight*0.1,),
                      ],
                    )
                ),
              ],
            )
        )
    );
  }
}
