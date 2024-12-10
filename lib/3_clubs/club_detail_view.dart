import 'dart:io';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import '../models/hive_models/7_days.dart';
import 'user_view/components/event_card.dart';
import '../provider/current_and_liked_elements_provider.dart';
import '../provider/fetched_content_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:club_me/shared/map_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import '../provider/state_provider.dart';
import '../shared/custom_text_style.dart';
import '../models/event.dart';
import 'package:collection/collection.dart';

class ClubDetailView extends StatefulWidget {
  const ClubDetailView({Key? key}) : super(key: key);

  @override
  State<ClubDetailView> createState() => _ClubDetailViewState();
}

class _ClubDetailViewState extends State<ClubDetailView> {

  var log = Logger();

  bool noEventsAvailable = false;
  bool showVIP = false;

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();

  List<String> alreadyFetchedFrontPageImages = [];
  List<ClubMeEvent> eventsToDisplay = [];
  List<String> priceListString = ["Aktionen"];
  List<String> mehrEventsString = ["Mehr Events!", "More events!"];
  List<String> mehrPhotosButtonString = ["Mehr Fotos!", "More photos!"];
  List<String> findOnMapsButtonString = ["Finde uns auf Maps!", "Find us on maps!"];

  List<String> specialDayToDisplay = [];
  List<int> specialDayWeekdayToDisplay = [];
  List<int> specialDayOpeningHourToDisplay = [];
  List<int> specialDayOpeningMinuteToDisplay = [];
  List<int> specialDayClosingHourToDisplay = [];
  List<int> specialDayClosingMinuteToDisplay = [];

  int galleryImageToShowIndex = 0;
  bool showGalleryImageFullScreen = false;

