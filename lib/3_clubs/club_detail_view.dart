import 'dart:io';

import 'package:club_me/stories/show_story_chewie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'user_view/components/event_card.dart';
import '../provider/current_and_liked_elements_provider.dart';
import '../provider/fetched_content_provider.dart';
import '../services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:club_me/shared/map_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../shared/custom_bottom_navigation_bar.dart';
import '../provider/state_provider.dart';
import '../shared/custom_text_style.dart';
import '../models/event.dart';


class ClubDetailView extends StatefulWidget {
  const ClubDetailView({Key? key}) : super(key: key);

  @override
  State<ClubDetailView> createState() => _ClubDetailViewState();
}

class _ClubDetailViewState extends State<ClubDetailView> {

  var log = Logger();

  bool noEventsAvailable = false;

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  final SupabaseService _supabaseService = SupabaseService();

  List<String> alreadyFetchedFrontPageImages = [];
  List<ClubMeEvent> eventsToDisplay = [];
  List<String> priceListString = ["Angebote"];
  List<String> mehrEventsString = ["Mehr Events!", "More events!"];
  List<String> mehrPhotosButtonString = ["Mehr Fotos!", "More photos!"];
  List<String> findOnMapsButtonString = ["Finde uns auf Maps!", "Find us on maps!"];


