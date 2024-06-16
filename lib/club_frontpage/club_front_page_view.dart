import 'package:club_me/models/parser/club_me_club_parser.dart';
import 'package:club_me/shared/map_utils.dart';
import 'package:club_me/shared/show_story_chewie.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../models/event.dart';
import '../models/parser/club_me_event_parser.dart';
import '../provider/state_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar_clubs.dart';
import '../shared/custom_text_style.dart';
import '../user_clubs/components/event_card.dart';
import 'package:timezone/standalone.dart' as tz;

class ClubFrontPageView extends StatefulWidget {
  const ClubFrontPageView({Key? key}) : super(key: key);

  @override
  State<ClubFrontPageView> createState() => _ClubFrontPageViewState();
}

class _ClubFrontPageViewState extends State<ClubFrontPageView> {

  String headLine = "Deine Startseite";

  List<ClubMeEvent> pastEvents = [];
  List<ClubMeEvent> upcomingEvents = [];
  List<String> priceListString = ["Preisliste"];
  List<String> mehrEventsString = ["Mehr Events!", "Get more events"];
  List<String> mehrPhotosButtonString = ["Mehr Fotos!", "Explore more photos"];
  List<String> findOnMapsButtonString = ["Finde uns auf Maps!", "Find us on maps!"];

  bool isLoading = false;
  bool showVideoIsActive = false;
  double moreButtonWidthFactor = 0.04;

  late Future getClub;
  late Future getEvents;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;
  late Future<void> _initializeVideoPlayerFuture;
  late VideoPlayerController _videoPlayerController;

  final SupabaseService _supabaseService = SupabaseService();


  @override
  void initState() {
    super.initState();
    final stateProvider = Provider.of<StateProvider>(context, listen:  false);

    getClub = _supabaseService.getSpecificClub(stateProvider.getUserData().getUserId()).then(
            (value) => stateProvider.setUserClub(parseClubMeClub(value[0])));

    if(stateProvider.getFetchedEvents().isEmpty){
      getEvents = _supabaseService.getEventsOfSpecificClub(stateProvider.getUserData().getUserId());
    }
  }
  @override
  void dispose() {
    super.dispose();
  }


