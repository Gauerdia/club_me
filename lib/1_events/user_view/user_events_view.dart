import 'dart:async';
import 'dart:io';
import 'package:club_me/main.dart';
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
// import 'package:workmanager/workmanager.dart';
import '../../models/event.dart';
import '../../models/parser/club_me_event_parser.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../shared/custom_bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'components/event_tile.dart';

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

  @override
  void initState(){

    super.initState();
    requestStoragePermission();
    dropdownValue = Utils.genreListForFiltering.first;
    weekDayDropDownValue = Utils.weekDaysForFiltering.first;

    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen:  false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    // Get and set geo location
    _determinePosition().then(
            (value) => setPositionLocallyAndInSupabase(value)
    );

    // Get or check all events
    if(fetchedContentProvider.getFetchedEvents().isEmpty) {
      _supabaseService.getAllEvents().then(
              (data) => processEventsFromQuery(data)
      );
    }else{
      processEventsFromProvider(fetchedContentProvider);
    }

    // Update the last login time
    _supabaseService.updateUserData(
      ClubMeUserData(
          firstName: userDataProvider.getUserData().getFirstName(),
          lastName: userDataProvider.getUserData().getLastName(),
          birthDate: userDataProvider.getUserData().getBirthDate(),
          eMail: userDataProvider.getUserData().getEMail(),
          gender: userDataProvider.getUserData().getGender(),
          userId: userDataProvider.getUserData().getUserId(),
          profileType: userDataProvider.getUserData().getProfileType(),
          lastTimeLoggedIn: DateTime.now()
      )
    );


    // Get all locally saved liked events
    getAllLikedEvents(stateProvider);

    if(!stateProvider.updatedLastLogInForNow){
      _supabaseService.updateUserLastTimeLoggedIn(userDataProvider.getUserDataId()).then(
          (result){
            if(result == 0){
              stateProvider.toggleUpdatedLastLogInForNow();
            }else{
              /// TODO: elaborated error handling
            }
          }
      );
    }

  }


  // BUILD
  AppBar _buildAppbar(){

    return isSearchActive ?

    // Show the app bar with the search bar
    AppBar(
      surfaceTintColor: customStyleClass.backgroundColorMain,
      backgroundColor: customStyleClass.backgroundColorMain,
      title: Container(
        width: screenWidth,
        color: customStyleClass.backgroundColorMain,
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
                    ),
                  ],
                )
            ),

            // Search icon
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
                  Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: GestureDetector(
                        child: Container(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              Icons.filter_alt_outlined,
                              color: isAnyFilterActive || isFilterMenuActive ? customStyleClass.primeColor : Colors.white,
                            )
                        ),
                        onTap: (){
                          toggleIsFilterMenuActive();
                        },
                      )
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    ):

    // Show the app bar with the title
    AppBar(
        surfaceTintColor: customStyleClass.backgroundColorMain,
        backgroundColor: customStyleClass.backgroundColorMain,
        title: Container(
          width: screenWidth,
          color: customStyleClass.backgroundColorMain,
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
                                  headLine,
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

              // Search icon
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
                    Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: GestureDetector(
                          child: Container(
                              padding: const EdgeInsets.all(7),
                              child: Icon(
                                Icons.filter_alt_outlined,
                                color: isAnyFilterActive || isFilterMenuActive ? customStyleClass.primeColor : Colors.white,
                              )
                          ),
                          onTap: (){
                            toggleIsFilterMenuActive();
                          },
                        )
                    )
                  ],
                ),
              ),

            ],
          ),
        )
    );
  }
  Widget _buildMainView(){
    return Container(
        width: screenWidth,
        height: screenHeight,
        color: customStyleClass.backgroundColorMain,
        child: Stack(
          children: [

            // Build Supabase events
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
              Container(
                height: screenHeight*0.14,
                width: screenWidth,
                color: customStyleClass.backgroundColorMain,
                child: Row(
                  children: [

                    // Preis
                    SizedBox(
                      width: screenWidth*0.33,
                      child: Column(
                        children: [

                          // Spacer
                          SizedBox(
                            height: screenHeight*0.01,
                          ),

                          // Price
                          Text(
                            "Preis",
                            style: customStyleClass.getFontStyle3(),
                          ),

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

                    SizedBox(
                      width: screenWidth*0.33,
                      child: Column(
                        children: [

                          // Spacer
                          SizedBox(
                            height: screenHeight*0.01,
                          ),

                          // Genre
                          SizedBox(
                            width: screenWidth*0.28,
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
                            child: DropdownButton(
                                value: weekDayDropDownValue,
                                menuMaxHeight: 300,
                                items: Utils.weekDaysForFiltering.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: customStyleClass.getFontStyle4Grey2(),
                                        ),
                                      );
                                    }
                                ).toList(),
                                onChanged: (String? value){
                                  setState(() {
                                    weekDayDropDownValue = value!;
                                    filterEvents(fetchedContentProvider);
                                  });
                                }
                            ),
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

                          // Genre
                          Text(
                            "Musikrichtung",
                            style: customStyleClass.getFontStyle3(),
                          ),

                          // Dropdown
                          Theme(
                            data: Theme.of(context).copyWith(
                                canvasColor: customStyleClass.backgroundColorMain
                            ),
                            child: DropdownButton(
                                value: dropdownValue,
                                menuMaxHeight: 300,
                                items: Utils.genreListForFiltering.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: customStyleClass.getFontStyle4Grey2(),
                                        ),
                                      );
                                    }
                                ).toList(),
                                onChanged: (String? value){
                                  setState(() {
                                    dropdownValue = value!;
                                    filterEvents(fetchedContentProvider);
                                  });
                                }
                            ),
                          )


                        ],
                      ),
                    )
                  ],
                ),
              ),
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
          return GestureDetector(
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
    eventsToDisplay = fetchedContentProvider.getFetchedEvents();
    filterEvents(fetchedContentProvider);

    setState(() {
      processingComplete = true;
    });

    log.d("processEventsFromProvider: Successful");
  }
  void processEventsFromQuery(var data){



    for(var element in data){

      ClubMeEvent currentEvent = parseClubMeEvent(element);

      if(checkIfUpcomingEvent(currentEvent)){
        if(!fetchedContentProvider.getFetchedEvents().contains(currentEvent)){
          fetchedContentProvider.addEventToFetchedEvents(currentEvent);
          eventsToDisplay.add(currentEvent);
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

    setState(() {
      processingComplete = true;
    });

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

      // reset array
      eventsToDisplay = [];

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
      eventsToDisplay = fetchedContentProvider.getFetchedEvents();
    }
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
  void requestStoragePermission() async {
    // Check if the platform is not web, as web has no permissions
    if (!kIsWeb) {
      // Request storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      // Request camera permission
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        await Permission.camera.request();
      }
    }
  }
  bool checkIfUpcomingEvent(ClubMeEvent currentEvent){

    // We are only interested in the upcoming events. Here, we sort for them
    if(currentEvent.getEventDate().isAfter(stateProvider.getBerlinTime()) ||
        currentEvent.getEventDate().isAtSameMomentAs(stateProvider.getBerlinTime())){
      return true;
    }
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
        extendBodyBehindAppBar: false,
        bottomNavigationBar: CustomBottomNavigationBar(),
        appBar: _buildAppbar(),
        body: _buildMainView()
    );
  }
}
