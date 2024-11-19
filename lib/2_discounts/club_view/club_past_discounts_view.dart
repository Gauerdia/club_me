import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/discount.dart';
import '../../models/hive_models/2_club_me_discount.dart';
import '../../models/hive_models/7_days.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import 'package:intl/intl.dart';

import '../../provider/user_data_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';

import '../../shared/dialogs/TitleAndContentDialog.dart';
import 'components/coupon_card_club.dart';
import 'components/discount_tile.dart';
import 'package:collection/collection.dart';

class ClubPastDiscountsView extends StatefulWidget {
  const ClubPastDiscountsView({Key? key}) : super(key: key);

  @override
  State<ClubPastDiscountsView> createState() => _ClubPastDiscountsViewState();
}

class _ClubPastDiscountsViewState extends State<ClubPastDiscountsView>
    with TickerProviderStateMixin{

  String headline = "Vergangene Coupons";

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  List<ClubMeDiscount> pastDbDiscounts = [];
  List<ClubMeDiscount> discountsToDisplay = [];

  bool isSearchbarActive = false;
  String searchValue = "";
  int _currentPageIndex = 0;
  late TabController _tabController;
  late PageController _pageViewController;

  final SupabaseService _supabaseService = SupabaseService();


  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);


    filterFetchedDiscounts();

  }


  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      surfaceTintColor: Colors.black,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      title: SizedBox(
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
                        color: Colors.white,
                        // size: 20,
                      ),
                    )
                  ],
                )
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildMainView(){

    return Container(
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
                    InkWell(
                      child: Icon(
                        Icons.keyboard_arrow_left_sharp,
                        size: customStyleClass.navigationArrowSize,
                        color: _currentPageIndex > 0 ? customStyleClass.primeColor: Colors.grey,
                      ),
                      onTap: () => deiterateView(),
                    ),
                    InkWell(
                      child: Icon(
                        Icons.keyboard_arrow_right_sharp,
                        size: customStyleClass.navigationArrowSize,
                        color: _currentPageIndex < (discountsToDisplay.length-1) ? customStyleClass.primeColor: Colors.grey,
                      ),
                      onTap: () => iterateView(),
                    ),
                  ],
                ),
              ),
          ],
        )
    );
  }
  Widget _buildSwipeView(){

    // If the provider has fetched elements so that the main function in _buildSupabaseDiscounts
    // is not called, we still need to add the ids to the array to display the banners.
    for(var discount in discountsToDisplay){
      if(!fetchedContentProvider.getFetchedBannerImageIds().contains(discount.getBigBannerFileName())){
        fetchedContentProvider.addFetchedBannerImageId(discount.getBigBannerFileName());
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
                                  clickedOnShare: clickEventShare,
                                  clickedOnLike: clickEventLike,
                                  isEditable: false,
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


  // CLICK EVENT
  void clickEventShare(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => TitleAndContentDialog(
            titleToDisplay: "Event teilen", contentToDisplay: "Die Funktion, ein Event zu teilen, ist derzeit noch"
            "nicht implementiert. Wir bitten um Verständnis."));
  }
  void clickEventLike(String input){

  }
  void clickEventTile(){
    // TODO: Implement click event
  }


  // MISC
  void filterFetchedDiscounts(){

    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    for(var discount in fetchedContentProvider.getFetchedDiscounts()){

      if(!checkIfIsUpcomingDiscount(discount)){
        discountsToDisplay.add(discount);
      }

      // // local var to shorten the expressions
      // DateTime discountTimestamp = discount.getDiscountDate();
      //
      // // Sort the discounts into the correct arrays
      // if(!discountTimestamp.isAfter(stateProvider.getBerlinTime())){
      //
      //   discountsToDisplay.add(discount);
      // }
    }

    discountsToDisplay.sort(
        (a,b) => b.getDiscountDate().compareTo(a.getDiscountDate())
    );

    _tabController = TabController(length: discountsToDisplay.length, vsync: this);
  }
  bool checkIfIsLiked(ClubMeDiscount discount){
    return false;
  }
  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  bool checkIfIsUpcomingDiscount(ClubMeDiscount currentDiscount){

    stateProvider = Provider.of<StateProvider>(context, listen: false);
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    Days? clubOpeningTimesForThisDay;
    DateTime closingHourToCompare;

    // Assumption: Every event starting before 6 is considered to be an event of
    // the previous day.
    var eventWeekDay = currentDiscount.getDiscountDate().hour <= 5 ?
    currentDiscount.getDiscountDate().weekday -1 :
    currentDiscount.getDiscountDate().weekday;

    // Get regular opening times
    try{
      // first where is enough because we assume that there is only one regular time each day.
      clubOpeningTimesForThisDay = userDataProvider.getUserClub().getOpeningTimes().days?.firstWhereOrNull(
              (days) => days.day == eventWeekDay);
    }catch(e){
      print("ClubCouponView. Error in checkIfUpcomingEvent, clubOpeningTimesForThisDay: $e");
      clubOpeningTimesForThisDay = null;
    }


    // Easiest case: There is a time limit
    if(currentDiscount.getHasTimeLimit()){

      closingHourToCompare = DateTime(
        currentDiscount.getDiscountDate().year,
        currentDiscount.getDiscountDate().month,
        currentDiscount.getDiscountDate().day,
        currentDiscount.getDiscountDate().hour,
        currentDiscount.getDiscountDate().minute,
      );

      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;

    }


    // Second case: There are regular opening times but no time limi
    if(clubOpeningTimesForThisDay != null){

      closingHourToCompare = DateTime(
          currentDiscount.getDiscountDate().year,
          currentDiscount.getDiscountDate().month,
          currentDiscount.getDiscountDate().day+1,
          clubOpeningTimesForThisDay.closingHour!,
          clubOpeningTimesForThisDay.closingHalfAnHour == 1 ? 30 :
          clubOpeningTimesForThisDay.closingHalfAnHour == 2 ? 59 : 0
      );

      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;
    }

    // third case: No regular opening times, no time limit
    if(!currentDiscount.getHasTimeLimit() && clubOpeningTimesForThisDay == null){
      closingHourToCompare = DateTime(
        currentDiscount.getDiscountDate().year,
        currentDiscount.getDiscountDate().month,
        currentDiscount.getDiscountDate().day,
        currentDiscount.getDiscountDate().hour+6,
        currentDiscount.getDiscountDate().minute,
      );

      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;

    }

    // If the code proceeded until this point and has not returned nothing yet,
    // we have an odd case and shouldn't display anything.
    _supabaseService.createErrorLog(
        "ClubCouponsView. Fct: checkIfUpcomingEvent. Reached last else. Is not supposed to happen.");
    return false;
  }

  void iterateView(){
    if(_currentPageIndex < (discountsToDisplay.length-1)){
      setState(() {
        _pageViewController.animateToPage( _currentPageIndex+1, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
      });
    }

  }
  void deiterateView(){
    if(_currentPageIndex > 0 ){
      setState(() {
        _pageViewController.animateToPage(  _currentPageIndex-1, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
      });
    }
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

      appBar: _buildAppBar(),
      body: _buildMainView(),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }
}
