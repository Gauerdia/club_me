import 'dart:io';

import 'package:club_me/models/club_me_local_discount.dart';
import 'package:club_me/models/discount.dart';
import 'package:club_me/models/parser/local_discount_to_discount_parser.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../models/parser/club_me_discount_parser.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar.dart';
import '../../shared/custom_text_style.dart';
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

  String headline = "Deine Coupons";
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
  final TextEditingController _textEditingController = TextEditingController();

  bool dbFetchComplete = false;
  bool isSearchbarActive = false;
  bool onlyFavoritesIsActive = false;

  String searchValue = "";
  int _currentPageIndex = 0;

  // Theoretically obsolete but maybe we need the separation in the future
  // List<ClubMeDiscount> localDiscounts = [];
  // List<ClubMeDiscount> dbDiscounts = [];

  // All elements that lie in the future and by that are worth to display
  List<ClubMeDiscount> upcomingDiscounts = [];
  // A dynamic array that considers all filters.
  List<ClubMeDiscount> discountsToDisplay = [];

  BoxDecoration gradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff2b353d),
          Color(0xff11181f)
        ],
        stops: [0.15, 0.6]
    ),
  );
  BoxDecoration plainBlackDecoration = const BoxDecoration(
      color: Colors.black
  );

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    if(fetchedContentProvider.getFetchedDiscounts().isEmpty) {
      fetchLocalDiscountsFromHive();
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
  Widget _buildSupabaseDiscounts(
      StateProvider stateProvider,
      double screenHeight
      ){

    // Only fetch from web when we have not yet fetched
    return fetchedContentProvider.getFetchedDiscounts().isEmpty ?
    FutureBuilder(
        future: getDiscounts,
        builder: (context, snapshot){

          if(snapshot.hasError){
            print("Error: ${snapshot.error}");
          }

          if(!snapshot.hasData){

            // Check if there is anything local to display
            if(discountsToDisplay.isNotEmpty){
              return _buildSwipeView();
            }else{
              return Center(
                child: CircularProgressIndicator(
                    color: customStyleClass.primeColor
                ),
              );
            }
          }else{

            final data = snapshot.data!;

            // get today in correct format to check which events are upcoming
            var todayRaw = DateTime.now();
            var today = DateFormat('yyyy-MM-dd').format(todayRaw);
            var todayFormatted = DateTime.parse(today);

            // The function will be called twice after the response.
            // Here, we avoid to fill the array twice as well.
            if(!dbFetchComplete){
              for(var element in data){

                ClubMeDiscount currentDiscount = parseClubMeDiscount(element);

                // Show only events that are not yet in the past.
                if(
                currentDiscount.getDiscountDate().isAfter(todayFormatted)
                    || currentDiscount.getDiscountDate().isAtSameMomentAs(todayFormatted)
                ){

                  // Check if we need to fetch the image
                  checkIfImageExistsLocally(currentDiscount.getBannerId()).then((exists){
                    if(!exists){

                        // Save the name so that we don't fetch the same image several times
                        // imageFileNamesToBeFetched.add(currentDiscount.getBannerId());
                        fetchAndSaveBannerImage(currentDiscount.getBannerId());

                    // If already exists, we still check if it has been logged
                    }else{
                      if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentDiscount.getBannerId())){
                        fetchedContentProvider.addFetchedBannerImageId(currentDiscount.getBannerId());
                      }
                    }
                  });

                  // maybe the discount is already part of the local ones?
                  if(!checkIfDiscountIsAlreadyPresent(currentDiscount)){

                    // Not yet part of the array? Add it for further processing.
                    upcomingDiscounts.add(currentDiscount);

                    // Doesn't exist yet on the local array? Add it to hive.
                    _hiveService.addLocalDiscount(currentDiscount);
                  }
                }

                // We collect all events so we don't have to reload them every time
                fetchedContentProvider.addDiscountToFetchedDiscounts(currentDiscount);
              }

              // Sort so that the next events come up earliest
              sortUpcomingDiscounts();
              fetchedContentProvider.sortFetchedDiscounts();
              dbFetchComplete = true;
            }

            discountsToDisplay = upcomingDiscounts;

            // Display someone if there is anything
            return discountsToDisplay.isNotEmpty ?
            _buildSwipeView()
            // Text, when no discounts available
            : _buildNothingToDisplay();
          }
        }
    )
        : discountsToDisplay.isNotEmpty ?
    _buildSwipeView() :
    _buildNothingToDisplay();
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
          color: searchValue != "" ? customStyleClass.primeColor : Colors.grey,
          // size: 20,
        ),
        onTap: () => toggleIsSearchActive(),
      ),
      actions: [
        IconButton(
            onPressed: () => filterForFavorites(),
            icon: Icon(
              Icons.stars,
              color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.grey,
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
        child: Text(
            headline,
          textAlign: TextAlign.center,
            style: customStyleClass.getFontStyle1()
        ),
      ),
      leading: GestureDetector(
        child: Icon(
          Icons.search,
          color: searchValue != "" ? customStyleClass.primeColor : Colors.grey,
          // size: 20,
        ),
        onTap: () => toggleIsSearchActive(),
      ),
      actions: [
        IconButton(
            onPressed: () => filterForFavorites(),
            icon: Icon(
              Icons.stars,
              color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.grey,
            )
        )
      ],
    );
  }
  Widget _buildNothingToDisplay(){
    return GestureDetector(
      child: SizedBox(
        width: screenWidth,
        height: screenHeight*0.7,
        child: Center(
          child: Text(
            "Derzeit sind leider keine Coupons verfügbar.",
            style: customStyleClass.getFontStyle3(),
          ),
        ),
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

  Future<bool> checkIfImageExistsLocally(String fileName) async{
    final String dirPath = stateProvider.appDocumentsDir.path;
    return await File('$dirPath/$fileName').exists();
  }
  void fetchAndSaveBannerImage(String fileName) async {
    var imageFile = await _supabaseService.getBannerImage(fileName);

    final String dirPath = stateProvider.appDocumentsDir.path;

    await File("$dirPath/$fileName").writeAsBytes(imageFile).then((onValue){
      setState(() {
        log.d("fetchAndSaveBannerImage: Finished successfully. Path: $dirPath/$fileName");
        fetchedContentProvider.addFetchedBannerImageId(fileName);
      });
    });
  }

  // FILTER
  void filterDiscounts(){

    // Check if we need any filtering at all
    if(searchValue != "" || onlyFavoritesIsActive){

      // Allocate space
      List<ClubMeDiscount> favoritesToDisplay = [];
      discountsToDisplay = [];

      // Fetch favorites
      for(var discount in upcomingDiscounts){
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
          for(var discount in upcomingDiscounts){

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
      discountsToDisplay = upcomingDiscounts;
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
    upcomingDiscounts.sort((a,b) =>
        a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
    );
  }
  void sortDiscountsIntoUpcomingDiscounts(StateProvider stateProvider){

    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    for(var currentDiscount in fetchedContentProvider.getFetchedDiscounts()){

      // Show only events that are yet to come
      if(
      currentDiscount.getDiscountDate().isAfter(todayFormatted)
          || currentDiscount.getDiscountDate().isAtSameMomentAs(todayFormatted)){

        // Check if any gender has been specified
        if(currentDiscount.getTargetGender() != 0){
          if(currentDiscount.getTargetGender() == userDataProvider.getUserData().getGender()){
            upcomingDiscounts.add(currentDiscount);
          }
        }else{
          upcomingDiscounts.add(currentDiscount);
        }
      }
    }
  }


  // MISC FUNCTIONS
  void fetchLocalDiscountsFromHive() async{

      // If the user didn't open the app for some time, some discounts might
      // be expired. To check this, we get the current date
      var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var todayFormatted = DateTime.parse(today);

      try{
        _hiveService.getAllLocalDiscounts().then((data){

          for(ClubMeLocalDiscount currentLocalDiscount in data){

            ClubMeDiscount tempDiscount = localDiscountToDiscountParser(currentLocalDiscount);

            // Show only events that are not yet in the past.
            if(
            tempDiscount.getDiscountDate().isAfter(todayFormatted)
                || tempDiscount.getDiscountDate().isAtSameMomentAs(todayFormatted)
            ){

              // Check if we need to fetch the image
              checkIfImageExistsLocally(tempDiscount.getBannerId()).then((exists){
                if(!exists){

                  print("doesnt exist: ${tempDiscount.getBannerId()}");

                  // If we haven't started to fetch the image yet, we ought to
                  if(!fetchedContentProvider.getFetchedBannerImageIds().contains(tempDiscount.getBannerId())){
                    fetchAndSaveBannerImage(tempDiscount.getBannerId());
                  }
                }else{
                  print("Exists: ${tempDiscount.getBannerId()}");
                  fetchedContentProvider.addFetchedBannerImageId(tempDiscount.getBannerId());
                }
              });

              if(!upcomingDiscounts.contains(tempDiscount)){
                upcomingDiscounts.add(tempDiscount);
              }
            }
            // Cleanse, if not applicable anymore
            else{
              _hiveService.deleteLocalDiscount(tempDiscount.discountId);
            }
          }
        });
        // If db-fetching takes a moment, we want to display the current state.
        setState(() {});
      }catch(e){
        print("Error in fetchLocalDiscountsFromHive: $e");
      }
  }

  bool checkIfDiscountIsAlreadyPresent(ClubMeDiscount clubMeDiscount){

    int counter = 0;

    for(var element in upcomingDiscounts){

      // Check, if there is one with the same id
      if(element.discountId == clubMeDiscount.discountId){

        // Maybe a field changed? We have to update the element
        if(element != clubMeDiscount){
          upcomingDiscounts[counter] = clubMeDiscount;
          _hiveService.updateLocalDiscount(element);
        }
        return true;
      }
      counter++;
    }
    return false;
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  bool checkIfIsLiked(ClubMeDiscount currentDiscount) {
    var isLiked = false;
    if (currentAndLikedElementsProvider.getLikedDiscounts().contains(
        currentDiscount.getDiscountId())) {
      isLiked = true;
    }
    return isLiked;
  }



  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    // Fetch from db or from provider
    getAllLikedDiscounts();

    // If no discounts locally available, get from provider
    if(upcomingDiscounts.isEmpty){
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
          decoration: plainBlackDecoration,
          child: Column(
            children: [

              // Spacer
              SizedBox(height: screenHeight*0.05,),

              _buildSupabaseDiscounts(stateProvider, screenHeight),

              // Spacer
              SizedBox(height: screenHeight*0.05,),

              if(discountsToDisplay.isNotEmpty)
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

            ],
          )
        )
    );
  }
}


