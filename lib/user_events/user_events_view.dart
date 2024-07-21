import 'package:club_me/services/hive_service.dart';
import 'package:club_me/services/supabase_service.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../models/parser/club_me_event_parser.dart';
import '../provider/state_provider.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import 'components/event_tile.dart';
import 'package:intl/intl.dart';

import 'package:timezone/standalone.dart' as tz;

class UserEventsView extends StatefulWidget {
  const UserEventsView({Key? key}) : super(key: key);

  @override
  State<UserEventsView> createState() => _UserEventsViewState();
}

class _UserEventsViewState extends State<UserEventsView> {

  String headLine = "Deine Events";

  var logger = Logger();

  late Future getEvents;
  late String dropdownValue;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

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


  @override
  void initState(){

    super.initState();
    requestStoragePermission();
    dropdownValue = genresDropdownList.first;

    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    if(stateProvider.getFetchedEvents().isEmpty) {
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
  void getAllLikedEvents(StateProvider stateProvider) async{
    try{
      var likedEvents = await _hiveService.getFavoriteEvents();
      stateProvider.setLikedEvents(likedEvents);
    }catch(e){
      _supabaseService.createErrorLog("user_events, getAllLikedEvents: " + e.toString());
    }
  }
  Widget _buildSupabaseEvents(StateProvider stateProvider, double screenHeight){

    // get today in correct format to check which events are upcoming
    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd hh:mm').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    // Get current time for germany
    final berlin = tz.getLocation('Europe/Berlin');
    final todayGermanTZ = tz.TZDateTime.from(DateTime.now(), berlin);


    if(stateProvider.getFetchedEvents().isEmpty){
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
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              // Process response
            }else{

              try{
                final data = snapshot.data!;

                // The function will be called twice after the response. Here, we avoid to fill the array twice as well.
                if(upcomingDbEvents.isEmpty){
                  for(var element in data){
                    ClubMeEvent currentEvent = parseClubMeEvent(element);

                    // Show only events that are not yet in the past.
                    if(
                    currentEvent.getEventDate().isAfter(todayGermanTZ)
                        || currentEvent.getEventDate().isAtSameMomentAs(todayGermanTZ)){
                      upcomingDbEvents.add(currentEvent);
                    }

                    // We collect all events so we dont have to reload them everytime
                    stateProvider.addEventToFetchedEvents(currentEvent);
                  }

                  // Sort so that the next events come up earliest
                  sortUpcomingEvents();
                  stateProvider.sortFetchedEvents();
                }

                filterEvents();
              }catch(e){
                _supabaseService.createErrorLog("user_events, _buildSupabaseEvents: " + e.toString());
              }

              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventsToDisplay.length,
                  itemBuilder: ((context, index){

                    // Check if the event was already liked by the user
                    var isLiked = false;
                    if(stateProvider.getLikedEvents().contains(eventsToDisplay[index].getEventId())){
                      isLiked = true;
                    }

                    // return clickable widget
                    return GestureDetector(
                      child: EventTile(
                          clubMeEvent: eventsToDisplay[index],
                          isLiked: isLiked,
                          clickedOnLike: clickedOnLike,
                          clickedOnShare: clickedOnShare
                      ),
                      onTap: (){
                        stateProvider.setCurrentEvent(eventsToDisplay[index]);
                        context.push('/event_details');
                      },
                    );
                  })
              );
            }
          }
      );
    }else{

      if(upcomingDbEvents.isEmpty){
        for(var currentEvent in stateProvider.getFetchedEvents()){
          if(
          currentEvent.getEventDate().isAfter(todayFormatted)
              || currentEvent.getEventDate().isAtSameMomentAs(todayFormatted)){
            upcomingDbEvents.add(currentEvent);
          }
        }
      }

      filterEvents();

      return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: eventsToDisplay.length,
          itemBuilder: ((context, index){

            ClubMeEvent currentEvent = eventsToDisplay[index];

            var isLiked = false;
            if(stateProvider.getLikedEvents().contains(currentEvent.getEventId())){
              isLiked = true;
            }

            return GestureDetector(
              child: EventTile(
                  clubMeEvent: currentEvent,
                  isLiked: isLiked,
                  clickedOnLike: clickedOnLike,
                  clickedOnShare: clickedOnShare
              ),
              onTap: (){
                stateProvider.setCurrentEvent(currentEvent);
                context.push('/event_details');
              },
            );
          })
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
    for(var e in upcomingDbEvents){
      var date = e.getEventDate();
      // print("Vorher: $date");
    }
    upcomingDbEvents.sort((a,b) =>
        a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
    );
    for(var e in upcomingDbEvents){
      var date = e.getEventDate();
      // print("Nachher: $date");
    }
  }
  void filterForFavorites(){
    setState(() {
      onlyFavoritesIsActive = !onlyFavoritesIsActive;
      filterEvents();
    });
  }
  bool checkIfIsLiked(ClubMeEvent currentEvent) {
    var isLiked = false;
    if (stateProvider.getLikedEvents().contains(
        currentEvent.getEventId())) {
      isLiked = true;
    }
    return isLiked;
  }

  // Click/TOGGLE
  void clickedOnLike(StateProvider stateProvider, String eventId){
    setState(() {
      if(stateProvider.getLikedEvents().contains(eventId)){
        stateProvider.deleteLikedEvent(eventId);
        _hiveService.deleteFavoriteEvent(eventId);
      }else{
        stateProvider.addLikedEvent(eventId);
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
                  Text(headLine,
                      textAlign: TextAlign.center,
                      style: customTextStyle.size2()
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
                        color: searchValue != "" ? stateProvider.getPrimeColor() : Colors.grey,
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
                      color: onlyFavoritesIsActive ? stateProvider.getPrimeColor() : Colors.grey,
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
                            color: isAnyFilterActive ? stateProvider.getPrimeColor() : Colors.grey,
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
                        color: searchValue != "" ? stateProvider.getPrimeColor() : Colors.grey,
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
                      color: onlyFavoritesIsActive ? stateProvider.getPrimeColor() : Colors.grey,
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
                            color: isAnyFilterActive ? stateProvider.getPrimeColor() : Colors.grey,
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

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    getAllLikedEvents(stateProvider);

    return Scaffold(

        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBar(),
        appBar: isSearchActive ?
        AppBar(
          automaticallyImplyLeading: false,
          title: _buildAppbarShowSearch(),
        ):
        AppBar(
            automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: _buildAppBarShowTitle()
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
                            const Text(
                                "Preis"
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
                                }
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
                                "Musikrichtung"
                            ),

                            // Dropdown
                            DropdownButton(
                                value: dropdownValue,
                                items: genresDropdownList.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem(value: value,child: Text(value));
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
                ):Container()
              ],
            )
        )
    );
  }
}
