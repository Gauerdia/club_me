import 'dart:io';
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
  late FetchedContentProvider fetchedContentProvider;
  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late Directory appDocumentsDir;

  String searchValue = "";
  bool isSearchActive = false;
  bool isAnyFilterActive = false;
  bool isFilterMenuActive = false;

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
  Widget _buildView(StateProvider stateProvider, double screenHeight){

    // get today in correct format to check which events are upcoming
    var todayRaw = DateTime.now();
    var today = DateFormat('yyyy-MM-dd').format(todayRaw);
    var todayFormatted = DateTime.parse(today);

    if(upcomingDbEvents.isEmpty){
      for(var currentEvent in fetchedContentProvider.getFetchedEvents()){
        if( currentEvent.getClubId() == userDataProvider.getUserClubId() &&
            (currentEvent.getEventDate().isBefore(todayFormatted))){
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

          return GestureDetector(
            child: EventTile(
                clubMeEvent: currentEvent,
                isLiked: isLiked,
                clickEventLike: clickedOnLike,
                clickEventShare: clickedOnShare,
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


  // CLICK
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
    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(

        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: AppBar(
            surfaceTintColor: customStyleClass.backgroundColorMain,
            automaticallyImplyLeading: false,
            backgroundColor: customStyleClass.backgroundColorMain,
            title: _buildAppBarShowTitle()
        ),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [
            //         // Color(0xff11181f),
            //         Color(0xff2b353d),
            //         Color(0xff11181f)
            //       ],
            //       stops: [0.15, 0.6]
            //   ),
            // ),
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

                // Filter menu
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
        )
    );
  }
}
