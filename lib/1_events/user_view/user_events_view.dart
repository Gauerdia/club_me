import 'dart:async';
import 'dart:io';
import 'package:club_me/services/hive_service.dart';
import 'package:club_me/services/supabase_service.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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

  String headLine = "Deine Events";

  var log = Logger();

  late Future getEvents;
  late String dropdownValue;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _textEditingController = TextEditingController();

  List<ClubMeEvent> eventsToDisplay = [];
  List<ClubMeEvent> upcomingDbEvents = [];
  List<String> genresDropdownList = ["Alle", "Techno", "90s", "Latin"];

  String searchValue = "";
  bool isSearchActive = false;
  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;
  bool onlyFavoritesIsActive = false;

  double maxValueRangeSlider = 0;
  double maxValueRangeSliderToDisplay = 0;
  RangeValues _currentRangeValues = RangeValues(0, 10);

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
    color: Colors.black,
    // image: DecorationImage(image: AssetImage("assets/images/club_me_icon_round.png"))
  );


  @override
  void initState(){

    super.initState();
    requestStoragePermission();
    dropdownValue = genresDropdownList.first;

    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    if(fetchedContentProvider.getFetchedEvents().isEmpty) {
      getEvents = _supabaseService.getAllEvents();
    }
  }

  // FETCH
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
  void getAllLikedEvents(StateProvider stateProvider) async{
    try{
      var likedEvents = await _hiveService.getFavoriteEvents();
      currentAndLikedElementsProvider.setLikedEvents(likedEvents);
    }catch(e){
      _supabaseService.createErrorLog("getAllLikedEvents, getAllLikedEvents: $e");
    }
  }
  Widget _buildSupabaseEvents(StateProvider stateProvider, double screenHeight){

    // get today in correct format to check which events are upcoming
    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd hh:mm').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    // Get current time for germany
    // final berlin = tz.getLocation('Europe/Berlin');
    // final todayGermanTZ = tz.TZDateTime.from(DateTime.now(), berlin);


    if(fetchedContentProvider.getFetchedEvents().isEmpty){
      return FutureBuilder(
          future: getEvents,
          builder: (context, snapshot){

            // Error-handling
            if(snapshot.hasError){
              print("Error: ${snapshot.error}");
            }

            // Waiting for response
            if(!snapshot.hasData){
              return SizedBox(
                height: screenHeight,
                child: Center(
                  child: CircularProgressIndicator(
                    color: customStyleClass.primeColor,
                  ),
                ),
              );
              // Process response
            }else{

              try{
                final data = snapshot.data!;

                // The function will be called twice after the response.
                // Here, we avoid to fill the array twice as well.
                if(upcomingDbEvents.isEmpty){
                  for(var element in data){
                    ClubMeEvent currentEvent = parseClubMeEvent(element);

                    // Show only events that are not yet in the past.
                    if(
                    currentEvent.getEventDate().isAfter(stateProvider.getBerlinTime())
                        || currentEvent.getEventDate().isAtSameMomentAs(stateProvider.getBerlinTime())){

                      upcomingDbEvents.add(currentEvent);

                      // Check if we need to fetch the image
                      checkIfImageExistsLocally(currentEvent.getBannerId()).then((exists){
                        if(!exists){

                          // If we haven't started to fetch the image yet, we ought to
                          if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentEvent.getBannerId())){
                            fetchAndSaveBannerImage(currentEvent.getBannerId());
                          }
                        }else{
                          fetchedContentProvider.addFetchedBannerImageId(currentEvent.getBannerId());
                        }
                      });
                    }

                    // We collect all events so we dont have to reload them everytime
                    fetchedContentProvider.addEventToFetchedEvents(currentEvent);
                  }

                  // Sort so that the next events come up earliest
                  sortUpcomingEvents();
                  fetchedContentProvider.sortFetchedEvents();
                }

                filterEvents();
              }catch(e){
                _supabaseService.createErrorLog("_buildSupabaseEvents, _buildSupabaseEvents: " + e.toString());
              }

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
                          clickedOnLike: clickedOnLike,
                          clickedOnShare: clickedOnShare,
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
                      "Derzeit sind keine Events geplant!",
                    style: customStyleClass.getFontStyle3(),
                  ),
                ),
              );
            }
          }
      );
    }else{

      if(upcomingDbEvents.isEmpty){
        for(var currentEvent in fetchedContentProvider.getFetchedEvents()){
          if(
          currentEvent.getEventDate().isAfter(todayFormatted)
              || currentEvent.getEventDate().isAtSameMomentAs(todayFormatted)){
            upcomingDbEvents.add(currentEvent);
            if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentEvent.getBannerId())){

              checkIfImageExistsLocally(currentEvent.getBannerId()).then((exists){
                if(!exists){
                  fetchAndSaveBannerImage(currentEvent.getBannerId());
                }else{
                  fetchedContentProvider.addFetchedBannerImageId(currentEvent.getBannerId());
                }
              });

            }
          }
        }
      }

      filterEvents();

      return eventsToDisplay.isNotEmpty?
      ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: eventsToDisplay.length,
          itemBuilder: ((context, index){

            ClubMeEvent currentEvent = eventsToDisplay[index];

            var isLiked = false;
            if(currentAndLikedElementsProvider.getLikedEvents().contains(currentEvent.getEventId())){
              isLiked = true;
            }

            return GestureDetector(
              child: EventTile(
                  clubMeEvent: currentEvent,
                  isLiked: isLiked,
                  clickedOnLike: clickedOnLike,
                  clickedOnShare: clickedOnShare,
              ),
              onTap: (){
                currentAndLikedElementsProvider.setCurrentEvent(currentEvent);
                stateProvider.setAccessedEventDetailFrom(0);
                context.push('/event_details');
              },
            );
          })
      ): Container(
        height: screenHeight*0.8,
        width: screenWidth,
        child: Center(
          child: Text(
              "Derzeit sind keine Events geplant!",
            style: customStyleClass.getFontStyle3(),
          ),
        ),
      );
    }
  }


  // FILTER
  void filterEvents(){

    // Just set max at the very beginning
    if(maxValueRangeSlider == 0){
      for(var element in upcomingDbEvents){
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
        dropdownValue != genresDropdownList[0] ||
        searchValue != "" ||
        onlyFavoritesIsActive
    ){

      // set for coloring
      if(_currentRangeValues.end != maxValueRangeSlider ||
          _currentRangeValues.start != 0 ||
          dropdownValue != genresDropdownList[0] ||
          onlyFavoritesIsActive){
        isAnyFilterActive = true;
      }else{
        isAnyFilterActive = false;
      }

      // reset array
      eventsToDisplay = [];

      // Iterate through all available events
      for(var event in upcomingDbEvents){

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
        if(dropdownValue != genresDropdownList[0] ){
          if(!event.getMusicGenres().toLowerCase().contains(dropdownValue.toLowerCase())){
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
      eventsToDisplay = upcomingDbEvents;
    }
  }
  void sortUpcomingEvents(){

    // First sort for date
    upcomingDbEvents.sort((a,b) =>
        a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
    );

    // Then go through the sorted array and sort for priority
      upcomingDbEvents.sort((a,b){
        var tempA = DateTime(a.getEventDate().year, a.getEventDate().month, a.getEventDate().day);
        var tempB = DateTime(b.getEventDate().year, b.getEventDate().month, b.getEventDate().day);
        bool cmp = tempB.isAfter(tempA);
        if(cmp == true) return 0;
        return b.getPriorityScore() > a.getPriorityScore() ?
        1 :  0;
      });
  }
  void filterForFavorites(){
    setState(() {
      onlyFavoritesIsActive = !onlyFavoritesIsActive;
      filterEvents();
    });
  }


  // Click/TOGGLE
  void clickedOnLike(StateProvider stateProvider, String eventId){
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


  // BUILD
  Widget _buildAppBarShowTitle(){
    return Container(
      width: screenWidth,
      color: Colors.black,
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
                  Text(
                      headLine,
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle1()
                  ),
                ],
              )
          ),

          // Search icon
          Container(
              width: screenWidth,
              alignment: Alignment.centerLeft,
              // color: Colors.grey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () => toggleIsSearchActive(),
                      icon: Icon(
                        Icons.search,
                        color: searchValue != "" ? customStyleClass.primeColor : Colors.grey,
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
            // color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () => filterForFavorites(),
                    icon: Icon(
                      Icons.stars,
                      color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.grey,
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: GestureDetector(
                      child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xff11181f),
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Icon(
                            Icons.filter_list_sharp,
                            color: isAnyFilterActive ? customStyleClass.primeColor : Colors.grey,
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
    );
  }
  Widget _buildAppbarShowSearch(){
    return Container(
      width: screenWidth,
      color: Colors.black,
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
                          filterEvents();
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
                        color: searchValue != "" ? customStyleClass.primeColor : Colors.grey,
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
                      Icons.stars,
                      color: onlyFavoritesIsActive ? customStyleClass.primeColor : Colors.grey,
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: GestureDetector(
                      child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xff11181f),
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Icon(
                            Icons.filter_list_sharp,
                            color: isAnyFilterActive ? customStyleClass.primeColor : Colors.grey,
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
    );
  }


  // MISC
  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    return connectivityResult != ConnectivityResult.none;
  }
  bool checkIfIsLiked(ClubMeEvent currentEvent) {
    var isLiked = false;
    if (currentAndLikedElementsProvider.getLikedEvents().contains(
        currentEvent.getEventId())) {
      isLiked = true;
    }
    return isLiked;
  }
  Future<bool> checkIfImageExistsLocally(String fileName) async{
    final String dirPath = stateProvider.appDocumentsDir.path;
    return await File('$dirPath/$fileName').exists();
  }


  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);

    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    getAllLikedEvents(stateProvider);

    return Scaffold(

        // extendBody: true,
        extendBodyBehindAppBar: false,

        bottomNavigationBar: CustomBottomNavigationBar(),
        appBar: isSearchActive ?
        AppBar(
          surfaceTintColor: Colors.black,
          backgroundColor: Colors.transparent,
          title: _buildAppbarShowSearch(),
        ):
        AppBar(
            // https://stackoverflow.com/questions/72379271/flutter-material3-disable-appbar-color-change-on-scroll
            surfaceTintColor: Colors.black,
            backgroundColor: Colors.transparent,
          title: _buildAppBarShowTitle()
        ),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            decoration: plainBlackDecoration, //gradientDecoration,
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

                        _buildSupabaseEvents(stateProvider, screenHeight),

                        // Spacer
                        SizedBox(height: screenHeight*0.1,),
                      ],
                    )
                ),

                // Filter menu
                isFilterMenuActive?Container(
                  height: screenHeight*0.14,
                  width: screenWidth,
                  color: const Color(0xff2b353d),
                  child: Row(
                    children: [

                      // Preis
                      SizedBox(
                        width: screenWidth*0.5,
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
                                  });
                                },
                              activeColor: customStyleClass.primeColor,
                              inactiveColor: customStyleClass.primeColor,
                              overlayColor: WidgetStateProperty.all(customStyleClass.primeColorDark),
                            )
                          ],
                        ),
                      ),

                      // Genre filter
                      SizedBox(
                        width: screenWidth*0.5,
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
                            DropdownButton(
                                value: dropdownValue,
                                items: genresDropdownList.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                              value,
                                            style: customStyleClass.getFontStyle4Grey2(),
                                          )
                                      );
                                    }
                                ).toList(),
                                onChanged: (String? value){
                                  setState(() {
                                    dropdownValue = value!;
                                    filterEvents();
                                  });
                                }
                            )


                          ],
                        ),
                      )
                    ],
                  ),
                ):Container(),
              ],
            )
        )
    );
  }
}
