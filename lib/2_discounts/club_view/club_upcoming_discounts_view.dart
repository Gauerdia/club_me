import 'package:club_me/2_discounts/club_view/components/coupon_card_club.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/discount.dart';
import '../../models/hive_models/2_club_me_discount.dart';
import '../../models/hive_models/7_days.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';
import 'package:collection/collection.dart';
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
  final SupabaseService _supabaseService = SupabaseService();

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

      if(checkIfIsUpcomingDiscount(discount)){
        discountsToDisplay.add(discount);
      }

      _tabController = TabController(length: discountsToDisplay.length, vsync: this);

      // // local var to shorten the expressions
      // DateTime discountTimestamp = discount.getDiscountDate();
      //
      // // Sort the discounts into the correct arrays
      // if(discountTimestamp.isAfter(stateProvider.getBerlinTime()) || discountTimestamp.isAtSameMomentAs(stateProvider.getBerlinTime())){
      //
      //     discountsToDisplay.add(discount);
      // }
    }
  }




  // CLICK EVENT
  void clickEventTile(){
    // TODO: Implement click event
  }
  bool checkIfIsLiked(ClubMeDiscount discount){
    return false;
  }
  void clickEventShare(){

  }
  void clickEventLike(String input){

  }

  // BUILD
  AppBar _buildAppBar(){

    return AppBar(
        surfaceTintColor: customStyleClass.backgroundColorMain,
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        title: Container(
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
                          color: Colors.white,
                        ),
                      )
                    ],
                  )
              ),

            ],
          ),
        )
    );
  }

  Widget _buildMainView(){

    var fetchedUpcomingDiscounts = fetchedContentProvider.getFetchedUpcomingDiscounts(userDataProvider.getUserClubId());

    return Container(
        color: customStyleClass.backgroundColorMain,
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [

            _buildSwipeView(),

            // Progress marker
            if(fetchedUpcomingDiscounts.isNotEmpty)
              Container(
                height: screenHeight*0.7,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_left_sharp,
                      size: customStyleClass.navigationArrowSize,
                      color: _currentPageIndex > 0 ? customStyleClass.primeColor: Colors.grey,
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_sharp,
                      size: customStyleClass.navigationArrowSize,
                      color: _currentPageIndex < (fetchedUpcomingDiscounts.length-1) ? customStyleClass.primeColor: Colors.grey,
                    ),
                  ],
                ),
              ),

          ],
        )
    );
  }

  Widget _buildSwipeView(){

    List<ClubMeDiscount> fetchedUpcomingDiscounts = fetchedContentProvider.getFetchedUpcomingDiscounts(
        userDataProvider.getUserClubId()
    );

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

                          for(var discount in fetchedUpcomingDiscounts)
                            Center(
                                child: CouponCardClub(
                                  clubMeDiscount: discount,
                                  isLiked: checkIfIsLiked(discount),
                                  clickedOnShare: clickEventShare,
                                  clickedOnLike: clickEventLike,
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


  bool checkIfIsUpcomingDiscount(ClubMeDiscount currentDiscount){

    stateProvider = Provider.of<StateProvider>(context, listen: false);
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    Days? clubOpeningTimesForThisDay;
    DateTime closingHourToCompare;

    // Assumption: Every event starting before 6 is considered to be an event of
    // the previous day.
    var eventWeekDay = currentDiscount.getDiscountDate().hour <= 6 ?
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
          currentDiscount.getDiscountDate().day,
          clubOpeningTimesForThisDay.closingHour!,
          clubOpeningTimesForThisDay.closingHalfAnHour == 1 ? 30 :
          clubOpeningTimesForThisDay.closingHalfAnHour == 2 ? 59 : 0
      );

      // Do this instead of day+1 because otherwise it might bug at the last day of a month
      if(clubOpeningTimesForThisDay.closingHour! < currentDiscount.getDiscountDate().hour){
        closingHourToCompare.add(const Duration(days: 1));
      }

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
        currentDiscount.getDiscountDate().hour,
        currentDiscount.getDiscountDate().minute,
      );
      // There is no time limit, we show for 6 hours after start
      closingHourToCompare.add(const Duration(hours: 6));

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

      appBar: _buildAppBar(),
      body: _buildMainView(),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }
}
