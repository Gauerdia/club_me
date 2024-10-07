import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:club_me/4_map/components/club_info_bottom_sheet.dart';
import 'package:club_me/models/club.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar.dart';
import 'package:club_me/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../models/parser/club_me_club_parser.dart';
import '../provider/current_and_liked_elements_provider.dart';
import '../provider/fetched_content_provider.dart';
import '../provider/state_provider.dart';
import '../provider/user_data_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';
import 'components/club_list_item.dart';


class UserMapView extends StatefulWidget {
  const UserMapView({Key? key}) : super(key: key);

  @override
  State<UserMapView> createState() => _UserMapViewState();
}

class _UserMapViewState extends State<UserMapView>{

  List<String> headline = ["Karte", "Liste"];

  late GoogleMapController mapController;

  late String weekDayDropDownValue;

  var log = Logger();

  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  List<BitmapDescriptor> customIcons = [];

  late ClubMeEvent clubMeEventToDisplay;
  late double screenWidth, screenHeight;
  late CustomStyleClass customStyleClass;

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  final SupabaseService _supabaseService = SupabaseService();
  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();

  bool isClubsFetched = false;
  bool showBottomSheet = false;
  bool showListIsActive = false;
  bool noEventAvailable = false;

  bool allPinsLoaded = false;

  bool isAnyFilterActive = false;
  bool showFilterMenu = false;

  List<String> alreadySetPins = [];
  
  List<Widget> listWidgetsToDisplay = [];

  List<ClubMeClub> clubsToDisplay = [];

  late Map<String, Marker> _markers = {};



  // INIT

