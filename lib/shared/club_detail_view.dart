import 'package:club_me/user_clubs/user_clubs_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/event.dart';
import '../provider/state_provider.dart';
import 'custom_bottom_navigation_bar.dart';

class ClubDetailView extends StatefulWidget {
  const ClubDetailView({Key? key}) : super(key: key);

  @override
  State<ClubDetailView> createState() => _ClubDetailViewState();
}

class _ClubDetailViewState extends State<ClubDetailView> {

  List<ClubMeEvent> events = [
    ClubMeEvent(
        title: "DJ Kheeling - Tropical Techno",
        clubName: "Berghain",
        DjName: "DJ Kheeling",
        date: "Freitag",
        price: "4",
        imagePath: "assets/images/img_4.png",
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
        musicGenres: "House, Trance, Psy",
        hours: "22:00 - 07:00 Uhr"
    ),
    ClubMeEvent(
        title: "The Halloween Special",
        clubName: "Berghain",
        DjName: "DJ Jürgen",
        date: "Samstag",
        price: "14",
        imagePath: "assets/images/img_4.png",
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
        musicGenres: "House, Trance, Psy",
        hours: "23:00 - 08:00 Uhr"
    )
  ];

  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  bool showVideoIsActive = false;


  void toggleShowVideoIsActive(){
    setState(() {
      showVideoIsActive = !showVideoIsActive;
      if(showVideoIsActive){
        _videoPlayerController.play();
      }else{
        _videoPlayerController.pause();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.asset("assets/videos/short_video_1.mp4");
    _videoPlayerController.setLooping(true);

    _initializeVideoPlayerFuture = _videoPlayerController.initialize();

  }

  @override
  void dispose() {
    _videoPlayerController.dispose();

    super.dispose();
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
          title: Text(stateProvider.clubMeClub.getClubName()),
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios,
            ),
            onTap: (){

              switch(stateProvider.pageIndex){
                case(0):context.go("/user_events");break;
                case(1):context.go("/user_clubs");break;
                case(2):context.go("/user_map");break;
                case(3):context.go("/user_coupons");break;
                default:context.go("/user_clubs");break;
              }


            },
          )
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
            SizedBox(
              height: screenHeight*0.12,
            ),

            Stack(
              children: [

                // BG Image
                Container(
                  height: screenHeight*0.25,
                  color: Colors.white,
                  child: Center(
                    child: SizedBox(
                      height: screenHeight,
                      child: Image.asset(
                        stateProvider.clubMeClub.getImagePath(),
                        // "assets/images/dj_wallpaper_3.png",
                        fit: BoxFit.cover,
                      ),
                    )
                  )
                ),

                // main Content
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight*0.24,
                  ),
                  child: Container(
                    width: screenWidth,
                    height: screenHeight*0.6,
                    decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.grey)
                        )
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          // Container for the bg gradient
                          Container(
                            // height: screenHeight*1.8,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xff11181f),
                                    Color(0xff2b353d),
                                  ],
                                  stops: [0.15, 0.6]
                              ),
                            ),

