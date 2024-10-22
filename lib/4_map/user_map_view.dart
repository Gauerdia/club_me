import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:club_me/4_map/components/club_info_bottom_sheet.dart';
import 'package:club_me/4_map/components/widget_to_map_icon.dart';
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
import 'package:widget_to_marker/widget_to_marker.dart';
import '../models/parser/club_me_club_parser.dart';
import '../provider/current_and_liked_elements_provider.dart';
import '../provider/fetched_content_provider.dart';
import '../provider/state_provider.dart';
import '../provider/user_data_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';
import 'components/club_list_item.dart';
import 'components/text_on_image.dart';

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

  BitmapDescriptor? userIcon, clubIcon, trustedClubIcon;

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
  bool showFilterMenu = false;
  bool isAnyFilterActive = false;


  List<String> alreadySetPins = [];
  List<ClubMeClub> clubsToDisplay = [];
  List<Widget> listWidgetsToDisplay = [];

  late Map<String, Marker> _markers = {};

  bool showMap = false;

  // INIT
  @override
  void initState() {
    super.initState();

    weekDayDropDownValue = Utils.weekDaysForFiltering.first;

    startPeriodicGeoLocatorStream();

    checkAndFetchClubs();

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


  Future<void> checkAndFetchClubs() async{

    stateProvider = Provider.of<StateProvider>(context, listen: false);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);


    // Do we need to fetch?
    if(fetchedContentProvider.getFetchedClubs().isEmpty){

      var data = await _supabaseService.getAllClubs();

      for(var element in data){

        ClubMeClub currentClub = parseClubMeClub(element);
        fetchedContentProvider.addClubToFetchedClubs(currentClub);
        clubsToDisplay.add(currentClub);

        setBasicMarker(currentClub);

      }

      // Check if we need to download the corresponding images
      _checkAndFetchService.checkAndFetchClubImages(
          fetchedContentProvider.getFetchedClubs(),
          stateProvider,
          fetchedContentProvider,
          false
      );

      setUserLocationMarker();

    }
    // Have we already fetched?
    else{
      for(var currentClub in fetchedContentProvider.getFetchedClubs()){
        clubsToDisplay.add(currentClub);
        setBasicMarker(currentClub);
      }

      // Check if we need to download the corresponding images
      _checkAndFetchService.checkAndFetchClubImages(
          fetchedContentProvider.getFetchedClubs(),
          stateProvider,
          fetchedContentProvider,
          false
      );

      setUserLocationMarker();

    }

    setState(() {
      showMap = true;
    });

  }


  // BUILD
  Widget _buildMainView(){
    return Container(
        width: screenWidth,
        height: screenHeight,
        color:customStyleClass.backgroundColorMain,
        child: Stack(
          children: [

            // GOOGLE MAP

            SizedBox(
                height:screenHeight*0.79,
                child: showMap ?
                    _buildFlutterMap() :
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
            if(showBottomSheet)
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.only(
                    bottom: 35
                ),
                alignment: Alignment.bottomCenter,
                child: ClubInfoBottomSheet(
                    showBottomSheet: showBottomSheet,
                    clubMeEvent: noEventAvailable ? null : clubMeEventToDisplay,
                    noEventAvailable: noEventAvailable
                ),
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

            // Filter menu
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
                            // width: screenWidth*0.28,
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
                            child:

                            DropdownMenu<String>(
                              width: 150,
                              initialSelection: weekDayDropDownValue,
                              onSelected: (String? value){
                                setState(() {
                                  weekDayDropDownValue = value!;
                                  filterClubs();
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
                  ],
                ),
              ),
          ],
        )
    );
  }
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
  AppBar _buildAppBar(){
    return AppBar(
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title: SizedBox(
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
                        color: (isAnyFilterActive || showFilterMenu) ? customStyleClass.primeColor : Colors.white,
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
                        color: showListIsActive ? customStyleClass.primeColor : Colors.white,
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
      ),
    );
  }


  // MARKERS
  void setBasicMarker(ClubMeClub currentClub) async{

    try{

      if(currentClub.closePartner){

        await TextOnImage(
            text: "Hello World",
            index: 1
        ).toBitmapDescriptor(
            logicalSize: const Size(250, 250), imageSize: const Size(250, 250)
        ).then((response) => {
          _markers[currentClub.getClubId()] = Marker(
              markerId: MarkerId(currentClub.getClubId()),
              position: LatLng(
                  currentClub.getGeoCoordLat(),
                  currentClub.getGeoCoordLng()
              ),
              onTap: () => onTapEventMarker(currentClub),
              icon: response
          )
        });

        setState(() {});

      }else{

        await TextOnImage(
            text: "Hello World",
            index: 2
        ).toBitmapDescriptor(
            logicalSize: const Size(150, 150), imageSize: const Size(150, 150)
        ).then((response) => {
          _markers[currentClub.getClubId()] = Marker(
              markerId: MarkerId(currentClub.getClubId()),
              position: LatLng(
                  currentClub.getGeoCoordLat(),
                  currentClub.getGeoCoordLng()
              ),
              onTap: () => onTapEventMarker(currentClub),
              icon: response
          )
        });
        setState(() {});
      }

    }catch(e){
      print("Error in UserMapView. Fct: setBasicMarker. Error: $e. Platform: ${Platform.isIOS? "iOS" : "Android"}");
      _supabaseService.createErrorLog("Error in UserMapView. Fct: setBasicMarker. Error: $e. Platform: ${Platform.isIOS? "iOS" : "Android"}");
    }

  }
  void setUserLocationMarker() async{


    try{

      userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

      log.d("UserMapView. Fct: setUserLocationMarker: Cuurrent UserDataProvider values: "
          "Lat(${userDataProvider.getUserLatCoord()}), Long(${userDataProvider.getUserLongCoord()})");

      await TextOnImage(
        text: "Hello World",
        index: 0
      ).toBitmapDescriptor(
          logicalSize: const Size(50, 50), imageSize: const Size(50, 50)
      ).then((response) => {
        _markers['user_location'] = Marker(
          markerId: const MarkerId("user_location"),
          position: LatLng(
          userDataProvider.getUserLatCoord(),
          userDataProvider.getUserLongCoord()
          ),
          icon: response
        )
      });

      setState(() {});

    }catch(e){
      _supabaseService.createErrorLog(
          "Error in UserMapView. Fct: setUserLocationMarker. Error: $e. Version >= 1.0.90"
      );
    }

  }


  // MAP
  Future<void> _onMapCreated(GoogleMapController controller) async{
    mapController = controller;
  }
  void onTapEventMarker(ClubMeClub club){

    try{
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
    }catch(e){
      _supabaseService.createErrorLog(
          "Error in UserMapView. Fct: onTapEventMarker. Error: $e"
      );
    }

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


  // Geo location services
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

        userDataProvider.setUserCoordinates(position);

        if(DateTime.now().isAfter(userDataProvider.getEarliestNextDBLocationUpdate())){
          uploadPositionToSupabase(position);
          userDataProvider.setEarliestNextDBLocationUpdate(
            DateTime.now().add(const Duration(seconds: 5))
          );
        }
      });
    });
  }
  void uploadPositionToSupabase(Position value) async{

    log.d("UserMapView. Fct: uploadPositionToSupabase. Values: $value");

    // final userDataProvider = Provider.of<UserDataProvider>(context);

    userDataProvider.setUserCoordinates(value);

    // Set marker for user
    setUserLocationMarker();

    _supabaseService.saveUsersGeoLocation(
        userDataProvider.getUserDataId(),
        value.latitude,
        value.longitude
    );
  }


  // MISC
  Future<void> filterClubs() async {

    // The current array of clubs we want to display
    clubsToDisplay = [];

    // Necessary for filtering
    _markers = {};

    // Any filter active?
    if(weekDayDropDownValue != Utils.weekDaysForFiltering[0]){

      // the provider is the source of all clubs available
      for(ClubMeClub club in fetchedContentProvider.getFetchedClubs()){

        int chosenDayIndex = Utils.weekDaysForFiltering.indexWhere(
                (element) => element == weekDayDropDownValue
        );

        bool atleastOneDayFits = false;

        // check if the chosen day is set as an opening day
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


      for(var currentClub in clubsToDisplay){
        setBasicMarker(currentClub);
      }

      isAnyFilterActive = true;

    }else{

      for(var club in fetchedContentProvider.getFetchedClubs()){
        clubsToDisplay.add(club);
        setBasicMarker(club);
      }

      isAnyFilterActive = false;
    }

    setUserLocationMarker();

    clubsToDisplay.sort((a,b) => b.getPriorityScore().compareTo(a.getPriorityScore()));

    setState(() {});

  }

  @override
  Widget build(BuildContext context) {

    initGeneralSettings();

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: _buildAppBar(),
      body: _buildMainView(),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   setState(() {
      //     _markers["test"] = const Marker(
      //       markerId: MarkerId("test"),
      //       position:  LatLng(48.773809, 9.182959),
      //     );
      //   });
      // }),
    );
  }
}





