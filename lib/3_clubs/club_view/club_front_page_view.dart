import 'dart:io';

import 'package:club_me/mock_ups/class_mock_ups.dart';
import 'package:club_me/models/club.dart';
import 'package:club_me/models/opening_times.dart';
import 'package:club_me/models/parser/club_me_club_parser.dart';
import 'package:club_me/provider/current_and_liked_elements_provider.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_two_buttons_dialog.dart';
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
import '../../models/hive_models/7_days.dart';
import '../../models/parser/club_me_event_parser.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../shared/custom_text_style.dart';

import '../user_view/components/event_card.dart';
import 'package:collection/collection.dart';

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

  List<String> specialDayToDisplay = [];
  List<int> specialDayWeekdayToDisplay = [];
  List<int> specialDayOpeningTimeToDisplay = [];
  List<int> specialDayClosingTimeToDisplay = [];

  bool isLoading = false;
  bool showVideoIsActive = false;
  double moreButtonWidthFactor = 0.04;

  late Future getClub;
  late Future getEvents;
  late String zipAndCity;
  late VideoPlayerController _videoPlayerController;

  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;


  final SupabaseService _supabaseService = SupabaseService();
  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();

  bool showGalleryImageFullScreen = false;
  int galleryImageToShowIndex = 0;

  @override
  void initState() {
    super.initState();
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    getClub = _supabaseService.getSpecificClub(userDataProvider.getUserData().getClubId()).then(
            (fetchedClub) => processFetchedSpecificClub(fetchedClub[0]));

    checkIfSpecialOpeningTimesApply();

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

    _checkAndFetchService.checkAndFetchSpecificClubImages(fetchedClub, stateProvider, fetchedContentProvider);

    // if(fetchedClub.getFrontPageGalleryImages().images != null){
    //   for(var element in fetchedClub.getFrontPageGalleryImages().images!){
    //     checkIfAllImagesAreFetched();
    //     // checkIfFrontPageImageIsFetched(element.id!);
    //   }
    // }
  }

  void checkIfSpecialOpeningTimesApply(){

    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final fetchedContentProvider = Provider.of<FetchedContentProvider>(context, listen:  false);

    // Get all current events of the club we display
    List<ClubMeEvent> eventsOfCurrentClub = fetchedContentProvider.getFetchedEvents().where(
            (event) => event.getClubId() == userDataProvider.getUserClub().getClubId()
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

      var yesterdayOpeningTime = userDataProvider.getUserClub()
          .getOpeningTimes().days?.firstWhereOrNull(
              (days) => days.day == eventWeekDay-1);

      var todayOpeningTime = userDataProvider.getUserClub()
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
    specialDayOpeningTimeToDisplay.add(eventDate.hour);

    // If we have a closing hour, we know the exact hour to display
    if(closingDate != null){
      specialDayClosingTimeToDisplay.add(closingDate.hour);
    }
    // If not, we signal our algo that we don't know, aka 99
    else{
      specialDayClosingTimeToDisplay.add(99);
    }

    // Save the weekday to display the written weekday
    specialDayWeekdayToDisplay.add(eventDate.weekday);
  }


  // BUILD
  Widget _buildMainView(){
    return Stack(
      children: [

        Column(
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
                        color: Colors.transparent,
                        // color: customStyleClass.primeColor,
                      ),
                      // Text(
                      //   "Lounges",
                      //   style: customStyleClass.getFontStyle6(),
                      // ),
                    ],
                  ),
                  // onTap: () => clickEventLounge()
              ),

              // Offers
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
                onTap: () => clickEventOffersList(screenHeight, screenWidth),
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

    return Container(
      width: screenWidth*0.25,
      height: screenWidth*0.25,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          border: Border.all(
              color: userDataProvider.getUserClubStoryId().isNotEmpty? customStyleClass.primeColor: Colors.grey,
              width: 2
          ),
      ),
      child: fetchedContentProvider
          .getFetchedBannerImageIds()
          .contains(userDataProvider.getUserClub().getSmallLogoFileName()) ?
      ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Image(
            image: FileImage(
                File(
                    "${stateProvider.appDocumentsDir.path}/${userDataProvider.getUserClub().getSmallLogoFileName()}"
                )
            )
        ),
      ):
      Center(
          child: CircularProgressIndicator(color: customStyleClass.primeColor,)
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
                      onTap: () => clickEventAddEvent(screenHeight, screenWidth),
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
                    onTap: () => clickEventEditNews(
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
            textAlign: TextAlign.center,
            userDataProvider.getUserClubNews(),
            style: customStyleClass.getFontStyle4(),
          ),
        ),
      ],
    );
  }
  Widget _buildPhotosAndVideosSection(){

    // Not necessary. Makes it easier to read the code below
    List<String> frontPageGalleryImageIds = [];
    if(userDataProvider.getUserClub().getFrontPageGalleryImages().images != null){
      for(var image in userDataProvider.getUserClub().getFrontPageGalleryImages().images!){
        frontPageGalleryImageIds.add(image.id!);
      }
    }


    return Column(
      children: [

        // TEXT + ICON: Headline
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
                  "Fotos",
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
                    onTap: () =>  clickEventAddPhotoOrVideo(screenHeight, screenWidth),
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
        Container(
          width: screenWidth*0.95,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              // Is there even one image? Than show loading animation or content
              if(frontPageGalleryImageIds.isNotEmpty)
                SizedBox(
                  width: screenWidth*0.29,
                  height: screenWidth*0.29,
                  child: fetchedContentProvider.getFetchedBannerImageIds().contains(frontPageGalleryImageIds[0]) ?
                  InkWell(
                    child: Image(
                      image: FileImage(
                          File(
                              "${stateProvider.appDocumentsDir.path}/${frontPageGalleryImageIds[0]}"
                          )
                      ),
                      fit: BoxFit.cover,
                    ),
                    onTap: () => setState(() {
                      galleryImageToShowIndex = 0;
                      showGalleryImageFullScreen = true;
                    }),
                  )
                      : Center(child: CircularProgressIndicator(color: customStyleClass.primeColor),)
                ),

              if(frontPageGalleryImageIds.length > 1)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child: fetchedContentProvider.getFetchedBannerImageIds().contains(frontPageGalleryImageIds[1]) ?
                    InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${frontPageGalleryImageIds[1]}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 1;
                        showGalleryImageFullScreen = true;
                      }),
                    ):  Center(child: CircularProgressIndicator(color: customStyleClass.primeColor),)
                ),


              if(frontPageGalleryImageIds.length > 2)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child: fetchedContentProvider.getFetchedBannerImageIds().contains(frontPageGalleryImageIds[2]) ?
                    InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${frontPageGalleryImageIds[2]}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 2;
                        showGalleryImageFullScreen = true;
                      }),
                    ):  Center(child: CircularProgressIndicator(color: customStyleClass.primeColor),)
                ),
            ],
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // Second row images
        Container(
          width: screenWidth*0.95,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if(frontPageGalleryImageIds.length > 3)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child: fetchedContentProvider.getFetchedBannerImageIds().contains(frontPageGalleryImageIds[3]) ?
                    InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${frontPageGalleryImageIds[3]}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 3;
                        showGalleryImageFullScreen = true;
                      }),
                    ): Center(child: CircularProgressIndicator(color: customStyleClass.primeColor),)
                ),
              SizedBox(width: screenWidth*0.02,),
              if(frontPageGalleryImageIds.length > 4)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child: fetchedContentProvider.getFetchedBannerImageIds().contains(frontPageGalleryImageIds[4]) ?
                    InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${frontPageGalleryImageIds[4]}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 4;
                        showGalleryImageFullScreen = true;
                      }),
                    ):  Center(child: CircularProgressIndicator(color: customStyleClass.primeColor),)
                ),
              SizedBox(width: screenWidth*0.02,),
              if(frontPageGalleryImageIds.length > 5)
                SizedBox(
                    width: screenWidth*0.29,
                    height: screenWidth*0.29,
                    child: fetchedContentProvider.getFetchedBannerImageIds().contains(frontPageGalleryImageIds[5]) ?
                    InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${frontPageGalleryImageIds[5]}"
                            )
                        ),
                        fit: BoxFit.cover,
                      ),
                      onTap: () => setState(() {
                        galleryImageToShowIndex = 5;
                        showGalleryImageFullScreen = true;
                      }),
                    ):  Center(child: CircularProgressIndicator(color: customStyleClass.primeColor),)
                ),
            ],
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.02,
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
        Container(
          width: screenWidth*0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Social media
              Padding(
                padding: EdgeInsets.only(
                    // left: screenWidth*0.03
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
                    // left: screenWidth*0.03
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
        )
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
            Text(
              textAlign: TextAlign.center,
              userDataProvider.getUserClubMusicGenres(),
              style: customStyleClass.getFontStyle4(),
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
                    onTap: () =>  clickOnEditOpeningTimes(),
                  )
              )
            ],
          ),
        ),


        // Spacer
        SizedBox(
          height: screenHeight*0.02,
        ),

        // Opening Times
        if(userDataProvider.userClub.getOpeningTimes().days != null)
          for(var element in userDataProvider.userClub.getOpeningTimes().days!)
            formatOpeningTime(element),

        // Special Opening Times
        for(int i = 0; i<specialDayToDisplay.length;i++)
          formatSpecialOpeningTime(
              specialDayWeekdayToDisplay[i], specialDayToDisplay[i],
              specialDayOpeningTimeToDisplay[i], specialDayClosingTimeToDisplay[i]),

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
                    onTap: () =>  clickEventEditContact(screenHeight, screenWidth),
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
                        // userDataProvider.getUserClubContact()[0].length > 17 ?
                        // userDataProvider.getUserClubContact()[0].substring(0,17) :
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
                            // userDataProvider.getUserClubContact()[1].length > 19 ?
                            // userDataProvider.getUserClubContact()[1].substring(0,19):
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
                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.2,
                        height: screenWidth*0.2,
                        child: Image.asset(
                          'assets/images/google_maps_3.png',
                        ),
                      ),
                      onTap: ()=> MapUtils.openMap(
                          userDataProvider.getUserClubCoordLat(),
                            userDataProvider.getUserClubCoordLng()),
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


  // FILTER
  void checkIfFilteringIsNecessary(){
    if(upcomingEvents.isEmpty && pastEvents.isEmpty){
      filterEventsFromProvider(stateProvider);
    }
  }
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
  void clickEventAddEvent(double screenHeight, double screenWidth){

    context.go("/club_new_event");

    // showDialog(context: context, builder: (BuildContext context){
    //   return AlertDialog(
    //     backgroundColor: customStyleClass.backgroundColorMain,
    //     shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(20.0),
    //         // side: BorderSide(
    //         //     color: customStyleClass.primeColor
    //         // )
    //     ),
    //     title: Text(
    //         "Neues Event",
    //       style: customStyleClass.getFontStyle1Bold(),
    //     ),
    //     content: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //
    //         // Question text
    //         Text(
    //           "Möchtest du ein neues Event anlegen?",
    //           textAlign: TextAlign.left,
    //           style: customStyleClass.getFontStyle4(),
    //         ),
    //
    //         // Spacer
    //         SizedBox(
    //           height: screenHeight*0.03,
    //         ),
    //
    //         // "New event" button
    //         Container(
    //             width: screenWidth*0.9,
    //             alignment: Alignment.bottomRight,
    //             child: GestureDetector(
    //               child: Container(
    //                 padding: EdgeInsets.symmetric(
    //                     vertical: screenHeight*0.015,
    //                     horizontal: screenWidth*0.03
    //                 ),
    //                 decoration: BoxDecoration(
    //                     // color: Colors.black54,
    //                     // border: Border.all(
    //                     //   color: customStyleClass.primeColor
    //                     // ),
    //                     borderRadius: BorderRadius.all(Radius.circular(10))
    //                 ),
    //                 child: Text(
    //                   "Neues Event!",
    //                   textAlign: TextAlign.center,
    //                   style: customStyleClass.getFontStyle4BoldPrimeColor(),
    //                 ),
    //               ),
    //               onTap: () => context.go("/club_new_event"),
    //             )
    //         ),
    //
    //       ],
    //     ),
    //   );
    // });
  }
  void clickEventOffersList(double screenHeight, double screenWidth){
    context.push("/club_offers");
  }
  void clickEventEditNews(double screenHeight, double screenWidth, ){
    context.push('/club_update_news');
    // showDialog(context: context, builder: (BuildContext context){
    //   return AlertDialog(
    //       backgroundColor: Color(0xff121111),
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(20.0),
    //           // side: BorderSide(
    //           //     color: customStyleClass.primeColor
    //           // )
    //       ),
    //       title: Text(
    //           "News",
    //         style: customStyleClass.getFontStyle1Bold(),
    //       ),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //
    //           // Question text
    //           Text(
    //               "Willst du die News anpassen?",
    //             style: customStyleClass.getFontStyle4(),
    //           ),
    //
    //           // Spacer
    //           SizedBox(
    //             height: screenHeight*0.02,
    //           ),
    //
    //           // "News anpassen" button
    //           Container(
    //               width: screenWidth*0.9,
    //               // color: Colors.red,
    //               alignment: Alignment.bottomRight,
    //               child: GestureDetector(
    //                 child: Container(
    //                   padding: EdgeInsets.symmetric(
    //                       vertical: screenHeight*0.015,
    //                       horizontal: screenWidth*0.03
    //                   ),
    //                   decoration: BoxDecoration(
    //                       // color: Colors.black54,
    //                       // border: Border.all(
    //                       //   color: customStyleClass.primeColor
    //                       // ),
    //                       borderRadius: BorderRadius.all(Radius.circular(10))
    //                   ),
    //                   child: Text(
    //                     "News anpassen!",
    //                     textAlign: TextAlign.center,
    //                     style: customStyleClass.getFontStyle4BoldPrimeColor(),
    //                   ),
    //                 ),
    //                 onTap: () => context.go('/club_update_news'),
    //               )
    //           ),
    //         ],
    //       )
    //   );
    // });
  }
  void clickEventEditContact(double screenHeight, double screenWidth){
    context.push('/club_update_contact');
    // showDialog(context: context, builder: (BuildContext context){
    //   return AlertDialog(
    //       backgroundColor: Color(0xff121111),
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(20.0),
    //           // side: BorderSide(
    //           //     color: customStyleClass.primeColor
    //           // )
    //       ),
    //       title: Text(
    //           "Kontakt",
    //         style: customStyleClass.getFontStyle1Bold(),
    //       ),
    //       content:Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //
    //           // Question text
    //           Text(
    //               "Willst du deine Adresse anpassen?",
    //             style: customStyleClass.getFontStyle4(),
    //           ),
    //
    //           // Spacer
    //           SizedBox(
    //             height: screenHeight*0.02,
    //           ),
    //
    //           Container(
    //               width: screenWidth*0.9,
    //               alignment: Alignment.bottomRight,
    //               child: GestureDetector(
    //                 child: Container(
    //                   padding: EdgeInsets.symmetric(
    //                       vertical: screenHeight*0.015,
    //                       horizontal: screenWidth*0.03
    //                   ),
    //                   decoration: BoxDecoration(
    //                       // color: Colors.black54,
    //                       // border: Border.all(
    //                       //   color: customStyleClass.primeColor
    //                       // ),
    //                       borderRadius: BorderRadius.all(Radius.circular(10))
    //                   ),
    //                   child: Text(
    //                     "Adresse anpassen!",
    //                     textAlign: TextAlign.center,
    //                     style: customStyleClass.getFontStyle4BoldPrimeColor(),
    //                   ),
    //                 ),
    //                 onTap: () => context.go('/club_update_contact'),
    //               )
    //           ),
    //
    //         ],
    //       )
    //   );
    // });
  }
  void clickEventAddPhotoOrVideo(double screenHeight, double screenWidth){

    context.go('/club_update_photos_and_videos');

    // showDialog(context: context, builder: (BuildContext context){
    //   return AlertDialog(
    //       backgroundColor: Color(0xff121111),
    //       shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(20.0),
    //           // side: BorderSide(
    //           //     color: customStyleClass.primeColor
    //           // )
    //       ),
    //       title: Text(
    //           "Fotos",
    //         style: customStyleClass.getFontStyle1Bold(),
    //       ),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //
    //           // Question text
    //           Text(
    //               "Willst du deine Fotos anpassen?",
    //             style: customStyleClass.getFontStyle4(),
    //           ),
    //
    //           // Spacer
    //           SizedBox(
    //             height: screenHeight*0.02,
    //           ),
    //
    //           // "News anpassen" button
    //           Container(
    //               width: screenWidth*0.9,
    //               // color: Colors.red,
    //               alignment: Alignment.bottomRight,
    //               child: GestureDetector(
    //                 child: Container(
    //                   padding: EdgeInsets.symmetric(
    //                       vertical: screenHeight*0.015,
    //                       horizontal: screenWidth*0.03
    //                   ),
    //                   decoration: BoxDecoration(
    //                       // color: Colors.black54,
    //                       // border: Border.all(
    //                       //   color: customStyleClass.primeColor
    //                       // ),
    //                       borderRadius: BorderRadius.all(Radius.circular(10))
    //                   ),
    //                   child: Text(
    //                     "Fotos anpassen!",
    //                     textAlign: TextAlign.center,
    //                     style: customStyleClass.getFontStyle4BoldPrimeColor(),
    //                   ),
    //                 ),
    //                 onTap: () => context.go('/club_update_photos_and_videos'),
    //               )
    //           ),
    //         ],
    //       )
    //   );
    // });
  }
  void clickEventDiscoverMoreEvents(double screenHeight, double screenWidth){
    stateProvider.toggleWentFromCLubDetailToEventDetail();
    context.push("/club_upcoming_events");
  }
  void clickEventDiscoverMorePhotos(double screenHeight, double screenWidth){
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
  void clickEventStoryButton(
      BuildContext context,
      double screenHeight,
      double screenWidth,
      StateProvider stateProvider
      ){

    showDialog(context: context, builder: (BuildContext context){

      return userDataProvider.getUserClubStoryId().isNotEmpty ?
          TitleContentAndTwoButtonsDialog(
              titleToDisplay: "Live-Story",
              contentToDisplay: "Möchtest du deine Live-Story bearbeiten?",
              firstButtonToDisplay: TextButton(
                onPressed: (){
                  currentAndLikedElementsProvider.setCurrentClub(userDataProvider.getUserClub());
                  context.push("/show_story");
                },
                child: Text(
                  "Story ansehen",
                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                ),
              ),
              secondButtonToDisplay: TextButton(
                  onPressed: () =>  context.go("/video_recording"),
                  child: Text(
                    "Neue Story",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  )
              )
          ):
          TitleContentAndButtonDialog(
              titleToDisplay: "Live-Story",
              contentToDisplay: "Möchtest du deine Live-Story bearbeiten?",
              buttonToDisplay: TextButton(
                  onPressed: () =>  context.go("/video_recording"),
                  child: Text(
                    "Neue Story",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  )
              ));
    });
  }
  void clickEventLounge(){
    showDialog(context: context, builder: (BuildContext context){
      return TitleAndContentDialog(
          titleToDisplay: "Lounges",
          contentToDisplay: "Diese Funktion steht zurzeit noch nicht zur Verfügung! Wir bitten um Entschuldigung!"
      );
    });
  }
  void clickEventChangeBannerImage(){

    context.go('/club_change_banner_image');

    // showDialog(context: context, builder: (BuildContext context){
    //   return TitleContentAndButtonDialog(
    //       titleToDisplay: "Bannerbild",
    //       contentToDisplay: "Möchtest du das Bannerbild anpassen?",
    //       buttonToDisplay: TextButton(
    //           onPressed: () => context.go('/club_change_banner_image'),
    //           child: Text(
    //             "Banner anpassen",
    //             textAlign: TextAlign.center,
    //             style: customStyleClass.getFontStyle4BoldPrimeColor(),
    //           ))
    //   );
    //
    //     AlertDialog(
    //       backgroundColor: Color(0xff121111),
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(20.0),
    //         // side: BorderSide(
    //         //     color: customStyleClass.primeColor
    //         // )
    //       ),
    //       title: Text(
    //         "Bannerbild",
    //         style: customStyleClass.getFontStyle1Bold(),
    //       ),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //
    //           // Question text
    //           Text(
    //             "Möchtest du das Bannerbild anpassen?",
    //             style: customStyleClass.getFontStyle4(),
    //           ),
    //
    //           // Spacer
    //           SizedBox(
    //             height: screenHeight*0.02,
    //           ),
    //
    //           // "News anpassen" button
    //           Container(
    //               width: screenWidth*0.9,
    //               // color: Colors.red,
    //               alignment: Alignment.bottomRight,
    //               child: GestureDetector(
    //                 child: Container(
    //                   width: screenWidth*0.9,
    //                   padding: EdgeInsets.symmetric(
    //                       vertical: screenHeight*0.015,
    //                       horizontal: screenWidth*0.03
    //                   ),
    //                   decoration: const BoxDecoration(
    //                     // color: Colors.black54,
    //                     // border: Border.all(
    //                     //   color: customStyleClass.primeColor
    //                     // ),
    //                       borderRadius: BorderRadius.all(Radius.circular(10))
    //                   ),
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.end,
    //                     children: [
    //                       Text(
    //                         "Banner anpassen",
    //                         textAlign: TextAlign.center,
    //                         style: customStyleClass.getFontStyle4BoldPrimeColor(),
    //                       ),
    //                       Icon(
    //                         Icons.arrow_forward_outlined,
    //                         color: customStyleClass.primeColor,
    //                       )
    //                     ],
    //                   ),
    //                 ),
    //                 onTap: () => context.go('/club_change_banner_image'),
    //               )
    //           ),
    //         ],
    //       )
    //   );
  }
  void clickOnEditOpeningTimes(){
    context.go('/club_change_opening_times');
  //   showDialog(context: context, builder: (BuildContext context){
  //     return TitleContentAndButtonDialog(
  //         titleToDisplay: "Öffnungszeiten",
  //         contentToDisplay: "Möchtest du deine Öffnungszeiten anpassen?",
  //         buttonToDisplay: TextButton(
  //             onPressed: () => context.go('/club_change_opening_times'),
  //             child: Text(
  //               "Öffnunsgzeiten anpassen",
  //               textAlign: TextAlign.center,
  //               style: customStyleClass.getFontStyle4BoldPrimeColor(),
  //             ))
  //     );
  // });
  }


  // MISC
  static Future<void> goToSocialMedia(String socialMediaLink) async{

    print("Link: $socialMediaLink");

    Uri googleUrl = Uri.parse(socialMediaLink);

    await canLaunchUrl(googleUrl)
        ? await launchUrl(googleUrl)
        : print("Error");
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
                width: screenWidth*0.07,
                child: Center(
                  child: Text(
                    "-",
                    style: customStyleClass.getFontStyle3(),
                  ),
                ),
              ),

              Container(
                // color: Colors.green,
                  alignment: Alignment.centerRight,
                  width: screenWidth*0.12,
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
      int openingHourToDisplay, int closingHourToDisplay){

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
                  openingHourToDisplay < 10 ?
                  "0${openingHourToDisplay.toString()}:00" :
                  "${openingHourToDisplay.toString()}:00",
                  style: customStyleClass.getFontStyle3(),
                ),
              ),


              Container(
                // color: Colors.red,
                width: screenWidth*0.07,
                child: Center(
                  child: Text(
                    "-",
                    style: customStyleClass.getFontStyle3(),
                  ),
                ),
              ),

              Container(
                // color: Colors.green,
                  alignment: Alignment.centerRight,
                  width: screenWidth*0.12,
                  child: Text(
                    closingHourToDisplay != 99 ?
                    closingHourToDisplay < 10 ?
                    "0${closingHourToDisplay.toString()}:00" :
                    "${closingHourToDisplay.toString()}:00"
                        : "--.--",
                    style: customStyleClass.getFontStyle3(),
                  )
              ),

              // Text(
              //   openingHourToDisplay,
              //   style: customStyleClass.getFontStyle3(),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //       horizontal: 10
              //   ),
              //   child: Text(
              //     "-",
              //     style: customStyleClass.getFontStyle3(),
              //   ),
              // ),
              // Text(
              //   closingHourToDisplay,
              //   style: customStyleClass.getFontStyle3(),
              // )
            ],
          )
        ],
      ),
    );


  }

  void setFundamentalVariables(){
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);


    customStyleClass = CustomStyleClass(context: context);

    zipAndCity = "${userDataProvider.getUserClubContact()[3]} ${userDataProvider.getUserClubContact()[4]}";
  }


  @override
  Widget build(BuildContext context) {

    setFundamentalVariables();
    checkIfFilteringIsNecessary();

    return Scaffold(

      extendBody: true,
      resizeToAvoidBottomInset: true,

      appBar: _buildAppBar(),
      body: Container(
        color: customStyleClass.backgroundColorMain,
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              Column(
              children: [
                // Content
                Stack(
                  children: [

                    // IMAGE: FrontPageBannerImage
                    Container(
                        width: screenWidth,
                        height: screenHeight*0.19,
                        // alignment: Alignment.center,
                        color: Colors.black,
                        child:
                        fetchedContentProvider
                            .getFetchedBannerImageIds()
                            .contains(userDataProvider.getUserClub().getFrontpageBannerFileName()) ?
                        Stack(
                          children: [

                            Container(
                              width: screenWidth,
                              height: screenHeight*0.19,
                              child: Image(
                                image: FileImage(
                                    File(
                                      "${stateProvider.appDocumentsDir.path}/${userDataProvider.getUserClub().getFrontpageBannerFileName()}",
                                    )
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),

                            Container(
                              width: screenWidth*0.95,
                              padding: const EdgeInsets.only(
                                  top: 5,
                                  right: 5
                              ),
                              alignment: Alignment.topRight,
                              child: InkWell(
                                child: Icon(
                                  Icons.edit,
                                  color: customStyleClass.primeColor,
                                ),
                                onTap: () => clickEventChangeBannerImage(),
                              ),
                            )

                          ],
                        )

                            : Center(
                          child: CircularProgressIndicator(
                            color: customStyleClass.primeColor,
                          ),
                        )
                    ),

                    // SINGLECHILDSCROLLVIEW: Main view
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight*0.19,
                      ),
                      child: Container(
                        width: screenWidth,
                        height: screenHeight*0.6,
                        decoration: BoxDecoration(

                            color: customStyleClass.backgroundColorMain
                        ),
                        child: SingleChildScrollView(
                            child:
                            _buildMainView()
                          //fetchEventsFromDbAndBuildWidget(stateProvider, screenHeight, screenWidth),
                        ),
                      ),
                    ),

                    // CIRCULAR AVATAR: LOGO
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
                  color: Colors.black.withOpacity(0.7),
                  width: screenWidth,
                  height: screenHeight,
                  child: Center(
                    child: InkWell(
                      child: Image(
                        image: FileImage(
                            File(
                                "${stateProvider.appDocumentsDir.path}/${userDataProvider.getUserClub().getFrontPageGalleryImages().images![galleryImageToShowIndex].id}"
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
          ),
      ),
      bottomNavigationBar: CustomBottomNavigationBarClubs(),
    );
  }
}