                            child: Column(
                              children: [

                                // Spacer
                                SizedBox(
                                  height: screenHeight*0.03,
                                ),

                                // Icons next to logo
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Icon(
                                          Icons.route_outlined,
                                          color: Colors.pinkAccent,
                                        ),
                                        Text(
                                            "Karte"
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Icon(
                                          Icons.search,
                                          color: Colors.pinkAccent,
                                        ),
                                        Text(
                                            "Preisliste"
                                        )
                                      ],
                                    ),
                                  ],
                                ),

                                // Spacer
                                SizedBox(
                                  height: screenHeight*0.02,
                                ),

                                // White line
                                const Divider(
                                  height:10,
                                  thickness: 1,
                                  color: Colors.white,
                                  indent: 20,
                                  endIndent: 20,
                                ),

                                // Events headline
                                Container(
                                  width: screenWidth,
                                  // color: Colors.red,
                                  padding: EdgeInsets.only(
                                      left: screenWidth*0.05,
                                      top: screenHeight*0.01
                                  ),
                                  child: const Text(
                                    "Events",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 24
                                    ),
                                  ),
                                ),

                                SizedBox(height: screenHeight*0.01,),

                                // Freitag
                                Container(
                                  width: screenWidth,
                                  padding: EdgeInsets.only(
                                      left: screenWidth*0.05,
                                      bottom: screenHeight*0.01
                                  ),
                                  child: Text(
                                    "Freitag",
                                    style: TextStyle(
                                        color: Colors.grey[500]
                                    ),
                                  ),
                                ),

                                EventCard(clubMeEvent: events[0],wentFromClubDetailToEventDetail: true,),

                                SizedBox(height: screenHeight*0.01,),

                                // Samstag
                                Container(
                                  width: screenWidth,
                                  padding: EdgeInsets.only(
                                      left: screenWidth*0.05,
                                      bottom: screenHeight*0.01
                                  ),
                                  child: Text(
                                    "Samstag",
                                    style: TextStyle(
                                        color: Colors.grey[500]
                                    ),
                                  ),
                                ),

                                // SizedBox(height: screenHeight*0.02,),

                                EventCard(clubMeEvent: events[1], wentFromClubDetailToEventDetail: true,),

                                SizedBox(height: screenHeight*0.02,),

                                // Get more button
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: screenWidth*0.05
                                  ),
                                  child:  Container(
                                    alignment: Alignment.bottomRight,
                                    width: screenWidth,

                                    child: Container(
                                        width: screenWidth*0.45,
                                        padding: EdgeInsets.only(
                                            top: screenHeight*0.014,
                                            bottom: screenHeight*0.014
                                        ),
                                        decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.all(Radius.circular(15))
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Get more events",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.purpleAccent,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                              ),
                                            ),
                                            Stack(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5
                                                  ),
                                                  child: Icon(
                                                    Icons.navigate_next,
                                                    color: Colors.purpleAccent,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.navigate_next,
                                                  color: Colors.purpleAccent,
                                                )
                                              ],
                                            )

                                          ],
                                        )
                                    ),
                                  ),
                                ),

                                SizedBox(height: screenHeight*0.02,),

                                // White line
                                const Divider(
                                  height:10,
                                  thickness: 1,
                                  color: Colors.white,
                                  indent: 20,
                                  endIndent: 20,
                                ),

                                // News headline
                                Container(
                                  width: screenWidth,
                                  // color: Colors.red,
                                  padding: EdgeInsets.only(
                                      left: screenWidth*0.05,
                                      top: screenHeight*0.01
                                  ),
                                  child: const Text(
                                    "News",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 24
                                    ),
                                  ),
                                ),

                                const Padding(
                                  padding: EdgeInsets.all(18),
                                  child: Text(
                                      "Bochum, 24. April 2024 – Nach über zwei Jahrzehnten kehrt die legendäre Bochumer Disco Tarm zurück. Im Mai 2024 öffnet die ehemalige Edel-Diskothek unter dem neuen Namen \"Tarm Event Center\" ihre Pforten und lädt Tanzbegeisterte aus der Region ein.Die neue Location befindet sich im Gewerbegebiet am Kemnader Weg und bietet neben einer großzügigen Tanzfläche auch Platz für Events und private Feiern. Inhaber Thorsten Heckendorf und sein Geschäftspartner Ralf Schäfer haben sich der Herausforderung verschrieben, dem Tarm neuen Glanz zu verleihen und gleichzeitig die Erinnerung an die legendären Partys der Vergangenheit zu bewahren."
                                  ),
                                ),

                                // White line
                                const Divider(
                                  height:10,
                                  thickness: 1,
                                  color: Colors.white,
                                  indent: 20,
                                  endIndent: 20,
                                ),

                                // Fotos and videos headline
                                Container(
                                  width: screenWidth,
                                  // color: Colors.red,
                                  padding: EdgeInsets.only(
                                      left: screenWidth*0.05,
                                      top: screenHeight*0.01
                                  ),
                                  child: const Text(
                                    "Fotos & Videos",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 24
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: screenHeight*0.02,
                                ),

                                // First row images
                                Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.05),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: screenWidth*0.29,
                                        height: screenWidth*0.29,
                                        child: Image.asset(
                                          'assets/images/dj_wallpaper_3.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth*0.02,),
                                      SizedBox(
                                        width: screenWidth*0.29,
                                        height: screenWidth*0.29,
                                        child: Image.asset(
                                          'assets/images/dj_wallpaper_4.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth*0.02,),
                                      SizedBox(
                                        width: screenWidth*0.29,
                                        height: screenWidth*0.29,
                                        child: Image.asset(
                                          'assets/images/dj_wallpaper_5.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: screenHeight*0.02,
                                ),

                                // Second row images
                                Padding(
                                  padding: EdgeInsets.only(left: screenWidth*0.05),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: screenWidth*0.29,
                                        height: screenWidth*0.29,
                                        child: Image.asset(
                                          'assets/images/dj_wallpaper_3.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth*0.02,),
                                      SizedBox(
                                        width: screenWidth*0.29,
                                        height: screenWidth*0.29,
                                        child: Image.asset(
                                          'assets/images/dj_wallpaper_4.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth*0.02,),
                                      SizedBox(
                                        width: screenWidth*0.29,
                                        height: screenWidth*0.29,
                                        child: Image.asset(
                                          'assets/images/dj_wallpaper_5.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: screenHeight*0.02,
                                ),

                                // Button, get more
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: screenWidth*0.05
                                  ),
                                  child:  Container(
                                    alignment: Alignment.bottomRight,
                                    width: screenWidth,

                                    child: Container(
                                        width: screenWidth*0.45,
                                        padding: EdgeInsets.only(
                                            top: screenHeight*0.014,
                                            bottom: screenHeight*0.014
                                        ),
                                        decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.all(Radius.circular(15))
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Get more photos",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.purpleAccent,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                              ),
                                            ),
                                            Stack(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5
                                                  ),
                                                  child: Icon(
                                                    Icons.navigate_next,
                                                    color: Colors.purpleAccent,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.navigate_next,
                                                  color: Colors.purpleAccent,
                                                )
                                              ],
                                            )

                                          ],
                                        )
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: screenHeight*0.02,
                                ),

                                // White line
                                const Divider(
                                  height:10,
                                  thickness: 1,
                                  color: Colors.white,
                                  indent: 20,
                                  endIndent: 20,
                                ),

                                // Kontakt headline
                                Container(
                                  width: screenWidth,
                                  // color: Colors.red,
                                  padding: EdgeInsets.only(
                                      left: screenWidth*0.05,
                                      top: screenHeight*0.01
                                  ),
                                  child: const Text(
                                    "Kontakt",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 24
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: screenHeight*0.02,
                                ),

                                // Anschrift + icon
                                Row(
                                  children: [
                                    SizedBox(
                                      width: screenWidth*0.05,
                                    ),

                                    SizedBox(
                                      width: screenWidth*0.45,
                                      height: screenHeight*0.12,
                                      // color: Colors.green,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: screenWidth*0.5,
                                            child: const Text(
                                              "Untergrund Club",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18
                                              ),
                                            ),
                                          ),

                                          SizedBox(
                                            width: screenWidth*0.5,
                                            child: const Text(
                                              "Kortumstraße 101",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 14
                                              ),
                                            ),
                                          ),

                                          SizedBox(
                                            width: screenWidth*0.5,
                                            child: const Text(
                                              "44787 Bochum",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 14
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),

                                    Container(
                                      width: screenWidth*0.45,
                                      // height: screenHeight*0.12,
                                      // color: Colors.red,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: screenWidth*0.2,
                                            height: screenWidth*0.2,
                                            child: Image.asset(
                                              'assets/images/google_maps_purple.png',
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),

                                // Button, get more
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: screenWidth*0.05
                                  ),
                                  child:  Container(
                                    alignment: Alignment.bottomRight,
                                    width: screenWidth,

                                    child: Container(
                                        width: screenWidth*0.45,
                                        padding: EdgeInsets.only(
                                            top: screenHeight*0.014,
                                            bottom: screenHeight*0.014
                                        ),
                                        decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.all(Radius.circular(15))
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Find on maps!",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.purpleAccent,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                              ),
                                            ),
                                            Stack(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5
                                                  ),
                                                  child: Icon(
                                                    Icons.navigate_next,
                                                    color: Colors.purpleAccent,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.navigate_next,
                                                  color: Colors.purpleAccent,
                                                )
                                              ],
                                            )

                                          ],
                                        )
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: screenHeight*0.1,
                                )


                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),

                // Centered logo
                Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight*0.185
                  ),
                  child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  left: BorderSide(color: Colors.purpleAccent),
                                  right: BorderSide(color: Colors.purpleAccent),
                                  top: BorderSide(color: Colors.purpleAccent)
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(45))
                          ),
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.black,
                            child: Text("ClubMe"),
                          ),
                        ),
                        onTap: () => toggleShowVideoIsActive()
                      )
                  ),
                ),

                showVideoIsActive ? GestureDetector(
                  child: Container(
                    width: screenWidth,
                    height: screenHeight*0.85,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  onTap: () => toggleShowVideoIsActive()
                ): Container(),

                showVideoIsActive ? FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the VideoPlayerController has finished initialization, use
                      // the data it provides to limit the aspect ratio of the video.
                      return Padding(
                            padding: EdgeInsets.only(
                              top: screenHeight*0.1
                            ),
                          child: Center(
                            child: Container(
                              width: screenWidth*0.9,
                              height: screenHeight*0.5,
                              color: Colors.grey,
                              child: Column(
                                children: [
                                  Container(
                                    width: screenWidth*0.9,
                                    height: screenHeight*0.48,
                                    child: VideoPlayer(_videoPlayerController),
                                  ),
                                  VideoProgressIndicator(_videoPlayerController, allowScrubbing: true)
                                ],
                              )
                            ),
                          ),
                        );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ): Container(),
              ],
            )
          ],
        ),
      ),
    );
  }
}