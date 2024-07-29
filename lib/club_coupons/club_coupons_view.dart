import 'package:club_me/models/discount.dart';
import 'package:club_me/models/parser/club_me_discount_parser.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/state_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar_clubs.dart';
import '../shared/custom_text_style.dart';
import 'components/small_discount_tile.dart';
import 'package:timezone/standalone.dart' as tz;

class ClubDiscountsView extends StatefulWidget {
  const ClubDiscountsView({Key? key}) : super(key: key);

  @override
  State<ClubDiscountsView> createState() => _ClubDiscountsViewState();
}

class _ClubDiscountsViewState extends State<ClubDiscountsView> {

  String headLine = "Deine Coupons";

  late Future getDiscounts;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
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
    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    if(stateProvider.getFetchedDiscounts().isEmpty) {
      getDiscounts = _supabaseService.getDiscountsOfSpecificClub(stateProvider.getUserData().getUserId());
    }
  }


  // FILTER
  void checkIfFilteringIsNecessary(){
    // Check if provider is full, but local arrays are empty
    if(upcomingDiscounts.isEmpty && pastDiscounts.isEmpty && stateProvider.getFetchedDiscounts().isNotEmpty){
      filterDiscountsFromProvider(stateProvider);
    }

    // Check if something has just been edited
    if(upcomingDiscounts.isNotEmpty && !identical(upcomingDiscounts[0], stateProvider.getFetchedDiscounts().where((element) => element.getDiscountId() == upcomingDiscounts[0].getDiscountId()))){
      filterDiscountsFromProvider(stateProvider);
    }

    // Check, if a coupon has just been created
    if(upcomingDiscounts.length+pastDiscounts.length != stateProvider.getFetchedDiscounts().length){
      filterDiscountsFromProvider(stateProvider);
    }
  }
  void filterDiscountsFromProvider(StateProvider stateProvider){

    upcomingDiscounts = [];
    pastDiscounts = [];

    for(var currentDiscount in stateProvider.getFetchedDiscounts()){
      // add 23 so that we can still find it as upcoming even though it's the same day
      DateTime discountTimestamp = currentDiscount.getDiscountDate();

      // Get current time for germany
      final berlin = tz.getLocation('Europe/Berlin');
      final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

      // Filter the events
      if(discountTimestamp.isAfter(todayTimestamp) || discountTimestamp.isAtSameMomentAs(todayTimestamp)){
        if(currentDiscount.getClubId() == stateProvider.userClub.getClubId()){
          upcomingDiscounts.add(currentDiscount);
        }
      }else{
        if(currentDiscount.getClubId() == stateProvider.userClub.getClubId()){
          pastDiscounts.add(currentDiscount);
        }
      }
    }
  }
  void filterDiscountsFromQuery(var data, StateProvider stateProvider){

    for(var element in data){
      ClubMeDiscount currentDiscount = parseClubMeDiscount(element);

      // add 23 so that we can still find it as upcoming even though it's the same day
      DateTime discountTimestamp = currentDiscount.getDiscountDate();

      // subtract 7 so that time zones and late at night queries work well
      // DateTime todayTimestamp = DateTime.now();

      // Get current time for germany
      final berlin = tz.getLocation('Europe/Berlin');
      final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin);

      // Filter the events
      if(discountTimestamp.isAfter(todayTimestamp) || discountTimestamp.isAtSameMomentAs(todayTimestamp)){
        if(currentDiscount.getClubId() == stateProvider.userClub.getClubId()){
          upcomingDiscounts.add(currentDiscount);
        }
      }else{
        if(currentDiscount.getClubId() == stateProvider.userClub.getClubId()){
          pastDiscounts.add(currentDiscount);
        }
      }

      if(upcomingDiscounts.isNotEmpty){
        upcomingDiscounts.sort((a,b) =>
            a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
        );
      }

      if(pastDiscounts.isNotEmpty){
        pastDiscounts.sort((a,b) =>
            a.getDiscountDate().millisecondsSinceEpoch.compareTo(b.getDiscountDate().millisecondsSinceEpoch)
        );
      }

      // Add to provider so that we dont need to call them from the db again
      stateProvider.addDiscountToFetchedDiscounts(currentDiscount);
    }
  }


  // BUILD
  Widget fetchDiscountsFromDbAndBuildWidget(
      StateProvider stateProvider,
      double screenHeight, double screenWidth){
    return stateProvider.getFetchedDiscounts().isEmpty ?
    FutureBuilder(
        future: getDiscounts,
        builder: (context, snapshot){

          print("fetched.empty: ${stateProvider.getFetchedDiscounts().isEmpty}, ${stateProvider.getFetchedDiscounts()}");

          if(snapshot.hasError){
            print("Error: ${snapshot.error}");
          }

          if(!snapshot.hasData){
            return Column(
              children: [

                SizedBox(
                  height: screenHeight*0.2,
                ),

                const Center(
                  child: CircularProgressIndicator(),
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

        // New Event Widget
        _buildNewDiscountWidget(
            context,
            stateProvider,
            screenHeight,
            screenWidth
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.05,
        ),

        // Current Event Widget
        _buildCurrentDiscountsWidget(
            stateProvider,
            screenHeight,
            screenWidth
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.05,
        ),

        _buildPastDiscountsWidget(
            stateProvider,
            screenHeight,
            screenWidth),

        // Spacer
        SizedBox(
          height: screenHeight*0.15,
        ),
      ],
    );
  }
  Widget _buildNewDiscountWidget(
      BuildContext context, StateProvider stateProvider,
      double screenHeight, double screenWidth
      ){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(newDiscountContainerHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*newDiscountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*newDiscountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[900]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*newDiscountContainerHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [
                // Events headline
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.only(
                      left: screenWidth*0.05,
                      top: screenHeight*0.03
                  ),
                  child: Text(
                    "Neuer Coupon",
                    textAlign: TextAlign.left,
                    style: customTextStyle.size1Bold()
                  ),
                ),

                // Neuen Discount erstellen button
                Padding(
                  padding: EdgeInsets.only(
                    top:screenHeight*0.015,
                    right: screenWidth*0.02,
                    bottom: screenWidth*0.02,
                  ),
                  child: Align(
                    child: GestureDetector(
                      child: Container(
                          width: screenWidth*0.8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  customTextStyle.primeColorDark,
                                  customTextStyle.primeColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: const [0.2, 0.9]
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: Offset(3, 3), // changes position of shadow
                              ),
                            ],
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Center(
                            child: Text(
                              "Neuen Coupon erstellen!",
                              style: customTextStyle.size4Bold()
                            ),
                          )
                      ),
                      onTap: (){
                        context.push("/club_new_discount");
                      },
                    ),
                  ),
                ),

                // 'From template' button
                stateProvider.getDiscountTemplates().isNotEmpty ?
                Padding(
                  padding: EdgeInsets.only(
                    top:screenHeight*0.015,
                    right: 7,
                    bottom: 7,
                  ),
                  child: Align(
                    child: GestureDetector(
                      child: Container(
                          width: screenWidth*0.8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  customTextStyle.primeColorDark,
                                  customTextStyle.primeColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: const [0.2, 0.9]
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: Offset(3, 3), // changes position of shadow
                              ),
                            ],
                            borderRadius: const BorderRadius.all(
                                Radius.circular(10)
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Center(
                            child: Text(
                              "Coupon aus Vorlage erstellen!",
                              style: customTextStyle.size4Bold(),
                            ),
                          )
                      ),
                      onTap: (){
                        context.push("/club_discount_templates");
                      },
                    ),
                  ),
                ):Container(),
              ],
            ),
          ),
        )

      ],
    );
  }
  Widget _buildCurrentDiscountsWidget(
      StateProvider stateProvider,double screenHeight, double screenWidth){

    upcomingDiscounts.isNotEmpty?
    newDiscountContainerHeightFactor = 0.2
        :newDiscountContainerHeightFactor = 0.2;

    upcomingDiscounts.isNotEmpty?
    discountContainerHeightFactor = 0.52
        : discountContainerHeightFactor = 0.24;

    return Stack(
      children: [

        // gradient from bottom left to bottom right
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(discountContainerHeightFactor+0.006),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // gradient from top right to bottom right
        Container(
          width: screenWidth*0.91,
          height: screenHeight*discountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // left highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*discountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[900]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // top left to top right
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*discountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // MAIN CONTENT
        Padding(
          // Needed for highlights
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*discountContainerHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: const [0.1,0.7]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // "Aktuelle Discounts"
                Container(
                  width: screenWidth,
                  // color: Colors.red,
                  padding: EdgeInsets.only(
                      left: screenWidth*0.05,
                      top: screenHeight*0.03
                  ),
                  child: Text(
                    "Aktuelle Coupons",
                    textAlign: TextAlign.left,
                    style: customTextStyle.size1Bold(),
                  ),
                ),

                SizedBox(
                  height: screenHeight*0.03,
                ),

                // Show fetched discounts
                upcomingDiscounts.isNotEmpty
                    ? Stack(
                  children: [
                    GestureDetector(
                      child: Center(
                        child: SmallDiscountTile(
                            clubMeDiscount: upcomingDiscounts[0]
                        ),
                      ),
                      onTap: () => clickedOnCurrentDiscount(),
                    ),

                    Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: screenHeight*0.005
                          ),
                          child: Container(
                            height: screenHeight*0.07,
                            width: screenWidth*0.8,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black, Colors.transparent],
                                // stops: [0.05, 0.95]
                              ),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  topLeft: Radius.circular(12)
                              ),
                            ),
                          ),
                        )
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                        right: screenWidth*0.05,
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            // Edit icon
                            IconButton(
                              icon: Icon(Icons.edit, size: screenWidth*0.08),
                              color: stateProvider.getPrimeColor(),
                              onPressed: () => editDiscount(stateProvider),
                            ),

                            // Delete icon
                            IconButton(
                              icon: Icon(Icons.clear_rounded, size: screenWidth*0.08),
                              color: customTextStyle.primeColor,
                              onPressed: () => clickOnDeleteDiscount(),
                            ),

                          ],
                        ),
                      ),
                    )
                  ],
                ): Text(
                    "Keine Coupons verfügbar",
                  style: customTextStyle.size4()
                ),

                stateProvider.getFetchedDiscounts().isEmpty ? SizedBox(
                  height: screenHeight*0.03,
                ):Container(),
              ],
            ),
          ),
        ),

        // "More Discounts" Buttons
        Container(
          width: screenWidth*0.9,
          height: screenHeight*discountContainerHeightFactor,
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight*0.015,
                right: screenWidth*0.02
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient:LinearGradient(
                      colors: [
                        customTextStyle.primeColorDark,
                        customTextStyle.primeColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.2, 0.9]
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(3, 3),
                    ),
                  ],
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10)
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Text(
                  "Mehr Coupons!",
                  style: customTextStyle.size5Bold()
                ),
              ),
            ),
            onTap: () => clickedOnMoreCurrentDiscounts(),
          ),
        ),
      ],
    );
  }
  Widget _buildPastDiscountsWidget(
      StateProvider stateProvider, double screenHeight, double screenWidth){

    double discountContainerHeightFactor;

    pastDiscounts.isNotEmpty?
    newDiscountContainerHeightFactor = 0.2
        :newDiscountContainerHeightFactor = 0.2;

    pastDiscounts.isNotEmpty?
    discountContainerHeightFactor = 0.52
        : discountContainerHeightFactor = 0.24;

    return Stack(
      children: [

        // gradient from bottom left to bottom right
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(discountContainerHeightFactor+0.006),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // gradient from top right to bottom right
        Container(
          width: screenWidth*0.91,
          height: screenHeight*discountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // left highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*discountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[900]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // top left to top right
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*discountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // MAIN CONTENT
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height:
            screenHeight*discountContainerHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: const [0.1,0.7]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // "Past Events" headline
                Container(
                  width: screenWidth,
                  // color: Colors.red,
                  padding: EdgeInsets.only(
                      left: screenWidth*0.05,
                      top: screenHeight*0.03
                  ),
                  child: Text(
                    "Vergangene Coupons",
                    textAlign: TextAlign.left,
                    style: customTextStyle.size1Bold()
                  ),
                ),

                // Spacer
                SizedBox(
                  height: screenHeight*0.03,
                ),

                // Show fetched discounts
                pastDiscounts.isNotEmpty
                    ? SmallDiscountTile(
                        clubMeDiscount: pastDiscounts[0]
                      )
                    :Text(
                    "Keine Coupons verfügbar",
                    style: customTextStyle.size4()
                ),

                stateProvider.getFetchedDiscounts().isEmpty ? SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

              ],
            ),
          ),
        ),

        // "More Discounts" Buttons
        Container(
          width: screenWidth*0.9,
          height: screenHeight*discountContainerHeightFactor,
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: screenHeight*0.015,
                  right: screenWidth*0.02
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient:LinearGradient(
                      colors: [
                        customTextStyle.primeColorDark,
                        customTextStyle.primeColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.2, 0.9]
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(3, 3),
                    ),
                  ],
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10)
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Text(
                  "Mehr Coupons!",
                  style: customTextStyle.size5Bold()
                ),
              ),
            ),
            onTap: () => clickedOnMorePastDiscounts(),
          ),
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
          style: customTextStyle.size2(),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  // CLICKED
  void clickOnDeleteDiscount(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Achtung!"),
        content: const Text(
          "Bist du sicher, dass du diesen Coupon löschen möchtest?",
          textAlign: TextAlign.left,
        ),
        actions: [
          TextButton(
              onPressed: () => _supabaseService.deleteDiscount(upcomingDiscounts[0].getDiscountId()).then((value){
                if(value == 0){
                  setState(() {
                    stateProvider.fetchedDiscounts.removeWhere((element) => element.getDiscountId() == upcomingDiscounts[0].getDiscountId());
                    upcomingDiscounts.removeAt(0);
                  });
                  Navigator.pop(context);
                }else{
                  Navigator.pop(context);
                }
              }),
              child: Text("Löschen")
          )
        ],
      );
    });
  }
  void clickedOnCurrentDiscount(){
    print ("currentDiscount");
  }
  void clickedOnMorePastDiscounts(){
    context.push("/club_past_discounts");
  }
  void clickedOnMoreCurrentDiscounts(){
    context.go("/club_upcoming_discounts");
  }

  // MISC FCTS
  void editDiscount(StateProvider stateProvider){
    stateProvider.setCurrentDiscount(upcomingDiscounts[0]);
    context.push("/discount_details");
  }

  void getAllDiscountTemplates(StateProvider stateProvider) async{
    try{
      var discountTemplates = await _hiveService.getAllDiscountTemplates();
      stateProvider.setDiscountTemplates(discountTemplates);
      if(discountTemplates.isNotEmpty){
        setState(() {
          newDiscountContainerHeightFactor = 0.3;
        });
      }
    }catch(e){
      _supabaseService.createErrorLog("getAllDiscountTemplates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    customTextStyle = CustomTextStyle(context: context);
    stateProvider = Provider.of<StateProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    checkIfFilteringIsNecessary();

    if(stateProvider.getDiscountTemplates().isEmpty){
      getAllDiscountTemplates(stateProvider);
    }else{
      newDiscountContainerHeightFactor = 0.3;
    }

    return Scaffold(

      extendBody: true,

      appBar: _buildAppBar(),
      body: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Colors.black,
                    // Colors.grey[800]!
                    Color(0xff2b353d),
                    Color(0xff11181f)
                  ],
                  stops: [0.15, 0.6]
              ),
            ),
            child: SingleChildScrollView(
                child: fetchDiscountsFromDbAndBuildWidget(stateProvider, screenHeight, screenWidth)
            )
        ),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }




}

