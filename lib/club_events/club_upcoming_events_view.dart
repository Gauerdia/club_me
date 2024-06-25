import 'package:club_me/shared/custom_bottom_navigation_bar.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../provider/state_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';

import 'package:intl/intl.dart';

import '../shared/custom_text_style.dart';
import '../user_events/components/event_tile.dart';

class ClubUpcomingEventsView extends StatefulWidget {
  const ClubUpcomingEventsView({Key? key}) : super(key: key);

  @override
  State<ClubUpcomingEventsView> createState() => _ClubUpcomingEventsViewState();
}

class _ClubUpcomingEventsViewState extends State<ClubUpcomingEventsView> {

  String headLine = "Kommende Events";

  var logger = Logger();

  String searchValue = "";
  bool isSearchActive = false;

  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;

  late String dropdownValue;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

  List<ClubMeEvent> eventsToDisplay = [];
  List<String> genresDropdownList = [
    "Alle", "Techno", "90s", "Latin"
  ];
  List<ClubMeEvent> upcomingDbEvents = [];

  RangeValues _currentRangeValues = const RangeValues(0, 30);

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _textEditingController = TextEditingController();


  @override
  void initState(){
    super.initState();
    dropdownValue = genresDropdownList.first;
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

          // back icon
          Container(
              width: screenWidth,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => context.go("/club_events"),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.grey,
                      // size: 20,
                    ),
                  )
                ],
              )
          ),

        ],
      ),
    );
  }
  void getAllLikedEvents(StateProvider stateProvider) async{
    var likedEvents = await _hiveService.getFavoriteEvents();
    stateProvider.setLikedEvents(likedEvents);
  }
  Widget _buildView(StateProvider stateProvider, double screenHeight){

    // get today in correct format to check which events are upcoming
    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    if(upcomingDbEvents.isEmpty){
      for(var currentEvent in stateProvider.getFetchedEvents()){
        if( currentEvent.getClubId() == stateProvider.userClub.getClubId() &&
            (currentEvent.getEventDate().isAfter(todayFormatted)
                || currentEvent.getEventDate().isAtSameMomentAs(todayFormatted))){
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
              context.go('/event_details');
            },
          );
        })
    );
  }


  // FILTER
  void filterEvents(){

    // Check if any filter is applied
    if(
    _currentRangeValues.end != 30 ||
        _currentRangeValues.start != 0 ||
        dropdownValue != genresDropdownList[0] ||
        searchValue != ""
    ){

      // set for coloring
      isAnyFilterActive = true;

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

        // All filter passed? evaluate
        if(fitsCriteria){
          eventsToDisplay.add(event);
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


  // CLICKED
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


  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    customTextStyle = CustomTextStyle(context: context);

    return Scaffold(

        extendBody: true,


      appBar: AppBar(
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

                // main view
                SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: Column(
                      children: [

                        _buildView(stateProvider, screenHeight),

                        // Spacer
                        SizedBox(height: screenHeight*0.1,),
                      ],
                    )
                ),

                // Filter
                isFilterMenuActive?Container(
                  height: screenHeight*0.14,
                  width: screenWidth,
                  color: const Color(0xff2b353d),
                  child: Row(
                    children: [
                      Container(
                        width: screenWidth*0.5,
                        child: Column(
                          children: [

                            SizedBox(
                              height: screenHeight*0.01,
                            ),

                            Text(
                                "Preis"
                            ),

                            RangeSlider(
                                max: 30,
                                divisions: 10,
                                labels: RangeLabels(
                                  _currentRangeValues.start.round().toString(),
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
                      Container(
                        width: screenWidth*0.5,
                        child: Column(
                          children: [

                            SizedBox(
                              height: screenHeight*0.01,
                            ),

                            Text(
                                "Genre"
                            ),

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
        ),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }
}
