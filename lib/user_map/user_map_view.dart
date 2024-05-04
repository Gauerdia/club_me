import 'package:club_me/models/club.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/clubs_in_proximity.dart';
import '../provider/state_provider.dart';
import '../user_clubs/user_clubs_view.dart';
import 'components/club_info_bottom_sheet.dart';
import 'components/club_list_item.dart';

class UserMapView extends StatefulWidget {
  const UserMapView({Key? key}) : super(key: key);

  @override
  State<UserMapView> createState() => _UserMapViewState();
}

class _UserMapViewState extends State<UserMapView> {

  String headline = "Find Your clubs!";

  bool showBottomSheet = false;
  bool showListIsActive = false;

  late ClubMeEvent clubMeEventToDisplay;

  List<ClubMeEvent> events = [
    ClubMeEvent(
      title: "LATINO NIGHT",
      clubName: "Untergrund Bochum",
      DjName: "DJ Angerfist",
      date: "Samstag",
      price: "5",
      imagePath: 'assets/images/img_4.png',
        description: "Tauch ein in die Nacht und erlebe die ultimative Disco-Party!"
            "Bist du bereit, die Nacht zum Tag zu machen? Dann ist diese Disco genau das Richtige für dich!"
            "Feiere mit uns zu den besten Hits der 70er, 80er und 90er Jahre."
            "Egal ob Discofox, Boogie oder einfach nur Tanzen - hier ist für jeden etwas dabei."
            "Unsere erfahrenen DJs sorgen für eine ausgelassene Stimmung und bringen dich garantiert zum Schwitzen."
            "Lasse dich von den bunten Lichtern und den pulsierenden Beats mitreißen und genieße die unvergessliche Atmosphäre."
            "Ob alleine, mit Freunden oder deinem Partner - hier ist jeder willkommen."
            "Komm vorbei und erlebe eine Nacht voller Spaß, Musik und Tanz!"
            "Dresscode:"
            "Zeige deinen ganz eigenen Style!"
            "Von bunten Outfits bis hin zu klassischen Disco-Looks - alles ist erlaubt.",
        musicGenres: "Latin",
        hours: "22:00 - 03:00 Uhr"
    ),
    ClubMeEvent(
      title: "TECHNO TECHNO",
      clubName: "Zombiekeller",
      DjName: "DJ Thomas",
      date: "Samstag",
      price: "3",
      imagePath: "assets/images/dj_wallpaper_3.png",
        description: "Tauch ein in die Nacht und erlebe die ultimative Disco-Party!"
            "Bist du bereit, die Nacht zum Tag zu machen? Dann ist diese Disco genau das Richtige für dich!"
            "Feiere mit uns zu den besten Hits der 70er, 80er und 90er Jahre."
            "Egal ob Discofox, Boogie oder einfach nur Tanzen - hier ist für jeden etwas dabei."
            "Unsere erfahrenen DJs sorgen für eine ausgelassene Stimmung und bringen dich garantiert zum Schwitzen."
            "Lasse dich von den bunten Lichtern und den pulsierenden Beats mitreißen und genieße die unvergessliche Atmosphäre."
            "Ob alleine, mit Freunden oder deinem Partner - hier ist jeder willkommen."
            "Komm vorbei und erlebe eine Nacht voller Spaß, Musik und Tanz!"
            "Dresscode:"
            "Zeige deinen ganz eigenen Style!"
            "Von bunten Outfits bis hin zu klassischen Disco-Looks - alles ist erlaubt.",
        musicGenres: "Techno",
        hours: "22:00 - 03:00 Uhr"
    )];

  List<Widget> listWidgetsToDisplay = [];
  List<ClubMeClub> clubMeClubs = [];

  @override
  void initState() {
    super.initState();
    clubMeClubs = [
      ClubMeClub(
          clubName: "Untergrund Bochum",
          distance: "1.2",
          NOfPeople: "54",
        genre: "90s",
        imagePath: 'assets/images/dj_wallpaper_5.png',
        price: "10"
      ),
      ClubMeClub(
          clubName: "Nightrooms Dortmund",
          distance: "2.5",
          NOfPeople: "163",
        genre: "Pop, R&B",
        imagePath: 'assets/images/dj_wallpaper_4.png',
        price: "15"
      ),
      ClubMeClub(
          clubName: "Village Essen",
          distance: "0.2",
          NOfPeople: "89",
        genre: "90s",
        imagePath: 'assets/images/img_4.png',
        price: "7"
      ),
    ];
    // _buildListWidgets(clubMeClubs);
  }

