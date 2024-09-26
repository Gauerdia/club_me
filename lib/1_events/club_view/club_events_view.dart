import 'dart:io';
import 'package:club_me/models/event.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
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

  late Future getEvents;
  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  List<ClubMeEvent> pastEvents = [];
  List<ClubMeEvent> upcomingEvents = [];

  double discountContainerHeightFactor = 0.52;
  double newDiscountContainerHeightFactor = 0.2;

  bool isDeleting = false;


  @override
  void initState(){
    super.initState();
    final userDataProvder = Provider.of<UserDataProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);
    if(fetchedContentProvider.getFetchedEvents().isEmpty){
      getEvents = _supabaseService.getEventsOfSpecificClub(userDataProvder.getUserDataId());
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
    }else{
      newDiscountContainerHeightFactor = 0.3;
    }

  }

  // BUILD
  Widget fetchEventsFromDbAndBuildWidget(
      StateProvider stateProvider,
      double screenHeight, double screenWidth
      ){

    return fetchedContentProvider.getFetchedEvents().isEmpty ?
    FutureBuilder(
        future: getEvents,
        builder: (context, snapshot){

          if(snapshot.hasError){
            /// TODO: ALL errors in db
            print("Error: ${snapshot.error}");
          }

          if(!snapshot.hasData){
            return SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Center(
                child: CircularProgressIndicator(
                  color: customStyleClass.primeColor,
                ),
              ),
            );
          }else{

            try{
              final data = snapshot.data!;
              filterEventsFromQuery(data, stateProvider);
            }catch(e){
              _supabaseService.createErrorLog("club_events, fetchAndBuild: " + e.toString());
            }

            return _buildMainView(stateProvider, screenHeight, screenWidth);

          }
        }
    ): _buildMainView(stateProvider, screenHeight, screenWidth);
  }
  Widget _buildMainView(
      StateProvider stateProvider,
      double screenHeight,
      double screenWidth){
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
                      // textAlign: TextAlign.center,
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
                      // textAlign: TextAlign.left,
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

        // Show fetched discounts
        upcomingEvents.isNotEmpty
            ? Stack(
          children: [

            // Event Tile
            GestureDetector(
              child: Center(
                child: SmallEventTile(
                  clubMeEvent: upcomingEvents[0],
                ),
              ),
              onTap: () => clickedOnCurrentEvent(stateProvider),
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
                    onTap: () => clickOnEditEvent(),
                  ),
                  InkWell(
                    child: Icon(
                        Icons.clear_rounded,
                        color: customStyleClass.primeColor,
                        size: screenWidth*0.06
                    ),
                    onTap: () => clickOnDeleteEvent(),
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
                context.go("/event_details");
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

  void clickEventGoToMoreEvents(int routeIndex){
    // fetchedContentProvider.setFetchedEventBannerImageIds(imageFileNamesAlreadyFetched);
    switch(routeIndex){
      case 0 : context.push("/club_upcoming_events"); break;
      case 1 : context.push("/club_past_events"); break;
      default: break;
    }
  }

  // FILTER FUNCTIONS

  void filterEventsFromProvider(){
  // Used, when the fetching of the db entries has happened already and we now
  // want to use the temporarily saved data to display events.

    // Reset both arrays so that we dont have duplicates by any chance
    upcomingEvents = [];
    pastEvents = [];

    // Everything is stored in the provider. Get the data and iterate
    for(var currentEvent in fetchedContentProvider.getFetchedEvents()){

      // local var to shorten the expressions
      DateTime eventTimestamp = currentEvent.getEventDate();


      // Get current time for germany
      // final berlin = tz.getLocation('Europe/Berlin');
      // final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin).subtract(const Duration(hours:5));

      // Maybe we have forgotten an image? better safe than sorry
      checkIfImageExistsLocally(currentEvent.getBannerId()).then((exists){
        if(!exists){

          // If we haven't started to fetch the image yet, we ought to
          if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentEvent.getBannerId())){

            // Save the name so that we don't fetch the same image several times
            // imageFileNamesToBeFetched.add(currentEvent.getBannerId());

            fetchAndSaveBannerImage(currentEvent.getBannerId());
          }
        }else{
          setState(() {
            fetchedContentProvider.addFetchedBannerImageId(currentEvent.getBannerId());
            // imageFileNamesAlreadyFetched.add(currentEvent.getBannerId());
          });
        }
      });

      // Sort the events into the correct arrays
      if(eventTimestamp.isAfter(stateProvider.getBerlinTime()) || eventTimestamp.isAtSameMomentAs(stateProvider.getBerlinTime())){
        if(currentEvent.getClubId() == userDataProvider.getUserClubId()){
          upcomingEvents.add(currentEvent);
        }
      }else{
        if(currentEvent.getClubId() == userDataProvider.getUserClubId()){
          pastEvents.add(currentEvent);
        }
      }
    }
    // Update the view
    setState(() {});
  }
  void filterEventsFromQuery(var data, StateProvider stateProvider){
    for(var element in data){

      // Get data in correct format
      ClubMeEvent currentEvent = parseClubMeEvent(element);

      // local var to shorten the expressions
      DateTime eventTimestamp = currentEvent.getEventDate();

      // Get current time for germany
      // final berlin = tz.getLocation('Europe/Berlin');
      // final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin).subtract(const Duration(hours:5));

      // Make sure we can show the corresponding image(s)
      checkIfImageExistsLocally(currentEvent.getBannerId()).then((exists){
        if(!exists){

          // If we haven't started to fetch the image yet, we ought to
          if(!fetchedContentProvider.getFetchedBannerImageIds().contains(currentEvent.getBannerId())){

            // Save the name so that we don't fetch the same image several times
            // imageFileNamesToBeFetched.add(currentEvent.getBannerId());

            fetchAndSaveBannerImage(currentEvent.getBannerId());
          }
        }else{
          setState(() {
            fetchedContentProvider.addFetchedBannerImageId(currentEvent.getBannerId());
            // imageFileNamesAlreadyFetched.add(currentEvent.getBannerId());
          });
        }
      });

      // Sort the events into the correct arrays
      if(eventTimestamp.isAfter(stateProvider.getBerlinTime()) || eventTimestamp.isAtSameMomentAs(stateProvider.getBerlinTime())){

        // Make sure that we only consider events of the current user's club
        if(currentEvent.getClubId() == userDataProvider.getUserClubId()){
          upcomingEvents.add(currentEvent);
        }
      }else{

        // Make sure that we only consider events of the current user's club
        if(currentEvent.getClubId() == userDataProvider.getUserClubId()){
          pastEvents.add(currentEvent);
        }
      }
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

      // Add to provider so that we don't need to call them from the db again
      fetchedContentProvider.addEventToFetchedEvents(currentEvent);
    }
    // Update the view
    setState(() {});
  }

  // CLICK
  void clickOnEditEvent(){
    currentAndLikedElementsProvider.setCurrentEvent(upcomingEvents[0]);
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return const ClubEditEventView();
    }));
  }
  void clickOnDeleteEvent(){
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
          )
        ],
      );
    });
  }
  void clickedOnCurrentEvent(StateProvider stateProvider){
    currentAndLikedElementsProvider.setCurrentEvent(upcomingEvents[0]);
    stateProvider.setAccessedEventDetailFrom(5);
    stateProvider.setClubUiActive(true);
    context.go("/event_details");
  }
  void clickEventNewEvent(){
    context.push("/club_new_event");
  }
  void clickEventEventFromTemplate(){
    context.push("/club_event_templates");
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
  Future<bool> checkIfImageExistsLocally(String fileName) async{
    final String dirPath = stateProvider.appDocumentsDir.path;
    return await File('$dirPath/$fileName').exists();
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
                child: fetchEventsFromDbAndBuildWidget(
                    stateProvider,
                    screenHeight,
                    screenWidth
                )
            )
        )
    );
  }

}


