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
    // final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    final userDataProvder = Provider.of<UserDataProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);
    if(fetchedContentProvider.getFetchedEvents().isEmpty){
      getEvents = _supabaseService.getEventsOfSpecificClub(userDataProvder.getUserDataId());
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
            textAlign: TextAlign.left,
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
            child: Text(
              "Neues Event erstellen!",
              textAlign: TextAlign.left,
              style: customStyleClass.getFontStyle4BoldPrimeColor(),
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
            child: Text(
              "Event aus Vorlage erstellen!",
              textAlign: TextAlign.left,
              style: customStyleClass.getFontStyle4BoldPrimeColor(),
            ),
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
            textAlign: TextAlign.left,
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

            // Shadow to highlight icons
            Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight*0.005
                  ),
                  child: Container(
                    height: screenHeight*0.06,
                    width: screenWidth*0.9,
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
            Container(
              padding: EdgeInsets.only(
                right: screenWidth*0.05,
              ),
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: screenWidth*0.08),
                    color: customStyleClass.primeColor,
                    onPressed: () => clickOnEditEvent(),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear_rounded, size: screenWidth*0.08),
                    color: customStyleClass.primeColor,
                    onPressed: () => clickOnDeleteEvent(),
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
            child: Text(
              "Mehr Events!",
              style: customStyleClass.getFontStyle4BoldPrimeColor(),
            ),
          ),
          onTap: () => clickEventGoToMoreEvents(0),
        ),

        // past events
        SizedBox(
          width: screenWidth*0.9,
          child: Text(
            "Vergangene Events",
            textAlign: TextAlign.left,
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
            Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight*0.005
                  ),
                  child: Container(
                    height: screenHeight*0.06,
                    width: screenWidth*0.9,
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
              child: Text(
                "Mehr Events!",
                style: customStyleClass.getFontStyle4BoldPrimeColor(),
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
                        customStyleClass.primeColorDark.withOpacity(0.4)
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
                        customStyleClass.primeColorDark.withOpacity(0.2)
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
                        style: customStyleClass.getFontStyle1Bold(),
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
                                      customStyleClass.primeColorDark,
                                      customStyleClass.primeColor,
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
                                  style: customStyleClass.getFontStyle4Bold(),
                                ),
                              )
                          ),
                          onTap: (){
                            context.push("/club_new_event");
                          },
                        ),
                      ),
                    ),

                    // 'From template' button
                    stateProvider.getClubMeEventTemplates().isNotEmpty ?
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
                                      customStyleClass.primeColorDark,
                                      customStyleClass.primeColor,
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
                                  "Event aus Vorlage erstellen!",
                                  style: customStyleClass.getFontStyle4Bold(),
                                ),
                              )
                          ),
                          onTap: (){
                            context.push("/club_event_templates");
                          },
                        ),
                      ),
                    ):Container(),
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
                    customStyleClass.primeColorDark.withOpacity(0.4)
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
                    customStyleClass.primeColorDark.withOpacity(0.2)
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
                    style: customStyleClass.getFontStyle1Bold(),
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
                                  clubMeEvent: upcomingEvents[0],
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
                                    color: customStyleClass.primeColor,
                                    onPressed: () => clickOnEditEvent(),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear_rounded, size: screenWidth*0.08),
                                    color: customStyleClass.primeColor,
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
                        style: customStyleClass.getFontStyle3(),
                ),

                // Spacer
                fetchedContentProvider.getFetchedDiscounts().isEmpty ? SizedBox(
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
                        customStyleClass.primeColorDark,
                        customStyleClass.primeColor,
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
                  style: customStyleClass.getFontStyle4Bold(),
                ),
              ),
            ),
            onTap: () => clickEventGoToMoreEvents(0),
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
                    customStyleClass.primeColorDark.withOpacity(0.4)
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
                    customStyleClass.primeColorDark.withOpacity(0.2)
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
                    style: customStyleClass.getFontStyle1Bold(),
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
                            clubMeEvent: pastEvents[0],
                        ),
                        onTap: (){
                          currentAndLikedElementsProvider.setCurrentEvent(pastEvents[0]);
                          stateProvider.setAccessedEventDetailFrom(5);
                          context.go("/event_details");
                        },
                      )
                    :Text(
                    "Keine Events verfügbar",
                  style: customStyleClass.getFontStyle4(),
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
                        customStyleClass.primeColorDark,
                        customStyleClass.primeColor,
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
                  style: customStyleClass.getFontStyle4Bold(),
                ),
              ),
            ),
            onTap: () => clickEventGoToMoreEvents(1),
          ),
        ),
      ],
    );
  }
  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
        surfaceTintColor: Colors.black,
        backgroundColor: Colors.transparent,
        title: SizedBox(
          width: screenWidth,
          child: Text(headLine,
            textAlign: TextAlign.center,
            style: customStyleClass.getFontStyle1(),
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

  void filterEventsFromProvider(StateProvider stateProvider){
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
                    fetchedContentProvider.fetchedEvents.removeWhere((element) => element.getEventId() == upcomingEvents[0].getEventId());
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
      // if(eventTemplates.isNotEmpty){
      //   setState(() {
      //     newDiscountContainerHeightFactor = 0.3;
      //   });
      // }
    }catch(e){
      _supabaseService.createErrorLog("getAllEventTemplates: $e");
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

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    customStyleClass = CustomStyleClass(context: context);

    if(upcomingEvents.isEmpty && pastEvents.isEmpty){
      filterEventsFromProvider(stateProvider);
    }
    if(upcomingEvents.isNotEmpty && !identical(upcomingEvents[0], fetchedContentProvider.getFetchedEvents().where((element) => element.getEventId() == upcomingEvents[0].getEventId()))){
      filterEventsFromProvider(stateProvider);
    }

    if(stateProvider.getClubMeEventTemplates().isEmpty){
      getAllEventTemplates(stateProvider);
    }else{
      newDiscountContainerHeightFactor = 0.3;
    }

    return Scaffold(

        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
        body: SizedBox(
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


