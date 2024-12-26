import 'package:club_me/models/club.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../models/hive_models/2_club_me_discount.dart';
import '../../models/hive_models/7_days.dart';
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

class UserCouponsView extends StatefulWidget {
  const UserCouponsView({Key? key}) : super(key: key);

  @override
  State<UserCouponsView> createState() => _UserCouponsViewState();
}

class _UserCouponsViewState extends State<UserCouponsView>
    with TickerProviderStateMixin{

  var log = Logger();

  String headline = "Angebote";


  late Future getDiscounts;
  late StateProvider stateProvider;
  late TabController _tabController;
  late double screenWidth, screenHeight;
  late UserDataProvider userDataProvider;
  late CustomStyleClass customStyleClass;
  late PageController _pageViewController;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();
  final TextEditingController _textEditingController = TextEditingController();

  bool showVIP = false;
  bool isSearchActive = false;
  bool dbFetchComplete = false;
  bool isFilterMenuActive = false;
  bool processingComplete = false;
  bool onlyFavoritesIsActive = false;

  String searchValue = "";
  int _currentPageIndex = 0;

  // A dynamic array that considers all filters.
  List<ClubMeDiscount> discountsToDisplay = [];

  late String offerTypeValue;

  // INIT
  @override
  void initState() {
    super.initState();

    // Controllers for the swipe view
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    offerTypeValue = Utils.offerTypeFiltering.first;

    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    _hiveService.getUsedDiscounts().then(
            (usedDiscounts) => fetchedContentProvider.setUsedDiscounts(usedDiscounts)
    );

    // Get and process data
    if(fetchedContentProvider.getFetchedDiscounts().isEmpty) {
      _hiveService.getAllLocalDiscounts().then((data){
                processDiscountsFromHive(data);
                _supabaseService.getAllDiscountsFromYesterday().then(
                        (data) => processDiscountsFromQuery(data)
                );
      });

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
  AppBar _buildAppBar(){

    return AppBar(
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title: Container(
        width: screenWidth,
        child: Stack(
          children: [

            // Headline
            if(!isSearchActive)
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
                              if(showVIP)
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

            if(isSearchActive)
              Container(
                alignment: Alignment.bottomCenter,
                height: 50,
                width: screenWidth,
                child: SizedBox(
                  width: screenWidth*0.65,
                  child: TextField(
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
                ),
              ),

            // ICON: SEARCH
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

            // ICONS: FAV, FILTER
            Container(
                width: screenWidth,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    IconButton(
                        onPressed: () => filterForFavorites(),
                        icon: Icon(
                          onlyFavoritesIsActive ? Icons.star : Icons.star_border,
                          color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.white,
                        )
                    ),

                    InkWell(
                      child: Icon(
                        Icons.filter_alt_outlined,
                        color: isFilterMenuActive || offerTypeValue != Utils.offerTypeFiltering.first ?
                        customStyleClass.primeColor : Colors.white,
                      ),
                      onTap: () => clickEventShowFilterMenu(),
                    ),

                  ],
                )
            )

          ],
        ),
      ),
    );
  }
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

  Widget _buildMainView(){
    return Container(
        width: screenWidth,
        height: screenHeight,
        color: customStyleClass.backgroundColorMain,
        child: Stack(
          children: [

            Column(
              children: [

                // Spacer
                SizedBox(height: screenHeight*0.05,),

                // Swipe View
                discountsToDisplay.isNotEmpty ?
                _buildSwipeView() :
                _buildNothingToDisplay(),

                // Page arrows
                if(discountsToDisplay.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.keyboard_arrow_left_sharp,
                          size: customStyleClass.navigationArrowSize,
                          color: _currentPageIndex > 0 ? customStyleClass.primeColor : Colors.grey,
                        ),
                        onTap: () => clickEventDeiterateView(),
                      ),
                      InkWell(
                        child: Icon(
                          Icons.keyboard_arrow_right_sharp,
                          size: customStyleClass.navigationArrowSize,
                          color: _currentPageIndex < (discountsToDisplay.length-1) ? customStyleClass.primeColor : Colors.grey,
                        ),
                        onTap: () => clickEventIterateView(),
                      ),
                    ],
                  ),
              ],
            ),

            if(isFilterMenuActive)
              _buildFilterMenu(),

            // if(isFilterMenuActive)
            //   GestureDetector(
            //     child: Container(
            //       color: Colors.transparent,
            //       width: screenWidth,
            //       height: screenHeight,
            //     ),
            //     onTap: () => setState(() {isFilterMenuActive = false;}),
            //     onHorizontalDragDown: (DragDownDetails details) => setState(() {isFilterMenuActive = false;}),
            //   )

          ],
        )
    );
  }

  Widget _buildFilterMenu(){
    return Container(
      padding: EdgeInsets.only(
          top: screenHeight*0.02
      ),
      decoration: BoxDecoration(
          color: customStyleClass.backgroundColorMain,
          border: Border(
              bottom: BorderSide(
                  color: Colors.grey[900]!,
                  width: 1
              )
          )
      ),
      height: 110,
      width: screenWidth,

      child: Row(
        children: [

          SizedBox(
            width: screenWidth,
            child: Column(
              children: [

                // Genre
                SizedBox(
                  // width: screenWidth*0.5,
                  child: Text(
                    "Angebotstyp",
                    textAlign: TextAlign.left,
                    style: customStyleClass.getFontStyle3(),
                  ),
                ),

                // Dropdown
                Theme(
                    data: Theme.of(context).copyWith(
                        canvasColor: customStyleClass.backgroundColorMain
                    ),
                    child: DropdownMenu<String>(
                      width: screenWidth*0.5,
                      initialSelection: offerTypeValue,
                      onSelected: (String? value){
                        setState(() {
                          offerTypeValue = value!;
                          filterDiscounts();
                        });
                      },
                      textStyle: const TextStyle(
                          color: Colors.white
                      ),
                      menuStyle: MenuStyle(
                        surfaceTintColor: WidgetStateProperty.all<Color>(customStyleClass.backgroundColorEventTile),
                        backgroundColor: WidgetStateProperty.all<Color>(customStyleClass.backgroundColorEventTile),
                        alignment: Alignment.bottomLeft,
                        maximumSize: const WidgetStatePropertyAll(
                          Size.fromHeight(300),
                        ),
                      ),
                      dropdownMenuEntries: Utils.offerTypeFiltering
                          .map<DropdownMenuEntry<String>>((String value){
                        return DropdownMenuEntry(
                            value: value,
                            label: value,
                            style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.white)
                            )
                        );
                      }).toList(),
                    )
                )
              ],
            ),
          ),

        ],
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
  }


  // PROCESS
  void processDiscountsFromQuery(var data){

    for(var element in data){

      ClubMeDiscount currentDiscount = parseClubMeDiscount(element);


      // Accessing as dev: Just push it through. Otherwise, check for toggle
      if(stateProvider.getUsingTheAppAsADeveloper()){

        if(checkIfIsUpcomingDiscount(currentDiscount)){
          if(!fetchedContentProvider.getFetchedDiscounts().contains(currentDiscount) &&
              !checkIfAnyRestrictionsApply(currentDiscount)){
            fetchedContentProvider.addDiscountToFetchedDiscounts(currentDiscount);
          }
        }

      }else if(!fetchedContentProvider.getFetchedDiscounts().contains(currentDiscount) && currentDiscount.getShowDiscountInApp()){
        if(checkIfIsUpcomingDiscount(currentDiscount)){
          if(!fetchedContentProvider.getFetchedDiscounts().contains(currentDiscount) &&
              !checkIfAnyRestrictionsApply(currentDiscount)){
            fetchedContentProvider.addDiscountToFetchedDiscounts(currentDiscount);
          }
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

    // If the gender changes, we need to take that into consideration
    filterDiscounts();

    setState(() {

    });

  }
  void processDiscountsFromProvider(FetchedContentProvider fetchedContentProvider){
    // Events in the provider ought to have all images fetched, already. So, we just sort.
    // checkDiscountsForRestrictions(fetchedContentProvider.getFetchedDiscounts());

    // If the gender changes, we need to take that into consideration
    filterDiscounts();

    setState(() {
      processingComplete = true;
    });
  }
  void processDiscountsFromHive(var data){

    for(ClubMeDiscount currentDiscount in data){

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
  void clickEventShare(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            TitleAndContentDialog(
                titleToDisplay: "Teilen",
                contentToDisplay: "Das Teilen von Inhalten aus der App ist derzeit noch nicht möglich. Wir bitten um Entschuldigung."
            )
    );
  }
  void toggleIsSearchActive(){
    setState(() {
      isSearchActive = !isSearchActive;
    });
  }
  void clickEventIterateView(){
    if(_currentPageIndex < (discountsToDisplay.length-1)){
      setState(() {
        _pageViewController.animateToPage( _currentPageIndex+1, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
      });
    }

  }
  void clickEventDeiterateView(){
    if(_currentPageIndex > 0 ){
      setState(() {
        _pageViewController.animateToPage(  _currentPageIndex-1, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
      });
    }
  }
  void clickEventShowFilterMenu(){
    setState(() {
      isFilterMenuActive = !isFilterMenuActive;
    });
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

    fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen: false);

    // Check if we need any filtering at all
    if(
      searchValue != "" ||
      onlyFavoritesIsActive ||
      offerTypeValue != Utils.offerTypeFiltering.first
    ){

      // Get all elements available and pop one each time it doesn't fit
      // If i assign getFetchedDiscount to this array, I get the error:
      // Concurrent modification during iteration: Instance(length:20) of '_GrowableList'.
      // Maybe its because its not a copy but a pointer. So we do it like this.
      List<ClubMeDiscount> discountsAfterFiltering = [];
      for(var element in fetchedContentProvider.getFetchedDiscounts()){
        discountsAfterFiltering.add(element);
      }

      // Check for favourites
      if(onlyFavoritesIsActive){
        for(var discount in fetchedContentProvider.getFetchedDiscounts()){
          if(!checkIfIsLiked(discount)){
            discountsAfterFiltering.removeWhere((discountToCheck) => discountToCheck == discount);
          }
        }
      }

      // Check, if we are using the search bar
      if(searchValue != ""){

        for(var discount in fetchedContentProvider.getFetchedDiscounts()){

          String allInformationLowerCase = "${discount.getDiscountTitle()} ${discount
              .getClubName()}".toLowerCase();

          if (!allInformationLowerCase.contains(
              searchValue.toLowerCase())) {
            discountsAfterFiltering.removeWhere((discountToCheck) => discountToCheck == discount);
          }
        }
      }

      // Check for offer type filtering
      if(offerTypeValue != Utils.offerTypeFiltering.first){

        // Get all current discounts to filter
        for(var discount in fetchedContentProvider.getFetchedDiscounts()){

          /// TODO: Would be smoother with indices instead of text comparison
          // Depending on the filter value, we display only some discounts
          if(offerTypeValue == "Informationen"){
            if(discount.getIsRedeemable()){
              discountsAfterFiltering.removeWhere((discountToCheck) => discountToCheck == discount);
            }
          }else{
            if(!discount.getIsRedeemable()){
              discountsAfterFiltering.removeWhere((discountToCheck) => discountToCheck == discount);
            }
          }
        }
      }

      // After filtering, assign to the array to be displayed
      discountsToDisplay = discountsAfterFiltering;

    }else{

      // No filters applied? Show all the discounts
      discountsToDisplay = fetchedContentProvider.getFetchedDiscounts();
    }

    // Sort by priority
    discountsToDisplay.sort((a,b){

      DateTime firstDate = DateTime(
          a.getDiscountDate().year,
          a.getDiscountDate().month,
          a.getDiscountDate().hour < 5 ? a.getDiscountDate().day-1 : a.getDiscountDate().day);
      DateTime secondDate = DateTime(
          b.getDiscountDate().year,
          b.getDiscountDate().month,
          b.getDiscountDate().hour < 5 ? b.getDiscountDate().day-1 : b.getDiscountDate().day);

      int cmp = firstDate.compareTo(secondDate);
      if (cmp != 0) return cmp;

      if(a.getIsRedeemable() &&
          !b.getIsRedeemable()){
        return -1;
      }
      if(b.getIsRedeemable() &&
          !a.getIsRedeemable()){
        return 1;
      }

      return b.getPriorityScore().compareTo(a.getPriorityScore());

      // return b.priorityScore.compareTo(a.priorityScore);
    });

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
      isFilterMenuActive = false;
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

      int userAge = userDataProvider.getUserData().getUserAge();

      if(currentDiscount.getTargetGender() != 0 &&
          currentDiscount.getTargetGender() != userDataProvider.getUserData().getGender()
      ){
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

        int howOftenDoesTheDiscountAppearInUsedDiscounts =
            fetchedContentProvider.getUsedDiscounts().where(
                    (element) => element.discountId == currentDiscount.getDiscountId()).length;

        bool wasUsedAtLeastAsOftenAsLimit = false;

        if(howOftenDoesTheDiscountAppearInUsedDiscounts >= currentDiscount.getNumberOfUsages()){
          wasUsedAtLeastAsOftenAsLimit = true;
        }

        // print("${currentDiscount.getDiscountTitle()}: $howOftenDoesTheDiscountAppearInUsedDiscounts, ${currentDiscount.getNumberOfUsages()}, $wasUsedAtLeastAsOftenAsLimit");

        if(wasUsedAtLeastAsOftenAsLimit){
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

    Days? clubOpeningTimesForThisDay;
    DateTime closingHourToCompare;

    // If there exists a time limit and it is set for the morning hours, we have
    // to look at the day before.
    var discountWeekDay = currentDiscount.getDiscountDate().hour <= 6 ?
    currentDiscount.getDiscountDate().weekday-1 : currentDiscount.getDiscountDate().weekday;

    ClubMeClub? currentClub = fetchedContentProvider.getFetchedClubs().firstWhere(
            (club) => club.getClubId() == currentDiscount.getClubId()
    );

    // Get regular opening times
    try{
      clubOpeningTimesForThisDay = currentClub.getOpeningTimes().days?.firstWhere(
              (days) => days.day == discountWeekDay);
    }catch(e){
      print("UserEventsView. Error in checkIfUpcomingEvent, clubOpeningTimesForThisDay: $e");
      clubOpeningTimesForThisDay = null;
    }

    // Edge case 1: If it goes on for some time, we only check against the finish line
    if(currentDiscount.getLongTermEndDate() != null){

      closingHourToCompare = DateTime(
          currentDiscount.getLongTermEndDate()!.year,
          currentDiscount.getLongTermEndDate()!.month,
          currentDiscount.getLongTermEndDate()!.day,
          currentDiscount.getLongTermEndDate()!.hour,
          currentDiscount.getLongTermEndDate()!.minute
      );

      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;

    }

    // Edge case 2 : If there is a time limit, we already know exactly when to stop showing the discount
    if(currentDiscount.getHasTimeLimit()){

      closingHourToCompare = DateTime(
          currentDiscount.getDiscountDate().year,
          currentDiscount.getDiscountDate().month,
          currentDiscount.getDiscountDate().day,
          currentDiscount.getDiscountDate().hour,
          currentDiscount.getDiscountDate().minute
      );

      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;
    }

    // Check if regular opening times apply
    if(clubOpeningTimesForThisDay != null){

      closingHourToCompare = DateTime(
          currentDiscount.getDiscountDate().year,
          currentDiscount.getDiscountDate().month,
          currentDiscount.getDiscountDate().day+1,
          clubOpeningTimesForThisDay.closingHour!,
          clubOpeningTimesForThisDay.closingHalfAnHour! == 1 ? 30 :
          clubOpeningTimesForThisDay.closingHalfAnHour! == 2 ? 59 : 0
      );


      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;

    }

    // third case: No regular opening times, no time limit
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
        appBar: _buildAppBar(),
        body: _buildMainView()
    );
  }
}


