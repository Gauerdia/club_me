import 'package:club_me/2_discounts/club_view/components/coupon_card_club.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/discount.dart';
import '../../models/hive_models/2_club_me_discount.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../shared/custom_text_style.dart';



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
