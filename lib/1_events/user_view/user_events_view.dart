import 'dart:async';
import 'package:club_me/models/hive_models/0_club_me_user_data.dart';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:club_me/services/supabase_service.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../models/club.dart';
import '../../models/event.dart';
import '../../models/hive_models/7_days.dart';
import '../../models/parser/club_me_club_parser.dart';
import '../../models/parser/club_me_event_parser.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../shared/custom_bottom_navigation_bar.dart';
import 'components/event_tile.dart';

import 'package:collection/collection.dart';

class UserEventsView extends StatefulWidget {
  const UserEventsView({Key? key}) : super(key: key);

  @override
  State<UserEventsView> createState() => _UserEventsViewState();
}

class _UserEventsViewState extends State<UserEventsView> {

  String headLine = "Events";

  var log = Logger();

  late String dropdownValue;

  late String weekDayDropDownValue;

  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late UserDataProvider userDataProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;


  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();

  final TextEditingController _textEditingController = TextEditingController();

  List<ClubMeEvent> eventsToDisplay = [];

  String searchValue = "";
  bool isSearchActive = false;
  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;
  bool onlyFavoritesIsActive = false;

  double maxValueRangeSlider = 0;
  double maxValueRangeSliderToDisplay = 0;
  RangeValues _currentRangeValues = RangeValues(0, 10);

  bool processingComplete = false;

  bool checkedForInfoScreen = false;
  bool noInfoScreenToShow = true;

  @override
  void initState(){

    super.initState();
    //requestStoragePermission();
    dropdownValue = Utils.genreListForFiltering.first;
    weekDayDropDownValue = Utils.weekDaysForFiltering.first;

    stateProvider = Provider.of<StateProvider>(context, listen: false);
    userDataProvider = Provider.of<UserDataProvider>(context, listen:  false);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    // GEO LOCATION
    _determinePosition().then((value) => setPositionLocallyAndInSupabase(value));

    // INFO SCREEN
    checkForInfoScreen();

    // FETCHING CLUBS, THEN EVENTS
    if(fetchedContentProvider.getFetchedClubs().isEmpty){
      _supabaseService.getAllClubs().then(
              (data) {
            for(var element in data){
              ClubMeClub currentClub = parseClubMeClub(element);

              // Don't save the clubs that are only for development purposes
              if(stateProvider.getUsingTheAppAsADeveloper()){

                if(!fetchedContentProvider.getFetchedClubs().contains(currentClub)){
                  fetchedContentProvider.addClubToFetchedClubs(currentClub);
                }

              }else if(!fetchedContentProvider.getFetchedClubs().contains(currentClub) && currentClub.getShowClubInApp()){
                fetchedContentProvider.addClubToFetchedClubs(currentClub);
              }

            }

            // Check if we need to download the corresponding images
            _checkAndFetchService.checkAndFetchClubImages(
                fetchedContentProvider.getFetchedClubs(),
                stateProvider,
                fetchedContentProvider,
                false
            );

            // Get or check all events
            if(fetchedContentProvider.getFetchedEvents().isEmpty) {
              _supabaseService.getAllEventsAfterYesterday().then((data) => processEventsFromQuery(data));
            }else{
              processEventsFromProvider(fetchedContentProvider);
            }

          }
      );
    }else{
      processEventsFromProvider(fetchedContentProvider);
    }

    // Update the last login time
    if(!stateProvider.updatedLastLogInForNow){
      _supabaseService.updateUserData(
          ClubMeUserData(
              firstName: userDataProvider.getUserData().getFirstName(),
              lastName: userDataProvider.getUserData().getLastName(),
              birthDate: userDataProvider.getUserData().getBirthDate(),
              eMail: userDataProvider.getUserData().getEMail(),
              gender: userDataProvider.getUserData().getGender(),
              userId: userDataProvider.getUserData().getUserId(),
              profileType: userDataProvider.getUserData().getProfileType(),
              lastTimeLoggedIn: DateTime.now(),
              userProfileAsClub: userDataProvider.getUserData().getUserProfileAsClub(),
              clubId: ''
          )
      );
      stateProvider.updatedLastLogInForNow = true;
    }

    // Test if it is ready by the time we navigate to the map
    fetchedContentProvider.setCustomIcons();

    // Get all locally saved liked events
    getAllLikedEvents(stateProvider);

    if(!stateProvider.updatedLastLogInForNow){
      _supabaseService.updateUserLastTimeLoggedIn(userDataProvider.getUserDataId()).then(
          (result){
            if(result == 0){
              stateProvider.toggleUpdatedLastLogInForNow();
            }
          }
      );
    }
  }