  @override
  void initState() {
    super.initState();
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen: false);
    stateProvider = Provider.of<StateProvider>(context, listen: false);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen: false);

    checkIfSpecialOpeningTimesApply();

    _checkAndFetchService.checkAndFetchSpecificClubImages(
        currentAndLikedElementsProvider.currentClubMeClub,
        stateProvider,
        fetchedContentProvider);
  }
  @override
  void dispose() {
    super.dispose();
  }


  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
        surfaceTintColor: customStyleClass.backgroundColorMain,
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        title: Container(
          // width: screenWidth*0.67,
          child: Stack(
            children: [

              // Headline
              Container(
                // color: Colors.red,
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
                              if(showVIP)
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

              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                width: screenWidth,
                child: IconButton(
                    onPressed: (){

                      switch(stateProvider.pageIndex){
                        case(0):context.go("/user_events");break;
                        case(1):context.go("/user_clubs");break;
                        case(2):context.go("/user_map");break;
                        case(3):context.go("/user_coupons");break;
                        default:context.go("/user_clubs");break;
                      }


                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    )),
              )

            ],
          ),
        ),

    );
  }
  Widget _buildMainView(){

    // Stack for the image full screen view
    return Container(
        width: screenWidth,
        height: screenHeight,
        color: customStyleClass.backgroundColorMain,
        child: Stack(
          children: [

            // The main view
            Column(
              children: [

                // Spacer
                SizedBox(
                  height: screenHeight*0.12,
                ),

                // MAIN CONTENT
                Stack(
                  children: [

                    // BG Image
                    fetchedContentProvider.getFetchedBannerImageIds().contains(currentAndLikedElementsProvider.currentClubMeClub.getFrontpageBannerFileName()) ?
                    Container(
                        height: screenHeight*0.19,
                        color: Colors.black,
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
                    ) : Container(
                      height: screenHeight*0.19,
                      color: Colors.black,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: customStyleClass.primeColor,
                        ),
                      ),
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
            ),

            if(showGalleryImageFullScreen)
              Container(
                width: screenWidth,
                height: screenHeight,
                color:Colors.black.withOpacity(0.7),
                child: Center(
                  child: InkWell(
                    child: Image(
                      image: FileImage(
                          File(
                              "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![galleryImageToShowIndex].id}"
                          )
                      ),
                      // fit: BoxFit.cover,
                    ),
                    onTap: () => setState(() {
                      showGalleryImageFullScreen = false;
                    }),
                  ),
                ),
              )

          ],
        )
    );
  }
  Widget _buildLogoIcon(){

    return Container(
      width: screenWidth*0.25,
      height: screenWidth*0.25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(
            color: currentAndLikedElementsProvider.currentClubMeClub.getStoryId().isNotEmpty?  customStyleClass.primeColor: Colors.grey,
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

        // First event card
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

        // second event card
        noEventsAvailable?
        Container() : eventsToDisplay.length > 1?
        EventCard(
            clubMeEvent: eventsToDisplay[1],
            accessedEventDetailFrom: 2,
            wentFromClubDetailToEventDetail: true,
          backgroundColorIndex: 1,
        ):Container(),

        noEventsAvailable?
        Container() :
            Container(
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: Row(
                      children: [
                        Text(
                          "Mehr Events",
                          style: customStyleClass.getFontStyle3BoldPrimeColor(),
                        ),
                        Icon(
                          Icons.arrow_forward_outlined,
                          color: customStyleClass.primeColor,
                        )
                      ],
                    ),
                    onTap: () => context.push("/user_upcoming_events"),
                  )
                ],
              ),
            ),

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

        // opening times
        for(var element in currentAndLikedElementsProvider.currentClubMeClub.getOpeningTimes().days!)
          formatOpeningTime(element),

        for(int i = 0; i<specialDayToDisplay.length;i++)
          formatSpecialOpeningTime(
              specialDayWeekdayToDisplay[i], specialDayToDisplay[i],
              specialDayOpeningHourToDisplay[i], specialDayOpeningMinuteToDisplay[i],
              specialDayClosingHourToDisplay[i], specialDayClosingMinuteToDisplay[i]),

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

    ContactZipToDisplay = currentAndLikedElementsProvider.currentClubMeClub.getContactZip();
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
              Column(
                children: [

                  InkWell(
                    child: SizedBox(
                      width: screenWidth*0.2,
                      height: screenWidth*0.2,
                      child: Image.asset(
                        'assets/images/google_maps_3.png',
                      ),
                    ),
                    onTap: ()=> MapUtils.openMap(
                      currentAndLikedElementsProvider.currentClubMeClub.getGeoCoordLat(),
                        currentAndLikedElementsProvider.currentClubMeClub.getGeoCoordLng()),
                  ),
                ],
              )
            ],
          ),
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
          width: screenWidth*0.5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              if(currentAndLikedElementsProvider.currentClubMeClub.getInstagramLink().isNotEmpty)
                IconButton(
                    onPressed: () => goToSocialMedia(currentAndLikedElementsProvider.currentClubMeClub.getInstagramLink()),
                    icon: Icon(
                        FontAwesomeIcons.instagram,
                        color: customStyleClass.primeColor
                    )
                ),

              if(currentAndLikedElementsProvider.currentClubMeClub.getFacebookLink().isNotEmpty)
                IconButton(
                    onPressed: () => goToSocialMedia(currentAndLikedElementsProvider.currentClubMeClub.getFacebookLink()),
                    icon: Icon(
                        FontAwesomeIcons.facebook,
                        color: customStyleClass.primeColor
                    )
                ),

              if(currentAndLikedElementsProvider.currentClubMeClub.getWebsiteLink().isNotEmpty)
              IconButton(
                  onPressed: () => goToSocialMedia(
                      currentAndLikedElementsProvider.currentClubMeClub.getWebsiteLink()
                  ),
                  icon: Icon(
                    Icons.home_filled,
                    color: customStyleClass.primeColor,
                  )
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
            "Fotos",
            textAlign: TextAlign.left,
            style: customStyleClass.getFontStyle1Bold(),
          ),
        ),

        SizedBox(
          height: screenHeight*0.02,
        ),

        // First row images
        SizedBox(
          width: screenWidth*0.9,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              if(
              currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!.isNotEmpty &&
                  fetchedContentProvider.getFetchedBannerImageIds()
                      .contains(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![0].id)
              )
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child: InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![0].id}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 0;
                        showGalleryImageFullScreen = true;
                      }),
                    )
                ),


              if(
              currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!.length > 1 &&
                  fetchedContentProvider.getFetchedBannerImageIds()
                      .contains(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![1].id)
              )
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![1].id}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 1;
                        showGalleryImageFullScreen = true;
                      }),
                    )
                ),
              if(
              currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!.length > 2 &&
                  fetchedContentProvider.getFetchedBannerImageIds()
                      .contains(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![2].id)
              )
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![2].id}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 2;
                        showGalleryImageFullScreen = true;
                      }),
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
              if(
              currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!.length > 3 &&
                  fetchedContentProvider.getFetchedBannerImageIds()
                      .contains(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![3].id)
              )
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![3].id}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 3;
                        showGalleryImageFullScreen = true;
                      }),
                    )
                ),
              SizedBox(width: screenWidth*0.02,),
              if(
              currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!.length > 4 &&
                  fetchedContentProvider.getFetchedBannerImageIds()
                      .contains(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![4].id)
              )
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![4].id}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 4;
                        showGalleryImageFullScreen = true;
                      }),
                    )
                ),
              SizedBox(width: screenWidth*0.02,),
              if(
              currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!.length > 5 &&
                  fetchedContentProvider.getFetchedBannerImageIds()
                      .contains(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![5].id)
              )
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child:InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![5].id}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 5;
                        showGalleryImageFullScreen = true;
                      }),
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
                          color: Colors.transparent,
                          // color: customStyleClass.primeColor
                      ),
                      // Text(
                      //   "Lounges",
                      //   style: customStyleClass.getFontStyle6(),
                      // ),
                    ],
                  ),
                  // onTap: () => clickEventLounge()
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
                      "Aktionen",
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


  // CLICKED
  void clickEventOfferList(double screenHeight, double screenWidth){

    if(currentAndLikedElementsProvider.currentClubMeClub.clubOffers.offers.isNotEmpty){
      context.push("/user_offers");
    }else{
      _showDialogWithTitleAndText(
          "Aktionen",
          "Dieser Club verfügt derzeit über keine speziellen Aktionen in der App."
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
    }
  }
  void clickEventLounge(){
    _showDialogWithTitleAndText(
        "Lounges",
        "Die Buchung von Lounges ist derzeit noch nicht möglich, wird aber bald verfügbar sein. Wir bitten um Entschuldigung."
    );
  }


  // CHECK
  bool checkIfIsEventIsAfterToday(ClubMeEvent currentEvent){

    // Assumption: Every event until 4:59 started the day before.
    // Assumption: There are no official opening times for events between 5 and 12.
    // We'll just add 6 hours to it.

    Days? clubOpeningTimesForThisDay;
    DateTime closingHourToCompare;

    var eventWeekDay = currentEvent.getEventDate().hour <= 4 ?
    currentEvent.getEventDate().weekday -1 :
    currentEvent.getEventDate().weekday;

    // Get regular opening times
    try{
      // first where is enough because we assume that there is only one regular time each day.
      clubOpeningTimesForThisDay = currentAndLikedElementsProvider.currentClubMeClub.getOpeningTimes().days?.firstWhereOrNull(
              (days) => days.day == eventWeekDay);
    }catch(e){
      print("ClubEventsView. Error in checkIfUpcomingEvent, clubOpeningTimesForThisDay: $e");
      clubOpeningTimesForThisDay = null;
    }

    // Easies case: With closing data, we know exactly when to stop displaying.
    if(currentEvent.getClosingDate() != null){


      closingHourToCompare = DateTime(
        currentEvent.getClosingDate()!.year,
        currentEvent.getClosingDate()!.month,
        currentEvent.getClosingDate()!.day,
        currentEvent.getClosingDate()!.hour,
        currentEvent.getClosingDate()!.minute,
      );

      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;
    }

    // Second case: the event aligns with the opening hours
    if(clubOpeningTimesForThisDay != null){

      // If there is an event during the day and we look at the app during the day but
      // there is also a regular opening in the evening.
      if(currentEvent.getEventDate().hour < clubOpeningTimesForThisDay.openingHour!){

        // We don't have any guideline for this case. So 6 hours it is.
        closingHourToCompare = DateTime(
            currentEvent.getEventDate().year,
            currentEvent.getEventDate().month,
            currentEvent.getEventDate().day,
            currentEvent.getEventDate().hour+6,
            currentEvent.getEventDate().minute
        );

      }
      else{

        closingHourToCompare = DateTime(
            currentEvent.getEventDate().year,
            currentEvent.getEventDate().month,
            currentEvent.getEventDate().day+1,
            clubOpeningTimesForThisDay.closingHour!,
            clubOpeningTimesForThisDay.closingHalfAnHour == 1 ? 30 :
            clubOpeningTimesForThisDay.closingHalfAnHour == 2 ? 59 : 0
        );

      }

      if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
          closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
        return true;
      }
      return false;

    }

    // Third case: event is out of general opening times and no closing hour.
    // We don't have any guideline for this case. So 6 hours it is.
    closingHourToCompare = DateTime(
      currentEvent.getEventDate().year,
      currentEvent.getEventDate().month,
      currentEvent.getEventDate().day,
      currentEvent.getEventDate().hour+6,
      currentEvent.getEventDate().minute,
    );

    if(closingHourToCompare.isAfter(stateProvider.getBerlinTime()) ||
        closingHourToCompare.isAtSameMomentAs(stateProvider.getBerlinTime())){
      return true;
    }
    return false;

  }
  void checkIfSpecialOpeningTimesApply(){

    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    //final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    // Get all current events of the club we display
    List<ClubMeEvent> eventsOfCurrentClub = fetchedContentProvider.getFetchedEvents().where(
            (event) => event.getClubId() == currentAndLikedElementsProvider.currentClubMeClub.getClubId()
    ).toList();

    // Only use the ones that are in the future
    List<ClubMeEvent> eventsInTheFuture = eventsOfCurrentClub.where(
            (event){
          DateTime eventWithEstimatedLength = DateTime(
            event.getEventDate().year,
            event.getEventDate().month,
            event.getEventDate().day,
            event.getEventDate().hour+6,
            event.getEventDate().minute,
          );
          DateTime berlinTimeWithoutTZ = DateTime(
              stateProvider.getBerlinTime().year,
              stateProvider.getBerlinTime().month,
              stateProvider.getBerlinTime().day,
              stateProvider.getBerlinTime().hour,
              stateProvider.getBerlinTime().month
          );
          if(eventWithEstimatedLength.isAfter(berlinTimeWithoutTZ)){
            return true;
          }else{
            return false;
          }
        }
    ).toList();



    // Check if any is outside of regular opening hours
    for(var event in eventsInTheFuture){

      int eventWeekDay = event.getEventDate().weekday;

      var yesterdayOpeningTime = currentAndLikedElementsProvider.currentClubMeClub
          .getOpeningTimes().days?.firstWhereOrNull(
              (days) => days.day == eventWeekDay-1);

      var todayOpeningTime = currentAndLikedElementsProvider.currentClubMeClub
          .getOpeningTimes().days?.firstWhereOrNull(
              (days) => days.day == eventWeekDay);


      // First case: Only an event from yesterday might influence our decision
      if(yesterdayOpeningTime != null && todayOpeningTime == null){

        DateTime yesterdayClosing = DateTime(
            event.getEventDate().year,
            event.getEventDate().month,
            event.getEventDate().day,
            yesterdayOpeningTime.closingHour!,
            yesterdayOpeningTime.closingHalfAnHour == 2 ?
            59 : yesterdayOpeningTime.closingHalfAnHour == 1 ? 30:0
        );

        // If we are already past the closing time, than it is out of line
        if(event.getEventDate().isAfter(yesterdayClosing)){
          formatAndSaveSpecialDayToDisplay(event.getEventDate(), event.getClosingDate());
        }

      }
      // Second case: Both days are to consider
      else if(yesterdayOpeningTime != null && todayOpeningTime != null){

        DateTime yesterdayOpening = DateTime(
            event.getEventDate().year,
            event.getEventDate().month,
            event.getEventDate().day-1,
            yesterdayOpeningTime.openingHour!,
            yesterdayOpeningTime.openingHalfAnHour == 2 ?
            59 : yesterdayOpeningTime.openingHalfAnHour == 1 ? 30:0
        );

        DateTime todayOpening = DateTime(
            event.getEventDate().year,
            event.getEventDate().month,
            event.getEventDate().day,
            todayOpeningTime.openingHour!,
            todayOpeningTime.openingHalfAnHour == 2 ?
            59 : todayOpeningTime.openingHalfAnHour == 1 ? 30:0
        );

        if(event.getEventDate().isAfter(yesterdayOpening) && event.getEventDate().isBefore(todayOpening)){
          formatAndSaveSpecialDayToDisplay(event.getEventDate(), event.getClosingDate());
        }

      }
      // Third case: Nothing yesterday, but something today
      else if(yesterdayOpeningTime == null && todayOpeningTime != null){

        DateTime todayOpening = DateTime(
            event.getEventDate().year,
            event.getEventDate().month,
            event.getEventDate().day,
            todayOpeningTime.openingHour!,
            todayOpeningTime.openingHalfAnHour == 2 ?
            59 : todayOpeningTime.openingHalfAnHour == 1 ? 30:0
        );

        if(event.getEventDate().isBefore(todayOpening)){
          formatAndSaveSpecialDayToDisplay(event.getEventDate(), event.getClosingDate());
        }


      }
      // There are no opening times yesterday or today? Definitely a special opening time
      else if(yesterdayOpeningTime == null && todayOpeningTime == null){
        formatAndSaveSpecialDayToDisplay(
            event.getEventDate(),
            event.getClosingDate()
        );
      }

    }
  }
  void checkForUpcomingEventsAndSetList(){

    eventsToDisplay = fetchedContentProvider.getFetchedEvents()
        .where((event){
      return (
          event.getClubId() == currentAndLikedElementsProvider.currentClubMeClub.getClubId() &&
              checkIfIsEventIsAfterToday(event));
    }).toList();

    if(eventsToDisplay.isEmpty){
      noEventsAvailable = true;
    }
  }
  void checkForGalleryImages(){

    // Check if there is anything to consider and if yes, if we still need to do anything
    if(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!.isNotEmpty &&
        alreadyFetchedFrontPageImages.length != currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!.length){

      // Go through all gallery images that are supposed to be displayed
      for(int i = 0; i< currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images!.length; i++){

        // Does this image already exist in our provider?
        if(fetchedContentProvider.getFetchedBannerImageIds()
            .contains(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![i])){

          // If it already exists, let's see if the current view knows about it
          if(!alreadyFetchedFrontPageImages
              .contains(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![i])){

            // If not, tell him and update the view
            setState(() {
              alreadyFetchedFrontPageImages.add(currentAndLikedElementsProvider.currentClubMeClub.getFrontPageGalleryImages().images![i].id!);
            });
          }

        }
      }
    }
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

    if(days.openingHalfAnHour == 1){
      openingHourToDisplay = days.openingHour! < 10 ? "0${days.openingHour}:30": "${days.openingHour}:30";
    }else if(days.openingHalfAnHour == 2){
      openingHourToDisplay = days.openingHour! < 10 ? "0${days.openingHour}:59": "${days.openingHour}:59";
    }
    else{
      openingHourToDisplay = days.openingHour! < 10 ? "0${days.openingHour}:00": "${days.openingHour}:00";
    }

    if(days.closingHalfAnHour == 1){
      closingHourToDisplay = days.closingHour! < 10 ?  "0${days.closingHour}:30": "${days.closingHour}:30";
    }else if(days.closingHalfAnHour == 2){
      closingHourToDisplay = days.closingHour! < 10 ?  "0${days.closingHour}:59": "${days.closingHour}:59";
    }
    else{
      closingHourToDisplay = days.closingHour! < 10 ?  "0${days.closingHour}:00": "${days.closingHour}:00";
    }

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
              SizedBox(
                child: Text(
                  openingHourToDisplay,
                  style: customStyleClass.getFontStyle3(),
                ),
              ),
              Container(
                // color: Colors.red,
                // width: screenWidth*0.07,
                child: Center(
                  child: Text(
                    " - ",
                    style: customStyleClass.getFontStyle3(),
                  ),
                ),
              ),

              Container(
                // color: Colors.green,
                  alignment: Alignment.centerRight,
                  // width: screenWidth*0.12,
                  child: Text(
                    closingHourToDisplay,
                    style: customStyleClass.getFontStyle3(),
                  )
              ),

            ],
          )
        ],
      ),
    );

  }
  Container formatSpecialOpeningTime(
      int weekDay, String textToDisplay,
      int openingHourToDisplay, int openingMinuteToDisplay,
      int closingHourToDisplay, int closingMinuteToDisplay){

    String dayToDisplay = "";

    switch(weekDay){
      case(1):dayToDisplay = "Montag";break;
      case(2):dayToDisplay = "Dienstag";break;
      case(3):dayToDisplay = "Mittwoch";break;
      case(4):dayToDisplay = "Donnerstag";break;
      case(5):dayToDisplay = "Freitag";break;
      case(6):dayToDisplay = "Samstag";break;
      case(7):dayToDisplay = "Sonntag";break;
    }

    dayToDisplay = "$dayToDisplay, $textToDisplay";

    var openingHourString = openingHourToDisplay < 10 ? "0${openingHourToDisplay.toString()}" : openingHourToDisplay.toString();
    var openingMinuteString = openingMinuteToDisplay < 10  ? "0${openingMinuteToDisplay.toString()}" : openingMinuteToDisplay.toString();

    var closingHourString = "";
    var closingMinuteString = "";

    if(closingHourToDisplay != 99){
      closingHourString = closingHourToDisplay < 10 ? "0${closingHourToDisplay.toString()}" : closingHourToDisplay.toString();
      closingMinuteString = closingMinuteToDisplay < 10 ? "0${closingMinuteToDisplay.toString()}" : closingMinuteToDisplay.toString();
    }

    return Container(
      width: screenWidth*0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dayToDisplay,
            style: customStyleClass.getFontStyle3BoldPrimeColor(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              // Opening hour
              SizedBox(
                child: Text(
                  "$openingHourString:$openingMinuteString",
                  style: customStyleClass.getFontStyle3(),
                ),
              ),


              Container(
                child: Center(
                  child: Text(
                    " - ",
                    style: customStyleClass.getFontStyle3(),
                  ),
                ),
              ),

              Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    closingHourToDisplay != 99 ?
                    "$closingHourString:$closingMinuteString"
                        : "  --.--",
                    style: customStyleClass.getFontStyle3(),
                  )
              ),

            ],
          )
        ],
      ),
    );


  }void _showDialogWithTitleAndText(String titleToDisplay, String contentToDisplay){
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
  void formatAndSaveSpecialDayToDisplay(DateTime eventDate, DateTime? closingDate){

    // format the string to display
    String dayToAdd = eventDate.day < 10 ?
    "0${eventDate.day}": eventDate.day.toString();
    String monthToAdd = eventDate.month < 10 ?
    "0${eventDate.month}": eventDate.month.toString();

    // Add the date to display
    specialDayToDisplay.add(
        "$dayToAdd.$monthToAdd.${eventDate.year}"
    );

    // Save the opening hour
    specialDayOpeningHourToDisplay.add(eventDate.hour);
    specialDayOpeningMinuteToDisplay.add(eventDate.minute);

    // If we have a closing hour, we know the exact hour to display
    if(closingDate != null){
      specialDayClosingHourToDisplay.add(closingDate.hour);
      specialDayClosingMinuteToDisplay.add(closingDate.minute);
    }
    // If not, we signal our algo that we don't know, aka 99
    else{
      specialDayClosingHourToDisplay.add(99);
      specialDayClosingMinuteToDisplay.add(99);
    }

    // Save the weekday to display the written weekday
    specialDayWeekdayToDisplay.add(eventDate.weekday);
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
      body: _buildMainView(),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

}