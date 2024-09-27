import 'dart:io';

import 'package:club_me/models/discount.dart';
import 'package:club_me/models/hive_models/1_club_me_discount_template.dart';
import 'package:club_me/models/parser/club_me_discount_parser.dart';
import 'package:club_me/provider/current_and_liked_elements_provider.dart';
import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../provider/state_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';
import 'components/small_discount_tile.dart';

class ClubDiscountsView extends StatefulWidget {
  const ClubDiscountsView({Key? key}) : super(key: key);

  @override
  State<ClubDiscountsView> createState() => _ClubDiscountsViewState();
}

class _ClubDiscountsViewState extends State<ClubDiscountsView> {

  String headLine = "Coupons";

  var log = Logger();

  List<String> imageFileNamesToBeFetched = [];
  List<String> imageFileNamesAlreadyFetched = [];

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late UserDataProvider userDataProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late Future getDiscounts;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  List<ClubMeDiscount> pastDiscounts = [];
  List<ClubMeDiscount> upcomingDiscounts = [];

  double discountContainerHeightFactor = 0.52;
  double newDiscountContainerHeightFactor = 0.2;

  final SupabaseService _supabaseService = SupabaseService();
  final HiveService _hiveService = HiveService();

  @override
  void initState(){
    super.initState();

    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen: false);