  // BUILD
  Widget fetchEventsFromDbAndBuildWidget(
      StateProvider stateProvider,
      double screenHeight, double screenWidth
      ){

    return stateProvider.getFetchedEvents().isEmpty || stateProvider.userClub == null ?
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
        // Container for the bg gradient
        Container(

          // background
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

              _buildMapAndPricelistIcons(),

              // White line
              const Divider(
                height:10,
                thickness: 1,
                color: Colors.white,
                indent: 20,
                endIndent: 20,
              ),

              _buildEventSection(),

              // White line
              const Divider(
                height:10,
                thickness: 1,
                color: Colors.white,
                indent: 20,
                endIndent: 20,
              ),

              _buildNewsSection(),

              // White line
              const Divider(
                height:10,
                thickness: 1,
                color: Colors.white,
                indent: 20,
                endIndent: 20,
              ),

              _buildPhotosAndVideosSection(),

              // White line
              const Divider(
                height:10,
                thickness: 1,
                color: Colors.white,
                indent: 20,
                endIndent: 20,
              ),

              _buildSocialMediaSection(),

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

              _buildMusicGenresSection(),

              // White line
              const Divider(
                height:10,
                thickness: 1,
                color: Colors.white,
                indent: 20,
                endIndent: 20,
              ),

              _buildContactSection(),

              SizedBox(
                height: screenHeight*0.1,
              )


            ],
          ),
        ),

      ],
    );
  }
  Widget _buildLogoIcon(){
    return stateProvider.getUserClub().getStoryId().isNotEmpty?
    Stack(
      children: [
        Container(
          // alignment: Alignment.center,
          width: screenWidth*0.25,
          height: screenWidth*0.25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
                color: Colors.black
            ),
            image: DecorationImage(
              fit: BoxFit.cover,
              opacity: 0.5,
              image: AssetImage(
                "assets/images/${stateProvider.getUserClub().getBannerId()}",
              ),
            ),
          ),
        ),
        Container(
          width: screenWidth*0.25,
          height: screenWidth*0.25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(45)
                    ),
                    border: Border.all(
                        color: Colors.white
                    )
                ),
                child: Icon(
                  Icons.play_arrow,
                  size: customTextStyle.getIconSize1(),
                ),
              )
            ],
          ),
        )
      ],
    ):
    Container(
      width: screenWidth*0.25,
      height: screenWidth*0.25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            "assets/images/${stateProvider.getUserClub().getBannerId()}",
          ),
        ),
      ),
    );
  }
  Widget _buildMapAndPricelistIcons(){
    return Column(
      children: [
        // Spacer
        SizedBox(
          height: screenHeight*0.03,
        ),

        // Icons next to logo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              child: Column(
                children: [

                  Icon(
                    Icons.location_on_outlined,
                    color: stateProvider.getPrimeColor(),
                  ),

                  const Text(
                      "Karte"
                  ),
                ],
              ),
              onTap: (){
                MapUtils.openMap(stateProvider.getClubCoordLat(), stateProvider.getClubCoordLng());
              },
            ),
            GestureDetector(
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    color: stateProvider.getPrimeColor(),
                  ),
                  Text(
                      priceListString[0]
                  )
                ],
              ),
              onTap: () => clickOnPriceList(screenHeight, screenWidth),
            )
          ],
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),
      ],
    );
  }
  Widget _buildEventSection(){
    return Column(
      children: [

        // Events headline
        Container(
            width: screenWidth,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                top: screenHeight*0.01
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // Headline
                Text(
                  "Events",
                  textAlign: TextAlign.left,
                  style: customTextStyle.size2BoldLightGrey(),
                ),

                // New event icon
                Padding(
                    padding: EdgeInsets.only(
                        right: screenWidth*0.05
                    ),
                    child: GestureDetector(
                      child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Icon(
                            Icons.add,
                            color: stateProvider.getPrimeColor(),
                          )
                      ),
                      onTap: () => clickOnAddEvent(screenHeight, screenWidth),
                    )
                )
              ],
            )
        ),

        // Spacer
        SizedBox(height: screenHeight*0.01,),

        // First Event
        upcomingEvents.isNotEmpty ?
        EventCard(clubMeEvent: upcomingEvents[0])
            : Container(),

        // Spacer
        SizedBox(height: screenHeight*0.01,),

        // Second Event
        upcomingEvents.length > 1 ?
        EventCard(clubMeEvent: upcomingEvents[1])
            : Container(),

        // Text, when no event available
        upcomingEvents.isEmpty ?
        Text(
          "Keine neuen Events.",
          style: customTextStyle.size3(),
        )
            : Container(),

        // Spacer
        SizedBox(height: screenHeight*0.02,),

        // Button mehr events
        Container(
            width: screenWidth*0.9,
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight*0.015,
                    horizontal: screenWidth*0.03
                ),
                decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Text(
                  mehrEventsString[0],
                  textAlign: TextAlign.center,
                  style: customTextStyle.size4BoldPrimeColor(),
                ),
              ),
              onTap: () => clickOnDiscoverMoreEvents(screenHeight, screenWidth),
            )
        ),

        // Spacer
        SizedBox(height: screenHeight*0.02,),
      ],
    );
  }
  Widget _buildNewsSection(){
    return Column(
      children: [

        // News Headline
        Container(
          width: screenWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // News headline
              Container(
                padding: EdgeInsets.only(
                    left: screenWidth*0.05,
                    top: screenHeight*0.01
                ),
                child: Text(
                  "News",
                  textAlign: TextAlign.left,
                  style: customTextStyle.size2BoldLightGrey(),
                ),
              ),

              // New button
              Padding(
                  padding: EdgeInsets.only(
                      right: screenWidth*0.05,
                      top: screenHeight*0.01
                  ),
                  child: GestureDetector(
                    child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: stateProvider.getPrimeColor(),
                        )
                    ),
                    onTap: () => clickOnEditNews(
                        screenHeight,
                        screenWidth
                    ),
                  )
              )
            ],
          ),
        ),

        // News Content
        Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            stateProvider.getUserClubNews(),
            style: customTextStyle.size4(),
          ),
        ),
      ],
    );
  }
  Widget _buildPhotosAndVideosSection(){
    return Column(
      children: [

        // Photos and videos headline
        Container(
            width: screenWidth,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                top: screenHeight*0.01
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // Headline text
                Text(
                  "Fotos & Videos",
                  textAlign: TextAlign.left,
                  style: customTextStyle.size2BoldLightGrey(),
                ),

                // Add photo icon
                Padding(
                    padding: EdgeInsets.only(
                      right: screenWidth*0.05,
                      // top: screenHeight*0.01
                    ),
                    child: GestureDetector(
                      child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Icon(
                            Icons.add,
                            color: stateProvider.getPrimeColor(),
                          )
                      ),
                      onTap: () => clickOnAddPhotoOrVideo(screenHeight, screenWidth),
                    )
                ),

              ],
            )
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // First row images
        Padding(
          padding: EdgeInsets.only(left: screenWidth*0.05),
          child: Row(
            children: [
              Container(
                width: screenWidth*0.29,
                height: screenWidth*0.29,
                child: Image.asset(
                  'assets/images/dj_wallpaper_3.png', // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: screenWidth*0.02,),
              Container(
                width: screenWidth*0.29,
                height: screenWidth*0.29,
                child: Image.asset(
                  'assets/images/dj_wallpaper_4.png', // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: screenWidth*0.02,),
              Container(
                width: screenWidth*0.29,
                height: screenWidth*0.29,
                child: Image.asset(
                  'assets/images/dj_wallpaper_5.png', // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // Second row images
        Padding(
          padding: EdgeInsets.only(left: screenWidth*0.05),
          child: Row(
            children: [
              Container(
                width: screenWidth*0.29,
                height: screenWidth*0.29,
                child: Image.asset(
                  'assets/images/dj_wallpaper_3.png', // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: screenWidth*0.02,),
              Container(
                width: screenWidth*0.29,
                height: screenWidth*0.29,
                child: Image.asset(
                  'assets/images/dj_wallpaper_4.png', // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: screenWidth*0.02,),
              Container(
                width: screenWidth*0.29,
                height: screenWidth*0.29,
                child: Image.asset(
                  'assets/images/dj_wallpaper_5.png', // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // More button
        Container(
            width: screenWidth*0.9,
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight*0.015,
                    horizontal: screenWidth*0.03
                ),
                decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Text(
                  mehrPhotosButtonString[0],
                  textAlign: TextAlign.center,
                  style: customTextStyle.size4BoldPrimeColor(),
                ),
              ),
              onTap: () => clickOnDiscoverMorePhotos(screenHeight, screenWidth),
            )
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),
      ],
    );
  }
  Widget _buildSocialMediaSection(){
    return Column(
      children: [

        // Social Media headline
        Container(
          width: screenWidth,
          // color: Colors.red,
          padding: EdgeInsets.only(
              left: screenWidth*0.05,
              top: screenHeight*0.01
          ),
          child: Text(
            "Social Media",
            textAlign: TextAlign.left,
            style: customTextStyle.size2BoldLightGrey(),
          ),
        ),

        // Insta Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Social media
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.03
              ),
              child: IconButton(
                  onPressed: () => goToSocialMedia(stateProvider.getUserClubInstaLink()),
                  icon: Icon(
                    FontAwesomeIcons.instagram,
                    color: stateProvider.getPrimeColor(),
                  )
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.03
              ),
              child: IconButton(
                  onPressed: () => goToSocialMedia(
                      stateProvider.getUserClubWebsiteLink()
                  ),
                  icon: Icon(
                    Icons.home_filled,
                    color: stateProvider.getPrimeColor(),
                  )
              ),
            ),

          ],
        ),
      ],
    );
  }
  Widget _buildMusicGenresSection(){
    return Column(
      children: [

        // headline
        Container(
          width: screenWidth,
          padding: EdgeInsets.only(
              left: screenWidth*0.05,
              top: screenHeight*0.01
          ),
          child: Text(
            "Musikrichtungen",
            textAlign: TextAlign.left,
            style: customTextStyle.size2BoldLightGrey(),
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // Musikgenres
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.05
              ),
              child: Text(
                stateProvider.userClub.getMusicGenres(),
                style: customTextStyle.size4(),
              ),
            )
          ],
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),
      ],
    );
  }
  Widget _buildContactSection(){
    return Column(
      children: [

        // Kontakt headline
        Container(
            width: screenWidth,
            // color: Colors.red,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                top: screenHeight*0.01
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kontakt",
                  textAlign: TextAlign.left,
                  style: customTextStyle.size2BoldLightGrey(),
                ),

                // New icon
                Padding(
                    padding: EdgeInsets.only(
                      right: screenWidth*0.05,
                      // top: screenHeight*0.01
                    ),
                    child: GestureDetector(
                      child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: stateProvider.getPrimeColor(),
                          )
                      ),
                      onTap: () => clickOnEditContact(screenHeight, screenWidth),
                    )
                ),
              ],
            )
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // Anschrift + icon
        Row(
          children: [

            // Spacer
            SizedBox(
              width: screenWidth*0.05,
            ),

            // Anschrift
            SizedBox(
              width: screenWidth*0.45,
              height: screenHeight*0.12,
              child: Column(
                children: [

                  // Contact name text
                  SizedBox(
                    width: screenWidth*0.5,
                    child: Text(
                      stateProvider.getUserContact()[0].length > 15 ?
                      stateProvider.getUserContact()[0].substring(0,15) :
                      stateProvider.getUserContact()[0],
                      textAlign: TextAlign.left,
                      style: customTextStyle.size4Bold(),
                    ),
                  ),

                  // Street
                  SizedBox(
                    width: screenWidth*0.5,
                    child: Text(
                      stateProvider.getUserContact()[1].length > 15 ?
                      stateProvider.getUserContact()[1].substring(0,15):
                      stateProvider.getUserContact()[1],
                      textAlign: TextAlign.left,
                      style:customTextStyle.size4(),
                    ),
                  ),

                  // City
                  SizedBox(
                    width: screenWidth*0.5,
                    child: Text(
                      stateProvider.getUserContact()[2].length > 15 ?
                      stateProvider.getUserContact()[2].substring(0,15):
                      stateProvider.getUserContact()[2],
                      textAlign: TextAlign.left,
                      style: customTextStyle.size4(),
                    ),
                  )
                ],
              ),
            ),

            // Google maps icon
            SizedBox(
              width: screenWidth*0.45,
              child: Column(
                children: [
                  SizedBox(
                    width: screenWidth*0.2,
                    height: screenWidth*0.2,
                    child: Image.asset(
                      'assets/images/google_maps_teal.png',
                    ),
                  )
                ],
              ),
            )
          ],
        ),

        // Find us on maps icon
        Container(
            width: screenWidth*0.9,
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight*0.015,
                    horizontal: screenWidth*0.03
                ),
                decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Text(
                  findOnMapsButtonString[0],
                  textAlign: TextAlign.center,
                  style: customTextStyle.size4BoldPrimeColor(),
                ),
              ),
              onTap: () => MapUtils.openMap(stateProvider.getClubCoordLat(), stateProvider.getClubCoordLng()),
            )
        ),

      ],
    );
  }
  AppBar _buildAppBar(){
    return AppBar(
        backgroundColor: Colors.transparent,
        title: SizedBox(
          width: screenWidth,
          child: Stack(
            children: [
              Container(
                width: screenWidth,
                padding: EdgeInsets.only(
                    top: screenHeight*0.01
                ),
                child: Center(
                  child: Text(headLine,
                      textAlign: TextAlign.center,
                      style: customTextStyle.size2()
                  ),
                ),
              ),
              Container(
                width: screenWidth,
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                      Icons.settings
                  ),
                  onPressed: () => context.push("/settings"),
                ),
              )
            ],
          ),
        )
    );
  }

  // FILTER
  void filterEventsFromProvider(StateProvider stateProvider){
    for(var currentEvent in stateProvider.getFetchedEvents()){
      // add 23 so that we can still find it as upcoming even though it's the same day
      DateTime eventTimestamp = currentEvent.getEventDate();

      // subtract 7 so that time zones and late at night queries work well
      // DateTime todayTimestamp = DateTime.now().subtract(Duration(hours: 7));

      // Get current time for germany
      final berlin = tz.getLocation('Europe/Berlin');
      final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin).subtract(const Duration(hours:5));

      // Filter the events
      if(eventTimestamp.isAfter(todayTimestamp)){
        upcomingEvents.add(currentEvent);
      }else{
        pastEvents.add(currentEvent);
      }
    }
  }
  void filterEventsFromQuery(var data, StateProvider stateProvider){
    for(var element in data){
      ClubMeEvent currentEvent = parseClubMeEvent(element);

      // add 23 so that we can still find it as upcoming even though it's the same day
      DateTime eventTimestamp = currentEvent.getEventDate();

      // subtract 7 so that time zones and late at night queries work well
      // DateTime todayTimestamp = DateTime.now().subtract(Duration(hours: 7));

      // Get current time for germany
      final berlin = tz.getLocation('Europe/Berlin');
      final todayTimestamp = tz.TZDateTime.from(DateTime.now(), berlin).subtract(const Duration(hours:5));

      // Filter the events
      if(eventTimestamp.isAfter(todayTimestamp)){
        upcomingEvents.add(currentEvent);
      }else{
        pastEvents.add(currentEvent);
      }

      // Add to provider so that we dont need to call them from the db again
      stateProvider.addEventToFetchedEvents(currentEvent);
    }
  }


  // CLICK
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
  void clickOnAddEvent(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Neues Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Question text
            const Text(
              "Möchtest du ein neues Event anlegen?",
              textAlign: TextAlign.left,
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // "New event" button
            Container(
                width: screenWidth*0.9,
                // color: Colors.red,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight*0.015,
                        horizontal: screenWidth*0.03
                    ),
                    decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Text(
                      "Neues Event!",
                      textAlign: TextAlign.center,
                      style: customTextStyle.size4BoldPrimeColor(),
                    ),
                  ),
                  onTap: () => context.go("/club_new_event"),
                )
            ),

          ],
        ),
      );
    });
  }
  void clickOnPriceList(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Preisliste"),
        content: Text(
          "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!",
          textAlign: TextAlign.left,
          style: customTextStyle.size4(),
        ),
      );
    });
  }
  void clickOnEditNews(double screenHeight, double screenWidth, ){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          title: const Text("News"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Question text
              Text("Willst du die News anpassen?"),

              // Spacer
              SizedBox(
                height: screenHeight*0.02,
              ),

              // "News anpassen" button
              Container(
                  width: screenWidth*0.9,
                  // color: Colors.red,
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight*0.015,
                          horizontal: screenWidth*0.03
                      ),
                      decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Text(
                        "News anpassen!",
                        textAlign: TextAlign.center,
                        style: customTextStyle.size4BoldPrimeColor(),
                      ),
                    ),
                    onTap: () => context.go('/club_update_news'),
                  )
              ),
            ],
          )
      );
    });
  }
  void clickOnEditContact(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          title: const Text("Kontakt"),
          content:Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Question text
              Text("Willst du deine Adresse anpassen?"),

              // Spacer
              SizedBox(
                height: screenHeight*0.02,
              ),

              Container(
                  width: screenWidth*0.9,
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight*0.015,
                          horizontal: screenWidth*0.03
                      ),
                      decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Text(
                        "Adresse anpassen!",
                        textAlign: TextAlign.center,
                        style: customTextStyle.size4BoldPrimeColor(),
                      ),
                    ),
                    onTap: () => context.go('/club_update_contact'),
                  )
              ),

            ],
          )
      );
    });
  }
  void clickOnAddPhotoOrVideo(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Hinzufügen von Photos und Videos"),
        content: SizedBox(
            height: screenHeight*0.12,
            child: Center(
              child: Text(
                "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!",
                textAlign: TextAlign.left,
                style: customTextStyle.size4(),
              ),
            )
        ),
      );
    });
  }
  void clickOnDiscoverMoreEvents(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Ausführliche Eventliste"),
        content: Text(
          "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!",
          textAlign: TextAlign.left,
          style: customTextStyle.size4(),
        )
      );
    });
  }
  void clickOnDiscoverMorePhotos(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Ausführliche Photoliste"),
        content: Text(
          "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!",
          textAlign: TextAlign.left,
          style: customTextStyle.size4(),
        ),
      );
    });
  }
  void clickOnStoryButton(BuildContext context, double screenHeight, double screenWidth, StateProvider stateProvider){

    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Story"),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // Question text
            Text(
              "Möchtest du eine Story hochladen?",
              textAlign: TextAlign.left,
              style: customTextStyle.size4(),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),


            // "New event" button
            Container(
                width: screenWidth*0.9,
                // color: Colors.red,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight*0.015,
                        horizontal: screenWidth*0.03
                    ),
                    decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Text(
                      "Neue Story!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: stateProvider.getPrimeColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth*moreButtonWidthFactor
                      ),
                    ),
                  ),
                  onTap: () =>  context.go("/video_recording"),
                )
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.01,
            ),

            // Does a story exist? Then show a button to play it
            stateProvider.getClubStoryId().isNotEmpty ?

            Container(
                width: screenWidth*0.9,
                // color: Colors.red,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight*0.015,
                        horizontal: screenWidth*0.03
                    ),
                    decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Text(
                      "Story anschauen!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: stateProvider.getPrimeColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth*moreButtonWidthFactor
                      ),
                    ),
                  ),
                  onTap: () =>  {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShowStoryChewie(
                            storyUUID: stateProvider.getClubStoryId(),
                            clubName:  stateProvider.getClubName(),
                        ),
                      ),
                    )
                  },
                )
            ): Container(),

          ],
        ),
      );
    });
  }


  // MISC
  static Future<void> goToSocialMedia(String socialMediaLink) async{

    print("Link: $socialMediaLink");

    Uri googleUrl = Uri.parse(socialMediaLink);

    await canLaunchUrl(googleUrl)
        ? await launchUrl(googleUrl)
        : print("Error");
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    customTextStyle = CustomTextStyle(context: context);

    // Check if filter necessary
    if(upcomingEvents.isEmpty && pastEvents.isEmpty){
      filterEventsFromProvider(stateProvider);
    }

    return Scaffold(

      // extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: true,


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
          child: Column(
            children: [

              // // Spacer
              // SizedBox(
              //   height: screenHeight*0.12,
              // ),

              // Content
              Stack(
                children: [

                  // BG Image
                  Container(
                      height: screenHeight*0.25,
                      color: stateProvider.userClub.getBackgroundColorId() == 0 ? Colors.white : Colors.black,
                      child: Center(
                          child: SizedBox(
                            height: screenHeight,
                            child: Image.asset(
                              "assets/images/${stateProvider.userClub.getBannerId()}",
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
                        child: fetchEventsFromDbAndBuildWidget(stateProvider, screenHeight, screenWidth),
                      ),
                    ),
                  ),

                  // Centered logo
                  Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight*0.185
                    ),
                    child: Align(
                        // alignment: Alignment.center,
                        child: GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildLogoIcon()
                              ],
                            ),
                            onTap: () => clickOnStoryButton(context, screenHeight, screenWidth, stateProvider)
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
                                    SizedBox(
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
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }



}
