import 'dart:io';

import 'package:club_me/mock_ups/class_mock_ups.dart';
import 'package:club_me/models/club.dart';
import 'package:club_me/models/opening_times.dart';
import 'package:club_me/models/parser/club_me_club_parser.dart';
import 'package:club_me/shared/map_utils.dart';
import 'package:club_me/stories/show_story_chewie.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../models/event.dart';
import '../../models/parser/club_me_event_parser.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';

import '../user_view/components/event_card.dart';

class ClubFrontPageView extends StatefulWidget {
  const ClubFrontPageView({Key? key}) : super(key: key);

  @override
  State<ClubFrontPageView> createState() => _ClubFrontPageViewState();
}

class _ClubFrontPageViewState extends State<ClubFrontPageView> {

  String headLine = "Profil";

  var log = Logger();

  bool bannerImageFetched = false;

  List<ClubMeEvent> pastEvents = [];
  List<ClubMeEvent> upcomingEvents = [];
  List<String> priceListString = ["Angebote"];
  List<String> mehrEventsString = ["Mehr Events!", "Get more events"];
  List<String> mehrPhotosButtonString = ["Mehr Fotos!", "Explore more photos"];

  List<String> alreadyFetchedFrontPageImages = [];

  bool isLoading = false;
  bool showVideoIsActive = false;
  double moreButtonWidthFactor = 0.04;
  late UserDataProvider userDataProvider;
  late Future getClub;
  late Future getEvents;
  late String zipAndCity;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late FetchedContentProvider fetchedContentProvider;
  late VideoPlayerController _videoPlayerController;

  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    getClub = _supabaseService.getSpecificClub(userDataProvider.getUserData().getUserId()).then(
            (fetchedClub) => processFetchedSpecificClub(fetchedClub[0]));

