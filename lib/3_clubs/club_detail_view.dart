import 'dart:io';

import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/stories/show_story_chewie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import '../models/opening_times.dart';
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
    checkIfAllImagesAreFetched();
  }
  @override
  void dispose() {
    super.dispose();
  }


  // CLICKED


  void clickEventOfferList(double screenHeight, double screenWidth){

    if(currentAndLikedElementsProvider.currentClubMeClub.clubOffers.offers.isNotEmpty){
      context.push("/user_offers");
    }else{
      _showDialogWithTitleAndText(
          "Angebote",
          "Dieser Club hat derzeit noch keine Angebote im Sortiment!"
      );
    }


  }
  void clickEventDiscoverMoreEvents(double screenHeight, double screenWidth){
    stateProvider.toggleWentFromCLubDetailToEventDetail();
    context.push("/user_upcoming_events");
  }
  void clickEventStoryButton(BuildContext context, double screenHeight, double screenWidth, StateProvider stateProvider){

    if(currentAndLikedElementsProvider.getCurrentClubStoryId().isNotEmpty){

      context.push("/show_story");

      // Didn't use router because it was easier like this with the
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => ShowStoryChewie(
      //     ),
      //   ),
      // );
    }
  }
  void clickEventLounge(){
    _showDialogWithTitleAndText(
        "Lounges",
        "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!"
    );
  }


  // BUILD


  AppBar _buildAppBar(){
    return AppBar(
        surfaceTintColor: customStyleClass.backgroundColorMain,
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        title: Container(
          width: screenWidth*0.67,
          child: Stack(
            children: [

              // Headline
              Container(
                  alignment: Alignment.bottomCenter,
                  height: 50,
                  width: screenWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Text(
                                currentAndLikedElementsProvider.currentClubMeClub.getClubName(),
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyleHeadline1Bold(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 15
                                ),
                                child: Text(
                                  "VIP",
                                  style: customStyleClass.getFontStyleVIPGold(),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  )
              ),

            ],
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
                height: screenHeight*0.19,
                color: currentAndLikedElementsProvider.currentClubMeClub.getBackgroundColorId() == 0 ?
                      Colors.white :
                      Colors.black,
                child: Center(
                    child: SizedBox(
                      height: screenHeight,
                      width: screenWidth,
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getFrontpageBannerFileName()}",
                            ),
                        ),
                        fit:BoxFit.cover,
                      )
                    )
                )
            ),

            // main Content
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight*0.19,
              ),
              child: Container(
                width: screenWidth,
                height: screenHeight*0.6,
                color: customStyleClass.backgroundColorMain,
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      // Container for the bg gradient
                      Container(
                        color: customStyleClass.backgroundColorMain,

                        child: Column(
                          children: [

                            _buildMapAndPricelistIconSection(),

                            // White line
                            Divider(
                              height:10,
                              thickness: 1,
                              color: Colors.grey[900],
                              indent: 0,
                              endIndent: 0,
                            ),

                            _buildEventSection(),

                            // White line
                            Divider(
                              height:10,
                              thickness: 1,
                              color: Colors.grey[900],
                              indent: 0,
                              endIndent: 0,
                            ),

                            _buildNewsSection(),

                            // White line
                            Divider(
                              height:10,
                              thickness: 1,
                              color: Colors.grey[900],
                              indent: 0,
                              endIndent: 0,
                            ),

                            _buildPhotosAndVideosSection(),

                            // White line
                            Divider(
                              height:10,
                              thickness: 1,
                              color: Colors.grey[900],
                              indent: 0,
                              endIndent: 0,
                            ),

                            _buildSocialMediaSection(),

                            // White line
                            Divider(
                              height:10,
                              thickness: 1,
                              color: Colors.grey[900],
                              indent: 0,
                              endIndent: 0,
                            ),

                            _buildMusicGenresSection(),

                            // White line
                            Divider(
                              height:10,
                              thickness: 1,
                              color: Colors.grey[900],
                              indent: 0,
                              endIndent: 0,
                            ),

                            _buildOpeningHoursSection(),

                            // White line
                            Divider(
                              height:10,
                              thickness: 1,
                              color: Colors.grey[900],
                              indent: 0,
                              endIndent: 0,
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
                  top: screenHeight*0.135
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
                      onTap: () => clickEventStoryButton(context, screenHeight, screenWidth, stateProvider)
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

        // Logo image
        Container(
          width: screenWidth*0.25,
          height: screenWidth*0.25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: customStyleClass.primeColor,
              width: 2
            ),
            image: DecorationImage(
              fit: BoxFit.cover,
              // opacity: 0.5,
              image: FileImage(
                  File(
                      "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getSmallLogoFileName()}"
                  )
              ),
            ),
          ),
        ),

      ],
    ):
    Container(
      width: screenWidth*0.25,
      height: screenWidth*0.25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(
            color: Colors.grey,
          width: 2
        ),

        image: DecorationImage(
          fit: BoxFit.cover,
          image: FileImage(
              File(
                  "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getSmallLogoFileName()}"
              )
          ),
        ),
      ),
      // child: Image.asset(
      //     "assets/images/WONDERS_100x100px.png"
      // ),
    );
  }
  Widget _buildNewsSection(){
    return Column(
      children: [
        // News headline
        Container(
          width: screenWidth,
          // color: Colors.red,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              // left: screenWidth*0.05,
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
            textAlign: TextAlign.center,
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
          alignment: Alignment.center,
          // color: Colors.red,
          padding: EdgeInsets.only(
              // left: screenWidth*0.05,
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
          backgroundColorIndex: 1,
        ),

        // Spacer
        SizedBox(height: screenHeight*0.01,),

        noEventsAvailable?
        Container() : eventsToDisplay.length > 1?
        EventCard(
            clubMeEvent: eventsToDisplay[1],
            accessedEventDetailFrom: 2,
            wentFromClubDetailToEventDetail: true,
          backgroundColorIndex: 1,
        ):Container(),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // More events
        // Container(
        //     width: screenWidth*0.9,
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
        //           mehrEventsString[0],
        //           textAlign: TextAlign.center,
        //           style: customStyleClass.getFontStyle4BoldPrimeColor(),
        //         ),
        //       ),
        //       onTap: ()=> clickOnDiscoverMoreEvents(screenHeight, screenWidth),
        //     )
        // ),

        // Spacer
        SizedBox(height: screenHeight*0.02,),
      ],
    );
  }
  Widget _buildOpeningHoursSection(){
    return Column(
      children: [

        // headline
        Container(
          width: screenWidth,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              // left: screenWidth*0.05,
              top: screenHeight*0.01
          ),
          child: Text(
            "Öffnungszeiten",
            textAlign: TextAlign.left,
            style: customStyleClass.getFontStyle1Bold(),
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // Musikgenres
        for(var element in currentAndLikedElementsProvider.currentClubMeClub.getOpeningTimes().days!)
          formatOpeningTime(element),

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

    // currentAndLikedElementsProvider.currentClubMeClub.getContactZip().length > 6 ?
    // ContactZipToDisplay = currentAndLikedElementsProvider.currentClubMeClub.getContactZip().substring(0, 6) :
    ContactZipToDisplay = currentAndLikedElementsProvider.currentClubMeClub.getContactZip();

    // currentAndLikedElementsProvider.currentClubMeClub.getContactCity().length > 15 ?
    // ContactCityToDisplay = currentAndLikedElementsProvider.currentClubMeClub.getContactCity().substring(0, 15) :
    ContactCityToDisplay = currentAndLikedElementsProvider.currentClubMeClub.getContactCity();

    return Column(
      children: [
        // Kontakt headline
        Container(
          width: screenWidth,
          // color: Colors.red,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              // left: screenWidth*0.05,
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
        Container(
          width: screenWidth*0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Anschrift
              Container(
                child: Column(
                  children: [

                    // Contact name text
                    SizedBox(
                      width: screenWidth*0.6,
                      child: Text(
                        // currentAndLikedElementsProvider.currentClubMeClub.getContactName().length > 17 ?
                        // currentAndLikedElementsProvider.currentClubMeClub.getContactName().substring(0,17) :
                        currentAndLikedElementsProvider.currentClubMeClub.getContactName(),
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle4Bold(),
                      ),
                    ),

                    // Street
                    Container(
                      width: screenWidth*0.6,
                      // color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            // currentAndLikedElementsProvider.currentClubMeClub.getContactStreet().length > 30 ?
                            // currentAndLikedElementsProvider.currentClubMeClub.getContactStreet().substring(0,30):
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
                    ),

                    // City
                    SizedBox(
                      width: screenWidth*0.6,
                      child: Text(
                        "$ContactZipToDisplay $ContactCityToDisplay",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle4(),
                      ),
                    )
                  ],
                ),
              ),

              // Google maps icon
              Container(

                // width: screenWidth*0.35,
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
        //           findOnMapsButtonString[0],
        //           textAlign: TextAlign.center,
        //           style: customStyleClass.getFontStyle4BoldPrimeColor(),
        //         ),
        //       ),
        //       onTap: ()=> MapUtils.openMap(
        //           currentAndLikedElementsProvider.currentClubMeClub.getGeoCoordLat(), currentAndLikedElementsProvider.currentClubMeClub.getGeoCoordLng()),
        //     )
        // ),

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
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              // left: screenWidth*0.05,
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 10
              ),
              child: Text(
                textAlign: TextAlign.center,
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
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              // left: screenWidth*0.05,
              top: screenHeight*0.01
          ),
          child: Text(
            "Social Media",
            textAlign: TextAlign.left,
            style: customStyleClass.getFontStyle1Bold(),
          ),
        ),

        // Insta Icon
        Container(
          width: screenWidth*0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          alignment: Alignment.center,
          // color: Colors.red,
          padding: EdgeInsets.only(
              // left: screenWidth*0.05,
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
                              "${stateProvider.appDocumentsDir.path}/${alreadyFetchedFrontPageImages[3]}"
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
                              "${stateProvider.appDocumentsDir.path}/${alreadyFetchedFrontPageImages[4]}"
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
                              "${stateProvider.appDocumentsDir.path}/${alreadyFetchedFrontPageImages[5]}"
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
          height: screenHeight*0.015,
        ),

        // Icons next to logo
        Container(
          width: screenWidth*0.75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Lounges
              GestureDetector(
                  child: Column(
                    children: [
                      Icon(
                          Icons.event_seat_outlined,
                          color: customStyleClass.primeColor,
                      ),
                      Text(
                        "Lounges",
                        style: customStyleClass.getFontStyle6(),
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
                        Icons.file_open_outlined,
                        color: customStyleClass.primeColor,
                    ),
                    Text(
                      "Angebote",
                      style: customStyleClass.getFontStyle6(),
                    )
                  ],
                ),
                onTap: () => clickEventOfferList(screenHeight, screenWidth),
              ),
            ],
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.01,
        ),
      ],
    );
  }


  // MISC FUNCTS
  Container formatOpeningTime(Days days){

    String dayToDisplay = "";
    String openingHourToDisplay = "";
    String closingHourToDisplay = "";

    switch(days.day){
      case(1):dayToDisplay = "Montag";break;
      case(2):dayToDisplay = "Dienstag";break;
      case(3):dayToDisplay = "Mittwoch";break;
      case(4):dayToDisplay = "Donnerstag";break;
      case(5):dayToDisplay = "Freitag";break;
      case(6):dayToDisplay = "Samstag";break;
      case(7):dayToDisplay = "Sonntag";break;
    }

    openingHourToDisplay = days.openingHour! < 10 ? "0${days.openingHour}:00": "${days.openingHour}:00";
    closingHourToDisplay = days.closingHour! < 10 ?  "0${days.closingHour}:00": "${days.closingHour}:00";

    return Container(
      width: screenWidth*0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dayToDisplay,
            style: customStyleClass.getFontStyle3(),
          ),
          Row(
            children: [
              Text(
                openingHourToDisplay,
                style: customStyleClass.getFontStyle3(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10
                ),
                child: Text(
                  "-",
                  style: customStyleClass.getFontStyle3(),
                ),
              ),
              Text(
                closingHourToDisplay,
                style: customStyleClass.getFontStyle3(),
              )
            ],
          )
        ],
      ),
    );

  }
  void _showDialogWithTitleAndText(String titleToDisplay, String contentToDisplay){
    showDialog(context: context, builder: (BuildContext context){
      return TitleAndContentDialog(
          titleToDisplay: titleToDisplay,
          contentToDisplay: contentToDisplay
      );
    });
  }
  static Future<void> goToSocialMedia(String socialMediaLink) async{

    Uri googleUrl = Uri.parse(socialMediaLink);

    await canLaunchUrl(googleUrl)
        ? await launchUrl(googleUrl)
        : print("Error");
  }


  // CHECK


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
  void checkIfAllImagesAreFetched() async{

    final String dirPath = stateProvider.appDocumentsDir.path;

    List<String> imageFileNamesToCheckAndFetch = [];
    List<String> folderOfImage = [];


    imageFileNamesToCheckAndFetch.add(currentAndLikedElementsProvider.currentClubMeClub.getSmallLogoFileName());
    folderOfImage.add("small_banner_images");

    imageFileNamesToCheckAndFetch.add(currentAndLikedElementsProvider.currentClubMeClub.getBigLogoFileName());
    folderOfImage.add("big_banner_images");

    imageFileNamesToCheckAndFetch.add(currentAndLikedElementsProvider.currentClubMeClub.getFrontpageBannerFileName());
    folderOfImage.add("frontpage_banner_images");

    if(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images != null){
      for(var element in currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!){

        imageFileNamesToCheckAndFetch.add(element.id!);
        folderOfImage.add("frontpage_gallery_images");

        // checkIfFrontPageImageIsFetched(element.id!);
      }
    }

    for(var i = 0; i<imageFileNamesToCheckAndFetch.length;i++){

      final filePath = '$dirPath/${imageFileNamesToCheckAndFetch[i]}';

      File(filePath).exists().then((exists) async {
        if(!exists){
          await _supabaseService.getClubImagesByFolder(
              imageFileNamesToCheckAndFetch[i],
              folderOfImage[i])
              .then((imageFile) async {
            await File(filePath).writeAsBytes(imageFile).then((onValue){
              setState(() {
                log.d("ClubDetailView. Function: checkIfFrontPageImageIsFetched. Result: Finished successfully. Path: $dirPath/${imageFileNamesToCheckAndFetch[i]}");
                alreadyFetchedFrontPageImages.add(imageFileNamesToCheckAndFetch[i]);
              });
            });
          });
        }else{
          setState(() {
            alreadyFetchedFrontPageImages.add(imageFileNamesToCheckAndFetch[i]);
          });
        }
      });

    }

  }
  // void checkForFrontPageImages(
  //     CurrentAndLikedElementsProvider currentAndLikedElementsProvider,
  //     StateProvider stateProvider
  //     ) async {
  //   if(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images != null){
  //     for(var element in currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!){
  //       checkIfFrontPageImageIsFetched(element.id!);
  //     }
  //   }
  // }
  // void checkIfFrontPageImageIsFetched(String fileName) async {
  //   final String dirPath = stateProvider.appDocumentsDir.path;
  //   final filePath = '$dirPath/$fileName';
  //
  //   await File(filePath).exists().then((exists) async {
  //     if(!exists){
  //
  //       await _supabaseService.getFrontPageImage(fileName).then((imageFile) async {
  //         await File(filePath).writeAsBytes(imageFile).then((onValue){
  //           setState(() {
  //             log.d("checkIfFrontPageImageIsFetched: Finished successfully. Path: $dirPath/$fileName");
  //             alreadyFetchedFrontPageImages.add(fileName);
  //           });
  //         });
  //       });
  //     }else{
  //       setState(() {
  //         alreadyFetchedFrontPageImages.add(fileName);
  //       });
  //     }
  //   });
  // }


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
        color: customStyleClass.backgroundColorMain,
        child: _buildMainView()
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

}