import 'package:club_me/club_coupons/components/discount_card.dart';
import 'package:club_me/club_coupons/components/small_discount_tile.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/user_coupons/components/coupon_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/discount.dart';
import 'package:intl/intl.dart';

import '../shared/custom_bottom_navigation_bar.dart';
import '../shared/custom_text_style.dart';


class ClubUpcomingDiscountsView extends StatefulWidget {
  const ClubUpcomingDiscountsView({Key? key}) : super(key: key);

  @override
  State<ClubUpcomingDiscountsView> createState() => _ClubUpcomingDiscountsViewState();
}

class _ClubUpcomingDiscountsViewState extends State<ClubUpcomingDiscountsView> {

  String headline = "Kommende Coupons";

  late CustomTextStyle customTextStyle;

  late double screenHeight, screenWidth;
  late StateProvider stateProvider;

  List<ClubMeDiscount> upcomingDbDiscounts = [];
  List<ClubMeDiscount> discountsToDisplay = [];

  Widget _buildMainView(StateProvider stateProvider, double screenHeight){

    // get today in correct format to check which events are upcoming
    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    if(upcomingDbDiscounts.isEmpty){
      for(var currentDiscount in stateProvider.getFetchedDiscounts()){
        if( currentDiscount.getClubId() == stateProvider.userClub.getClubId() &&
            (currentDiscount.getDiscountDate().isAfter(todayFormatted)
                || currentDiscount.getDiscountDate().isAtSameMomentAs(todayFormatted))){
          upcomingDbDiscounts.add(currentDiscount);
        }
      }
    }

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: upcomingDbDiscounts.length,
        itemBuilder: ((context, index){

          ClubMeDiscount currentDiscount = upcomingDbDiscounts[index];

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

    customTextStyle = CustomTextStyle(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

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
                        SizedBox(height: screenHeight*0.1),
                      ],
                    )
                ),
              ],
            )
        )
    );
  }
}
