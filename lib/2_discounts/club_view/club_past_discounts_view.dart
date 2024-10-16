import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/discount.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import 'package:intl/intl.dart';

import '../../provider/user_data_provider.dart';
import '../../shared/custom_text_style.dart';

import '../../shared/dialogs/TitleAndContentDialog.dart';
import 'components/coupon_card_club.dart';
import 'components/discount_tile.dart';


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
                        color: Colors.grey,
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
                    Icon(
                      Icons.keyboard_arrow_left_sharp,
                      size: customStyleClass.navigationArrowSize,
                      color: _currentPageIndex > 0 ? customStyleClass.primeColor: Colors.grey,
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_sharp,
                      size: customStyleClass.navigationArrowSize,
                      color: _currentPageIndex < (discountsToDisplay.length-1) ? customStyleClass.primeColor: Colors.grey,
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

      // local var to shorten the expressions
      DateTime discountTimestamp = discount.getDiscountDate();

      // Sort the discounts into the correct arrays
      if(!discountTimestamp.isAfter(stateProvider.getBerlinTime())){

        discountsToDisplay.add(discount);
      }
    }
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
