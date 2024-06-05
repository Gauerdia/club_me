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

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  final TextEditingController _textEditingController = TextEditingController();

  late CustomTextStyle customTextStyle;

  bool onlyFavoritesIsActive = false;

  bool isSearchbarActive = false;
  String searchValue = "";

  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  List<ClubMeDiscount> upcomingDbDiscounts = [];
  List<ClubMeDiscount> discountsToDisplay = [];

  toggleIsSearchActive(){
    setState(() {
      isSearchbarActive = !isSearchbarActive;
    });
  }



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

  void getAllLikedDiscounts() async{
    var likedEvents = await _hiveService.getFavoriteDiscounts();
    stateProvider.setLikedDiscounts(likedEvents);
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

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void filterDiscounts(){

    if(searchValue != "" || onlyFavoritesIsActive){


      List<ClubMeDiscount> favoritesToDisplay = [];
      discountsToDisplay = [];

      // Fetch only favorites
      for(var discount in upcomingDbDiscounts){
        if(checkIfIsLiked(discount)){
          favoritesToDisplay.add(discount);
        }
      }

      // Check if we have to combine favorites and search
      if(searchValue != ""){
        for(var discount in favoritesToDisplay){

          String allInformationLowerCase = "${discount.getDiscountTitle()} ${discount
              .getClubName()}".toLowerCase();

          if (allInformationLowerCase.contains(
              searchValue.toLowerCase())) {
            discountsToDisplay.add(discount);
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

              // The function will be called twice after the response. Here, we avoid to fill the array twice as well.
              if(upcomingDbDiscounts.isEmpty){
                for(var element in data){
                  ClubMeDiscount currentDiscount = parseClubMeDiscount(element);

                  // Show only events that are not yet in the past.
                  if(
                  currentDiscount.getDiscountDate().isAfter(todayFormatted)
                      || currentDiscount.getDiscountDate().isAtSameMomentAs(todayFormatted)){
                    upcomingDbDiscounts.add(currentDiscount);
                  }

                  // We collect all events so we dont have to reload them everytime
                  stateProvider.addDiscountToFetchedDiscounts(currentDiscount);
                }

                // Sort so that the next events come up earliest
                sortUpcomingDiscounts();
                stateProvider.sortFetchedDiscounts();
              }

              discountsToDisplay = upcomingDbDiscounts;
              stateProvider.setFetchedDiscounts(discountsToDisplay);


              return Container(
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
              );
            }
          }
      )
        : Container(
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
        );
  }


  bool checkIfIsLiked(ClubMeDiscount currentDiscount) {
    var isLiked = false;
    if (stateProvider.getLikedDiscounts().contains(
        currentDiscount.getDiscountId())) {
      isLiked = true;
    }
    return isLiked;
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

    for(var currentDiscount in stateProvider.getFetchedDiscounts()){
      // Show only events that are not yet in the past.
      if(
      currentDiscount.getDiscountDate().isAfter(todayFormatted)
          || currentDiscount.getDiscountDate().isAtSameMomentAs(todayFormatted)){
        upcomingDbDiscounts.add(currentDiscount);
      }

    }
  }

  void filterForFavorites(){
    setState(() {
      onlyFavoritesIsActive = !onlyFavoritesIsActive;
      filterDiscounts();
    });
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    getAllLikedDiscounts();

    if(upcomingDbDiscounts.isEmpty){
      sortDiscountsIntoUpcomingDiscounts(stateProvider);
    }

    if(discountsToDisplay.isEmpty){
      filterDiscounts();
    }

    return Scaffold(

        // extendBodyBehindAppBar: true,
        extendBody: true,

        resizeToAvoidBottomInset: false,

        bottomNavigationBar: CustomBottomNavigationBar(),
        appBar: isSearchbarActive ?
        AppBar(
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
        ):
        AppBar(

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

        ),
        body: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // Color(0xff11181f),
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

              PageIndicator(
                tabController: _tabController,
                currentPageIndex: _currentPageIndex,
                onUpdateCurrentPageIndex: _updateCurrentPageIndex,
              ),
            ],
          )
        )
    );
  }
}


