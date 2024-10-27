import 'dart:io';
import 'package:club_me/models/event.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../models/parser/club_me_event_parser.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';

import 'club_edit_event_view.dart';
import 'components/small_event_tile.dart';

class ClubEventsView extends StatefulWidget {
  const ClubEventsView({Key? key}) : super(key: key);

  @override
  State<ClubEventsView> createState() => _ClubEventsViewState();
}

class _ClubEventsViewState extends State<ClubEventsView> {

  String headLine = "Events";

  var log = Logger();

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;


  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();

  List<ClubMeEvent> pastEvents = [];
  List<ClubMeEvent> upcomingEvents = [];


  bool isDeleting = false;


  //  INIT
  @override
  void initState(){
    super.initState();

    // Get providers needed for fetching
    stateProvider = Provider.of<StateProvider>(context,listen: false);
    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    // Fetch events of our club
    if(fetchedContentProvider.getFetchedEvents().isEmpty){
      _supabaseService.getEventsOfSpecificClub(userDataProvider.getUserData().getClubId())
          .then((data) => filterEventsFromQuery(data, stateProvider));
    }else{
      for(var currentEvent in fetchedContentProvider.getFetchedEvents()){
        checkIfUpcomingOrPastEvent(currentEvent);
      }
    }

    // Update last log in
    if(!stateProvider.updatedLastLogInForNow){
      _supabaseService.updateClubLastLogInApp(userDataProvider.getUserData().getClubId()).then(
          (result) => {
            if(result == 0){
              stateProvider.toggleUpdatedLastLogInForNow()
            }else{
              /// TODO: elaborated error handling
            }
          }
      );
    }

  }
  void initGeneralSettings(){

    // TODO: MUSS DAS HIER WIRKLICH BEI JEDEM BUILD GEMACHT WERDEN?

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    customStyleClass = CustomStyleClass(context: context);

    stateProvider.setClubUiActive(true);

    if(upcomingEvents.isEmpty && pastEvents.isEmpty){
      filterEventsFromProvider();
    }
    if(upcomingEvents.isNotEmpty &&
        !identical(upcomingEvents[0], fetchedContentProvider.getFetchedEvents().where(
                (element) => element.getEventId() == upcomingEvents[0].getEventId()))){
      filterEventsFromProvider();
    }

    if(stateProvider.getClubMeEventTemplates().isEmpty){
      getAllEventTemplates(stateProvider);
    }

  }


  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        surfaceTintColor: customStyleClass.backgroundColorMain,
        title: SizedBox(
          width: screenWidth,
          child: Text(headLine,
            textAlign: TextAlign.center,
            style: customStyleClass.getFontStyleHeadline1Bold(),
          ),
        )
    );
  }
  Widget _buildMainView(){
    return Column(
      children: [

        // Spacer
        SizedBox(
          height: screenHeight*0.05,
        ),

        // Neues Event
        SizedBox(
          width: screenWidth*0.9,
          child: Text(
            "Neues Event",
            textAlign: TextAlign.center,
            style: customStyleClass.getFontStyle1Bold(),
          ),
        ),

        // New event
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.only(
                top: 10,
                bottom: 7
            ),
            width: screenWidth*0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                Row(
                  children: [
                    Text(
                      "Neues Event erstellen",
                      style: customStyleClass.getFontStyle4BoldPrimeColor(),
                    ),
                    Icon(
                      Icons.arrow_forward_outlined,
                      color: customStyleClass.primeColor,
                    )
                  ],
                )

              ],
            ),
          ),
          onTap: () => clickEventNewEvent(),
        ),

        // Template event
        if(stateProvider.getClubMeEventTemplates().isNotEmpty)
         GestureDetector(
          child: Container(
            padding: const EdgeInsets.only(
                bottom: 30
            ),
            width: screenWidth*0.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Text(
                      "Event aus Vorlage erstellen",
                      style: customStyleClass.getFontStyle4BoldPrimeColor(),
                    ),
                    Icon(
                      Icons.arrow_forward_outlined,
                      color: customStyleClass.primeColor,
                    )
                  ],
                )

              ],
            )
          ),
          onTap: () => clickEventEventFromTemplate(),
        ),

        if(stateProvider.getClubMeEventTemplates().isEmpty)
          const SizedBox(
            height: 30,
          ),

        // Current events
        SizedBox(
          width: screenWidth*0.9,
          child: Text(
            "Aktuelle Events",
            textAlign: TextAlign.center,
            style: customStyleClass.getFontStyle1Bold(),
          ),
        ),

        // Show fetched events
        upcomingEvents.isNotEmpty ? Stack(
          children: [

            // Event Tile
            GestureDetector(
              child: Center(
                child: SmallEventTile(
                  clubMeEvent: upcomingEvents[0],
                ),
              ),
              onTap: () => clickEventCurrentEvent(stateProvider),
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
                        color: customStyleClass.primeColor,
                        size: screenWidth*0.06
                    ),
                    onTap: () => clickEventEditEvent(),
                  ),
                  InkWell(
                    child: Icon(
                        Icons.clear_rounded,
                        color: customStyleClass.primeColor,
                        size: screenWidth*0.06
                    ),
                    onTap: () => clickEventDeleteEvent(),
                  ),
                ],
              ),
            ),
          ],
        )
            :Container(
          padding: const EdgeInsets.only(
              bottom: 20,
            top: 20
          ),
          child: Text(
            "Keine Events verfügbar",
            style: customStyleClass.getFontStyle3(),
          ),
        ),

        // More events
        if(upcomingEvents.isNotEmpty)
        GestureDetector(
          child: Container(
            width: screenWidth*0.9,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(
                bottom: 30
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      "Mehr Events",
                      style: customStyleClass.getFontStyle4BoldPrimeColor(),
                    ),
                    Icon(
                      Icons.arrow_forward_outlined,
                      color: customStyleClass.primeColor,
                    )
                  ],
                )
              ],
            ),
          ),
          onTap: () => clickEventGoToMoreEvents(0),
        ),

        // past events
        SizedBox(
          width: screenWidth*0.9,
          child: Text(
            "Vergangene Events",
            textAlign: TextAlign.center,
            style: customStyleClass.getFontStyle1Bold(),
          ),
        ),

        // Show fetched discounts
        pastEvents.isNotEmpty
            ? Stack(
          children: [
            GestureDetector(
              child: Center(
                child: SmallEventTile(
                  clubMeEvent: pastEvents[0],
                ),
              ),
              onTap: (){
                currentAndLikedElementsProvider.setCurrentEvent(pastEvents[0]);
                stateProvider.setAccessedEventDetailFrom(5);
                context.push("/event_details");
              },
            ),

            // Shadow to highlight icons

          ],
        ) :Container(
            padding: const EdgeInsets.only(
                bottom: 20,
                top: 20
            ),
            child: Text(
              "Keine Events verfügbar",
              style: customStyleClass.getFontStyle4(),
            )
        ),

        // More events
        if(pastEvents.isNotEmpty)
          GestureDetector(
            child: Container(
              width: screenWidth*0.9,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(
                  bottom: 30
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  Row(
                    children: [
                      Text(
                        "Mehr Events",
                        style: customStyleClass.getFontStyle4BoldPrimeColor(),
                      ),
                      Icon(
                        Icons.arrow_forward_outlined,
                        color: customStyleClass.primeColor,
                      )
                    ],
                  )

                ],
              ),
            ),
            onTap: () => clickEventGoToMoreEvents(1),
          ),

        // Spacer
        SizedBox(
          height: screenHeight*0.15,
        ),
      ],
    );
  }


  // FILTER FUNCTIONS
  void filterEventsFromProvider(){
  // Used, when the fetching of the db entries has happened already and we now
  // want to use the temporarily saved data to display events.

    // Reset both arrays so that we don't have duplicates by any chance
    upcomingEvents = [];
    pastEvents = [];

    // Everything is stored in the provider. Get the data and iterate
    for(var currentEvent in fetchedContentProvider.getFetchedEvents()){

      // Sort into upcoming and past arrays
      checkIfUpcomingOrPastEvent(currentEvent);

    }

    // Check if we need to download the corresponding images
    _checkAndFetchService.checkAndFetchEventImages(
        fetchedContentProvider.getFetchedEvents(),
        stateProvider,
        fetchedContentProvider);

    // We have something to show? Awesome, now apply an ascending order
    if(upcomingEvents.isNotEmpty){
      upcomingEvents.sort((a,b) =>
          a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
      );
    }

    // We have something to show? Awesome, now apply an ascending order
    if(pastEvents.isNotEmpty){
      pastEvents.sort((a,b) =>
          a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
      );
    }
  }
  void checkIfUpcomingOrPastEvent(ClubMeEvent currentEvent){

    stateProvider = Provider.of<StateProvider>(context, listen: false);

    // Sort the events into the correct arrays
    if(currentEvent.getEventDate().isAfter(stateProvider.getBerlinTime()) ||
        currentEvent.getEventDate().isAtSameMomentAs(stateProvider.getBerlinTime())){

      // Make sure that we only consider events of the current user's club
      if(currentEvent.getClubId() == userDataProvider.getUserData().getClubId()){
        upcomingEvents.add(currentEvent);
      }
    }else{

      // Make sure that we only consider events of the current user's club
      if(currentEvent.getClubId() == userDataProvider.getUserData().getClubId()){
        pastEvents.add(currentEvent);
      }
    }

    setState(() {});

  }
  void filterEventsFromQuery(var data, StateProvider stateProvider){

    for(var element in data){


      // Get data in correct format
      ClubMeEvent currentEvent = parseClubMeEvent(element);

      // Sort into upcoming and past arrays
      checkIfUpcomingOrPastEvent(currentEvent);

      // Check if maybe already fetched
      if(!fetchedContentProvider.getFetchedEvents().contains(currentEvent)){
        fetchedContentProvider.addEventToFetchedEvents(currentEvent);
      }
    }

    // Check if we need to download the corresponding images
    _checkAndFetchService.checkAndFetchEventImages(
        fetchedContentProvider.getFetchedEvents(),
        stateProvider,
        fetchedContentProvider
    );

    // We have something to show? Awesome, now apply an ascending order
    if(upcomingEvents.isNotEmpty){
      upcomingEvents.sort((a,b) =>
          a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
      );
    }

    // We have something to show? Awesome, now apply an ascending order
    if(pastEvents.isNotEmpty){
      pastEvents.sort((a,b) =>
          a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
      );
    }

    setState(() {});

  }



  // CLICK
  void clickEventNewEvent(){
    context.push("/club_new_event");
  }
  void clickEventEditEvent(){
    currentAndLikedElementsProvider.setCurrentEvent(upcomingEvents[0]);
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return const ClubEditEventView();
    }));
  }
  void clickEventDeleteEvent(){
    showDialog(context: context, builder: (BuildContext context){
      return TitleContentAndButtonDialog(
          titleToDisplay: "Event löschen",
          contentToDisplay: "Bist du sicher, dass du dieses Event löschen möchtest?",
          buttonToDisplay: TextButton(
              onPressed: () => _supabaseService.deleteEvent(upcomingEvents[0].getEventId()).then((value){
                if(value == 0){
                  setState(() {
                    fetchedContentProvider.fetchedEvents.removeWhere((element) => element.getEventId() == upcomingEvents[0].getEventId());
                    upcomingEvents.removeAt(0);
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
  void clickEventEventFromTemplate(){
    context.push("/club_event_templates");
  }
  void clickEventGoToMoreEvents(int routeIndex){
    switch(routeIndex){
      case 0 : context.push("/club_upcoming_events"); break;
      case 1 : context.push("/club_past_events"); break;
      default: break;
    }
  }
  void clickEventCurrentEvent(StateProvider stateProvider){
    currentAndLikedElementsProvider.setCurrentEvent(upcomingEvents[0]);
    stateProvider.setAccessedEventDetailFrom(5);
    stateProvider.setClubUiActive(true);
    context.push("/event_details");
  }


  // FETCH CONTENT FROM DB
  void getAllEventTemplates(StateProvider stateProvider) async{
    try{
      var eventTemplates = await _hiveService.getAllClubMeEventTemplates();
      stateProvider.setClubMeEventTemplates(eventTemplates);
    }catch(e){
      _supabaseService.createErrorLog("ClubEventsView, getAllEventTemplates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    initGeneralSettings();

    return Scaffold(

        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
        body: Container(
          color: customStyleClass.backgroundColorMain,
            width: screenWidth,
            height: screenHeight,
            child: SingleChildScrollView(
                child:
                _buildMainView()
            )
        )
    );
  }

}