    if(fetchedContentProvider.getFetchedDiscounts().isEmpty) {
      getDiscounts = _supabaseService.getDiscountsOfSpecificClub(userDataProvider.getUserData().getUserId());
    }

  }


  // FILTER
  void checkIfFilteringIsNecessary(){

    // Check if provider is full, but local arrays are empty
    if(upcomingDiscounts.isEmpty && pastDiscounts.isEmpty && fetchedContentProvider.getFetchedDiscounts().isNotEmpty){
      filterDiscountsFromProvider(stateProvider);
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
      filterDiscountsFromProvider(stateProvider);
    }

    // Check, if a coupon has just been created
    if(upcomingDiscounts.length+pastDiscounts.length != fetchedContentProvider.getFetchedDiscounts().length){
      filterDiscountsFromProvider(stateProvider);
    }
  }
  void filterDiscountsFromProvider(StateProvider stateProvider){

    upcomingDiscounts = [];
    pastDiscounts = [];

    for(var currentDiscount in fetchedContentProvider.getFetchedDiscounts()){
      // add 23 so that we can still find it as upcoming even though it's the same day
      DateTime discountTimestamp = currentDiscount.getDiscountDate();

      // Get current time for germany
      // final berlin = tz.getLocation('Europe/Berlin');
      // final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

      checkIfImageExistsLocally(currentDiscount.getBannerId()).then((exists){
        if(!exists){

          // If we haven't started to fetch the image yet, we ought to
          if(!imageFileNamesToBeFetched.contains(currentDiscount.getBannerId())){

            // Save the name so that we don't fetch the same image several times
            imageFileNamesToBeFetched.add(currentDiscount.getBannerId());

            fetchAndSaveBannerImage(currentDiscount.getBannerId());
          }
        }else{
          setState(() {
            imageFileNamesAlreadyFetched.add(currentDiscount.getBannerId());
          });
        }
      });

      // Filter the events
      if(discountTimestamp.isAfter(stateProvider.getBerlinTime()) || discountTimestamp.isAtSameMomentAs(stateProvider.getBerlinTime())){
        if(currentDiscount.getClubId() == userDataProvider.getUserClubId()){
          upcomingDiscounts.add(currentDiscount);
        }
      }else{
        if(currentDiscount.getClubId() == userDataProvider.getUserClubId()){
          pastDiscounts.add(currentDiscount);
        }
      }
    };
  }
  void filterDiscountsFromQuery(var data, StateProvider stateProvider){

    for(var element in data){

      // Get data in correct format
      ClubMeDiscount currentDiscount = parseClubMeDiscount(element);

      // local var to shorten the expressions
      DateTime discountTimestamp = currentDiscount.getDiscountDate();

      // Make sure we can show the corresponding image(s)
      checkIfImageExistsLocally(currentDiscount.getBannerId()).then((exists){
        if(!exists){

          // If we haven't started to fetch the image yet, we ought to
          if(!imageFileNamesToBeFetched.contains(currentDiscount.getBannerId())){

            // Save the name so that we don't fetch the same image several times
            imageFileNamesToBeFetched.add(currentDiscount.getBannerId());

            fetchAndSaveBannerImage(currentDiscount.getBannerId());
          }
        }else{
          setState(() {
            imageFileNamesAlreadyFetched.add(currentDiscount.getBannerId());
          });
        }
      });

      // Sort the discounts into the correct arrays
      if(discountTimestamp.isAfter(stateProvider.getBerlinTime()) || discountTimestamp.isAtSameMomentAs(stateProvider.getBerlinTime())){

        // Make sure that we only consider discounts of the current user's club
        if(currentDiscount.getClubId() == userDataProvider.getUserClubId()){
          upcomingDiscounts.add(currentDiscount);
        }

      }else{

        // Make sure that we only consider discounts of the current user's club
        if(currentDiscount.getClubId() == userDataProvider.getUserClubId()){
          pastDiscounts.add(currentDiscount);
        }

      }

      // We have something to show? Awesome, now apply an ascending order
      if(upcomingDiscounts.isNotEmpty){
        upcomingDiscounts.sort((a,b) =>
            a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
        );
      }

      // We have something to show? Awesome, now apply an ascending order
      if(pastDiscounts.isNotEmpty){
        pastDiscounts.sort((a,b) =>
            a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
        );
      }

      // Add to provider so that we don't need to fetch them from the db again
      fetchedContentProvider.addDiscountToFetchedDiscounts(currentDiscount);
    }
  }

  // BUILD
  Widget fetchDiscountsFromDbAndBuildWidget(
      StateProvider stateProvider,
      double screenHeight, double screenWidth){
    return fetchedContentProvider.getFetchedDiscounts().isEmpty ?
    FutureBuilder(
        future: getDiscounts,
        builder: (context, snapshot){

          if(snapshot.hasError){
            print("Error: ${snapshot.error}");
          }

          if(!snapshot.hasData){
            return Column(
              children: [

                SizedBox(
                  height: screenHeight*0.2,
                ),

                Center(
                  child: CircularProgressIndicator(
                    color: customStyleClass.primeColor,
                  ),
                )
              ],
            );
          }else{

            final data = snapshot.data!;

            filterDiscountsFromQuery(data, stateProvider);

            return _buildMainView(stateProvider, screenHeight, screenWidth);

          }
        }
    ): _buildMainView(stateProvider, screenHeight, screenWidth);
  }
  Widget _buildMainView(
      StateProvider stateProvider,
      double screenHeight, double screenWidth
      ){
    return Column(
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
                  clubMeDiscount: upcomingDiscounts[0],
                  imageFileNamesAlreadyFetched: imageFileNamesAlreadyFetched,
                ),
              ),
              onTap: () => clickedOnCurrentDiscount(),
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
                    onTap: () => clickOnEditDiscount(),
                  ),

                  InkWell(
                    child: Icon(
                        Icons.clear_rounded,
                      color: customStyleClass.primeColor,
                        size: screenWidth*0.06
                    ),
                    onTap: () => clickOnDeleteDiscount(),
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
                  clubMeDiscount: pastDiscounts[0],
                  imageFileNamesAlreadyFetched: imageFileNamesAlreadyFetched,
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
    );
  }

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

  // CLICKED
  void clickOnDeleteDiscount(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        backgroundColor: Color(0xff121111),
        title:  Text(
            "Achtung!",
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content:  Text(
          "Bist du sicher, dass du diesen Coupon löschen möchtest?",
          textAlign: TextAlign.left,
          style: customStyleClass.getFontStyle3(),
        ),
        actions: [
          TextButton(
              onPressed: () => _supabaseService.deleteDiscount(upcomingDiscounts[0].getDiscountId()).then((value){
                if(value == 0){
                  setState(() {
                    fetchedContentProvider.fetchedDiscounts.removeWhere((element) => element.getDiscountId() == upcomingDiscounts[0].getDiscountId());
                    upcomingDiscounts.removeAt(0);
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
          )
        ],
      );
    });
  }
  void clickedOnCurrentDiscount(){
    print ("currentDiscount");
  }

  void clickEventGoToMoreDiscounts(int routeIndex){
    switch(routeIndex){
      case 0 : context.push("/club_upcoming_discounts"); break;
      case 1 : context.push("/club_past_discounts"); break;
      default: break;
    }
  }


  // MISC FCTS
  void clickOnEditDiscount(){
    currentAndLikedElementsProvider.setCurrentDiscount(upcomingDiscounts[0]);
    context.push("/discount_details");
  }
  void clickEventNewCoupon(){
    context.push("/club_new_discount");
  }
  clickEventNewCouponFromTemplate(){
    context.push("/club_discount_templates");
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
        imageFileNamesAlreadyFetched.add(fileName);
      });
    });
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

    if(stateProvider.getDiscountTemplates().isEmpty){
      getAllDiscountTemplates();
    }

    checkIfFilteringIsNecessary();

    return Scaffold(

      extendBody: true,

      appBar: _buildAppBar(),
      body: Container(
            width: screenWidth,
            height: screenHeight,
            color: customStyleClass.backgroundColorMain,
            child: SingleChildScrollView(
                child: fetchDiscountsFromDbAndBuildWidget(stateProvider, screenHeight, screenWidth)
            )
        ),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }




}

