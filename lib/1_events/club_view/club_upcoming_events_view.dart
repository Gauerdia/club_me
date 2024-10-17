import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
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
import '../../services/supabase_service.dart';

import '../../shared/custom_text_style.dart';
import '../user_view/components/event_tile.dart';

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

  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  late String dropdownValue;
  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  List<ClubMeEvent> eventsToDisplay = [];
  List<ClubMeEvent> upcomingDbEvents = [];

  RangeValues _currentRangeValues = const RangeValues(0, 30);

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();


  @override
  void initState(){
    super.initState();
    dropdownValue = Utils.genreListForFiltering[0];
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
                        onPressed: () => clickEventBack(),
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

            // main view
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


    if(upcomingDbEvents.isEmpty){
      for(var currentEvent in fetchedContentProvider.getFetchedEvents()){
        if( currentEvent.getClubId() == userDataProvider.getUserClubId() &&
            (currentEvent.getEventDate().isAfter(stateProvider.getBerlinTime())
                || currentEvent.getEventDate().isAtSameMomentAs(stateProvider.getBerlinTime()))){
          upcomingDbEvents.add(currentEvent);
        }
      }
    }

    filterEvents();

    List<ClubMeEvent> fetchedUpcomingEvents = fetchedContentProvider.getFetchedUpcomingEvents(
        userDataProvider.getUserClubId()
    );

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: fetchedUpcomingEvents.length,
        itemBuilder: ((context, index){

          ClubMeEvent currentEvent = fetchedUpcomingEvents[index];

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
                  clickEventLike: clickEventLike,
                  clickEventShare: clickEventShare,
                  showMaterialButton: false,
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
                      onTap: () => clickEventEditEvent(currentEvent),
                    ),
                    InkWell(
                      child: Icon(
                        Icons.clear_rounded,
                        size: screenWidth*0.06,
                        color: customStyleClass.primeColor,
                      ),
                      onTap: () => clickEventDeleteEvent(currentEvent),
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
        dropdownValue != Utils.genreListForFiltering[0] ||
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
      eventsToDisplay = upcomingDbEvents;
    }

  }
  void sortUpcomingEvents(){
    upcomingDbEvents.sort((a,b) =>
        a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
    );
  }


  // CLICKED
  void clickEventBack(){
    Navigator.pop(context);
  }
  void clickEventShare(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => TitleAndContentDialog(
            titleToDisplay: "Event teilen",
            contentToDisplay: "Die Funktion, ein Event zu teilen, ist derzeit noch"
                "nicht implementiert. Wir bitten um Verständnis.")
    );
  }
  void clickEventEditEvent(ClubMeEvent clubMeEvent){
    currentAndLikedElementsProvider.setCurrentEvent(clubMeEvent);
    context.push("/club_edit_event");
  }
  void clickEventDeleteEvent(ClubMeEvent clubMeEvent){
    showDialog(context: context, builder: (BuildContext context){
      return TitleContentAndButtonDialog(
          titleToDisplay: "Achtung",
          contentToDisplay: "Bist du sicher, dass du dieses Event löschen möchtest?",
          buttonToDisplay: TextButton(
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
          ));
    });
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


  // TOGGLE
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
  void getAllLikedEvents(StateProvider stateProvider) async{
    var likedEvents = await _hiveService.getFavoriteEvents();
    currentAndLikedElementsProvider.setLikedEvents(likedEvents);
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
      appBar: _buildAppBar(),
      body: _buildMainView(),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }
}
