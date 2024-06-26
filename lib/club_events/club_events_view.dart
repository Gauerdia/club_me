import 'package:club_me/club_events/club_edit_event_view.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/parser/club_me_event_parser.dart';
import '../provider/state_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';
import 'components/small_event_tile.dart';
import 'package:timezone/standalone.dart' as tz;

class ClubEventsView extends StatefulWidget {
  const ClubEventsView({Key? key}) : super(key: key);

  @override
  State<ClubEventsView> createState() => _ClubEventsViewState();
}

class _ClubEventsViewState extends State<ClubEventsView> {

  String headLine = "Deine Events";

  late Future getEvents;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

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
    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    if(stateProvider.getFetchedEvents().isEmpty){
      getEvents = _supabaseService.getEventsOfSpecificClub(stateProvider.getUserData().getUserId());
    }
  }

  // BUILD
  Widget fetchEventsFromDbAndBuildWidget(
      StateProvider stateProvider,
      double screenHeight, double screenWidth
      ){

    return stateProvider.getFetchedEvents().isEmpty ?
    FutureBuilder(
        future: getEvents,
        builder: (context, snapshot){

          print("Futurebuilder: fetchedEvents isEmpty");

          if(snapshot.hasError){
            print("Error: ${snapshot.error}");
          }

          if(!snapshot.hasData){
            return SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }else{

            final data = snapshot.data!;

            filterEventsFromQuery(data, stateProvider);

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

        // New Event Widget
        buildNewEventWidget(
            context,
            stateProvider,
            screenHeight,
            screenWidth
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.05,
        ),

        // Current Event Widget
        buildCurrentEventsWidget(
            stateProvider,
            screenHeight,
            screenWidth
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.05,
        ),

        buildPastEventsWidget(
            stateProvider,
            screenHeight,
            screenWidth),

        // Spacer
        SizedBox(
          height: screenHeight*0.15,
        ),
      ],
    );
  }
  Widget buildNewEventWidget(
      BuildContext context, StateProvider stateProvider,
      double screenHeight, double screenWidth
      ){
    return SizedBox(
      child: SizedBox(
        child: Stack(
          children: [

            // Bottom accent
            Container(
              width: screenWidth*0.91,
              height: screenHeight*(newDiscountContainerHeightFactor+0.005),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        customTextStyle.primeColorDark.withOpacity(0.4)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            // Top accent
            Container(
              width: screenWidth*0.91,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        customTextStyle.primeColorDark.withOpacity(0.2)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            // left highlight
            Container(
              width: screenWidth*0.89,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            // Top accent
            Padding(
                padding: const EdgeInsets.only(
                    left:2
                ),
                child: Container(
                  width: screenWidth*0.9,
                  height: screenHeight*newDiscountContainerHeightFactor,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.topRight,
                          colors: [Colors.grey[600]!, Colors.grey[900]!],
                          stops: const [0.1, 0.9]
                      ),
                      borderRadius: BorderRadius.circular(
                          15
                      )
                  ),
                )
            ),

            // main Div
            Padding(
              padding: const EdgeInsets.only(
                  left:2,
                  top: 2
              ),
              child: Container(
                width: screenWidth*0.9,
                height: screenHeight*newDiscountContainerHeightFactor,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[800]!.withOpacity(0.7),
                          Colors.grey[900]!
                        ],
                        stops: const [0.1,0.9]
                    ),
                    borderRadius: BorderRadius.circular(
                        15
                    )
                ),
                child: Column(
                  children: [

                    // "New Event" headline
                    Container(
                      width: screenWidth,
                      // color: Colors.red,
                      padding: EdgeInsets.only(
                          left: screenWidth*0.05,
                          top: screenHeight*0.03
                      ),
                      child: Text(
                        "Neues Event",
                        textAlign: TextAlign.left,
                        style: customTextStyle.size1Bold(),
                      ),
                    ),

                    // 'Create new event' button
                    Padding(
                      padding: EdgeInsets.only(
                        top:screenHeight*0.015,
                        right: 7,
                        bottom: 7,
                      ),
                      child: Align(
                        child: GestureDetector(
                          child: Container(
                              width: screenWidth*0.8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      customTextStyle.primeColorDark,
                                      customTextStyle.primeColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: const [0.2, 0.9]
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: Offset(3, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10)
                                ),
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Center(
                                child: Text(
                                  "Neues Event erstellen!",
                                  style: customTextStyle.size4Bold(),
                                ),
                              )
                          ),
                          onTap: (){
                            context.push("/club_new_event");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget buildCurrentEventsWidget(
      StateProvider stateProvider,double screenHeight, double screenWidth){

    double discountContainerHeightFactor;

    upcomingEvents.isNotEmpty?
    discountContainerHeightFactor = 0.52
        : discountContainerHeightFactor = 0.26;

    return Stack(
      children: [

        // gradient from bottom left to bottom right
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(discountContainerHeightFactor+0.006),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // gradient from top right to bottom right
        Container(
          width: screenWidth*0.91,
          height: screenHeight*discountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // left highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*discountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[900]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // top left to top right
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*discountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // MAIN CONTENT
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*discountContainerHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: const [0.1,0.7]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // "Aktuelle Events"
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.only(
                      left: screenWidth*0.05,
                      top: screenHeight*0.03
                  ),
                  child: Text(
                    "Aktuelle Events",
                    textAlign: TextAlign.left,
                    style: customTextStyle.size1Bold(),
                  ),
                ),

                // Spacer
                SizedBox(
                  height: screenHeight*0.03,
                ),

                // Show fetched discounts
                upcomingEvents.isNotEmpty
                    ? Stack(
                        children: [

                          // Event Tile
                          GestureDetector(
                            child: Center(
                              child: SmallEventTile(
                                  clubMeEvent: upcomingEvents[0]
                              ),
                            ),
                            onTap: () => clickedOnCurrentEvent(stateProvider),
                          ),

                          // Shadow to highlight icons
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: screenHeight*0.005
                              ),
                              child: Container(
                                height: screenHeight*0.07,
                                width: screenWidth*0.8,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.black, Colors.transparent],
                                  ),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      topLeft: Radius.circular(12)
                                  ),
                                ),
                              ),
                            )
                          ),

                          // Edit button
                          Padding(
                            padding: EdgeInsets.only(
                              right: screenWidth*0.05,
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, size: screenWidth*0.08),
                                    color: customTextStyle.primeColor,
                                    onPressed: () => clickOnEditEvent(),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear_rounded, size: screenWidth*0.08),
                                    color: customTextStyle.primeColor,
                                    onPressed: () => clickOnDeleteEvent(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    :Text(
                      "Keine Events verfügbar",
                        style: customTextStyle.size3(),
                ),

                // Spacer
                stateProvider.getFetchedDiscounts().isEmpty ? SizedBox(
                  height: screenHeight*0.03,
                ):Container(),
              ],
            ),
          ),
        ),

        // "More Discounts" Buttons
        Container(
          width: screenWidth*0.9,
          height: screenHeight*discountContainerHeightFactor,
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: screenHeight*0.015,
                  right: screenWidth*0.02
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient:LinearGradient(
                      colors: [
                        customTextStyle.primeColorDark,
                        customTextStyle.primeColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.2, 0.9]
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(3, 3),
                    ),
                  ],
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10)
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Text(
                  "Mehr Events!",
                  style: customTextStyle.size4Bold(),
                ),
              ),
            ),
            onTap: () => context.go("/club_upcoming_events"),
          ),
        ),
      ],
    );
  }
  Widget buildPastEventsWidget(
      StateProvider stateProvider, double screenHeight, double screenWidth){

    double discountContainerHeightFactor;

    pastEvents.isNotEmpty?
    discountContainerHeightFactor = 0.52
        : discountContainerHeightFactor = 0.26;

    return Stack(
      children: [

        // gradient from bottom left to bottom right
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(discountContainerHeightFactor+0.006),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // gradient from top right to bottom right
        Container(
          width: screenWidth*0.91,
          height: screenHeight*discountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // left highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*discountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[900]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // top left to top right
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*discountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // MAIN CONTENT
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height:
            screenHeight*discountContainerHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: const [0.1,0.7]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // "Past Events"
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.only(
                      left: screenWidth*0.05,
                      top: screenHeight*0.03
                  ),
                  child: Text(
                    "Vergangene Events",
                    textAlign: TextAlign.left,
                    style: customTextStyle.size1Bold(),
                  ),
                ),

                // Spacer
                SizedBox(
                  height: screenHeight*0.03,
                ),

                // Show fetched discounts
                pastEvents.isNotEmpty
                    ? GestureDetector(
                        child: SmallEventTile(
                            clubMeEvent: pastEvents[0]
                        ),
                        onTap: (){
                          stateProvider.setCurrentEvent(pastEvents[0]);
                          context.go("/event_details");
                        },
                      )
                    :Text(
                    "Keine Events verfügbar",
                  style: customTextStyle.size4(),
                ),
              ],
            ),
          ),
        ),

        // "More Discounts" Buttons
        Container(
          width: screenWidth*0.9,
          height: screenHeight*discountContainerHeightFactor,
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: screenHeight*0.015,
                  right: screenWidth*0.02
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient:LinearGradient(
                      colors: [
                        customTextStyle.primeColorDark,
                        customTextStyle.primeColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.2, 0.9]
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(3, 3),
                    ),
                  ],
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10)
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Text(
                  "Mehr Events!",
                  style: customTextStyle.size4Bold(),
                ),
              ),
            ),
            onTap: () => context.go("/club_past_events"),
          ),
        ),
      ],
    );
  }
  AppBar _buildAppBar(){
    return AppBar(
        backgroundColor: Colors.transparent,
        title: SizedBox(
          width: screenWidth,
          child: Text(headLine,
            textAlign: TextAlign.center,
            style: customTextStyle.size2(),
          ),
        )
    );
  }

  // FILTER
  void filterEventsFromProvider(StateProvider stateProvider){

    upcomingEvents = [];
    pastEvents = [];

    for(var currentEvent in stateProvider.getFetchedEvents()){

      // add 23 so that we can still find it as upcoming even though it's the same day
      DateTime eventTimestamp = currentEvent.getEventDate();


      // Get current time for germany
      final berlin = tz.getLocation('Europe/Berlin');
      final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin).subtract(const Duration(hours:5));

      // Filter the events
      if(eventTimestamp.isAfter(todayTimestamp)){
        if(currentEvent.getClubId() == stateProvider.userClub.getClubId()){
          upcomingEvents.add(currentEvent);
        }
      }else{
        if(currentEvent.getClubId() == stateProvider.userClub.getClubId()){
          pastEvents.add(currentEvent);
        }
      }
    }
  }
  void filterEventsFromQuery(var data, StateProvider stateProvider){
    for(var element in data){
      ClubMeEvent currentEvent = parseClubMeEvent(element);

      // add 23 so that we can still find it as upcoming even though it's the same day
      DateTime eventTimestamp = currentEvent.getEventDate();

      // Get current time for germany
      final berlin = tz.getLocation('Europe/Berlin');
      final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin).subtract(const Duration(hours:5));

      // Filter the events
      if(eventTimestamp.isAfter(todayTimestamp)){
        if(currentEvent.getClubId() == stateProvider.userClub.getClubId()){
          upcomingEvents.add(currentEvent);
        }
      }else{
        if(currentEvent.getClubId() == stateProvider.userClub.getClubId()){
          pastEvents.add(currentEvent);
        }
      }

      if(upcomingEvents.isNotEmpty){
        upcomingEvents.sort((a,b) =>
            a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
        );
      }

      if(pastEvents.isNotEmpty){
        pastEvents.sort((a,b) =>
            a.getEventDate().millisecondsSinceEpoch.compareTo(b.getEventDate().millisecondsSinceEpoch)
        );
      }

      // Add to provider so that we dont need to call them from the db again
      stateProvider.addEventToFetchedEvents(currentEvent);
    }
  }

  // CLICK
  void clickOnEditEvent(){
    stateProvider.setCurrentEvent(upcomingEvents[0]);
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return const ClubEditEventView();
    }));
  }
  void clickOnDeleteEvent(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Achtung!"),
        content: const Text(
          "Bist du sicher, dass du dieses Event löschen möchtest?",
          textAlign: TextAlign.left,
        ),
        actions: [
          TextButton(
              onPressed: () => _supabaseService.deleteEvent(upcomingEvents[0].getEventId()).then((value){
                if(value == 0){
                  setState(() {
                    stateProvider.fetchedEvents.removeWhere((element) => element.getEventId() == upcomingEvents[0].getEventId());
                    upcomingEvents.removeAt(0);
                  });
                  Navigator.pop(context);
                }else{
                  Navigator.pop(context);
                }
              }),
              child: const Text("Löschen")
          )
        ],
      );
    });
  }
  void clickedOnCurrentEvent(StateProvider stateProvider){
    stateProvider.setCurrentEvent(upcomingEvents[0]);
    context.go("/event_details");
  }



  @override
  Widget build(BuildContext context) {


    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    if(upcomingEvents.isEmpty && pastEvents.isEmpty){
      filterEventsFromProvider(stateProvider);
    }
    if(upcomingEvents.isNotEmpty && !identical(upcomingEvents[0], stateProvider.getFetchedEvents().where((element) => element.getEventId() == upcomingEvents[0].getEventId()))){
      filterEventsFromProvider(stateProvider);
    }

    return Scaffold(

        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
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
            child: SingleChildScrollView(

                child: fetchEventsFromDbAndBuildWidget(
                    stateProvider,
                    screenHeight,
                    screenWidth)
            )
        )
    );
  }

}