  @override
  void initState() {
    super.initState();

    final currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen:  false);
    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    checkForFrontPageImages(currentAndLikedElementsProvider, stateProvider);

  }
  @override
  void dispose() {
    super.dispose();
  }


  void _showDialogWithTitleAndText(String title, String content){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
                color: customStyleClass.primeColor
            )
        ),
        title: Text(
            title,
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                content,
                style: customStyleClass.getFontStyle4(),
              ),
            )
          ],
        ),
      );
    });
  }

  // CLICKED
  void clickOnPriceList(double screenHeight, double screenWidth){

    if(currentAndLikedElementsProvider.currentClubMeClub.clubOffers.offers.isNotEmpty){
      context.push("/user_offers");
    }else{
      _showDialogWithTitleAndText(
          "Angebote",
          "Dieser Club hat derzeit noch keine Angebote im Sortiment!"
      );
    }


  }
  void clickOnDiscoverMoreEvents(double screenHeight, double screenWidth){

    stateProvider.toggleWentFromCLubDetailToEventDetail();
    context.push("/user_upcoming_events");

    // showDialog(context: context, builder: (BuildContext context){
    //   return AlertDialog(
    //     title: const Text("Ausführliche Eventliste"),
    //     content: SizedBox(
    //         height: screenHeight*0.12,
    //         child: Center(
    //           child: Text("Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!"),
    //         )
    //     ),
    //   );
    // });

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
  void clickOnStoryButton(BuildContext context, double screenHeight, double screenWidth, StateProvider stateProvider){

    if(currentAndLikedElementsProvider.getCurrentClubStoryId().isNotEmpty){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShowStoryChewie(
            storyUUID: currentAndLikedElementsProvider.getCurrentClubStoryId(),
            clubName: currentAndLikedElementsProvider.currentClubMeClub.getClubName(),
          ),
        ),
      );
    }
  }
  void clickEventLounge(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text("Lounges"),
        content: SizedBox(
            height: screenHeight*0.12,
            child: const Center(
              child: Text("Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!"),
            )
        ),
      );
    });
  }

  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
        surfaceTintColor: Colors.black,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: SizedBox(
          width: screenWidth*0.6,
          child: Text(
            currentAndLikedElementsProvider.currentClubMeClub.getClubName(),
            textAlign: TextAlign.center,
            style: customStyleClass.getFontStyleHeadline1Bold(),
          ),
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
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
    );
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
                color: currentAndLikedElementsProvider.currentClubMeClub.getBackgroundColorId() == 0 ? Colors.white : Colors.black,
                child: Center(
                    child: SizedBox(
                      height: screenHeight,
                      child:
                      Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getBannerId()}"
                            )
                        ),
                      )
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
                        color: Colors.black,
                        // decoration: const BoxDecoration(
                        //   gradient: LinearGradient(
                        //       begin: Alignment.topCenter,
                        //       end: Alignment.bottomCenter,
                        //       colors: [
                        //         Color(0xff11181f),
                        //         Color(0xff2b353d),
                        //       ],
                        //       stops: [0.15, 0.6]
                        //   ),
                        // ),

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
          ],
        )
      ],
    );
  }
  Widget _buildLogoIcon(){
    return currentAndLikedElementsProvider.currentClubMeClub.getStoryId().isNotEmpty?
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
              image:FileImage(
                  File(
                      "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getBannerId()}"
                  )
              ),
            ),
          ),
        ),
        SizedBox(
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
                  size: customStyleClass.getIconSize1(),
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
        border: Border.all(
            color: Colors.black
        ),
        image: DecorationImage(
          fit: BoxFit.cover,
          image:
          FileImage(
              File(
                  "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getBannerId()}"
              )
          ),
        ),
      ),
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
            style: customStyleClass.getFontStyle1Bold(),
          ),
        ),

        // News text
        Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            currentAndLikedElementsProvider.currentClubMeClub.getNews(),
            style: customStyleClass.getFontStyle4(),
          ),
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
            style: customStyleClass.getFontStyle1Bold(),
          ),
        ),

        // Spacer
        SizedBox(height: screenHeight*0.01,),

        noEventsAvailable?
        Container(
          height: screenHeight*0.1,
          child: Center(
            child: Text(
                "Derzeit keine Events geplant!",
              style: customStyleClass.getFontStyle3(),
            ),
          ),
        )
            :EventCard(
          clubMeEvent: eventsToDisplay[0],
          wentFromClubDetailToEventDetail: true,
          accessedEventDetailFrom: 2,
        ),

        // Spacer
        SizedBox(height: screenHeight*0.01,),

        noEventsAvailable?
        Container() : eventsToDisplay.length > 1?
        EventCard(
            clubMeEvent: eventsToDisplay[1],
            accessedEventDetailFrom: 2,
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
                  style: customStyleClass.getFontStyle4BoldPrimeColor(),
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
  Widget _buildContactSection(){

    String ContactZipToDisplay = "";
    String ContactCityToDisplay = "";

    currentAndLikedElementsProvider.currentClubMeClub.getContactZip().length > 6 ?
    ContactZipToDisplay = currentAndLikedElementsProvider.currentClubMeClub.getContactZip().substring(0, 6) :
    ContactZipToDisplay = currentAndLikedElementsProvider.currentClubMeClub.getContactZip();

    currentAndLikedElementsProvider.currentClubMeClub.getContactCity().length > 10 ?
    ContactCityToDisplay = currentAndLikedElementsProvider.currentClubMeClub.getContactCity().substring(0, 10) :
    ContactCityToDisplay = currentAndLikedElementsProvider.currentClubMeClub.getContactCity();

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
            style: customStyleClass.getFontStyle1Bold(),
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
                      currentAndLikedElementsProvider.currentClubMeClub.getContactName().length > 15 ?
                      currentAndLikedElementsProvider.currentClubMeClub.getContactName().substring(0,15):
                      currentAndLikedElementsProvider.currentClubMeClub.getContactName(),
                      textAlign: TextAlign.left,
                      style: customStyleClass.getFontStyle2Bold(),
                    ),
                  ),

                  Row(
                    children: [
                      Text(
                        currentAndLikedElementsProvider.currentClubMeClub.getContactStreet().length > 19 ?
                        currentAndLikedElementsProvider.currentClubMeClub.getContactStreet().substring(0,19):
                        currentAndLikedElementsProvider.currentClubMeClub.getContactStreet(),
                        textAlign: TextAlign.left,
                        style:customStyleClass.getFontStyle4(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:5),
                        child: Text(
                          currentAndLikedElementsProvider.currentClubMeClub.getContactStreetNumber().toString(),
                          textAlign: TextAlign.left,
                          style:customStyleClass.getFontStyle4(),
                        ),
                      )
                    ],
                  ),

                  SizedBox(
                    width: screenWidth*0.5,
                    child: Text(
                      "$ContactZipToDisplay $ContactCityToDisplay",
                      textAlign: TextAlign.left,
                      style: customStyleClass.getFontStyle4(),
                    ),
                  ),

                ],
              ),
            ),

            // Image
            Container(
              width: screenWidth*0.45,
              child: Column(
                children: [
                  Container(
                    width: screenWidth*0.2,
                    height: screenWidth*0.2,
                    child:
                    Image.asset(
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
                  style: customStyleClass.getFontStyle4BoldPrimeColor(),
                ),
              ),
              onTap: ()=> MapUtils.openMap(
                  currentAndLikedElementsProvider.currentClubMeClub.getGeoCoordLat(), currentAndLikedElementsProvider.currentClubMeClub.getGeoCoordLng()),
            )
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.1,
        )
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
            style: customStyleClass.getFontStyle1Bold(),
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
                currentAndLikedElementsProvider.currentClubMeClub.getMusicGenres(),
                style: customStyleClass.getFontStyle4(),
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
            style: customStyleClass.getFontStyle1Bold(),
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
                  onPressed: () => goToSocialMedia(currentAndLikedElementsProvider.currentClubMeClub.getInstagramLink()),
                  icon: Icon(
                      FontAwesomeIcons.instagram,
                      color: customStyleClass.primeColor
                  )
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.03
              ),
              child: IconButton(
                  onPressed: () => goToSocialMedia(
                      currentAndLikedElementsProvider.currentClubMeClub.getWebsiteLink()
                  ),
                  icon: Icon(
                    Icons.home_filled,
                    color: customStyleClass.primeColor,
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
            style: customStyleClass.getFontStyle1Bold(),
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
              if(alreadyFetchedFrontPageImages.isNotEmpty)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:
                    Image(
                      image: FileImage(
                          File(
                              "${stateProvider.appDocumentsDir.path}/${alreadyFetchedFrontPageImages[0]}"
                          )
                      ),
                      fit: BoxFit.cover,
                    )
                ),
              SizedBox(width: screenWidth*0.02,),
              if(alreadyFetchedFrontPageImages.length > 1)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:
                    Image(
                      image: FileImage(
                          File(
                              "${stateProvider.appDocumentsDir.path}/${alreadyFetchedFrontPageImages[1]}"
                          )
                      ),
                      fit: BoxFit.cover,
                    )
                ),
              SizedBox(width: screenWidth*0.02,),
              if(alreadyFetchedFrontPageImages.length > 2)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:
                    Image(
                      image: FileImage(
                          File(
                              "${stateProvider.appDocumentsDir.path}/${alreadyFetchedFrontPageImages[2]}"
                          )
                      ),
                      fit: BoxFit.cover,
                    )
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
              if(alreadyFetchedFrontPageImages.length > 3)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:
                    Image(
                      image: FileImage(
                          File(
                              "${stateProvider.appDocumentsDir.path}/${alreadyFetchedFrontPageImages[2]}"
                          )
                      ),
                      fit: BoxFit.cover,
                    )
                ),
              SizedBox(width: screenWidth*0.02,),
              if(alreadyFetchedFrontPageImages.length > 4)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:
                    Image(
                      image: FileImage(
                          File(
                              "${stateProvider.appDocumentsDir.path}/${alreadyFetchedFrontPageImages[2]}"
                          )
                      ),
                      fit: BoxFit.cover,
                    )
                ),
              SizedBox(width: screenWidth*0.02,),
              if(alreadyFetchedFrontPageImages.length > 5)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:
                    Image(
                      image: FileImage(
                          File(
                              "${stateProvider.appDocumentsDir.path}/${alreadyFetchedFrontPageImages[2]}"
                          )
                      ),
                      fit: BoxFit.cover,
                    )
                ),
            ],
          ),
        ),

        SizedBox(
          height: screenHeight*0.02,
        ),


        // Container(
        //     width: screenWidth*0.9,
        //     // color: Colors.red,
        //     alignment: Alignment.bottomRight,
        //     child: GestureDetector(
        //       child: Container(
        //         padding: EdgeInsets.symmetric(
        //             vertical: screenHeight*0.015,
        //             horizontal: screenWidth*0.03
        //         ),
        //         decoration: const BoxDecoration(
        //             color: Colors.black54,
        //             borderRadius: BorderRadius.all(Radius.circular(10))
        //         ),
        //         child: Text(
        //           mehrPhotosButtonString[0],
        //           textAlign: TextAlign.center,
        //           style: customStyleClass.getFontStyle4BoldPrimeColor(),
        //         ),
        //       ),
        //       onTap: ()=> clickOnDiscoverMorePhotos(screenHeight, screenWidth),
        //     )
        // ),

        SizedBox(
          height: screenHeight*0.02,
        ),
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
                    Icons.event_seat,
                    color: customStyleClass.primeColor,
                    size:
                      customStyleClass.getIconSize2()
                  ),
                  Text(
                      "Lounge",
                    style: customStyleClass.getFontStyle3(),
                  ),
                ],
              ),
              onTap: () => clickEventLounge()
            ),
            // Price list
            GestureDetector(
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    color: customStyleClass.primeColor,
                    size: customStyleClass.getIconSize2()
                  ),
                  Text(
                      "Angebote",
                    style: customStyleClass.getFontStyle3(),
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


  // MISC FUNCTS
  static Future<void> goToSocialMedia(String socialMediaLink) async{

    Uri googleUrl = Uri.parse(socialMediaLink);

    await canLaunchUrl(googleUrl)
        ? await launchUrl(googleUrl)
        : print("Error");
  }
  bool checkIfIsEventIsAfterToday(ClubMeEvent event){

    if(event.getEventDate().isBefore(stateProvider.getBerlinTime())){
      return false;
    }else{
      return true;
    }

  }
  void checkForUpcomingEventsAndSetList(){

    eventsToDisplay = fetchedContentProvider.getFetchedEvents()
        .where((event){
      return (event.getClubId() == currentAndLikedElementsProvider.currentClubMeClub.getClubId() && checkIfIsEventIsAfterToday(event));
    }).toList();

    if(eventsToDisplay.isEmpty){
      noEventsAvailable = true;
      }
  }
  void checkForFrontPageImages(CurrentAndLikedElementsProvider currentAndLikedElementsProvider, StateProvider stateProvider) async{
    if(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageImages().images != null){
      for(var element in currentAndLikedElementsProvider.currentClubMeClub.getFrontPageImages().images!){
        checkIfFrontPageImageIsFetched(element.id!, stateProvider);
      }
    }
  }
  void checkIfFrontPageImageIsFetched(String fileName, StateProvider stateProvider) async {
    final String dirPath = stateProvider.appDocumentsDir.path;
    final filePath = '$dirPath/$fileName';

    await File(filePath).exists().then((exists) async {
      if(!exists){

        await _supabaseService.getFrontPageImage(fileName).then((imageFile) async {
          await File(filePath).writeAsBytes(imageFile).then((onValue){
            setState(() {
              log.d("checkIfFrontPageImageIsFetched: Finished successfully. Path: $dirPath/$fileName");
              alreadyFetchedFrontPageImages.add(fileName);
            });
          });
        });
      }else{
        setState(() {
          alreadyFetchedFrontPageImages.add(fileName);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    // Set noEventsAvailable
    checkForUpcomingEventsAndSetList();


    return Scaffold(

      extendBody: true,
      extendBodyBehindAppBar: true,

      appBar: _buildAppBar(),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //       colors: [
        //         // Color(0xff11181f),
        //         Color(0xff2b353d),
        //         Color(0xff11181f)
        //       ],
        //       stops: [0.15, 0.6]
        //   ),
        // ),
        child: _buildMainView()
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

}