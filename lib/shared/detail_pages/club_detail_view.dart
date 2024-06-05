import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../user_clubs/components/event_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:club_me/shared/map_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../custom_bottom_navigation_bar.dart';
import '../../provider/state_provider.dart';
import '../custom_text_style.dart';
import '../../models/event.dart';
import '../show_story.dart';

class ClubDetailView extends StatefulWidget {
  const ClubDetailView({Key? key}) : super(key: key);

  @override
  State<ClubDetailView> createState() => _ClubDetailViewState();
}

class _ClubDetailViewState extends State<ClubDetailView> {

  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  List<String> priceListString = ["Preisliste"];
  List<String> mehrEventsString = ["Mehr Events!", "Get more events"];
  List<String> mehrPhotosButtonString = ["Mehr Photos!", "Explore more photos"];
  List<String> findOnMapsButtonString = ["Finde uns auf Maps!", "Find us on maps!"];

  late double screenHeight, screenWidth;
  late StateProvider stateProvider;

  late CustomTextStyle customTextStyle;

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  bool showVideoIsActive = false;
  bool noEventsAvailable = false;

  List<ClubMeEvent> eventsToDisplay = [];


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

  void clickOnStoryButton(BuildContext context, double screenHeight, double screenWidth, StateProvider stateProvider){

    if(stateProvider.getCurrentClubStoryId().isNotEmpty){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShowStory(storyUUID: stateProvider.getCurrentClubStoryId()),
        ),
      );
    }else{

    }
  }

  static Future<void> goToSocialMedia(String socialMediaLink) async{

    print("Link: $socialMediaLink");

    Uri googleUrl = Uri.parse(socialMediaLink);

    await canLaunchUrl(googleUrl)
        ? await launchUrl(googleUrl)
        : print("Error");
  }

  void addPhotoOrVideo(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Hinzufügen von Photos und Videos"),
        content: SizedBox(
            height: screenHeight*0.12,
            child: Center(
              child: Text("Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!"),
            )
        ),
      );
    });
  }

  void clickOnDiscoverMoreEvents(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Ausführliche Eventliste"),
        content: SizedBox(
            height: screenHeight*0.12,
            child: Center(
              child: Text("Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!"),
            )
        ),
      );
    });
  }

  void clickOnDiscoverMorePhotos(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Ausführliche Photoliste"),
        content: SizedBox(
            height: screenHeight*0.12,
            child: Center(
              child: Text("Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!"),
            )
        ),
      );
    });
  }

  void clickOnPriceList(double screenHeight, double screenWidth){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Preisliste"),
        content: SizedBox(
            height: screenHeight*0.12,
            child: Center(
              child: Text("Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!"),
            )
        ),
      );
    });
  }

  Widget _buildMainView(){
    return Column(
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
                color: stateProvider.clubMeClub.getBackgroundColorId() == 0 ? Colors.white : Colors.black,
                child: Center(
                    child: SizedBox(
                      height: screenHeight,
                      child: Image.asset(
                        "assets/images/${stateProvider.clubMeClub.getBannerId()}",
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

                            _buildMapAndPricelistIconSection(),

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
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(color: stateProvider.getPrimeColor()),
                                right: BorderSide(color: stateProvider.getPrimeColor()),
                                top: BorderSide(color: stateProvider.getPrimeColor())
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(45))
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.black,
                          child: stateProvider.clubMeClub.getStoryId().isNotEmpty ? Icon(Icons.play_arrow):Text("ClubMe"),
                        ),
                      ),
                      onTap: () => clickOnStoryButton(context, screenHeight, screenWidth, stateProvider)
                  )
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMapAndPricelistIconSection(){
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
            // Map
            GestureDetector(
              child: Column(
                children: [
                  Icon(
                    Icons.route_outlined,
                    color: stateProvider.getPrimeColor(),
                    size: screenHeight*stateProvider.getIconSizeFactor(),
                  ),
                  Text(
                      "Karte",
                    style: customTextStyle.size5(),
                  ),
                ],
              ),
              onTap: () => MapUtils.openMap(stateProvider.clubMeClub.geoCoordLat, stateProvider.clubMeClub.geoCoordLng),
            ),
            // Price list
            GestureDetector(
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    color: stateProvider.getPrimeColor(),
                    size: screenHeight*stateProvider.getIconSizeFactor(),
                  ),
                  Text(
                      "Preisliste",
                    style: customTextStyle.size5(),
                  )
                ],
              ),
              onTap: () => clickOnPriceList(screenHeight, screenWidth),
            ),
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
          // color: Colors.red,
          padding: EdgeInsets.only(
              left: screenWidth*0.05,
              top: screenHeight*0.01
          ),
          child: Text(
            "Events",
            textAlign: TextAlign.left,
            style: customTextStyle.size2BoldLightGrey(),
          ),
        ),

        // Spacer
        SizedBox(height: screenHeight*0.01,),

        noEventsAvailable?
        Container(
          height: screenHeight*0.1,
          child: const Center(
            child: Text("Derzeit keine Events geplant!"),
          ),
        )
            :EventCard(
          clubMeEvent: eventsToDisplay[0],
          wentFromClubDetailToEventDetail: true,
        ),

        // Spacer
        SizedBox(height: screenHeight*0.01,),

        noEventsAvailable?
        Container() : eventsToDisplay.length > 1?
        EventCard(
          clubMeEvent: eventsToDisplay[1],
          wentFromClubDetailToEventDetail: true
        ):Container(),

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
                  mehrEventsString[0],
                  textAlign: TextAlign.center,
                  style: customTextStyle.size4BoldPrimeColor(),
                ),
              ),
              onTap: ()=> clickOnDiscoverMoreEvents(screenHeight, screenWidth),
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
        // News headline
        Container(
          width: screenWidth,
          // color: Colors.red,
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

        // News text
        Padding(
          padding: EdgeInsets.all(18),
          child: Text(
              stateProvider.clubMeClub.getNews(),
            style: customTextStyle.size4(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosAndVideosSection(){
    return Column(
      children: [
        // Fotos and videos headline
        Container(
          width: screenWidth,
          // color: Colors.red,
          padding: EdgeInsets.only(
              left: screenWidth*0.05,
              top: screenHeight*0.01
          ),
          child: Text(
            "Fotos & Videos",
            textAlign: TextAlign.left,
            style: customTextStyle.size2BoldLightGrey(),
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
                  mehrPhotosButtonString[0],
                  textAlign: TextAlign.center,
                  style: customTextStyle.size4BoldPrimeColor(),
                ),
              ),
              onTap: ()=> clickOnDiscoverMorePhotos(screenHeight, screenWidth),
            )
        ),

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

            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.03
              ),
              child: IconButton(
                  onPressed: () => goToSocialMedia(stateProvider.clubMeClub.getInstagramLink()),
                  icon: const Icon(
                      FontAwesomeIcons.instagram
                  )
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.03
              ),
              child: IconButton(
                  onPressed: () => goToSocialMedia(
                      stateProvider.clubMeClub.getWebsiteLink()
                  ),
                  icon: Icon(
                    Icons.home_filled,
                    color: stateProvider.getPrimeColor(),
                  )
              ),
            ),

          ],
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
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
                  stateProvider.clubMeClub.getMusicGenres(),
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

    String ContactZipToDisplay = "";
    String ContactCityToDisplay = "";

    stateProvider.clubMeClub.getContactZip().length > 6 ?
        ContactZipToDisplay = stateProvider.clubMeClub.getContactZip().substring(0, 6) :
    ContactZipToDisplay = stateProvider.clubMeClub.getContactZip();

    stateProvider.clubMeClub.getContactCity().length > 10 ?
        ContactCityToDisplay = stateProvider.clubMeClub.getContactCity().substring(0, 10) :
        ContactCityToDisplay = stateProvider.clubMeClub.getContactCity();

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
          child: Text(
            "Kontakt",
            textAlign: TextAlign.left,
            style: customTextStyle.size2BoldLightGrey(),
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

            // Left Contact text column
            SizedBox(
              width: screenWidth*0.45,
              height: screenHeight*0.12,
              child: Column(
                children: [
                  SizedBox(
                    width: screenWidth*0.5,
                    child: Text(
                      stateProvider.clubMeClub.getContactName().length > 15 ?
                      stateProvider.clubMeClub.getContactName().substring(0,15):
                      stateProvider.clubMeClub.getContactName(),
                      textAlign: TextAlign.left,
                      style: customTextStyle.size4Bold(),
                    ),
                  ),

                  SizedBox(
                    width: screenWidth*0.5,
                    child: Text(
                      stateProvider.clubMeClub.getContactStreet().length > 15 ?
                      stateProvider.clubMeClub.getContactStreet().substring(0,15):
                      stateProvider.clubMeClub.getContactStreet(),
                      textAlign: TextAlign.left,
                      style: customTextStyle.size4(),
                    ),
                  ),

                  SizedBox(
                    width: screenWidth*0.5,
                    child: Text(
                      "$ContactZipToDisplay $ContactCityToDisplay",
                      textAlign: TextAlign.left,
                      style: customTextStyle.size4(),
                    ),
                  ),

                ],
              ),
            ),

            // Image
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
                      'assets/images/google_maps_teal.png',
                    ),
                  )
                ],
              ),
            )
          ],
        ),

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
                  findOnMapsButtonString[0],
                  textAlign: TextAlign.center,
                  style: customTextStyle.size4BoldPrimeColor(),
                ),
              ),
              onTap: ()=> MapUtils.openMap(stateProvider.clubMeClub.geoCoordLat, stateProvider.clubMeClub.geoCoordLng),
            )
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.1,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customTextStyle = CustomTextStyle(context: context);

    if(eventsToDisplay.isEmpty){
      if(stateProvider.getFetchedEvents().where((event) => event.getClubId() == stateProvider.clubMeClub.getClubId()).isEmpty){
        noEventsAvailable = true;
      }else{
        eventsToDisplay = stateProvider.getFetchedEvents().where((event) => event.getClubId() == stateProvider.clubMeClub.getClubId()).toList();
        noEventsAvailable = false;
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,

      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: SizedBox(
            width: screenWidth*0.6,
            child: Text(
              stateProvider.clubMeClub.getClubName(),
              textAlign: TextAlign.center,
              style: customTextStyle.size2(),
            ),
          ),
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
        child: _buildMainView()
      ),
    );
  }

}