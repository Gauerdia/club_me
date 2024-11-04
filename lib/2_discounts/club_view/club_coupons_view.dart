import 'dart:io';

import 'package:club_me/models/discount.dart';
import 'package:club_me/models/hive_models/1_club_me_discount_template.dart';
import 'package:club_me/models/parser/club_me_discount_parser.dart';
import 'package:club_me/provider/current_and_liked_elements_provider.dart';
import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../models/hive_models/2_club_me_discount.dart';
import '../../models/hive_models/7_days.dart';
import '../../provider/state_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';
import 'components/small_discount_tile.dart';


import 'package:collection/collection.dart';

class ClubDiscountsView extends StatefulWidget {
  const ClubDiscountsView({Key? key}) : super(key: key);

  @override
  State<ClubDiscountsView> createState() => _ClubDiscountsViewState();
}

class _ClubDiscountsViewState extends State<ClubDiscountsView> {

  String headLine = "Coupons";

  var log = Logger();

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  List<ClubMeDiscount> pastDiscounts = [];
  List<ClubMeDiscount> upcomingDiscounts = [];

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();

  // INIT
  @override
  void initState(){
    super.initState();

    stateProvider = Provider.of<StateProvider>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen: false);

    if(stateProvider.getDiscountTemplates().isEmpty){
      getAllDiscountTemplates();
    }

