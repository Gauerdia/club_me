import 'dart:io';
import 'package:club_me/models/discount.dart';
import 'package:club_me/models/hive_models/5_club_me_used_discount.dart';
import 'package:club_me/models/parser/local_discount_to_discount_parser.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../models/hive_models/2_club_me_local_discount.dart';
import '../../models/parser/club_me_discount_parser.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar.dart';
import '../../shared/custom_text_style.dart';
import '../../utils/utils.dart';
import 'components/coupon_card.dart';
import 'package:intl/intl.dart';

class UserCouponsView extends StatefulWidget {
  const UserCouponsView({Key? key}) : super(key: key);

  @override
  State<UserCouponsView> createState() => _UserCouponsViewState();
}

class _UserCouponsViewState extends State<UserCouponsView>
    with TickerProviderStateMixin{

  var log = Logger();

  String headline = "Coupons";
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  late FetchedContentProvider fetchedContentProvider;
  late Future getDiscounts;
  late StateProvider stateProvider;
  late TabController _tabController;
  late CustomStyleClass customStyleClass;
  late PageController _pageViewController;
  late double screenWidth, screenHeight;
  late UserDataProvider userDataProvider;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();

  final TextEditingController _textEditingController = TextEditingController();

  bool dbFetchComplete = false;
  bool isSearchActive = false;
  bool onlyFavoritesIsActive = false;

  String searchValue = "";
  int _currentPageIndex = 0;

  // A dynamic array that considers all filters.
  List<ClubMeDiscount> discountsToDisplay = [];

  bool processingComplete = false;


  // INIT
  @override
  void initState() {
    super.initState();

    // Controllers for the swipe view
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    _hiveService.getUsedDiscounts().then(
            (usedDiscounts) => fetchedContentProvider.setUsedDiscounts(usedDiscounts)
    );

    // Get and process data
    if(fetchedContentProvider.getFetchedDiscounts().isEmpty) {
      fetchLocalDiscountsFromHive();
      _supabaseService.getAllDiscounts().then((data) => processDiscountsFromQuery(data));
    }else{
      processDiscountsFromProvider(fetchedContentProvider);
      _tabController = TabController(length:fetchedContentProvider.getFetchedDiscounts().length, vsync: this);
    }

    // Fetch from db or from provider
    getAllLikedDiscounts();

  }
  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  void initGeneralSettings(){
    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

  }


  // BUILD
  Widget _buildSwipeView(){

    // If the provider has fetched elements so that the main function in _buildSupabaseDiscounts
    // is not called, we still need to add the ids to the array to display the banners.
    for(var discount in discountsToDisplay){
      if(!fetchedContentProvider.getFetchedBannerImageIds().contains(discount.getBigBannerFileName())){
        // fetchedContentProvider.addFetchedBannerImageId(discount.getBigBannerFileName());
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
                                child: CouponCard(
                                  clubMeDiscount: discount,
                                  isLiked: checkIfIsLiked(discount),
                                  clickedOnShare: clickEventShare,
                                  clickedOnLike: clickEventLike,
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
          isSearchActive = false;
        });
      },
      onVerticalDragStart: (DragStartDetails){
        setState(() {
          isSearchActive = false;
        });
      },
    );
  }
  AppBar _buildAppBarWithSearch(){
    return AppBar(
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title: TextField(
        autofocus: true,
        controller: _textEditingController,
        onChanged: (text){
          _textEditingController.text = text;
          searchValue = text;
          setState(() {
            filterDiscounts();
          });
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: customStyleClass.primeColor),
          ),
          hintStyle: TextStyle(
              color: customStyleClass.primeColor
          ),
        ),
        style: const TextStyle(
            color: Colors.white
        ),
        cursorColor: customStyleClass.primeColor,
      ),
      leading:GestureDetector(
        child: Icon(
          Icons.search,
          color: searchValue != "" ? customStyleClass.primeColor : Colors.white,
          // size: 20,
        ),
        onTap: () => toggleIsSearchActive(),
      ),
      actions: [
        IconButton(
            onPressed: () => filterForFavorites(),
            icon: Icon(
              onlyFavoritesIsActive ? Icons.star : Icons.star_border,
              color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.white,
            )
        )
      ],
    );
  }
  AppBar _buildAppBarWithTitle(){
    return AppBar(
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title: Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Text(
                                headline,
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyleHeadline1Bold()
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 15
                              ),
                              child: Text(
                                "VIP",
                                style: customStyleClass.getFontStyleVIPGold(),
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                )
            ),


            Container(
              alignment: Alignment.centerLeft,
              width: screenWidth,
              height: 50,
              child: IconButton(
                  onPressed: () => toggleIsSearchActive(),
                  icon: Icon(
                    Icons.search,
                    color: searchValue != "" ? customStyleClass.primeColor : Colors.white,
                    // size: 20,
                  )
              )
            ),

            Container(
              width: screenWidth,
              height: 50,
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () => filterForFavorites(),
                  icon: Icon(
                    onlyFavoritesIsActive ? Icons.star : Icons.star_border,
                    color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.white,
                  )
              )
            )

          ],
        ),
      ),
    );
  }
  Widget _buildNothingToDisplay(){

    return isSearchActive ?
    SizedBox(
      width: screenWidth,
      height: screenHeight*0.8,
      child: Center(
        child: Text(
          textAlign: TextAlign.center,
          Utils.noDiscountElementsDueToFilter,
          style: customStyleClass.getFontStyle3(),
        ),
      ),
    ):  onlyFavoritesIsActive ?
    SizedBox(
      width: screenWidth,
      height: screenHeight*0.8,
      child: Center(
        child: Text(
          textAlign: TextAlign.center,
          Utils.noDiscountElementsDueToNoFavorites,
          style: customStyleClass.getFontStyle3(),
        ),
      ),
    ): processingComplete ?
    SizedBox(
      width: screenWidth,
      height: screenHeight*0.8,
      child: Center(
        child: Text(
          textAlign: TextAlign.center,
          Utils.noDiscountElementsDueToNothingOnTheServer,
          style: customStyleClass.getFontStyle3(),
        ),
      ),
    ):SizedBox(
      width: screenWidth,
      height: screenHeight*0.8,
      child: Center(
        child: CircularProgressIndicator(
          color: customStyleClass.primeColor,
        ),
      ),
    );


    //   GestureDetector(
    //   child: SizedBox(
    //     width: screenWidth,
    //     height: screenHeight*0.7,
    //     child: Center(
    //       child: Text(
    //         onlyFavoritesIsActive ?
    //         "Derzeit sind keine Coupons als Favoriten markiert." :
    //         "Derzeit sind leider keine Coupons verfügbar.",
    //         style: customStyleClass.getFontStyle3(),
    //       ),
    //     ),
    //   ),
    //   onTap: (){
    //     setState(() {
    //       isSearchbarActive = false;
    //     });
    //   },
    //   onVerticalDragStart: (DragStartDetails){
    //     setState(() {
    //       isSearchbarActive = false;
    //     });
    //   },
    // );
  }


  // PROCESS
  void processDiscountsFromQuery(var data){

    for(var element in data){

      ClubMeDiscount currentDiscount = parseClubMeDiscount(element);

      if(checkIfIsUpcomingDiscount(currentDiscount)){
        if(!fetchedContentProvider.getFetchedDiscounts().contains(currentDiscount) &&
           !checkIfAnyRestrictionsApply(currentDiscount)){
          fetchedContentProvider.addDiscountToFetchedDiscounts(currentDiscount);
        }
      }
    }

    _tabController = TabController(length:fetchedContentProvider.getFetchedDiscounts().length, vsync: this);

    // Check if we need to download the corresponding images
    _checkAndFetchService.checkAndFetchDiscountImages(
        fetchedContentProvider.getFetchedDiscounts(),
        stateProvider,
        fetchedContentProvider
    );


  }
  void processDiscountsFromProvider(FetchedContentProvider fetchedContentProvider){
    // Events in the provider ought to have all images fetched, already. So, we just sort.
    // checkDiscountsForRestrictions(fetchedContentProvider.getFetchedDiscounts());
    setState(() {
      processingComplete = true;
    });
  }
  void processDiscountsFromHive(var data){

    for(ClubMeLocalDiscount currentLocalDiscount in data){

      ClubMeDiscount currentDiscount = localDiscountToDiscountParser(currentLocalDiscount);

      // If the user didn't open the app for some time, some discounts might
      // be expired. To check this, we get the current date
      if(checkIfIsUpcomingDiscount(currentDiscount)){
        if(!fetchedContentProvider.getFetchedDiscounts().contains(currentDiscount)){
          fetchedContentProvider.addDiscountToFetchedDiscounts(currentDiscount);
          discountsToDisplay.add(currentDiscount);
        }
      }else{
        // Cleanse, if not applicable anymore
        _hiveService.deleteLocalDiscount(currentDiscount.discountId);
      }

    }

    // Check if we need to download the corresponding images
    _checkAndFetchService.checkAndFetchDiscountImages(
        fetchedContentProvider.getFetchedDiscounts(),
        stateProvider,
        fetchedContentProvider
    );

    setState(() {
      processingComplete = true;
    });

  }


  // CLICKED
  toggleIsSearchActive(){
    setState(() {
      isSearchActive = !isSearchActive;
    });
  }
  void clickEventShare(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            TitleAndContentDialog(
                titleToDisplay: "Event teilen",
                contentToDisplay: "Die Funktion, ein Event zu teilen, ist derzeit noch "
                    "nicht implementiert. Wir bitten um Verständnis.")
    );
  }
  void clickEventLike(String discountId){
    setState(() {
      if(currentAndLikedElementsProvider.getLikedDiscounts().contains(discountId)){
        currentAndLikedElementsProvider.deleteLikedDiscount(discountId);
        _hiveService.deleteFavoriteDiscount(discountId);
      }else{
        currentAndLikedElementsProvider.addLikedDiscount(discountId);
        _hiveService.insertFavoriteDiscount(discountId);
      }
    });
  }


  // FETCH AND BUILD
  void getAllLikedDiscounts() async{
    var likedEvents = await _hiveService.getFavoriteDiscounts();
    currentAndLikedElementsProvider.setLikedDiscounts(likedEvents);
  }


  // FILTER
  void filterDiscounts(){

    // Check if we need any filtering at all
    if(searchValue != "" || onlyFavoritesIsActive){

      // Allocate space
      List<ClubMeDiscount> favoritesToDisplay = [];
      discountsToDisplay = [];

      // Fetch favorites
      for(var discount in fetchedContentProvider.getFetchedDiscounts()){
        if(checkIfIsLiked(discount)){
          favoritesToDisplay.add(discount);
        }
      }

      // Check, if we are using the search bar
      if(searchValue != ""){

        // Check if we have to combine favorites and search
        if(onlyFavoritesIsActive){
          for(var discount in favoritesToDisplay){

            String allInformationLowerCase = "${discount.getDiscountTitle()} ${discount
                .getClubName()}".toLowerCase();

            if (allInformationLowerCase.contains(
                searchValue.toLowerCase())) {
              discountsToDisplay.add(discount);
            }
          }
          // If not: Fill the other array
        }else{
          for(var discount in fetchedContentProvider.getFetchedDiscounts()){

            String allInformationLowerCase = "${discount.getDiscountTitle()} ${discount
                .getClubName()}".toLowerCase();

            if (allInformationLowerCase.contains(
                searchValue.toLowerCase())) {
              discountsToDisplay.add(discount);
            }
          }
        }

        // If we are only looking for fav's we are done
      }else{
        discountsToDisplay = favoritesToDisplay;
      }
      // If no fav's and no search results are wanted, we are done already
    }else{
      discountsToDisplay = fetchedContentProvider.getFetchedDiscounts();
    }

    discountsToDisplay.sort((a,b) => b.priorityScore.compareTo(a.priorityScore));

  }
  void filterForFavorites(){
    setState(() {
      onlyFavoritesIsActive = !onlyFavoritesIsActive;
      filterDiscounts();
    });
  }
  void fetchLocalDiscountsFromHive() async{

      try{
        _hiveService.getAllLocalDiscounts().then((data) => processDiscountsFromHive(data));
        // If db-fetching takes a moment, we want to display the current state.
        setState(() {});
      }catch(e){
        print("Error in fetchLocalDiscountsFromHive: $e");
      }
  }


  // MISC
  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }


  // CHECK
  bool checkIfIsLiked(ClubMeDiscount currentDiscount) {
    var isLiked = false;
    if (currentAndLikedElementsProvider.getLikedDiscounts().contains(
        currentDiscount.getDiscountId())) {
      isLiked = true;
    }
    return isLiked;
  }
  bool checkIfDiscountIsAlreadyPresent(ClubMeDiscount clubMeDiscount){

    for(var element in fetchedContentProvider.getFetchedDiscounts()){

      // Check, if there is one with the same id
      if(element.discountId == clubMeDiscount.discountId){

        // Maybe a field changed? We have to update the element
        if(element != clubMeDiscount){
          fetchedContentProvider.updateSpecificDiscount(clubMeDiscount.getDiscountId(), clubMeDiscount);
          _hiveService.updateLocalDiscount(element);
        }
        return true;
      }
    }
    return false;
  }
  bool checkIfAnyRestrictionsApply(ClubMeDiscount currentDiscount) {

    print("Test: ${currentDiscount.getDiscountId()}");

      int userAge = userDataProvider.getUserData().getUserAge();

      if(currentDiscount.getTargetGender() != 0 &&
          currentDiscount.getTargetGender() != userDataProvider.getUserData().getGender()){
        return true;
      }

      // age limit
      if(currentDiscount.hasAgeLimit){
        if(currentDiscount.getAgeLimitLowerLimit() > userAge ||
            currentDiscount.getAgeLimitUpperLimit() < userAge){
          return true;
        }
      }

      // usage limit
      if(currentDiscount.hasUsageLimit){

        if(fetchedContentProvider.getUsedDiscounts().where((element) => element.discountId
                == currentDiscount.getDiscountId()).length >= currentDiscount.getNumberOfUsages()
        ){
          return true;
        }

      }

      if(
      currentDiscount.hasTimeLimit &&
          !currentDiscount.getDiscountDate().isAfter(stateProvider.getBerlinTime())
      ){
        return true;
      }


      return false;
  }
  bool checkIfIsUpcomingDiscount(ClubMeDiscount currentDiscount){

    // We are only interested in the upcoming events. Here, we sort for them
    if(currentDiscount.getDiscountDate().isAfter(stateProvider.getBerlinTime()) ||
        currentDiscount.getDiscountDate().isAtSameMomentAs(stateProvider.getBerlinTime())){
      return true;
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {


    initGeneralSettings();

    // If no discounts fulfill the filters, check if that's still the case
    if(discountsToDisplay.isEmpty){
      filterDiscounts();
    }



    return Scaffold(

        extendBody: true,
        resizeToAvoidBottomInset: false,

        bottomNavigationBar: CustomBottomNavigationBar(),
        appBar: isSearchActive ?
        _buildAppBarWithSearch():
        _buildAppBarWithTitle(),
        body: Container(
          width: screenWidth,
          height: screenHeight,
          color: customStyleClass.backgroundColorMain,
          child: Column(
            children: [

              // Spacer
              SizedBox(height: screenHeight*0.05,),

              discountsToDisplay.isNotEmpty ?
                _buildSwipeView() :
                _buildNothingToDisplay(),


              // Page arrows
              if(discountsToDisplay.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_left_sharp,
                      size: customStyleClass.navigationArrowSize,
                      color: _currentPageIndex > 0 ? customStyleClass.primeColor : Colors.grey,
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_sharp,
                      size: customStyleClass.navigationArrowSize,
                      color: _currentPageIndex < (discountsToDisplay.length-1) ? customStyleClass.primeColor : Colors.grey,
                    ),
                  ],
                ),
            ],
          )
        )
    );
  }
}


