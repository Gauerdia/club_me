import 'package:club_me/models/club.dart';
import 'package:club_me/models/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';
import '../shared/custom_bottom_navigation_bar.dart';

class UserClubsView extends StatefulWidget {
  const UserClubsView({Key? key}) : super(key: key);

  @override
  State<UserClubsView> createState() => _UserClubsViewState();
}

class _UserClubsViewState extends State<UserClubsView>
  with TickerProviderStateMixin{

  List<ClubMeEvent> events = [
    ClubMeEvent(
        title: "Tropical Techno",
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

  List<ClubMeClub> clubMeClubs = [
    ClubMeClub(
        clubName: "Berghain",
        distance: "1.2",
        NOfPeople: "54",
        genre: "Techno",
        imagePath: 'assets/images/berghain_logo.jpg',
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

  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  Color navigationBackgroundColor = const Color(0xff11181f);

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
          title: const Text("Clubs for You"),
          leading: const Icon(
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
          child: Column(
            children: [

              // Spacer
              SizedBox(height: screenHeight*0.07,),

              // Pageview of the club cards
              Container(
                height: screenHeight*0.85,
                // color: Colors.red,
                child: PageView(
                  /// [PageView.scrollDirection] defaults to [Axis.horizontal].
                  /// Use [Axis.vertical] to scroll vertically.
                  controller: _pageViewController,
                  onPageChanged: _handlePageViewChanged,
                  children: <Widget>[
                    Center(
                      child: ClubCard(events: events,clubMeClub: clubMeClubs[0],),
                    ),
                    Center(
                      child: Text('Second Page', style: TextStyle()),
                    ),
                    Center(
                      child: Text('Third Page', style: TextStyle()),
                    ),
                  ],
                ),
              ),

              Container(
                height: screenHeight*0.07,
                child: PageIndicator(
                  tabController: _tabController,
                  currentPageIndex: _currentPageIndex,
                  onUpdateCurrentPageIndex: _updateCurrentPageIndex,
                ),
              )
            ],
          )
        )
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}


class ClubCard extends StatelessWidget {

  ClubCard({Key? key, required this.events, required this.clubMeClub}) : super(key: key);

  List<ClubMeEvent> events;
  ClubMeClub clubMeClub;

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(

        width: screenWidth*0.95,
        height: screenHeight*0.752,//0.7885,

        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
                width: 1, color: Colors.white60
            ),
            right: BorderSide(
                width: 1, color: Colors.white60
            ),
            bottom: BorderSide(
                width: 1, color: Colors.white60
            ),
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),

      child: Column(
        children: [

          // Image part
          GestureDetector(
            child: SizedBox(
              height: screenHeight*0.2,
              child: Stack(
                children: [

                  Container(
                    // Image background
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.grey[700]!,
                            Colors.grey[850]!
                          ],
                          stops: const [0.3, 0.8]
                      ),
                    ),

                    // Image + its sides
                    child: Container(
                        width: screenWidth*0.95,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          color: Colors.white,
                        ),
                        // height: screenHeight*0.17,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              topLeft: Radius.circular(12)
                          ),
                          child: Image.asset(
                            "assets/images/berghain_logo.jpg",
                            // fit: BoxFit.cover,
                          ),
                        )
                    ),

                  )
                ],
              ),
            ),
            onTap: (){
              stateProvider.setCurrentClub(clubMeClub);
              context.go("/club_details");
            },
          ),

          // Content
          Container(
            height: screenHeight*0.55,//0.5485,
            width: screenWidth*0.95,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[700]!,
                    Colors.grey[850]!
                  ],
                  stops: const [0.3, 0.8]
              ),
            ),

            child: Column(
              children: [

                const SizedBox(height: 7),

                // Header: name, icons
                Container(
                  // color: Colors.yellowAccent,
                  height: screenHeight*0.08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10,
                              left: 10,
                              bottom: 10
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Berghain",
                              style: TextStyle(
                                  fontSize: screenHeight*0.03,//26,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                        onTap: (){
                          stateProvider.setCurrentClub(clubMeClub);
                          context.go("/club_details");
                        },
                      ),

                      // Icon row
                      SizedBox(
                        height: screenHeight*0.08,
                        // color: Colors.red,
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.purpleAccent,
                                      size: screenHeight*0.035,
                                    ),
                                    SizedBox(
                                      width: screenWidth*0.035,
                                    ),
                                    Icon(
                                      Icons.star_border,
                                      color: Colors.purpleAccent,
                                      size: screenHeight*0.035,
                                    ),
                                    SizedBox(
                                      width: screenWidth*0.035,
                                    ),
                                    Icon(
                                      Icons.share,
                                      color: Colors.purpleAccent,
                                      size: screenHeight*0.035,
                                    ),
                                    SizedBox(
                                      width: screenWidth*0.03,
                                    ),
                                  ],
                                ),
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: screenWidth*0.03,
                                    ),
                                    Text(
                                      "Info",
                                      style: TextStyle(
                                          fontSize: screenHeight*0.018,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth*0.025,
                                    ),
                                    Text(
                                      "Like",
                                      style: TextStyle(
                                        fontSize: screenHeight*0.018,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth*0.025,
                                    ),
                                    Text(
                                      "Share",
                                      style: TextStyle(
                                        fontSize: screenHeight*0.018,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth*0.035,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                            )
                        ),
                      )

                    ],
                  ),
                ),

                // White line
                const Divider(
                  height:10 ,
                  thickness: 1,
                  color: Colors.white,
                  indent: 20,
                  endIndent: 20,
                ),

                // const SizedBox(height: 10,),

                // Middle part: next two events
                Container(
                  height: screenHeight*0.33,
                  // color: Colors.red,
                  child: SingleChildScrollView(
                    child:Column(
                      children: [

                        // Friday
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 5,
                              left: 10,
                              bottom: 5
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Freitag",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 5,),

                        // Card
                        GestureDetector(
                          child: EventCard(clubMeEvent: events[0],),
                          onTap: (){
                            stateProvider.setCurrentEvent(events[0]);
                            context.go('/event_details');
                          },
                        ),

                        SizedBox(height: 5,),

                        // Saturday
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10,
                              left: 10,
                              bottom: 5
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Samstag",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[400]
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 5,),

                        // Card
                        GestureDetector(
                          child: EventCard(clubMeEvent: events[1],),
                          onTap: (){
                            stateProvider.setCurrentEvent(events[1]);
                            context.go('/event_details');
                          },
                        ),

                      ],
                    ),
                  )
                ),

                // Spacer
                // const SizedBox(height: 20),

                // White line
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.white,
                  indent: 20,
                  endIndent: 20,
                ),

                // Spacer
                // const SizedBox(height: 15),

                // Bottom
                // Container(
                //   width: screenWidth,
                //   height: screenHeight*0.1,
                //   // color: Colors.green,
                // )
                Container(
                  height: screenHeight*0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      const Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white60,
                              child: CircleAvatar(
                                backgroundImage: AssetImage(
                                    "assets/images/person_1.jpg",
                                ),
                                radius: 19,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30),
                            child: CircleAvatar(
                              radius: 21,
                              backgroundColor: Colors.white60,
                              child: CircleAvatar(
                                backgroundImage: AssetImage(
                                  "assets/images/person_2.jpg",
                                ),
                                radius: 20,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 50),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white60,
                              child: CircleAvatar(
                                backgroundImage: AssetImage(
                                  "assets/images/person_3.jpg",
                                ),
                                radius: 21,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Icon Row
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Align(
                          // alignment: Alignment.bottomRight,
                          child: Container(
                            width: screenWidth*0.5,
                            height: screenHeight*0.05,

                            decoration: const BoxDecoration(
                              color: Color(0xff11181f),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(12)
                              ),
                            ),
                            child: Row(
                              children: [

                                SizedBox(width: 5,),

                                Container(
                                  padding: const EdgeInsets.all(
                                      4
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(45)
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.route,
                                    color: Colors.purpleAccent,
                                    size: 16,
                                  ),
                                ),

                                SizedBox(width: 5,),

                                const Text(
                                  "1.2",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14
                                  ),
                                ),

                                const SizedBox(width: 5,),

                                Container(
                                  padding: const EdgeInsets.all(
                                      4
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(45)
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.library_music_outlined,
                                    color: Colors.purpleAccent,
                                    size: 16,
                                  ),
                                ),

                                SizedBox(width: 5,),

                                const Text(
                                  "Techno",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14
                                  ),
                                ),

                                SizedBox(width: 5,),

                                Container(
                                  padding: const EdgeInsets.all(
                                      4
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(45)
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.people_alt_outlined,
                                    color: Colors.purpleAccent,
                                    size: 16,
                                  ),
                                ),

                                SizedBox(width: 5,),

                                const Text(
                                  "64",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )

              ],
            ),
          ),
        ],
      )
    );
  }
}