  void toggleShowBottomSheet(){
    setState(() {
      showBottomSheet = !showBottomSheet;
    });
  }

  void toggleShowListIsActive(){
    setState(() {
      showListIsActive = !showListIsActive;
    });
  }

  Widget _darkModeTileBuilder(
      BuildContext context,
      Widget tileWidget,
      TileImage tile,
      ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
        0,       0,       0,       1, 0,   // Alpha channel
      ]),
      child: tileWidget,
    );
  }


  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

        extendBodyBehindAppBar: true,
        extendBody: true,

      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(headline),

        // Search icon
        leading: const Icon(
          Icons.search,
          color: Colors.grey,
          // size: 20,
        ),

        actions: [

          // Step to club UI
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 10
              ),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: Color(0xff11181f),
                  borderRadius: BorderRadius.all(
                    Radius.circular(45)
                  )
                ),

                child: const Icon(
                  Icons.switch_access_shortcut,
                  color: Colors.grey,
                ),
              ),
            ),
            onTap: (){
              stateProvider.setPageIndex(0);
              stateProvider.toggleClubUIActive();
              context.go("/club_events");
            },
          ),

          // List view
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 10
              ),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                    color: Color(0xff11181f),
                    borderRadius: BorderRadius.all(
                        Radius.circular(45)
                    )
                ),

                child:  Icon(
                  Icons.list_alt,
                  color: showListIsActive ? Colors.purpleAccent : Colors.grey,
                ),
              ),
            ),
            onTap: (){
              toggleShowListIsActive();
              // context.go("/club_events");
            },
          )
        ],
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
          child: Column(
            children: [

              // Spacer
              SizedBox(height: screenHeight*0.12,),

              // Content
              SizedBox(
                width: screenWidth,
                height: screenHeight*0.83,
                child: Stack(
                  children: [

                    // The map
                    FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(48.773809, 9.182959),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                            tileBuilder: _darkModeTileBuilder,
                          ),

                          MarkerLayer(
                              markers: [
                                Marker(
                                    point: const LatLng(48.773809, 9.182959),
                                    width: 80,
                                    height: 80,
                                    child: GestureDetector(
                                      child: const Image(
                                        image: AssetImage("assets/images/club1.png"),
                                      ),
                                      onTap: (){
                                        clubMeEventToDisplay = events[0];
                                        stateProvider.setCurrentClub(clubMeClubs[0]);
                                        toggleShowBottomSheet();
                                      },
                                    )
                                ),

                                Marker(
                                    point: const LatLng(48.783809, 9.182959),
                                    width: 80,
                                    height: 80,
                                    child: GestureDetector(
                                      child: const Image(
                                        image: AssetImage("assets/images/club1.png"),
                                      ),
                                      onTap: (){
                                        clubMeEventToDisplay = events[1];
                                        stateProvider.setCurrentClub(clubMeClubs[1]);
                                        toggleShowBottomSheet();
                                      },
                                    )
                                )

                              ]
                          )
                        ]
                    ),

                    // transparent layer to click out of bottom sheet
                    showBottomSheet?
                        GestureDetector(
                          child: Container(
                            width: screenWidth,
                            height: screenHeight*0.83,
                            color: Colors.transparent,
                          ),
                          onTap: (){
                            toggleShowBottomSheet();
                          },
                        ):Container(),

                    // The bottom info container
                    GestureDetector(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child:
                        showBottomSheet ?
                        ClubInfoBottomSheet
                          (showBottomSheet: showBottomSheet,
                            clubMeEvent: clubMeEventToDisplay
                        )
                            : Container(),
                      ),
                      onTap: (){
                        // club will be set in stateprovider when clicked on marker
                        context.go("/club_details");
                      },
                    ),

                    showListIsActive?
                        Container(
                          width: screenWidth,
                          height: screenHeight,
                          color: Colors.black.withOpacity(0.7),
                        ): Container(),

                    showListIsActive ?
                        Padding(
                            padding: EdgeInsets.only(
                                // top: screenWidth*0.1
                            ),
                          child: Center(

                            // Whole list background
                            child: Container(
                              width: screenWidth*0.9,
                              height: screenHeight*0.7,
                              // color: Colors.red,
                              child: Column(
                                children: [
                                  for( var element in clubMeClubs)
                                    ClubListItem(
                                        clubName: element.getClubName(),
                                        NOfPeople: element.getNOfPeople(),
                                        distance: element.getDistance(),
                                        price: element.getPrice()
                                    )
                                ],
                              )
                              
                            ),
                          )
                        ):Container()
                        

                  ],
                )

              )
            ],
          )
          ),
    );
  }
}