  @override
  void initState() {
    super.initState();

    weekDayDropDownValue = Utils.weekDaysForFiltering.first;

    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    if(fetchedContentProvider.getFetchedClubs().isEmpty){
      _supabaseService.getAllClubs().then((data) => processClubsFromQuery(data));
    }else{
      processClubsFromProvider(fetchedContentProvider);
    }

    _determinePosition().then((value) => uploadPositionToSupabase(value));

    startPeriodicGeoLocatorStream();

  }
  void initGeneralSettings(){
    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);

  }


  // PROCESS FETCHED CONTENT
  void processClubsFromQuery(var data) async{

    for(var element in data){
      ClubMeClub currentClub = parseClubMeClub(element);


      if(!fetchedContentProvider.getFetchedClubs().contains(currentClub)){
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

    filterClubs();

    _getUserLocation();

    for(var club in fetchedContentProvider.getFetchedClubs()){

      var icon = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(46,46)),
          "assets/images/beispiel_100x100.png"
      );

      // Set base markers for all clubs
      final marker = Marker(
        icon: icon,
        onTap: () => onTapEventMarker(club),
        markerId: MarkerId(club.getClubId()),
        position: LatLng(club.getGeoCoordLat(), club.getGeoCoordLng(),
        ),
      );
      _markers[club.getClubId()] = marker;

    }

    checkForMapPinImagesUntilAllAreLoaded();
    
    setUserLocationMarker();

    setState(() {

    });
  }
  
  void checkForMapPinImagesUntilAllAreLoaded() async{

    bool allPinsSet = true;

    for(var club in fetchedContentProvider.getFetchedClubs()){

      if(!alreadySetPins.contains(club.getMapPinImageName())){

        bool fileExists = await _checkAndFetchService.checkIfImageExistsLocally(club.getMapPinImageName(), stateProvider);
        if(fileExists){
          setState(() {
            alreadySetPins.add(club.getMapPinImageName());
            setCustomMarker(club);
          });
        }else{
          allPinsSet = false;
        }
      }
    }

    if(allPinsSet){
      allPinsLoaded = true;
    }
  }
  
  void processClubsFromProvider(FetchedContentProvider fetchedContentProvider) async{

    for(var club in fetchedContentProvider.getFetchedClubs()){

      var icon = await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(46,46)),
          "assets/images/beispiel_100x100.png"
      );

      // Set base markers for all clubs
      final marker = Marker(
        icon: icon,
        onTap: () => onTapEventMarker(club),
        markerId: MarkerId(club.getClubId()),
        position: LatLng(club.getGeoCoordLat(), club.getGeoCoordLng(),
        ),
      );
      _markers[club.getClubId()] = marker;


    }

    filterClubs();

    setUserLocationMarker();
  }

  void setCustomMarker(ClubMeClub club){

    File file = File(
        "${stateProvider.appDocumentsDir.path}/${club.getMapPinImageName()}"
    );

    Uint8List bytes = file.readAsBytesSync();

    var icon = BitmapDescriptor.bytes(bytes, width: 46, height: 46);

    customIcons.add(icon);

    final marker = Marker(
      icon: icon,
      onTap: () => onTapEventMarker(club),
      markerId: MarkerId(club.getClubId()),
      position: LatLng(club.getGeoCoordLat(), club.getGeoCoordLng(),
      ),
    );
    _markers[club.getClubId()] = marker;
  }
  
  // MAP
  Future<void> _onMapCreated(GoogleMapController controller) async{
    mapController = controller;
  }
  void onTapEventMarker(ClubMeClub club){

    if(fetchedContentProvider.fetchedEvents
        .where(
            (event) => (event.getClubId() == club.getClubId() && event.getEventDate().isAfter(DateTime.now()))
        ).isEmpty
    ){
      noEventAvailable = true;
    }else{
      clubMeEventToDisplay = fetchedContentProvider.fetchedEvents.firstWhere(
              (event) => (event.getClubId() == club.getClubId() && event.getEventDate().isAfter(DateTime.now()))
      );
      noEventAvailable = false;
    }
    currentAndLikedElementsProvider.setCurrentClub(club);
    toggleShowBottomSheet();
  }

  // TOGGLE
  void toggleShowBottomSheet(){
    setState(() {
      showBottomSheet = !showBottomSheet;
    });
  }
  void toggleShowListIsActive(){
    setState(() {
      showListIsActive = !showListIsActive;
    });
  }
  void toggleShowFilterMenu(){
    setState(() {
      showFilterMenu = !showFilterMenu;
    });
  }


  void setUserLocationMarker() async{
    // Set marker for user
    // var icon = await BitmapDescriptor.asset(
    //     const ImageConfiguration(size: Size(46,46)),
    //     "assets/images/marker1.png"
    // );

    _markers['user_location'] = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(userDataProvider.getUserLatCoord(), userDataProvider.getUserLongCoord()),
    );
  }

  // BUILD
  Widget _buildFlutterMap(){

    return GoogleMap(
      style: Utils.mapStyles,
      onMapCreated: _onMapCreated,
        mapToolbarEnabled: false,
        initialCameraPosition: const CameraPosition(
            target: LatLng(48.773809, 9.182959),
            zoom: 11.0
        ),
      markers: _markers.values.toSet(),
      myLocationButtonEnabled: false,
    );

  }
  Widget _buildAppBar(){

    return SizedBox(
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
                              showListIsActive ? headline[1] : headline[0],
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
            height: 50,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    child:  Icon(
                      Icons.filter_alt_outlined,
                      color: isAnyFilterActive ? customStyleClass.primeColor : Colors.grey,
                    ),
                  ),
                  onTap: (){
                    toggleShowFilterMenu();
                  },
                ),

                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    child:  Icon(
                      Icons.format_list_bulleted,
                      color: showListIsActive ? customStyleClass.primeColor : Colors.grey,
                    ),
                  ),
                  onTap: (){
                    toggleShowListIsActive();
                  },
                )
              ],
            ),
          )

        ],
      ),
    );
  }

  void filterClubs(){

    if(weekDayDropDownValue != Utils.weekDaysForFiltering[0]){

      clubsToDisplay = [];

      for(ClubMeClub club in fetchedContentProvider.getFetchedClubs()){

        int chosenDayIndex = Utils.weekDaysForFiltering.indexWhere((element) => element == weekDayDropDownValue);

        bool atleastOneDayFits = false;

        for(var days in club.getOpeningTimes().days!){

          int weekDayToCompare = days.day!;

          // Some clubs start at 0 am so we have to adjust the algorithm to consider them
          if(days.openingHour! < 10){
            weekDayToCompare = days.day! - 1;
          }

          if(weekDayToCompare == chosenDayIndex){
            atleastOneDayFits = true;
          }
        }
        if(atleastOneDayFits) clubsToDisplay.add(club);

      }

      _markers = {};
      for(var club in clubsToDisplay){
        setCustomMarker(club);
      }

      isAnyFilterActive = true;

      setState(() {});

    }else{

      _markers = {};

      for(var club in fetchedContentProvider.getFetchedClubs()){
        clubsToDisplay.add(club);
        setCustomMarker(club);
      }

      isAnyFilterActive = false;
      setState(() {

      });
    }
  }

  // Geo location services
  _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    setUserLocationMarker();

    setState(() {});
  }
  void startPeriodicGeoLocatorStream(){
    Timer.periodic(const Duration(seconds: 10), (timer){

      log.d("Periodic timer triggered");

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(
          locationSettings: locationSettings).listen((Position position) {
        log.d('Location updated: ${position.latitude}, ${position.longitude}');
        uploadPositionToSupabase(position);
      });
    });
  }
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
  void uploadPositionToSupabase(Position value) async{

    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    userDataProvider.setUserCoordinates(value);

    // Set marker for user
    setUserLocationMarker();

    _supabaseService.saveUsersGeoLocation(userDataProvider.getUserDataId(), value.latitude, value.longitude);
  }

  @override
  Widget build(BuildContext context) {

    initGeneralSettings();

    if(!allPinsLoaded){
      checkForMapPinImagesUntilAllAreLoaded();
    }

    return Scaffold(

      extendBody: true,

      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        backgroundColor: customStyleClass.backgroundColorMain,
        surfaceTintColor: customStyleClass.backgroundColorMain,
        title: _buildAppBar(),
      ),
      body: Container(
        width: screenWidth,
          height: screenHeight,
          color:customStyleClass.backgroundColorMain,
          child: Column(
            children: [

              // Content
              SizedBox(
                width: screenWidth,
                height: screenHeight*0.83,
                child: Stack(
                  children: [

                    // GOOGLE MAP
                    SizedBox(
                      height:screenHeight*0.8,
                      child: allPinsLoaded ?
                        _buildFlutterMap():
                        Center(
                          child: CircularProgressIndicator(
                            color: customStyleClass.primeColor,
                          ),
                        )
                    ),

                    // transparent layer to click out of bottom sheet
                    if(showBottomSheet)
                      GestureDetector(
                          child: Container(
                            width: screenWidth,
                            height: screenHeight*0.83,
                            color: Colors.transparent,
                          ),
                          onTap: (){
                            toggleShowBottomSheet();
                          },
                        ),

                    // The bottom info container
                    GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 10
                        ),
                        alignment: Alignment.bottomCenter,
                        child: showBottomSheet ?
                          noEventAvailable?
                          ClubInfoBottomSheet
                          (showBottomSheet: showBottomSheet,
                            clubMeEvent: null,
                            noEventAvailable: noEventAvailable
                        ):ClubInfoBottomSheet
                          (showBottomSheet: showBottomSheet,
                            clubMeEvent: clubMeEventToDisplay,
                            noEventAvailable: noEventAvailable
                        )
                            : Container(),

                      ),
                      onTap: (){
                        // club will be set in stateprovider when clicked on marker
                        context.push("/club_details");
                      },
                    ),

                    // Grey background when list active
                    if(showListIsActive)
                      GestureDetector(
                          child: Container(
                            width: screenWidth,
                            height: screenHeight,
                            color: customStyleClass.backgroundColorMain.withOpacity(0.95),
                          ),
                          onTap: (){
                            setState(() {
                              showListIsActive = false;
                            });
                          },
                        ),

                    // List view of clubs
                    if(showListIsActive)
                      Padding(
                            padding: const EdgeInsets.only(
                            ),
                          child: Center(

                            // Whole list background
                            child: Container(
                              height: screenHeight,
                              // color: Colors.red,
                              padding: const EdgeInsets.only(
                                // top: 20,
                                bottom: 20
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [

                                    // Spacer
                                    const SizedBox(
                                      height: 10,
                                    ),

                                    for( ClubMeClub club in clubsToDisplay)
                                      ClubListItem(
                                          currentClub: club,
                                      ),

                                    const SizedBox(
                                      height: 50,
                                    ),
                                  ],
                                ),
                              )

                            ),
                          )
                        ),

                    if(showFilterMenu)
                      Container(
                      height: screenHeight*0.14,
                      width: screenWidth,
                      color: customStyleClass.backgroundColorMain,
                      child: Row(
                        children: [

                          SizedBox(
                            width: screenWidth,
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
                                          filterClubs();
                                        });
                                      }
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              )

            ],
          )
          ),
    );
  }
}





