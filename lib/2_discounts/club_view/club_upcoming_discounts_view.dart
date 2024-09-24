import 'package:club_me/2_discounts/club_view/components/coupon_card_club.dart';
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

class _ClubUpcomingDiscountsViewState extends State<ClubUpcomingDiscountsView>
    with TickerProviderStateMixin{

  String headline = "Aktuelle Coupons";

  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late double screenHeight, screenWidth;

  List<ClubMeDiscount> upcomingDbDiscounts = [];
  List<ClubMeDiscount> discountsToDisplay = [];

  bool isSearchbarActive = false;
  String searchValue = "";
  int _currentPageIndex = 0;
  late TabController _tabController;
  late PageController _pageViewController;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);


    filterFetchedDiscounts();

  }


  void filterFetchedDiscounts(){

    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    for(var discount in fetchedContentProvider.getFetchedDiscounts()){

      // local var to shorten the expressions
      DateTime discountTimestamp = discount.getDiscountDate();

      // Sort the discounts into the correct arrays
      if(discountTimestamp.isAfter(stateProvider.getBerlinTime()) || discountTimestamp.isAtSameMomentAs(stateProvider.getBerlinTime())){

          discountsToDisplay.add(discount);
      }
    }
  }

  bool checkIfIsLiked(ClubMeDiscount discount){
    return false;
  }
  void clickedOnShare(){

  }
  void clickedOnLike(String input){

  }


  // CLICKED
  void clickedOnTile(){
    // TODO: Implement click event
  }

  // BUILD
  Widget _buildAppBarShowTitle(){
    return Container(
      color: customStyleClass.backgroundColorMain,
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
                      style: customStyleClass.getFontStyleHeadline1Bold()
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
                    onPressed: () => Navigator.pop(context),
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

  Widget _buildSwipeView(){

    // If the provider has fetched elements so that the main function in _buildSupabaseDiscounts
    // is not called, we still need to add the ids to the array to display the banners.
    for(var discount in discountsToDisplay){
      if(!fetchedContentProvider.getFetchedBannerImageIds().contains(discount.getBannerId())){
        fetchedContentProvider.addFetchedBannerImageId(discount.getBannerId());
      }
    }

    return GestureDetector(
      child: Container(
          color: Colors.transparent,
          child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  SizedBox(
                      height: screenHeight*0.62,
                      child: PageView(
                        controller: _pageViewController,
                        onPageChanged: _handlePageViewChanged,
                        children: <Widget>[

                          for(var discount in discountsToDisplay)
                            Center(
                                child: CouponCardClub(
                                  clubMeDiscount: discount,
                                  isLiked: checkIfIsLiked(discount),
                                  clickedOnShare: clickedOnShare,
                                  clickedOnLike: clickedOnLike,
                                  isEditable: true,
                                )
                            ),
                        ],
                      )
                  ),
                ],
              )
          )
      ),
      onTap: (){
        setState(() {
          isSearchbarActive = false;
        });
      },
      onVerticalDragStart: (DragStartDetails){
        setState(() {
          isSearchbarActive = false;
        });
      },
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
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
          surfaceTintColor: customStyleClass.backgroundColorMain,
          automaticallyImplyLeading: false,
          backgroundColor: customStyleClass.backgroundColorMain,
          title: _buildAppBarShowTitle()
      ),
      body: Container(
          color: customStyleClass.backgroundColorMain,
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [

                _buildSwipeView(),

                // Progress marker
                if(discountsToDisplay.isNotEmpty)
                  Container(
                    height: screenHeight*0.7,
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_left_sharp,
                          size: 50,
                          color: _currentPageIndex > 0 ? customStyleClass.primeColor: Colors.grey,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right_sharp,
                          size: 50,
                          color: _currentPageIndex < (discountsToDisplay.length-1) ? customStyleClass.primeColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),

              ],
            )
        ),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }
}