    if(fetchedContentProvider.getFetchedEvents().isEmpty){
      getEvents = _supabaseService.getEventsOfSpecificClub(userDataProvider.getUserData().getUserId());
    }
  }
  @override
  void dispose() {
    super.dispose();
  }

  void processFetchedSpecificClub(var fetchedClubQueryResult){

    ClubMeClub fetchedClub = parseClubMeClub(fetchedClubQueryResult);

    userDataProvider.setUserClub(fetchedClub);

    if(fetchedClub.getFrontPageImages().images != null){
      for(var element in fetchedClub.getFrontPageImages().images!){
        checkIfFrontPageImageIsFetched(element.id!);
      }
    }
  }

  // BUILD
  Widget fetchEventsFromDbAndBuildWidget(
      StateProvider stateProvider,
      double screenHeight, double screenWidth
      ){

    // We check if when reaching the front page there have already been a fetching
    // of the information we want to display. If not, we have to take care of that.
    return
      fetchedContentProvider.getFetchedEvents().isEmpty ||
          userDataProvider.getUserClubId() == mockUpClub.getClubId() ?
    FutureBuilder(
        future: getEvents,
        builder: (context, snapshot){

          if(snapshot.hasError){
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

              return _buildMainView(stateProvider, screenHeight, screenWidth);
            }catch(e){
              _supabaseService.createErrorLog("club_frontpage, fetchEventsFromDbAndBuildWidget: " + e.toString());
              return Container();
            }

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

              // Spacer
              SizedBox(
                height: screenHeight*0.02,
              ),

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

              SizedBox(
                height: screenHeight*0.1,
              )


            ],
          ),
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
          color: customStyleClass.backgroundColorMain,
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
                onTap: () => clickOnPriceList(screenHeight, screenWidth),
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
  Widget _buildLogoIcon(){


    return userDataProvider.getUserClubStoryId().isNotEmpty?
    // If there is a story available, we want to emphasise that with a play button
    Stack(
      children: [

        // Are we finished with fetching the banner image?
        bannerImageFetched ?
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
              image: Image.file(
                  File("${stateProvider.appDocumentsDir.path}/${userDataProvider.getUserClubBannerId()}")
              ).image
            )
          ),
        ):

        // Show just the plain color while no image is available
        Container(
          width: screenWidth*0.25,
          height: screenWidth*0.25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
                color: Colors.black
            ),
          ),
        ),

        // Play icon when story is available
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
    // If no story is available we just show the logo
    bannerImageFetched ?
    Container(
      width: screenWidth*0.25,
      height: screenWidth*0.25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.grey[300]!
        ),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.file(
              File("${stateProvider.appDocumentsDir.path}/${userDataProvider.getUserClubBannerId()}")
          ).image,
        ),
      ),
    ): Container(
      width: screenWidth*0.25,
      height: screenWidth*0.25,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
  Widget _buildEventSection(){
    return Column(
      children: [

        // Events headline
        Container(
            width: screenWidth,
            padding: EdgeInsets.only(
                top: screenHeight*0.01
            ),
            child:  Stack(
              children: [

                // Headline
                Center(
                  child: Text(
                    "Events",
                    style: customStyleClass.getFontStyle1Bold(),
                  ),
                ),

                // New event icon
                Padding(
                    padding: EdgeInsets.only(
                        right: screenWidth*0.05
                    ),
                    child: GestureDetector(
                      child: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            // color: Colors.black,
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Icon(
                            Icons.add,
                            color: customStyleClass.primeColor,
                          )
                      ),
                      onTap: () => clickOnAddEvent(screenHeight, screenWidth),
                    )
                )

              ],

            ),
        ),

        // Spacer
        SizedBox(height: screenHeight*0.01,),

        // First Event
        upcomingEvents.isNotEmpty ?
        EventCard(
            clubMeEvent: upcomingEvents[0],
          accessedEventDetailFrom: 8,
          backgroundColorIndex: 1,
        )
            : Container(),

        // Spacer
        SizedBox(height: screenHeight*0.01,),

        // Second Event
        upcomingEvents.length > 1 ?
        EventCard(
            clubMeEvent: upcomingEvents[1],
          accessedEventDetailFrom: 8,
          backgroundColorIndex: 1,
        )
            : Container(),

        // Text, when no event available
        upcomingEvents.isEmpty ?
        Text(
          "Keine neuen Events.",
          style: customStyleClass.getFontStyle3(),
        )
            : Container(),

        // Spacer
        SizedBox(height: screenHeight*0.02,),

        // Button mehr events
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
        //       onTap: () => clickOnDiscoverMoreEvents(screenHeight, screenWidth),
        //     )
        // ),

        // Spacer
        SizedBox(height: screenHeight*0.02,),
      ],
    );
  }
  Widget _buildNewsSection(){
    return Column(
      children: [

        Container(
          width: screenWidth,
          padding: EdgeInsets.only(
              top: screenHeight*0.01
          ),
          child:  Stack(
            children: [

              // Headline
              Center(
                child: Text(
                  "News",
                  style: customStyleClass.getFontStyle1Bold(),
                ),
              ),

              // New event icon
              Padding(
                  padding: EdgeInsets.only(
                      right: screenWidth*0.05
                  ),
                  child: GestureDetector(
                    child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          // color: Colors.black,
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: customStyleClass.primeColor,
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
            userDataProvider.getUserClubNews(),
            style: customStyleClass.getFontStyle4(),
          ),
        ),
      ],
    );
  }
  Widget _buildPhotosAndVideosSection(){
    return Column(
      children: [

        Container(
          width: screenWidth,
          padding: EdgeInsets.only(
              top: screenHeight*0.01
          ),
          child:  Stack(
            children: [

              // Headline
              Center(
                child: Text(
                  "Fotos & Videos",
                  style: customStyleClass.getFontStyle1Bold(),
                ),
              ),

              // New event icon
              Padding(
                  padding: EdgeInsets.only(
                      right: screenWidth*0.05
                  ),
                  child: GestureDetector(
                    child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          // color: Colors.black,
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: customStyleClass.primeColor,
                        )
                    ),
                    onTap: () =>  clickOnAddPhotoOrVideo(screenHeight, screenWidth),
                  )
              )
            ],
          ),
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

        // Spacer
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

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // More button
        // Not yet needed

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
        //           mehrPhotosButtonString[0],
        //           textAlign: TextAlign.center,
        //           style: customStyleClass.getFontStyle4BoldPrimeColor(),
        //         ),
        //       ),
        //       onTap: () => clickOnDiscoverMorePhotos(screenHeight, screenWidth),
        //     )
        // ),

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


        Container(
          width: screenWidth,
          padding: EdgeInsets.only(
              top: screenHeight*0.01
          ),
          child:  Stack(
            children: [

              // Headline
              Center(
                child: Text(
                  "Social Media",
                  style: customStyleClass.getFontStyle1Bold(),
                ),
              ),

              // New event icon
              // Padding(
              //     padding: EdgeInsets.only(
              //         right: screenWidth*0.05
              //     ),
              //     child: GestureDetector(
              //       child: Container(
              //           alignment: Alignment.centerRight,
              //           padding: const EdgeInsets.all(7),
              //           decoration: BoxDecoration(
              //             // color: Colors.black,
              //             borderRadius: BorderRadius.circular(45),
              //           ),
              //           child: Icon(
              //             Icons.edit,
              //             color: customStyleClass.primeColor,
              //           )
              //       ),
              //       onTap: () =>  clickOnAddPhotoOrVideo(screenHeight, screenWidth),
              //     )
              // )
            ],
          ),
        ),

        // Insta Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Social media
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.03
              ),
              child: IconButton(
                  onPressed: () => goToSocialMedia(userDataProvider.getUserClubInstaLink()),
                  icon: Icon(
                    FontAwesomeIcons.instagram,
                    color: customStyleClass.primeColor,
                  )
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth*0.03
              ),
              child: IconButton(
                  onPressed: () => goToSocialMedia(
                      userDataProvider.getUserClubWebsiteLink()
                  ),
                  icon: Icon(
                    Icons.home_filled,
                    color: customStyleClass.primeColor,
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

        Container(
          width: screenWidth,
          padding: EdgeInsets.only(
              top: screenHeight*0.01
          ),
          child:  Stack(
            children: [

              // Headline
              Center(
                child: Text(
                  "Musikrichtungen",
                  style: customStyleClass.getFontStyle1Bold(),
                ),
              ),

              // New event icon
              // Padding(
              //     padding: EdgeInsets.only(
              //         right: screenWidth*0.05
              //     ),
              //     child: GestureDetector(
              //       child: Container(
              //           alignment: Alignment.centerRight,
              //           padding: const EdgeInsets.all(7),
              //           decoration: BoxDecoration(
              //             // color: Colors.black,
              //             borderRadius: BorderRadius.circular(45),
              //           ),
              //           child: Icon(
              //             Icons.add,
              //             color: customStyleClass.primeColor,
              //           )
              //       ),
              //       onTap: () => clickOnAddEvent(screenHeight, screenWidth),
              //     )
              // )

            ],

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
              padding: EdgeInsets.only(
                  left: screenWidth*0.05
              ),
              child: Text(
                userDataProvider.getUserClubMusicGenres(),
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
  Widget _buildOpeningHoursSection(){
    return Column(
      children: [


        Container(
          width: screenWidth,
          padding: EdgeInsets.only(
              top: screenHeight*0.01
          ),
          child:  Stack(
            children: [

              // Headline
              Center(
                child: Text(
                  "Öffnungszeiten",
                  style: customStyleClass.getFontStyle1Bold(),
                ),
              ),

              // New event icon
              // Padding(
              //     padding: EdgeInsets.only(
              //         right: screenWidth*0.05
              //     ),
              //     child: GestureDetector(
              //       child: Container(
              //           alignment: Alignment.centerRight,
              //           padding: const EdgeInsets.all(7),
              //           decoration: BoxDecoration(
              //             // color: Colors.black,
              //             borderRadius: BorderRadius.circular(45),
              //           ),
              //           child: Icon(
              //             Icons.edit,
              //             color: customStyleClass.primeColor,
              //           )
              //       ),
              //       onTap: () =>  clickOnEditContact(screenHeight, screenWidth),
              //     )
              // )
            ],
          ),
        ),


        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // Musikgenres
        for(var element in userDataProvider.userClub.getOpeningTimes().days!)
          formatOpeningTime(element),

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

        Container(
          width: screenWidth,
          padding: EdgeInsets.only(
              top: screenHeight*0.01
          ),
          child:  Stack(
            children: [

              // Headline
              Center(
                child: Text(
                  "Kontakt",
                  style: customStyleClass.getFontStyle1Bold(),
                ),
              ),

              // New event icon
              Padding(
                  padding: EdgeInsets.only(
                      right: screenWidth*0.05
                  ),
                  child: GestureDetector(
                    child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          // color: Colors.black,
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: customStyleClass.primeColor,
                        )
                    ),
                    onTap: () =>  clickOnEditContact(screenHeight, screenWidth),
                  )
              )
            ],
          ),
        ),


        // Spacer
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
                // color: Colors.red,
                // width: screenWidth*0.55,
                child: Column(
                  children: [

                    // Contact name text
                    SizedBox(
                      width: screenWidth*0.6,
                      child: Text(
                        userDataProvider.getUserClubContact()[0].length > 17 ?
                        userDataProvider.getUserClubContact()[0].substring(0,17) :
                        userDataProvider.getUserClubContact()[0],
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
                            userDataProvider.getUserClubContact()[1].length > 19 ?
                            userDataProvider.getUserClubContact()[1].substring(0,19):
                            userDataProvider.getUserClubContact()[1],
                            textAlign: TextAlign.left,
                            style:customStyleClass.getFontStyle4(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:5),
                            child: Text(
                              userDataProvider.getUserClubContact()[2],
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
                        zipAndCity.length > 25 ?
                        zipAndCity.substring(0,25):
                        zipAndCity,
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
        )

      ],
    );
  }
  AppBar _buildAppBar(){
    return AppBar(
        surfaceTintColor: customStyleClass.backgroundColorMain,
        backgroundColor:  customStyleClass.backgroundColorMain,
        title: SizedBox(
          width: screenWidth,
          child: Stack(
            children: [
              SizedBox(
                width: screenWidth,
                height: screenHeight*0.2,
                // padding: EdgeInsets.only(
                //     top: screenHeight*0.005
                // ),
                child: Center(
                  child: Text(headLine,
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyleHeadline1Bold()
                  ),
                ),
              ),
              Container(
                width: screenWidth,
                height: screenHeight*0.2,
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(
                      Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () => context.push("/club_settings"),
                ),
              )
            ],
          ),
        )
    );
  }

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

  // FILTER
  void filterEventsFromProvider(StateProvider stateProvider){
    for(var currentEvent in fetchedContentProvider.getFetchedEvents()){

      DateTime eventTimestamp = currentEvent.getEventDate();

      // Filter the events
      if(eventTimestamp.isAfter(stateProvider.getBerlinTime())){
        if(currentEvent.getClubId() == userDataProvider.getUserClubId()){
          upcomingEvents.add(currentEvent);
        }
      }else{
        if(currentEvent.getClubId() == userDataProvider.getUserClubId()){
          pastEvents.add(currentEvent);
        }
      }
    }
  }
  void filterEventsFromQuery(var data, StateProvider stateProvider){
    for(var element in data){
      ClubMeEvent currentEvent = parseClubMeEvent(element);

      DateTime eventTimestamp = currentEvent.getEventDate();

      // Filter the events
      if(eventTimestamp.isAfter(stateProvider.getBerlinTime())){
        if(currentEvent.getClubId() == userDataProvider.getUserClubId()){
          upcomingEvents.add(currentEvent);
        }
      }else{
        if(currentEvent.getClubId() == userDataProvider.getUserClubId()){
          pastEvents.add(currentEvent);
        }
      }

      // Add to provider so that we dont need to call them from the db again
      fetchedContentProvider.addEventToFetchedEvents(currentEvent);
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
        backgroundColor: Color(0xff121111),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            // side: BorderSide(
            //     color: customStyleClass.primeColor
            // )
        ),
        title: Text(
            "Neues Event",
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Question text
            Text(
              "Möchtest du ein neues Event anlegen?",
              textAlign: TextAlign.left,
              style: customStyleClass.getFontStyle4(),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // "New event" button
            Container(
                width: screenWidth*0.9,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight*0.015,
                        horizontal: screenWidth*0.03
                    ),
                    decoration: BoxDecoration(
                        // color: Colors.black54,
                        // border: Border.all(
                        //   color: customStyleClass.primeColor
                        // ),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Text(
                      "Neues Event!",
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle4BoldPrimeColor(),
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
    context.push("/club_offers");
  }
  void clickOnEditNews(double screenHeight, double screenWidth, ){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          backgroundColor: Color(0xff121111),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              // side: BorderSide(
              //     color: customStyleClass.primeColor
              // )
          ),
          title: Text(
              "News",
            style: customStyleClass.getFontStyle1Bold(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Question text
              Text(
                  "Willst du die News anpassen?",
                style: customStyleClass.getFontStyle4(),
              ),

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
                      decoration: BoxDecoration(
                          // color: Colors.black54,
                          // border: Border.all(
                          //   color: customStyleClass.primeColor
                          // ),
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Text(
                        "News anpassen!",
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle4BoldPrimeColor(),
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
          backgroundColor: Color(0xff121111),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              // side: BorderSide(
              //     color: customStyleClass.primeColor
              // )
          ),
          title: Text(
              "Kontakt",
            style: customStyleClass.getFontStyle1Bold(),
          ),
          content:Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Question text
              Text(
                  "Willst du deine Adresse anpassen?",
                style: customStyleClass.getFontStyle4(),
              ),

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
                      decoration: BoxDecoration(
                          // color: Colors.black54,
                          // border: Border.all(
                          //   color: customStyleClass.primeColor
                          // ),
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Text(
                        "Adresse anpassen!",
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle4BoldPrimeColor(),
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
          backgroundColor: Color(0xff121111),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              // side: BorderSide(
              //     color: customStyleClass.primeColor
              // )
          ),
          title: Text(
              "Fotos",
            style: customStyleClass.getFontStyle1Bold(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Question text
              Text(
                  "Willst du deine Fotos anpassen?",
                style: customStyleClass.getFontStyle4(),
              ),

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
                      decoration: BoxDecoration(
                          // color: Colors.black54,
                          // border: Border.all(
                          //   color: customStyleClass.primeColor
                          // ),
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Text(
                        "Fotos anpassen!",
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle4BoldPrimeColor(),
                      ),
                    ),
                    onTap: () => context.go('/club_update_photos_and_videos'),
                  )
              ),
            ],
          )
      );
    });
  }
  void clickOnDiscoverMoreEvents(double screenHeight, double screenWidth){
    stateProvider.toggleWentFromCLubDetailToEventDetail();
    context.push("/club_upcoming_events");
  }
  void clickOnDiscoverMorePhotos(double screenHeight, double screenWidth){
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
            "Ausführliche Fotoliste",
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content: Text(
          "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!",
          textAlign: TextAlign.left,
          style: customStyleClass.getFontStyle4(),
        ),
      );
    });
  }
  void clickOnStoryButton(
      BuildContext context,
      double screenHeight,
      double screenWidth,
      StateProvider stateProvider
      ){

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
            "Story",
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // Question text
            Text(
              "Möchtest du eine Story hochladen?",
              textAlign: TextAlign.left,
              style: customStyleClass.getFontStyle4(),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // "New Story" button
            Container(
                width: screenWidth*0.9,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight*0.015,
                        horizontal: screenWidth*0.03
                    ),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(
                          color: customStyleClass.primeColor
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Text(
                      "Neue Story!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: customStyleClass.primeColor,
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
            userDataProvider.getUserClubStoryId().isNotEmpty ?
            // Watch story
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
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(
                          color: customStyleClass.primeColor
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Text(
                      "Story anschauen!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: customStyleClass.primeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth*moreButtonWidthFactor
                      ),
                    ),
                  ),
                  onTap: () =>  {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShowStoryChewie(
                            storyUUID: userDataProvider.getUserClubStoryId(),
                            clubName:  userDataProvider.getUserClubName(),
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
  void clickEventLounge(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        backgroundColor: customStyleClass.backgroundColorMain,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          // side: BorderSide(
          //   color: customStyleClass.primeColor
          // )
        ),
        title: Text(
            "Lounges",
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content: Text(
          "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Verständnis!",
          textAlign: TextAlign.left,
          style: customStyleClass.getFontStyle4(),
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

  void setFundamentalVariables(){
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    customStyleClass = CustomStyleClass(context: context);

    zipAndCity = "${userDataProvider.getUserClubContact()[3]} ${userDataProvider.getUserClubContact()[4]}";
  }
  void checkIfFilteringIsNecessary(){
    if(upcomingEvents.isEmpty && pastEvents.isEmpty){
      filterEventsFromProvider(stateProvider);
    }
  }
  void checkIfBannerImageIsFetched() async{

    final String dirPath = stateProvider.appDocumentsDir.path;
    final fileName = userDataProvider.getUserClub().getBannerId();
    final filePath = '$dirPath/$fileName';

    await File(filePath).exists().then((exists) async {
      if(!exists){

        await _supabaseService.getBannerImage(fileName).then((imageFile) async {
          await File(filePath).writeAsBytes(imageFile).then((onValue){
            setState(() {
              log.d("fetchAndSaveBannerImage: Finished successfully. Path: $dirPath/$fileName");
              bannerImageFetched = true;
            });
          });
        });
      }else{
        setState(() {
          bannerImageFetched = true;
        });
      }
    });
  }
  void checkIfFrontPageImageIsFetched(String fileName) async {
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

    setFundamentalVariables();
    checkIfFilteringIsNecessary();
    checkIfBannerImageIsFetched();


    return Scaffold(

      extendBody: true,
      resizeToAvoidBottomInset: true,

      appBar: _buildAppBar(),
      body: Container(
        color: customStyleClass.backgroundColorMain,
          width: screenWidth,
          height: screenHeight,
          child: Column(
            children: [

              // Content
              Stack(
                children: [

                  // BG Image
                  bannerImageFetched ?
                  Container(
                      height: screenHeight*0.19,
                      color: userDataProvider.getUserClubBackgroundColorId() == 0 ?
                        Colors.white :
                        Colors.black,
                      child: Center(
                        child: SizedBox(
                          child: Image(
                              image: FileImage(
                                  File("${stateProvider.appDocumentsDir.path}/${userDataProvider.getUserClubBannerId()}")),
                              fit: BoxFit.cover,
                        ),
                      )
                      )
                  ): SizedBox(
                    height: screenHeight*0.25,
                    child:  Center(
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
                      decoration: BoxDecoration(
                          border: const Border(
                              top: BorderSide(color: Colors.grey)
                          ),
                        color: customStyleClass.backgroundColorMain
                      ),
                      child: SingleChildScrollView(
                        child: fetchEventsFromDbAndBuildWidget(stateProvider, screenHeight, screenWidth),
                      ),
                    ),
                  ),

                  // Centered logo
                  Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight*0.135
                    ),
                    child: Align(
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
          ),
      ),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }



}
