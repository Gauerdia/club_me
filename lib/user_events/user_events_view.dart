import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../provider/state_provider.dart';
import '../shared/custom_bottom_navigation_bar.dart';

class UserEventsView extends StatefulWidget {
  const UserEventsView({Key? key}) : super(key: key);

  @override
  State<UserEventsView> createState() => _UserEventsViewState();
}

class _UserEventsViewState extends State<UserEventsView> {

  String headLine = "Events for You";

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
    ),
    ClubMeEvent(
        title: "BEST OF 90s",
        clubName: "Village Dortmund",
        DjName: "DJ Gunnar",
        date: "Sonntag",
        price: "12",
      imagePath: "assets/images/dj_wallpaper_4.png",
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
      musicGenres: "90s",
      hours: "22:00 - 03:00 Uhr"
    ),
    ClubMeEvent(
        title: "THE MASH!",
        clubName: "Sausalitos Essen",
        DjName: "DJ Fed&Up",
        date: "24.05.2004",
        price: "4",
      imagePath: "assets/images/dj_wallpaper_5.png",
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
        musicGenres: "90s",
        hours: "22:00 - 03:00 Uhr"
    ),
  ];

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
          title: Text(headLine,
            style: TextStyle(
              // color: Colors.purpleAccent
            ),
          ),

          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 10),
              child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xff11181f),
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.grey,
                  )
              ),
            )
          ],

          leading: Icon(
            Icons.search,
            color: Colors.grey,
            // size: 20,
          ),

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
          child: SingleChildScrollView(
              child: Column(
                children: [

                  // Spacer
                  SizedBox(height: screenHeight*0.15,),

                  // EventTile, 0
                  GestureDetector(
                    child: EventTile(clubMeEvent: events[0]),
                    onTap: (){
                      stateProvider.setCurrentEvent(events[0]);
                      context.go('/event_details');
                    },
                  ),

                  GestureDetector(
                    child: EventTile(clubMeEvent: events[1]),
                    onTap: (){
                      stateProvider.setCurrentEvent(events[1]);
                      context.go('/event_details');
                    },
                  ),

                  GestureDetector(
                    child: EventTile(clubMeEvent: events[2]),
                    onTap: (){
                      stateProvider.setCurrentEvent(events[2]);
                      context.go('/event_details');
                    },
                  ),

                  GestureDetector(
                    child: EventTile(clubMeEvent: events[3]),
                    onTap: (){
                      stateProvider.setCurrentEvent(events[3]);
                      context.go('/event_details');
                    },
                  ),

                  // Spacer
                  SizedBox(height: screenHeight*0.1,),
                ],
              )
          ),
        )
    );
  }
}

class EventTile extends StatelessWidget {
  EventTile({Key? key, required this.clubMeEvent}) : super(key: key);

  ClubMeEvent clubMeEvent;

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(bottom: screenHeight*0.02),
      child: Card(
        child: Column(
          children: [

            // TODO: No matter which image: Everything should be cropped the same

            // Image container
            Container(
              width: screenWidth,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12)
                  ),
                  border: Border(
                    // top: BorderSide(
                    //     width: 1, color: Colors.white60
                    // ),
                    left: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                    right: BorderSide(
                        width: 1, color: Colors.white60
                    ),
                  ),
                ),
                child: Container(
                    height: screenHeight*0.17,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          topLeft: Radius.circular(12)
                      ),
                      child: Image.asset(
                        clubMeEvent.getImagePath(),
                        fit: BoxFit.cover,
                      ),
                    )
                )
            ),

            // Content container
            Container(
                height: screenHeight*0.19,
                width: screenWidth,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12)
                    ),
                    border: const Border(
                      left: BorderSide(
                          width: 1, color: Colors.white60
                      ),
                      right: BorderSide(
                          width: 1, color: Colors.white60
                      ),
                    ),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[700]!,
                        Colors.grey[850]!
                      ],
                      stops: [0.3, 0.8]
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [

                        // Title
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              clubMeEvent.getTitle(),
                              style: TextStyle(
                                  fontSize: screenWidth*0.07,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),

                        // Location
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              clubMeEvent.getClubName(),
                              style: TextStyle(
                                  fontSize: screenWidth*0.035,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),

                        // DJ
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 3,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              clubMeEvent.getDjName(),
                              style: TextStyle(
                                  fontSize: screenWidth*0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]
                              ),
                            ),
                          ),
                        ),

                        // When
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 3,
                              left: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              clubMeEvent.getDate(),
                              style: TextStyle(
                                  fontSize: screenWidth*0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),

                    Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          right: 15
                        ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                            "${clubMeEvent.getPrice()} €",
                          style: TextStyle(
                            fontSize: screenWidth*0.05,
                            color: Colors.white70
                          ),
                        ),
                      ),
                    ),

                    // Icons
                    const Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 15,),
                                Icon(
                                  Icons.star_border,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 15,),
                                Icon(
                                  Icons.share,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 25,),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Info",
                                  style: TextStyle(
                                      fontSize: 12
                                  ),
                                ),
                                SizedBox(width: 12,),
                                Text(
                                  "Like",
                                  style: TextStyle(
                                      fontSize: 12
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Text(
                                  "Share",
                                  style: TextStyle(
                                      fontSize: 12
                                  ),
                                ),
                                SizedBox(width: 18,),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        )
                    )

                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