  void checkForInfoScreen() async{

    final stateProvider = Provider.of<StateProvider>(context, listen: false);

    String currentInfoScreenName = "";

    try{
      if(!stateProvider.alreadyCheckedForInfoScreen){

        List<String> lastInfoScreenNames = await _hiveService.getLatestInfoScreenNames();

        //List<DateTime> lastInfoScreenDate = await _supabaseService.getLatestInfoScreenDate();
        //DateTime? localLastInfoScreenDate = await _hiveService.getLatestInfoScreenDate();

        // Only relevant if we are before the expiration date.
        // if( stateProvider.getBerlinTime().isBefore(lastInfoScreenDate[1]) ){
        //
        //   // If we have seen the ad already, let's see if there was an update.
        //   if(localLastInfoScreenDate != null){
        //
        //     // Have we already seen the recent ad?
        //     if(localLastInfoScreenDate.isAfter(lastInfoScreenDate[0])){
        //       noInfoScreenToShow = true;
        //     }else{
        //       noInfoScreenToShow = false;
        //     }
        //
        //   }else{
        //     noInfoScreenToShow = false;
        //   }
        //
        // }else{
        //   noInfoScreenToShow = true;
        // }

        if(lastInfoScreenNames.contains(currentInfoScreenName)){
          noInfoScreenToShow = true;
        }else{
          noInfoScreenToShow = false;
          await _hiveService.insertLatestInfoScreenNames(currentInfoScreenName);
        }

        //await _hiveService.updateLatestInfoScreenDate();

        setState(() {
          checkedForInfoScreen = true;
          stateProvider.alreadyCheckedForInfoScreen = true;
        });
      }else{
        setState(() {
          checkedForInfoScreen = true;
          noInfoScreenToShow = true;
        });
      }
    }catch(e){
      log.d("UserEventsView. Fct: checkForInfoScreen. Error: $e");
    }
  }


