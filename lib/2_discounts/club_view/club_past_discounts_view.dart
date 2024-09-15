
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/discount.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import 'package:intl/intl.dart';

import '../../provider/user_data_provider.dart';

import '../../shared/custom_text_style.dart';


import 'components/discount_tile_2.dart';


class ClubPastDiscountsView extends StatefulWidget {
  const ClubPastDiscountsView({Key? key}) : super(key: key);

  @override
  State<ClubPastDiscountsView> createState() => _ClubPastDiscountsViewState();
}

class _ClubPastDiscountsViewState extends State<ClubPastDiscountsView> {

  String headline = "Vergangene Coupons";

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  List<ClubMeDiscount> pastDbDiscounts = [];
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
              // color: Colors.red,
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
                      // size: 20,
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

    // final berlin = tz.getLocation('Europe/Berlin');
    // final todayTimestampGermany = tz.TZDateTime.from(DateTime.now(), berlin);


    if(pastDbDiscounts.isEmpty){
      for(var currentDiscount in fetchedContentProvider.getFetchedDiscounts()){
        if( currentDiscount.getClubId() == userDataProvider.getUserClubId() &&
            currentDiscount.getDiscountDate().isBefore(stateProvider.getBerlinTime())){
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
            child: DiscountTile2(
              clubMeDiscount: currentDiscount,
            ),
            onTap: () => clickedOnTile(),
          );
        })
    );
  }

  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);
    stateProvider = Provider.of<StateProvider>(context);

    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      extendBody: true,

      appBar: AppBar(
        surfaceTintColor: Colors.black,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: _buildAppBarShowTitle(),
        ),
      body: Container(
            width: screenWidth,
            height: screenHeight,
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
        ),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }
}
