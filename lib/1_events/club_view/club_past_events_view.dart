import 'dart:io';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';
import 'package:intl/intl.dart';

import '../user_view/components/event_tile.dart';

class ClubPastEventsView extends StatefulWidget {
  const ClubPastEventsView({Key? key}) : super(key: key);

  @override
  State<ClubPastEventsView> createState() => _ClubPastEventsViewState();
}

class _ClubPastEventsViewState extends State<ClubPastEventsView> {

  String headLine = "Vergangene Events";

  var logger = Logger();

  late String dropdownValue;

  late double screenHeight, screenWidth;

  late CustomStyleClass customStyleClass;

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late Directory appDocumentsDir;

  String searchValue = "";
  bool isSearchActive = false;
  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;

  List<ClubMeEvent> eventsToDisplay = [];

  List<ClubMeEvent> fetchedEventsThatHaveAlreadyTakenPlace = [];

  RangeValues _currentRangeValues = const RangeValues(0, 30);

  final HiveService _hiveService = HiveService();


  @override
  void initState(){
    super.initState();
    dropdownValue = Utils.genreListForFiltering.first;
  }

  void initGeneralSettings(){
    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);
  }

  // BUILD
  AppBar _buildAppBar(){

    return AppBar(
        surfaceTintColor: customStyleClass.backgroundColorMain,
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        title: SizedBox(
          width: screenWidth,
          child: Stack(
            children: [

              // Text: Headline
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

              // Icon: Back
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
                          color: Colors.white,
                          // size: 20,
                        ),
                      )
                    ],
                  )
              ),

            ],
          ),
        )
    );
  }
  Widget _buildMainView(){
    return SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [

            // ListView
            SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Column(
                  children: [

                    _buildListView(stateProvider, screenHeight),

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
                  SizedBox(
                    width: screenWidth*0.5,
                    child: Column(
                      children: [

                        SizedBox(
                          height: screenHeight*0.01,
                        ),

                        const Text(
                            "Genre"
                        ),

                        DropdownButton(
                            value: dropdownValue,
                            items: Utils.genreListForFiltering.map<DropdownMenuItem<String>>(
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
    );
  }
  Widget _buildListView(StateProvider stateProvider, double screenHeight){

    // Check all fetched events for the ones that have already taken place
    if(fetchedEventsThatHaveAlreadyTakenPlace.isEmpty){
      for(var currentEvent in fetchedContentProvider.getFetchedEvents()){
        if( currentEvent.getClubId() == userDataProvider.getUserClubId() &&
            (currentEvent.getEventDate().isBefore(stateProvider.getBerlinTime()))){
          fetchedEventsThatHaveAlreadyTakenPlace.add(currentEvent);
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

          return GestureDetector(
            child: EventTile(
                clubMeEvent: currentEvent,
                isLiked: isLiked,
                clickEventLike: clickEventLike,
                clickEventShare: clickEventShare,
              showMaterialButton: false,
            ),
            onTap: (){
              currentAndLikedElementsProvider.setCurrentEvent(currentEvent);
              stateProvider.setAccessedEventDetailFrom(7);
              context.push('/event_details');
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
        dropdownValue != Utils.genreListForFiltering[0] ||
        searchValue != ""
    ){

      // set for coloring
      isAnyFilterActive = true;

      // reset array
      eventsToDisplay = [];

      // Iterate through all available events
      for(var event in fetchedEventsThatHaveAlreadyTakenPlace){

        // If one criterium doesnt match, set to false
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

        // music genre doesn't match? filter
        if(dropdownValue != Utils.genreListForFiltering[0] ){
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
      eventsToDisplay = fetchedEventsThatHaveAlreadyTakenPlace;
    }
  }


  // CLICK
  void clickEventShare(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => TitleAndContentDialog(
            titleToDisplay: "Event teilen", contentToDisplay: "Die Funktion, ein Event zu teilen, ist derzeit noch"
            "nicht implementiert. Wir bitten um Verständnis."));
  }
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



  @override
  Widget build(BuildContext context) {

    initGeneralSettings();

    return Scaffold(

        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
        body: _buildMainView()
    );
  }
}
