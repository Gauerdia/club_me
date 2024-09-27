import 'dart:io';

import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';

import 'package:intl/intl.dart';

import '../../shared/custom_text_style.dart';
import '../user_view/components/event_tile.dart';
import 'club_edit_event_view.dart';

class ClubUpcomingEventsView extends StatefulWidget {
  const ClubUpcomingEventsView({Key? key}) : super(key: key);

  @override
  State<ClubUpcomingEventsView> createState() => _ClubUpcomingEventsViewState();
}

class _ClubUpcomingEventsViewState extends State<ClubUpcomingEventsView> {

  String headLine = "Aktuelle Events";

  var logger = Logger();

  String searchValue = "";
  bool isSearchActive = false;

  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;

  late Directory appDocumentsDir;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  late String dropdownValue;
  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
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

  void setApplicationDirectory() async {
    appDocumentsDir = await getApplicationDocumentsDirectory();
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
                      style: customStyleClass.getFontStyleHeadline1Bold()
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
                    onPressed: () => backButtonPressed(),
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

  void backButtonPressed(){
    Navigator.pop(context);
    // if(stateProvider.wentFromClubDetailToEventDetail && stateProvider.clubUIActive){
    //   stateProvider.resetWentFromCLubDetailToEventDetail();
    //   context.go("/club_frontpage");
    // }else{
    //   context.go("/club_events");
    // }
  }

  void clickOnEditEvent(ClubMeEvent clubMeEvent){
    currentAndLikedElementsProvider.setCurrentEvent(clubMeEvent);
    context.push("/club_edit_event");
  }
  void clickOnDeleteEvent(ClubMeEvent clubMeEvent){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        backgroundColor: Color(0xff121111),
        title:  Text(
          "Achtung!",
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content: Text(
          "Bist du sicher, dass du dieses Event löschen möchtest?",
          style: customStyleClass.getFontStyle3(),
          textAlign: TextAlign.left,
        ),
        actions: [
          TextButton(
              onPressed: () => _supabaseService.deleteEvent(clubMeEvent.getEventId()).then((value){
                if(value == 0){
                  setState(() {
                    fetchedContentProvider.fetchedEvents.removeWhere((element) => element.getEventId() == clubMeEvent.getEventId());
                  });
                  Navigator.pop(context);
                }else{
                  Navigator.pop(context);
                }
              }),
              child: Text(
                "Löschen",
                style: customStyleClass.getFontStyle3BoldPrimeColor(),
              )
          )
        ],
      );
    });
  }

  void getAllLikedEvents(StateProvider stateProvider) async{
    var likedEvents = await _hiveService.getFavoriteEvents();
    currentAndLikedElementsProvider.setLikedEvents(likedEvents);
  }
  Widget _buildView(StateProvider stateProvider, double screenHeight){

    // get today in correct format to check which events are upcoming
    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    if(upcomingDbEvents.isEmpty){
      for(var currentEvent in fetchedContentProvider.getFetchedEvents()){
        if( currentEvent.getClubId() == userDataProvider.getUserClubId() &&
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
          if(currentAndLikedElementsProvider.getLikedEvents().contains(currentEvent.getEventId())){
            isLiked = true;
          }

          return Stack(

            children: [

              GestureDetector(
                child: EventTile(
                  clubMeEvent: currentEvent,
                  isLiked: isLiked,
                  clickedOnLike: clickedOnLike,
                  clickedOnShare: clickedOnShare,
                ),
                onTap: (){
                  currentAndLikedElementsProvider.setCurrentEvent(currentEvent);
                  stateProvider.setAccessedEventDetailFrom(6);
                  context.push('/event_details');
                },
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
                          size: screenWidth*0.06,
                        color: customStyleClass.primeColor,
                      ),
                      onTap: () => clickOnEditEvent(currentEvent),
                    ),
                    InkWell(
                      child: Icon(
                          Icons.clear_rounded,
                          size: screenWidth*0.06,
                        color: customStyleClass.primeColor,
                      ),
                      onTap: () => clickOnDeleteEvent(currentEvent),
                    ),

                  ],
                ),
              ),

            ],

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
      if(currentAndLikedElementsProvider.getLikedEvents().contains(eventId)){
        currentAndLikedElementsProvider.deleteLikedEvent(eventId);
        _hiveService.deleteFavoriteEvent(eventId);
      }else{
        currentAndLikedElementsProvider.addLikedEvent(eventId);
        _hiveService.insertFavoriteEvent(eventId);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    return Scaffold(

        extendBody: true,


      appBar: AppBar(
          surfaceTintColor: customStyleClass.backgroundColorMain,
            automaticallyImplyLeading: false,
            backgroundColor: customStyleClass.backgroundColorMain,
            title: _buildAppBarShowTitle()
        ),
      body: Container(
            width: screenWidth,
            height: screenHeight,
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
                      SizedBox(
                        width: screenWidth*0.5,
                        child: Column(
                          children: [

                            SizedBox(
                              height: screenHeight*0.01,
                            ),

                            const Text(
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