    if(fetchedContentProvider.getFetchedDiscounts().isEmpty) {
      _supabaseService.getDiscountsOfSpecificClub(userDataProvider.getUserData().getClubId())
      .then((data) => filterDiscountsFromQuery(data));
    }else{
        filterDiscountsFromProvider();
        setState(() {});
    }

  }


  // FILTER
  void checkIfFilteringIsNecessary(){

    fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen: false);

    // Check if provider is full, but local arrays are empty
    if(upcomingDiscounts.isEmpty &&
        pastDiscounts.isEmpty &&
        fetchedContentProvider.getFetchedDiscounts().isNotEmpty){
      filterDiscountsFromProvider();
    }

    // Check if something has just been edited
    if(
    upcomingDiscounts.isNotEmpty &&
        !identical(upcomingDiscounts[0], fetchedContentProvider.getFetchedDiscounts()
            .where(
              (element) => element.getDiscountId() == upcomingDiscounts[0].getDiscountId()
            )
        )
    ){
      filterDiscountsFromProvider();
    }

    // Check, if a coupon has just been created
    if(upcomingDiscounts.length+pastDiscounts.length != fetchedContentProvider.getFetchedDiscounts().length){
      filterDiscountsFromProvider();
    }
  }
  void filterDiscountsFromProvider(){

    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen: false);

    upcomingDiscounts = [];
    pastDiscounts = [];

    for(var currentDiscount in fetchedContentProvider.getFetchedDiscounts()){
      if(checkIfIsUpcomingDiscount(currentDiscount)){
        upcomingDiscounts.add(currentDiscount);
      }else{
        pastDiscounts.add(currentDiscount);
      }
    }

    // Check if we need to download the corresponding images
    _checkAndFetchService.checkAndFetchDiscountImages(
        fetchedContentProvider.getFetchedDiscounts(),
        stateProvider,
        fetchedContentProvider
    );

    // We have something to show? Awesome, now apply an ascending order
    if(upcomingDiscounts.isNotEmpty){
      upcomingDiscounts.sort((a,b) =>
          a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
      );
    }

    // We have something to show? Awesome, now apply an ascending order
    if(pastDiscounts.isNotEmpty){
      pastDiscounts.sort((a,b) =>
          b.getDiscountDate().millisecondsSinceEpoch.compareTo(a.getDiscountDate().millisecondsSinceEpoch)
      );
    }

  }
  void filterDiscountsFromQuery(var data){

    for(var element in data){

      // Get data in correct format
      ClubMeDiscount currentDiscount = parseClubMeDiscount(element);

      // Sort into upcoming and past arrays
      if(checkIfIsUpcomingDiscount(currentDiscount)){
        upcomingDiscounts.add(currentDiscount);
      }else{
        pastDiscounts.add(currentDiscount);
      }

      // Check if maybe already fetched
      if(!fetchedContentProvider.getFetchedDiscounts().contains(currentDiscount)){
        fetchedContentProvider.addDiscountToFetchedDiscounts(currentDiscount);
      }
    }

    // Check if we need to download the corresponding images
    _checkAndFetchService.checkAndFetchDiscountImages(
        fetchedContentProvider.getFetchedDiscounts(),
        stateProvider,
        fetchedContentProvider
    );

    // We have something to show? Awesome, now apply an ascending order
    if(upcomingDiscounts.isNotEmpty){
      upcomingDiscounts.sort((a,b) =>
          a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
      );
    }

    // We have something to show? Awesome, now apply an ascending order
    if(pastDiscounts.isNotEmpty){
      pastDiscounts.sort((a,b) =>
          b.getDiscountDate().millisecondsSinceEpoch.compareTo(a.getDiscountDate().millisecondsSinceEpoch)
      );
    }

    setState(() {});

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


    // Second case: There are regular opening times but no time limit
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



  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      title: SizedBox(
        width: screenWidth,
        child: Text(headLine,
          textAlign: TextAlign.center,
          style: customStyleClass.getFontStyleHeadline1Bold(),
        ),
      ),
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
    );
  }
  Widget _buildMainView(){
    return Container(
        width: screenWidth,
        height: screenHeight,
        color: customStyleClass.backgroundColorMain,
        child: SingleChildScrollView(
            child: Column(
              children: [

                // Spacer
                SizedBox(
                  height: screenHeight*0.05,
                ),

                // Neues Event
                SizedBox(
                  width: screenWidth*0.9,
                  child: Text(
                    "Neuer Coupon",
                    textAlign: TextAlign.center,
                    style: customStyleClass.getFontStyle1Bold(),
                  ),
                ),

                // New event
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 7
                    ),
                    width: screenWidth*0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Neuen Coupon erstellen",
                              textAlign: TextAlign.left,
                              style: customStyleClass.getFontStyle4BoldPrimeColor(),
                            ),
                            Icon(
                              Icons.arrow_forward_outlined,
                              color: customStyleClass.primeColor,
                            )
                          ],
                        )
                      ],

                    ),
                  ),
                  onTap: () => clickEventNewCoupon(),
                ),

                // Template event
                if(stateProvider.getDiscountTemplates().isNotEmpty)
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.only(
                          bottom: 30
                      ),
                      width: screenWidth*0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Coupon aus Vorlage erstellen",
                                textAlign: TextAlign.left,
                                style: customStyleClass.getFontStyle4BoldPrimeColor(),
                              ),
                              Icon(
                                Icons.arrow_forward_outlined,
                                color: customStyleClass.primeColor,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    onTap: () => clickEventNewCouponFromTemplate(),
                  ),

                if(stateProvider.getDiscountTemplates().isEmpty)
                  const SizedBox(
                    height: 30,
                  ),


                // Current events
                SizedBox(
                  width: screenWidth*0.9,
                  child: Text(
                    "Aktuelle Coupons",
                    textAlign: TextAlign.center,
                    style: customStyleClass.getFontStyle1Bold(),
                  ),
                ),

                // Show fetched discounts
                upcomingDiscounts.isNotEmpty
                    ? Stack(
                  children: [

                    // Event Tile
                    GestureDetector(
                      child: Center(
                        child: SmallDiscountTile(
                            clubMeDiscount: upcomingDiscounts[0]
                        ),
                      ),
                      onTap: () => clickEventCurrentDiscount(),
                    ),

                    // Edit button
                    Container(
                      padding: EdgeInsets.only(
                          right: screenWidth*0.07,
                          top: screenWidth*0.03
                      ),
                      alignment: Alignment.topRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [

                          InkWell(
                            child: Icon(
                                Icons.edit,
                                color: customStyleClass.primeColor,
                                size: screenWidth*0.06
                            ),
                            onTap: () => clickEventEditDiscount(),
                          ),

                          InkWell(
                            child: Icon(
                                Icons.clear_rounded,
                                color: customStyleClass.primeColor,
                                size: screenWidth*0.06
                            ),
                            onTap: () => clickEventDeleteDiscount(),
                          ),

                        ],
                      ),
                    ),

                  ],
                )
                    :Container(
                  padding: const EdgeInsets.only(
                      bottom: 20,
                      top: 20
                  ),
                  child: Text(
                    "Keine Coupons verfügbar",
                    style: customStyleClass.getFontStyle3(),
                  ),
                ),

                // More events
                if(upcomingDiscounts.isNotEmpty)
                  GestureDetector(
                    child: Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(
                          bottom: 30
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Mehr Coupons",
                                style: customStyleClass.getFontStyle4BoldPrimeColor(),
                              ),
                              Icon(
                                Icons.arrow_forward_outlined,
                                color: customStyleClass.primeColor,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    onTap: () => clickEventGoToMoreDiscounts(0),
                  ),

                // past events
                SizedBox(
                  width: screenWidth*0.9,
                  child: Text(
                    "Vergangene Coupons",
                    textAlign: TextAlign.center,
                    style: customStyleClass.getFontStyle1Bold(),
                  ),
                ),

                // Show fetched discounts
                pastDiscounts.isNotEmpty
                    ? Stack(
                  children: [
                    GestureDetector(
                      child: Center(
                        child: SmallDiscountTile(
                            clubMeDiscount: pastDiscounts[0]
                        ),
                      ),
                      onTap: (){
                      },
                    ),

                  ],
                ) :Container(
                    padding: const EdgeInsets.only(
                        bottom: 20,
                        top: 20
                    ),
                    child: Text(
                      "Keine Coupons verfügbar",
                      style: customStyleClass.getFontStyle4(),
                    )
                ),

                // More events
                if(pastDiscounts.isNotEmpty)
                  GestureDetector(
                    child: Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(
                          bottom: 30
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Mehr Coupons",
                                style: customStyleClass.getFontStyle4BoldPrimeColor(),
                              ),
                              Icon(
                                Icons.arrow_forward_outlined,
                                color: customStyleClass.primeColor,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    onTap: () => clickEventGoToMoreDiscounts(1),
                  ),


                // Spacer
                SizedBox(
                  height: screenHeight*0.15,
                ),
              ],
            )
        )
    );
  }


  // CLICKED


  void clickEventNewCoupon(){
    context.push("/club_new_discount");
  }
  void clickEventEditDiscount(){
    currentAndLikedElementsProvider.setCurrentDiscount(upcomingDiscounts[0]);
    context.push("/discount_details");
  }
  void clickEventDeleteDiscount(){
    showDialog(context: context, builder: (BuildContext context){
      return TitleContentAndButtonDialog(
          titleToDisplay: "Achtung",
          contentToDisplay: "Bist du sicher, dass du diesen Coupon löschen möchtest?",
          buttonToDisplay: TextButton(
              onPressed: () => _supabaseService.deleteDiscount(upcomingDiscounts[0].getDiscountId()).then((value){
                if(value == 0){
                  setState(() {
                    fetchedContentProvider.removeFetchedDiscountById(upcomingDiscounts[0].getDiscountId());
                    upcomingDiscounts.removeAt(0);
                  //   fetchedContentProvider.fetchedDiscounts.removeWhere(
                  //           (element) => element.getDiscountId() == upcomingDiscounts[0].getDiscountId());
                  //   upcomingDiscounts.removeAt(0);
                  });
                  Navigator.pop(context);
                }else{
                  Navigator.pop(context);
                }
              }),
              child: Text(
                "Löschen",
                style: customStyleClass.getFontStyle4BoldPrimeColor(),
              )
          ));

    });
  }
  void clickEventCurrentDiscount(){
    print ("currentDiscount");
  }
  void clickEventNewCouponFromTemplate(){
    context.push("/club_discount_templates");
  }
  void clickEventGoToMoreDiscounts(int routeIndex){
    switch(routeIndex){
      case 0 : context.push("/club_upcoming_discounts"); break;
      case 1 : context.push("/club_past_discounts"); break;
      default: break;
    }
  }


  // Fetch content from DB
  void getAllDiscountTemplates() async{

    final stateProvider = Provider.of<StateProvider>(context, listen: false);

    try{
      List<ClubMeDiscountTemplate> discountTemplates = await _hiveService.getAllDiscountTemplates();
      stateProvider.setDiscountTemplates(discountTemplates);
    }catch(e){
      _supabaseService.createErrorLog("ClubCouponsView. Function: getAllDiscountTemplates. Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {


    customStyleClass = CustomStyleClass(context: context);
    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);


    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    // Triggers after deleting or adding a discount to the grid
    if(upcomingDiscounts.length + pastDiscounts.length != fetchedContentProvider.getFetchedDiscounts().where(
        (discount) => discount.getClubId() == userDataProvider.getUserData().getClubId()
    ).toList().length){
      filterDiscountsFromProvider();
    }

    // When the first element has been edited, we want the screen to re-render
    if(upcomingDiscounts.isNotEmpty &&
        !identical(upcomingDiscounts[0], fetchedContentProvider.getFetchedDiscounts().where(
                (element) => element.getDiscountId() == upcomingDiscounts[0].getDiscountId()))){
      filterDiscountsFromProvider();
    }

    return Scaffold(

      extendBody: true,

      appBar: _buildAppBar(),
      body: _buildMainView(),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }




}