class EventCard extends StatelessWidget {

  EventCard({
    Key? key,
    required this.clubMeEvent,
    this.wentFromClubDetailToEventDetail = false
  }) : super(key: key);

  ClubMeEvent clubMeEvent;

  bool wentFromClubDetailToEventDetail;


  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
        width: screenWidth*0.9,
        height: screenHeight*0.12,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[900]!,
              blurRadius: 4,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child:Stack(
          children: [

            // Event Title container
            SizedBox(
              width: screenWidth*0.9,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 2,
                    left: 10
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    textAlign: TextAlign.start,
                    clubMeEvent.getTitle(),
                    style: TextStyle(
                        fontSize: screenHeight*0.025,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),

            // eventGenre
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight*0.045,
                  left: 10
              ),
              child: Text(
                clubMeEvent.getMusicGenres(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            // eventWhen
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight*0.075,
                left: 10,
              ),
              child: Text(
                clubMeEvent.getHours(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            // Check it out button
            Padding(
                padding: const EdgeInsets.only(right: 7, bottom: 7),
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xff11181f),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        )
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      "Check it out!",
                      style: TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  onTap: (){
                    stateProvider.setCurrentEvent(clubMeEvent);
                    if(wentFromClubDetailToEventDetail)stateProvider.toggleWentFromCLubDetailToEventDetail();
                    context.go("/event_details");
                  },
                ),
              ),
            )
          ],
        )
    );
  }
}



class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;

  @override
  Widget build(BuildContext context) {

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(
              Icons.arrow_left_rounded,
              size: 32.0,
            ),
          ),
          TabPageSelector(
            controller: tabController,
            color: colorScheme.background,
            selectedColor: colorScheme.primary,
          ),
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 2) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(
              Icons.arrow_right_rounded,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}