  // BUILD
  AppBar _buildAppbar(){

    return
      checkedForInfoScreen ?
      AppBar(
      surfaceTintColor: noInfoScreenToShow ? customStyleClass.backgroundColorMain : Colors.transparent,
      backgroundColor: noInfoScreenToShow ? customStyleClass.backgroundColorMain : Colors.transparent,
      title: Container(
        width: screenWidth,
        color: noInfoScreenToShow ? customStyleClass.backgroundColorMain : Colors.transparent,
        child: Stack(
          children: [
            // Headline
            if(noInfoScreenToShow)
            Container(
                alignment: Alignment.bottomCenter,
                height: 50,
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    isSearchActive ?
                    SizedBox(
                      width: screenWidth*0.4,
                      child: TextField(
                        autofocus: true,
                        controller: _textEditingController,
                        onChanged: (text){
                          _textEditingController.text = text;
                          searchValue = text;
                          setState(() {
                            filterEvents(fetchedContentProvider);
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
                    ):Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Text(
                                headLine,
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyleHeadline1Bold()
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
            ),

            // Search icon
            if(noInfoScreenToShow)
            Container(
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () => toggleIsSearchActive(),
                        icon: Icon(
                          Icons.search,
                          color: searchValue != "" ? customStyleClass.primeColor : Colors.white,
                          // size: 20,
                        )
                    )
                  ],
                )
            ),

            // Right icons
            if(noInfoScreenToShow)
            Container(
              width: screenWidth,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () => filterForFavorites(),
                      icon: Icon(
                        onlyFavoritesIsActive ? Icons.star: Icons.star_border,
                        color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.white,
                      )
                  ),
                  GestureDetector(
                    child: Container(
                      // padding: const EdgeInsets.all(7),
                        child: Icon(
                          Icons.filter_alt_outlined,
                          color: isAnyFilterActive || isFilterMenuActive ? customStyleClass.primeColor : Colors.white,
                        )
                    ),
                    onTap: (){
                      toggleIsFilterMenuActive();
                    },
                  )
                ],
              ),
            ),

            if(!noInfoScreenToShow)
              Container(
                width: screenWidth,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: (){
                          setState(() {
                            noInfoScreenToShow = true;
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        )
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ):AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      );

    // Show the app bar with the title
    // AppBar(
    //     surfaceTintColor: customStyleClass.backgroundColorMain,
    //     backgroundColor: customStyleClass.backgroundColorMain,
    //     title: Container(
    //       width: screenWidth,
    //       color: customStyleClass.backgroundColorMain,
    //       child: Stack(
    //         children: [
    //
    //           // Headline
    //           Container(
    //               alignment: Alignment.bottomCenter,
    //               height: 50,
    //               width: screenWidth,
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                     children: [
    //                       Row(
    //                         children: [
    //                           Text(
    //                               headLine,
    //                               textAlign: TextAlign.center,
    //                               style: customStyleClass.getFontStyleHeadline1Bold()
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   )
    //                 ],
    //               )
    //           ),
    //
    //           // Search icon
    //           Container(
    //               width: screenWidth,
    //               alignment: Alignment.centerLeft,
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.end,
    //                 children: [
    //                   IconButton(
    //                       onPressed: () => toggleIsSearchActive(),
    //                       icon: Icon(
    //                         Icons.search,
    //                         color: searchValue != "" ? customStyleClass.primeColor : Colors.white,
    //                         // size: 20,
    //                       )
    //                   )
    //                 ],
    //               )
    //           ),
    //
    //           // Right icons
    //           Container(
    //             width: screenWidth,
    //             alignment: Alignment.centerRight,
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.end,
    //               children: [
    //                 IconButton(
    //                     onPressed: () => filterForFavorites(),
    //                     icon: Icon(
    //                       onlyFavoritesIsActive ? Icons.star : Icons.star_border,
    //                       color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.white,
    //                     )
    //                 ),
    //                 Padding(
    //                     padding: const EdgeInsets.only(right: 0),
    //                     child: GestureDetector(
    //                       child: Container(
    //                           padding: const EdgeInsets.all(7),
    //                           child: Icon(
    //                             Icons.filter_alt_outlined,
    //                             color: isAnyFilterActive || isFilterMenuActive ? customStyleClass.primeColor : Colors.white,
    //                           )
    //                       ),
    //                       onTap: (){
    //                         toggleIsFilterMenuActive();
    //                       },
    //                     )
    //                 )
    //               ],
    //             ),
    //           ),
    //
    //         ],
    //       ),
    //     )
    // );
  }
  Widget _buildMainView(){
    return Container(
        width: screenWidth,
        height: screenHeight,
        color: customStyleClass.backgroundColorMain,
        child: Stack(
          children: [

            // MainListView
            SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const ScrollPhysics(),
                child: Column(
                  children: [

                    // Spacer
                    SizedBox(height: screenHeight*0.02),

                    eventsToDisplay.isNotEmpty ?
                    // If we have something to display, let's go
                    _buildMainListView() :
                    _buildNothingToDisplay(),

                    // Spacer
                    SizedBox(height: screenHeight*0.1,),
                  ],
                )
            ),

            // Filter menu
            if(isFilterMenuActive)
              _buildFilterWidget()
          ],
        )
    );
  }
  Widget _buildMainListView(){
    return eventsToDisplay.isNotEmpty?
    ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: eventsToDisplay.length,
        itemBuilder: ((context, index){

          // Check if the event was already liked by the user
          var isLiked = false;
          if(currentAndLikedElementsProvider.getLikedEvents().contains(eventsToDisplay[index].getEventId())){
            isLiked = true;
          }

          // return clickable widget
          return Stack(
            children: [

              GestureDetector(
                child: EventTile(
                  clubMeEvent: eventsToDisplay[index],
                  isLiked: isLiked,
                  clickEventLike: clickEventLike,
                  clickEventShare: clickEventShare,
                  showMaterialButton: true,
                ),
                onTap: (){
                  currentAndLikedElementsProvider.setCurrentEvent(eventsToDisplay[index]);
                  stateProvider.setAccessedEventDetailFrom(0);
                  context.push('/event_details');
                },
              ),

              if(eventsToDisplay[index].getEventMarketingFileName().isNotEmpty)
              Container(
                  height: 140,
                  width: screenWidth*0.95,
                  padding: const EdgeInsets.only(
                    top: 12,
                    right: 8
                  ),
                  alignment: Alignment.topRight,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)
                    ),
                    child: InkWell(
                      child:
                        Icon(
                          Icons.camera_alt_outlined,
                          color: customStyleClass.primeColor,
                          size: 30,
                        ),
                        onTap: () {
                          currentAndLikedElementsProvider.setCurrentEvent(eventsToDisplay[index]);
                          stateProvider.setAccessedEventDetailFrom(0);
                          stateProvider.toggleOpenEventDetailContentDirectly();
                          context.push('/event_details');
                        }
                    ),
                  ),
                ),

            ],
          );
        })
    ): SizedBox(
      height: screenHeight*0.8,
      width: screenWidth,
      child: Center(
        child: Text(
          onlyFavoritesIsActive ?
          "Derzeit sind keine Events als Favoriten markiert." :
          "Derzeit sind keine Events geplant.",
          style: customStyleClass.getFontStyle3(),
        ),
      ),
    );
  }
  Widget _buildNothingToDisplay(){

    // Different messages depending on why there is nothing to display

    return (isAnyFilterActive || isSearchActive) ?
    SizedBox(
      width: screenWidth,
      height: screenHeight*0.8,
      child: Center(
        child: Text(
          textAlign: TextAlign.center,
          Utils.noEventElementsDueToFilter,
          style: customStyleClass.getFontStyle3(),
        ),
      ),
    ): onlyFavoritesIsActive ?
    SizedBox(
      width: screenWidth,
      height: screenHeight*0.8,
      child: Center(
        child: Text(
          textAlign: TextAlign.center,
          Utils.noEventElementsDueToNoFavorites,
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
          Utils.noEventElementsDueToNothingOnTheServer,
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

  Widget _buildInfoScreen(){
    return Container(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [

          Center(
            child: Image.asset(
                "assets/images/info_screen_09_12_24.jpg"
            ),
          ),

          Container(
            width: screenHeight*0.9,
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(
              bottom: 100
            ),
            child: InkWell(
              child: Container(
                width: 200,
                height: 60,
                padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10
                ),
                decoration: BoxDecoration(
                    color: Color(0xffad9430),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Center(
                  child: Text(
                    "Jetzt entdecken",
                    style: customStyleClass.getFontStyle2Bold(),
                  ),
                ),
              ),
              onTap: (){
                stateProvider.setPageIndex(3);
                context.go("/user_coupons");
              },
            ),
          )

        ],
      ),
    );
  }

  _buildLoadingScreen(){
    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Center(
        child: CircularProgressIndicator(
          color: customStyleClass.primeColor,
        ),
      ),
    );
  }

  Widget _buildFilterWidget(){
    return Container(
      padding: EdgeInsets.only(
        top: screenHeight*0.12
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
      height: 210,
      width: screenWidth,
      child: Container(
        child: Center(
          child:Row(
            children: [

              // Price
              SizedBox(
                width: screenWidth*0.33,
                child: Column(
                  children: [

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.01,
                    ),

                    // Text: Price
                    Text(
                      "Preis",
                      style: customStyleClass.getFontStyle3(),
                    ),

                    // RangeSlider: Price
                    RangeSlider(
                      max: maxValueRangeSlider,
                      divisions: 10,
                      labels: RangeLabels(
                        "0",
                        _currentRangeValues.end.round().toString(),
                      ),
                      values: _currentRangeValues,
                      onChanged: (RangeValues values) {
                        setState(() {
                          _currentRangeValues = values;
                          filterEvents(fetchedContentProvider);
                        });
                      },
                      activeColor: customStyleClass.primeColor,
                      inactiveColor: customStyleClass.primeColor,
                      overlayColor: WidgetStateProperty.all(customStyleClass.primeColorDark),
                    )
                  ],
                ),
              ),

              // Weekday
              SizedBox(
                width: screenWidth*0.33,
                child: Column(
                  children: [

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.01,
                    ),

                    // Text: Genre
                    SizedBox(
                      child: Text(
                        "Wochentag",
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
                          width: 110,
                          initialSelection: weekDayDropDownValue,
                          onSelected: (String? value){
                            setState(() {
                              weekDayDropDownValue = value!;
                              filterEvents(fetchedContentProvider);
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
                          dropdownMenuEntries: Utils.weekDaysForFiltering
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

              // Genre filter
              SizedBox(
                width: screenWidth*0.33,
                child: Column(
                  children: [

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.01,
                    ),

                    // Text: Genre
                    Text(
                      "Musikrichtung",
                      style: customStyleClass.getFontStyle3(),
                    ),

                    // Dropdown
                    Theme(
                        data: Theme.of(context).copyWith(
                            canvasColor: customStyleClass.backgroundColorMain
                        ),
                        child: DropdownMenu<String>(
                          width: 120,
                          initialSelection: dropdownValue,
                          onSelected: (String? value){
                            setState(() {
                              dropdownValue = value!;
                              filterEvents(fetchedContentProvider);
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
                          dropdownMenuEntries: Utils.genreListForFiltering
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
                    ),

                  ],
                ),
              )
            ],
          )
        ),
      ),
    );


    //
  }


  // GEO LOCATION
  Future<Position> _determinePosition() async {

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      log.d("Error in _determinePosition: Location services are disabled.");

      // Location services are not enabled return an error message
      return Future.error('Location services are disabled.');

    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        log.d("Error in _determinePosition: Location permissions are denied.");

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log.d("Error in _determinePosition: Location permissions are permanently denied, we cannot request permissions.");
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    log.d("_determinePosition: No error. Returning Location.");

    // If permissions are granted, return the current location
    return await Geolocator.getCurrentPosition();
  }
  void setPositionLocallyAndInSupabase(Position value){

    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    log.d("UserEventsView. Fct: setPositionLocallyAndInSupabase. Coordinates: ${value.longitude}, ${value.latitude}");

    userDataProvider.setUserCoordinates(value);
    _supabaseService.saveUsersGeoLocation(userDataProvider.getUserDataId(), value.latitude, value.longitude);
  }


  // FETCH
  void getAllLikedEvents(StateProvider stateProvider) async{
    try{
      var likedEvents = await _hiveService.getFavoriteEvents();
      currentAndLikedElementsProvider.setLikedEvents(likedEvents);
    }catch(e){
      _supabaseService.createErrorLog("getAllLikedEvents, getAllLikedEvents: $e");
    }
  }
  void processEventsFromProvider(FetchedContentProvider fetchedContentProvider){

    // Events in the provider ought to have all images fetched, already. So, we just sort.

    for(var currentEvent in fetchedContentProvider.getFetchedEvents()){
      if(checkIfUpcomingEvent(currentEvent)){
          eventsToDisplay.add(currentEvent);
      }
    }
    filterEvents(fetchedContentProvider);

    setState(() {processingComplete = true;});

    log.d("processEventsFromProvider: Successful");
  }
  void processEventsFromQuery(var data){

    for(var element in data){

      ClubMeEvent currentEvent = parseClubMeEvent(element);

      // Accessing as dev: Just push it through. Otherwise, check for toggle
      if(stateProvider.getUsingTheAppAsADeveloper()){

        if(checkIfUpcomingEvent(currentEvent)){
          if(!fetchedContentProvider.getFetchedEvents().contains(currentEvent)){
            fetchedContentProvider.addEventToFetchedEvents(currentEvent);
            eventsToDisplay.add(currentEvent);
          }
        }

      }else if(!fetchedContentProvider.getFetchedEvents().contains(currentEvent) && currentEvent.getShowEventInApp()){
        if(checkIfUpcomingEvent(currentEvent)){
          if(!fetchedContentProvider.getFetchedEvents().contains(currentEvent)){
            fetchedContentProvider.addEventToFetchedEvents(currentEvent);
            eventsToDisplay.add(currentEvent);
          }
        }
      }
    }



    // Check if we need to download the corresponding images
    _checkAndFetchService.checkAndFetchEventImages(
        fetchedContentProvider.getFetchedEvents(),
        stateProvider,
        fetchedContentProvider
    );

    filterEvents(fetchedContentProvider);

    setState(() {processingComplete = true;});

    log.d("processEventsFromQuery: Successful");
  }


  // FILTER
  void filterEvents(FetchedContentProvider fetchedContentProvider){

    // Just set max at the very beginning
    if(maxValueRangeSlider == 0){
      for(var element in fetchedContentProvider.getFetchedEvents()){
        if(maxValueRangeSlider == 0){
          maxValueRangeSlider = element.getEventPrice();
        }else{
          if(element.getEventPrice() > maxValueRangeSlider){
            maxValueRangeSlider = element.getEventPrice();
          }
        }
      }
      _currentRangeValues = RangeValues(0, maxValueRangeSlider);
    }

    // reset array
    eventsToDisplay = [];

    // Check if any filter is applied
    if(
    _currentRangeValues.end != maxValueRangeSlider ||
        _currentRangeValues.start != 0 ||
        dropdownValue != Utils.genreListForFiltering[0] ||
        searchValue != "" ||
        onlyFavoritesIsActive ||
      weekDayDropDownValue != Utils.weekDaysForFiltering[0]
    ){

      // set for coloring
      if(_currentRangeValues.end != maxValueRangeSlider ||
          _currentRangeValues.start != 0 ||
          dropdownValue != Utils.genreListForFiltering[0] ||
        weekDayDropDownValue != Utils.weekDaysForFiltering[0]
      ){
        isAnyFilterActive = true;
      }else{
        isAnyFilterActive = false;
      }

      // Iterate through all available events
      for(var event in fetchedContentProvider.getFetchedEvents()){

        // when one criterium doesnt match, set to false
        bool fitsCriteria = true;

        // Search bar used? Then filter
        if(searchValue != "") {
          String allInformationLowerCase = "${event.getEventTitle()} ${event
              .getClubName()} ${event.getDjName()} ${event.getEventDate()}"
              .toLowerCase();
          if (allInformationLowerCase.contains(
              searchValue.toLowerCase())) {} else {
            fitsCriteria = false;
          }
        }

        // Price range changed? Filter
        if((_currentRangeValues.start != 0 || _currentRangeValues.end != 30)
            && (event.getEventPrice() < _currentRangeValues.start || event.getEventPrice() > _currentRangeValues.end)
        ) fitsCriteria = false;

        // music genre doenst match? filter
        if(dropdownValue != Utils.genreListForFiltering[0] ){
          if(!event.getMusicGenres().toLowerCase().contains(dropdownValue.toLowerCase())){
            fitsCriteria = false;
          }
        }

        if(weekDayDropDownValue != Utils.weekDaysForFiltering[0]){
          int currentEventDayIndex = event.getEventDate().weekday;
          int chosenDayIndex = Utils.weekDaysForFiltering.indexWhere((element) => element == weekDayDropDownValue);
          if(currentEventDayIndex != chosenDayIndex){
            fitsCriteria = false;
          }
        }

        if(onlyFavoritesIsActive){
          if(!checkIfIsLiked(event)){
            fitsCriteria = false;
          }
        }

        // All filter passed? evaluate
        if(fitsCriteria){
          eventsToDisplay.add(event);
        }
      }

      // Adjust the price slider
      for(var element in eventsToDisplay){
        if(maxValueRangeSliderToDisplay == 0){
          maxValueRangeSliderToDisplay = element.getEventPrice();
        }else{
          if(element.getEventPrice() > maxValueRangeSliderToDisplay){
            maxValueRangeSliderToDisplay = element.getEventPrice();
          }
        }
      }

    }else{
      isAnyFilterActive = false;

      for(var event in fetchedContentProvider.getFetchedEvents()){
        eventsToDisplay.add(event);
      }
    }

    eventsToDisplay.sort((a,b) {

      // Currently, we want to give absolute priority to high life
      if(a.getClubId() == "2733b675-d574-4580-90c8-5fe371007b70" &&
          b.getClubId() != "2733b675-d574-4580-90c8-5fe371007b70"){
        return -1;
      }
      if(b.getClubId() == "2733b675-d574-4580-90c8-5fe371007b70" &&
          a.getClubId() != "2733b675-d574-4580-90c8-5fe371007b70"){
        return 1;
      }


      DateTime firstDate = DateTime(a.getEventDate().year, a.getEventDate().month, a.getEventDate().day);
      DateTime secondDate = DateTime(b.getEventDate().year, b.getEventDate().month, b.getEventDate().day);

      int cmp = firstDate.compareTo(secondDate);
      if (cmp != 0) return cmp;
      return b.getPriorityScore().compareTo(a.getPriorityScore());
    });

  }
  void filterForFavorites(){
    setState(() {
      onlyFavoritesIsActive = !onlyFavoritesIsActive;
      filterEvents(fetchedContentProvider);
    });
  }


  // Click/TOGGLE
  void clickEventLike(StateProvider stateProvider, String eventId){
    setState(() {
      if(currentAndLikedElementsProvider.getLikedEvents().contains(eventId)){
        currentAndLikedElementsProvider.deleteLikedEvent(eventId);
        _hiveService.deleteFavoriteEvent(eventId);
      }else{
        currentAndLikedElementsProvider.addLikedEvent(eventId);
        _hiveService.insertFavoriteEvent(eventId);
      }
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
  void toggleIsSearchActive(){
    setState(() {
      isSearchActive = !isSearchActive;
    });
  }
  void toggleIsAnyFilterActive(){
    setState(() {
      isAnyFilterActive = !isAnyFilterActive;
    });
  }
  void toggleIsFilterMenuActive(){
    setState(() {
      isFilterMenuActive = !isFilterMenuActive;
    });
  }


  // MISC
  // void requestStoragePermission() async {
  //   // Check if the platform is not web, as web has no permissions
  //   if (!kIsWeb) {
  //     // Request storage permission
  //     var status = await Permission.storage.status;
  //     if (!status.isGranted) {
  //       await Permission.storage.request();
  //     }
  //
  //     // Request camera permission
  //     var cameraStatus = await Permission.camera.status;
  //     if (!cameraStatus.isGranted) {
  //       await Permission.camera.request();
  //     }
  //   }
  // }
  bool checkIfUpcomingEvent(ClubMeEvent currentEvent){


    // Assumption: Every event until 4:59 started the day before.
    // Assumption: There are no official opening times for events between 5 and 12.
    // We'll just add 6 hours to it.

    Days? clubOpeningTimesForThisDay;
    DateTime closingHourToCompare;

    fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);
    stateProvider = Provider.of<StateProvider>(context, listen: false);

    var eventWeekDay = currentEvent.getEventDate().hour <= 4 ?
    currentEvent.getEventDate().weekday -1 :
    currentEvent.getEventDate().weekday;

    ClubMeClub? currentClub = fetchedContentProvider.getFetchedClubs().firstWhereOrNull(
            (club) => club.getClubId() == currentEvent.getClubId()
    );

    if(currentClub == null){
      log.d(
        "Error in UserEventsView. No corresponding club found. "
            "Event: ${currentEvent.getEventTitle()} ${currentEvent.getEventId()}, its clubId: ${currentEvent.getClubId()}"
      );
      return false;
    }

    // Get regular opening times
    try{
      clubOpeningTimesForThisDay = currentClub.getOpeningTimes().days?.firstWhereOrNull(
              (days) => days.day == eventWeekDay);
    }catch(e){
      print("UserEventsView. Error in checkIfUpcomingEvent, clubOpeningTimesForThisDay: $e");
      clubOpeningTimesForThisDay = null;
    }

    // Easiest case: There is a closing date. Just use it.
    if(currentEvent.getClosingDate() != null){
      closingHourToCompare = DateTime(
          currentEvent.getClosingDate()!.year,
          currentEvent.getClosingDate()!.month,
          currentEvent.getClosingDate()!.day,
          currentEvent.getClosingDate()!.hour,
          currentEvent.getClosingDate()!.minute
      );

      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;
    }

    // Second case: Are there regular opening times?
    if(clubOpeningTimesForThisDay != null){

      // Events that start in the morning should not be set to the next day
      if(currentEvent.getEventDate().hour >= 5 && currentEvent.getEventDate().hour <= 12){
        closingHourToCompare = DateTime(
            currentEvent.getEventDate().year,
            currentEvent.getEventDate().month,
            currentEvent.getEventDate().day,
            currentEvent.getEventDate().hour+6,
            currentEvent.getEventDate().minute
        );
      }

      else{
        closingHourToCompare = DateTime(
            currentEvent.getEventDate().year,
            currentEvent.getEventDate().month,
            currentEvent.getEventDate().day+1,
            clubOpeningTimesForThisDay.closingHour!,
            clubOpeningTimesForThisDay.closingHalfAnHour! == 1 ?
            30 : clubOpeningTimesForThisDay.closingHalfAnHour! == 2 ? 59 : 0
        );
      }

      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;

    }

    // Edge case: no official opening times. Maybe the club forgot to add this day?
    if(clubOpeningTimesForThisDay == null){

      // We will show the event for at least 6 hours of its duration
      closingHourToCompare = DateTime(
          currentEvent.getEventDate().year,
          currentEvent.getEventDate().month,
          currentEvent.getEventDate().day,
          currentEvent.getEventDate().hour+6,
        currentEvent.getEventDate().minute
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
          "UserEventsView. Fct: checkIfUpcomingEvent. "
              "Reached last else. Is not supposed to happen. Element title: ${currentEvent.getEventTitle()}, userID: ${userDataProvider.getUserData().getUserId()}");
      return false;

  }
  bool checkIfIsLiked(ClubMeEvent currentEvent) {
    var isLiked = false;
    if (currentAndLikedElementsProvider.getLikedEvents().contains(
        currentEvent.getEventId())) {
      isLiked = true;
    }
    return isLiked;
  }


  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);

    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      // Filter acted strange because of this. Without this, we dont need the padding for the
      // filter widget.
        extendBodyBehindAppBar: true,

        bottomNavigationBar:
        checkedForInfoScreen ? noInfoScreenToShow ?
        CustomBottomNavigationBar() : SizedBox() : SizedBox(),
        appBar: _buildAppbar(),
        body:
          checkedForInfoScreen ?
            noInfoScreenToShow ?
              _buildMainView() :
            _buildInfoScreen() :
            _buildLoadingScreen()
    );
  }
}
