import 'package:club_me/models/discount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parser/club_me_discount_parser.dart';
import '../provider/state_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import '../shared/custom_text_style.dart';
import '../user_clubs/components/page_indicator.dart';
import 'components/coupon_card.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;

class UserCouponsView extends StatefulWidget {
  const UserCouponsView({Key? key}) : super(key: key);

  @override
  State<UserCouponsView> createState() => _UserCouponsViewState();
}

class _UserCouponsViewState extends State<UserCouponsView>
    with TickerProviderStateMixin{

  String headline = "Deine Coupons";

  late Future getDiscounts;
  late StateProvider stateProvider;
  late TabController _tabController;
  late CustomTextStyle customTextStyle;
  late PageController _pageViewController;
  late double screenWidth, screenHeight;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _textEditingController = TextEditingController();

  bool isSearchbarActive = false;
  bool onlyFavoritesIsActive = false;

  String searchValue = "";
  int _currentPageIndex = 0;

  List<ClubMeDiscount> upcomingDbDiscounts = [];
  List<ClubMeDiscount> discountsToDisplay = [];


  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    if(stateProvider.getFetchedDiscounts().isEmpty) {
      getDiscounts = _supabaseService.getAllDiscounts();
    }

  }
  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }


  // CLICKED
  toggleIsSearchActive(){
    setState(() {
      isSearchbarActive = !isSearchbarActive;
    });
  }
  void clickedOnShare(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
            title: Text("Teilen noch nicht möglich!"),
            content: Text("Die Funktion, ein Event zu teilen, ist derzeit noch"
                "nicht implementiert. Wir bitten um Verständnis.")
        )
    );
  }
  void clickedOnLike(String discountId){
    setState(() {
      if(stateProvider.getLikedDiscounts().contains(discountId)){
        stateProvider.deleteLikedDiscount(discountId);
        _hiveService.deleteFavoriteDiscount(discountId);
      }else{
        stateProvider.addLikedDiscount(discountId);
        _hiveService.insertFavoriteDiscount(discountId);
      }
    });
  }


  // FETCH AND BUILD
  void getAllLikedDiscounts() async{
    var likedEvents = await _hiveService.getFavoriteDiscounts();
    stateProvider.setLikedDiscounts(likedEvents);
  }
  Widget _buildSupabaseDiscounts(
      StateProvider stateProvider,
      double screenHeight
      ){

    return stateProvider.getFetchedDiscounts().isEmpty ?
    FutureBuilder(
        future: getDiscounts,
        builder: (context, snapshot){

          if(snapshot.hasError){
            print("Error: ${snapshot.error}");
          }

          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else{

            final data = snapshot.data!;
            //
            // List<ClubMeDiscount> discountsToDisplay = [];

            // get today in correct format to check which events are upcoming
            var todayRaw = DateTime.now();
            var today = DateFormat('yyyy-MM-dd').format(todayRaw);
            var todayFormatted = DateTime.parse(today);

            print("today:" + todayFormatted.toString());

            // The function will be called twice after the response. Here, we avoid to fill the array twice as well.
            if(upcomingDbDiscounts.isEmpty){
              for(var element in data){

                ClubMeDiscount currentDiscount = parseClubMeDiscount(element);

                print(currentDiscount.discountDate);

                // Show only events that are not yet in the past.
                if(
                currentDiscount.getDiscountDate().isAfter(todayFormatted)
                    || currentDiscount.getDiscountDate().isAtSameMomentAs(todayFormatted)){

                  // Check if any gender has been specified
                  if(currentDiscount.getTargetGender() != 0){
                   if(currentDiscount.getTargetGender() == stateProvider.getUserData().getGender()){
                     upcomingDbDiscounts.add(currentDiscount);
                   }
                  }else{
                    upcomingDbDiscounts.add(currentDiscount);
                  }
                }

                // We collect all events so we don't have to reload them every time
                stateProvider.addDiscountToFetchedDiscounts(currentDiscount);
              }

              // Sort so that the next events come up earliest
              sortUpcomingDiscounts();
              stateProvider.sortFetchedDiscounts();
            }

            discountsToDisplay = upcomingDbDiscounts;
            // stateProvider.setFetchedDiscounts(discountsToDisplay);


            return discountsToDisplay.isNotEmpty ?
            Container(
                height: screenHeight*0.615,
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
                                        clickedOnShare: clickedOnShare,
                                        clickedOnLike: clickedOnLike,
                                      )
                                  ),
                              ],
                            )
                        ),
                      ],
                    )
                )
            ) : Container(
              width: screenWidth,
              height: screenHeight,
              child: const Center(
                child: Text("Derzeit sind leider keine Coupons verfügbar.")
              ),
            );
          }
        }
    )
        : discountsToDisplay.isNotEmpty ?
    Container(
        height: screenHeight*0.615,
        color: Colors.transparent,
        child:SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              SizedBox(
                  height: screenHeight*0.62,
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageViewController,
                        onPageChanged: _handlePageViewChanged,
                        children: <Widget>[
                          for(var discount in discountsToDisplay)
                            Center(
                                child: CouponCard(
                                  clubMeDiscount: discount,
                                  isLiked: checkIfIsLiked(discount),
                                  clickedOnLike: clickedOnLike,
                                  clickedOnShare: clickedOnShare,
                                )
                            ),
                        ],
                      )
                    ],
                  )
              )
            ],
          ),
        )
    ): SizedBox(
      width: screenWidth,
      height: screenHeight*0.7,
      child: const Center(
        child: Text("Derzeit sind leider keine Coupons verfügbar."),
      ),
    );
  }
  AppBar _buildAppBarWithSearch(){
    return AppBar(
      backgroundColor: Colors.transparent,
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
      ),
      leading:GestureDetector(
        child: Icon(
          Icons.search,
          color: searchValue != "" ? stateProvider.getPrimeColor() : Colors.grey,
          // size: 20,
        ),
        onTap: () => toggleIsSearchActive(),
      ),
      actions: [
        IconButton(
            onPressed: () => filterForFavorites(),
            icon: Icon(
              Icons.stars,
              color: onlyFavoritesIsActive ? stateProvider.getPrimeColor() : Colors.grey,
            )
        )
      ],
    );
  }
  AppBar _buildAppBarWithTitle(){
    return AppBar(
      backgroundColor: Colors.transparent,
      title: SizedBox(
        width: screenWidth,
        child: Text(headline,
          textAlign: TextAlign.center,
          style: customTextStyle.size2(),
        ),
      ),
      leading: GestureDetector(
        child: Icon(
          Icons.search,
          color: searchValue != "" ? stateProvider.getPrimeColor() : Colors.grey,
          // size: 20,
        ),
        onTap: () => toggleIsSearchActive(),
      ),
      actions: [
        IconButton(
            onPressed: () => filterForFavorites(),
            icon: Icon(
              Icons.stars,
              color: onlyFavoritesIsActive ? stateProvider.getPrimeColor() : Colors.grey,
            )
        )
      ],
    );
  }


  // FILTER
  void filterDiscounts(){

    // Check if we need any filtering at all
    if(searchValue != "" || onlyFavoritesIsActive){

      // Allocate space
      List<ClubMeDiscount> favoritesToDisplay = [];
      discountsToDisplay = [];

      // Fetch favorites
      for(var discount in upcomingDbDiscounts){
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
          for(var discount in upcomingDbDiscounts){

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
      discountsToDisplay = upcomingDbDiscounts;
    }

    discountsToDisplay.sort((a,b) => b.priorityScore.compareTo(a.priorityScore));

  }
  void filterForFavorites(){
    setState(() {
      onlyFavoritesIsActive = !onlyFavoritesIsActive;
      filterDiscounts();
    });
  }
  void sortUpcomingDiscounts(){
    upcomingDbDiscounts.sort((a,b) =>
        a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
    );
  }
  void sortDiscountsIntoUpcomingDiscounts(StateProvider stateProvider){

    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    // print("sort: " + stateProvider.getFetchedDiscounts().toString());

    for(var currentDiscount in stateProvider.getFetchedDiscounts()){

      // Show only events that are yet to come
      if(
      currentDiscount.getDiscountDate().isAfter(todayFormatted)
          || currentDiscount.getDiscountDate().isAtSameMomentAs(todayFormatted)){

        // Check if any gender has been specified
        if(currentDiscount.getTargetGender() != 0){
          if(currentDiscount.getTargetGender() == stateProvider.getUserData().getGender()){
            upcomingDbDiscounts.add(currentDiscount);
          }
        }else{
          upcomingDbDiscounts.add(currentDiscount);
        }
      }
    }
  }


  // MISC FUNCTIONS
  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }
  bool checkIfIsLiked(ClubMeDiscount currentDiscount) {
    var isLiked = false;
    if (stateProvider.getLikedDiscounts().contains(
        currentDiscount.getDiscountId())) {
      isLiked = true;
    }
    return isLiked;
  }


  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    // print("upcoming: " + upcomingDbDiscounts.toString());

    // Fetch from db or from provider
    getAllLikedDiscounts();

    // If no discounts locally available, get from provider
    if(upcomingDbDiscounts.isEmpty){
      sortDiscountsIntoUpcomingDiscounts(stateProvider);
    }

    // If no discounts fulfill the filters, check if that's still the case
    if(discountsToDisplay.isEmpty){
      filterDiscounts();
    }

    return Scaffold(

        extendBody: true,
        resizeToAvoidBottomInset: false,

        bottomNavigationBar: CustomBottomNavigationBar(),
        appBar: isSearchbarActive ?
        _buildAppBarWithSearch():
        _buildAppBarWithTitle(),
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
          child: Column(
            children: [

              // Spacer
              SizedBox(height: screenHeight*0.05,),

              _buildSupabaseDiscounts(stateProvider, screenHeight),

              // Spacer
              SizedBox(height: screenHeight*0.05,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_left_sharp,
                    size: 50,
                    color: _currentPageIndex > 0 ? Colors.white: Colors.grey,
                  ),
                  Icon(
                      Icons.keyboard_arrow_right_sharp,
                    size: 50,
                    color: _currentPageIndex < (discountsToDisplay.length-1) ? Colors.white: Colors.grey,
                  ),
                ],
              ),

              // discountsToDisplay.length > 1 ? PageIndicator(
              //   tabController: _tabController,
              //   currentPageIndex: _currentPageIndex,
              //   onUpdateCurrentPageIndex: _updateCurrentPageIndex,
              // ): Container(),
            ],
          )
        )
    );
  }
}


