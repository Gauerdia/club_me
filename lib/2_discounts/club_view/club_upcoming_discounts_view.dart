import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/discount.dart';
import 'package:intl/intl.dart';

import '../../provider/fetched_content_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../shared/custom_text_style.dart';
import 'components/discount_tile_2.dart';



class ClubUpcomingDiscountsView extends StatefulWidget {
  const ClubUpcomingDiscountsView({Key? key}) : super(key: key);

  @override
  State<ClubUpcomingDiscountsView> createState() => _ClubUpcomingDiscountsViewState();
}

class _ClubUpcomingDiscountsViewState extends State<ClubUpcomingDiscountsView> {

  String headline = "Kommende Coupons";

  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late double screenHeight, screenWidth;

  List<ClubMeDiscount> upcomingDbDiscounts = [];
  List<ClubMeDiscount> discountsToDisplay = [];

  // CLICKED
  void clickedOnTile(){
    // TODO: Implement click event
  }

  // BUILD
  Widget _buildAppBarShowTitle(){
    return SizedBox(
      width: screenWidth,
      child: Stack(
        children: [
          // Headline
          Container(
              alignment: Alignment.bottomCenter,
              height: 50,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(headline,
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle1()
                  ),
                ],
              )
          ),

          // back icon
          Container(
              width: screenWidth,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => context.go("/club_discounts"),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.grey,
                    ),
                  )
                ],
              )
          ),

        ],
      ),
    );
  }
  Widget _buildMainView(StateProvider stateProvider, double screenHeight){

    // get today in correct format to check which events are upcoming
    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    if(upcomingDbDiscounts.isEmpty){
      for(var currentDiscount in fetchedContentProvider.getFetchedDiscounts()){
        if( currentDiscount.getClubId() == userDataProvider.getUserClubId() &&
            (currentDiscount.getDiscountDate().isAfter(todayFormatted)
                || currentDiscount.getDiscountDate().isAtSameMomentAs(todayFormatted))){
          upcomingDbDiscounts.add(currentDiscount);
        }
      }
    }

    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(
          vertical: screenHeight*0.02
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: upcomingDbDiscounts.length,
        itemBuilder: ((context, index){

          ClubMeDiscount currentDiscount = upcomingDbDiscounts[index];

          return GestureDetector(
            child:
            DiscountTile2(
              clubMeDiscount: currentDiscount,
            ),
            onTap: () => clickedOnTile(),
          );
        })
    );
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    userDataProvider = Provider.of<UserDataProvider>(context);
    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(

      extendBody: true,

      appBar: AppBar(
          surfaceTintColor: Colors.black,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: _buildAppBarShowTitle()
      ),
      body: Container(
            width: screenWidth,
            height: screenHeight,
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [
            //         Color(0xff2b353d),
            //         Color(0xff11181f)
            //       ],
            //       stops: [0.15, 0.6]
            //   ),
            // ),
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
        ),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }
}
