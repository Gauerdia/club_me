import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:club_me/models/club.dart';
import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/provider/user_data_provider.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../provider/current_and_liked_elements_provider.dart';
import '../provider/state_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import '../shared/custom_text_style.dart';

import 'package:gal/gal.dart';

import '../shared/map_utils.dart';

class EventDetailView extends StatefulWidget {
  const EventDetailView({Key? key}) : super(key: key);

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView>{

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  var log = Logger();

  late Future getEventContent;

  String titleToDisplay = "Events";


  bool contentDownloadIsLoading = false;

  bool isUploading = false;
  bool isDateSelected = false;
  bool isContentShown = false;
  String priceFormatted = "";

  bool showVIP = false;

  double mainInfosContainerHeight = 110;

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  late UserDataProvider userDataProvider;

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;
  late String formattedEventTitle, formattedDjName, formattedEventGenres, formattedEventPrice, formattedWeekday;


  List<String> genresToDisplay = [];

  late File file;
  late Uint8List? videoThumbnail;
  bool isImage = false;
  bool isVideo = false;
  String fileExtension = "";

  ChewieController? _chewieController;
  late VideoPlayerController _controller;

  @override
  void initState(){

    super.initState();
    stateProvider = Provider.of<StateProvider>(context, listen:  false);
    if(stateProvider.openEventDetailContentDirectly){
      isContentShown = true;
      stateProvider.resetOpenEventDetailContentDirectly();
    }
    prepareContent();

    // Check if we access the event from the club view
    if(stateProvider.accessedEventDetailFrom == 5 ||
        stateProvider.accessedEventDetailFrom == 6 ||
        stateProvider.accessedEventDetailFrom == 7){
      showVIP = false;
    }
  }

  @override
  void dispose() {
    try{
      if(isImage || isVideo){
        _controller.dispose();
        _chewieController!.dispose();
        _chewieController!.setVolume(0.0);
      }
    }catch(e){
      print("Error in dispose: $e");
    }

    super.dispose();
  }

  // BUILD
  AppBar _buildAppBar(){

    if(isContentShown){
      return AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,);
    }else{
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        surfaceTintColor: customStyleClass.backgroundColorMain,
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Container(
              color: Colors.grey[900],
              height: 1.0,
            )
        ),
        title: SizedBox(
          width: screenWidth,
          height: 50,
          child: Stack(
            children: [

              // Show "back" button when no content displayed
              isContentShown ? Container()
                  :SizedBox(
                child: IconButton(
                  onPressed: () => clickEventBack(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    // size: 20,
                  ),
                ),
              ),

              // Show Title when no content displayed
              isContentShown ? Container()
                  :SizedBox(
                width: screenWidth,
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Text(
                                titleToDisplay,
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyleHeadline1Bold()
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
                ),
              ),

              // Show "close" button when content is shown
              isContentShown ?
              stateProvider.getUsingTheAppAsADeveloper() ?
              Container(
                alignment: Alignment.centerRight,
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    contentDownloadIsLoading ? CircularProgressIndicator(color: customStyleClass.primeColor,):
                    IconButton(
                      onPressed: () => clickEventDownloadContent(),
                      icon: Icon(
                        Icons.save,
                        color: customStyleClass.primeColor,
                        size: 30,
                      ),
                    ),

                    IconButton(
                      onPressed: () => clickEventContent(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ) :
              Container(
                alignment: Alignment.centerRight,
                width: screenWidth,
                child: IconButton(
                  onPressed: () => clickEventContent(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ):Container(),

            ],
          ),
        ),
      );
    }

      // title: Container(
      //   // color: Colors.green,
      //   // width: screenWidth,
      //   // height: 50,
      //   child: Container(
      //     width: screenWidth,
      //     color: Colors.red,
      //     height: 50,
      //   ),


        // Stack(
        //   children: [
        //
        //     // Show "close" button when content is shown
        //     stateProvider.getUsingTheAppAsADeveloper() ?
        //     Container(
        //       alignment: Alignment.centerRight,
        //       width: screenWidth,
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //
        //           contentDownloadIsLoading ?
        //           CircularProgressIndicator(color: customStyleClass.primeColor) :
        //           InkWell(
        //             child: Icon(
        //               Icons.save,
        //               color: customStyleClass.primeColor,
        //               size: 30,
        //             ),
        //             onTap: () =>clickEventDownloadContent(),
        //           ),
        //           // IconButton(
        //           //   onPressed: () => clickEventDownloadContent(),
        //             icon: Icon(
        //               Icons.save,
        //               color: customStyleClass.primeColor,
        //               size: 30,
        //             ),
        //           ),
        //
        //           InkWell(
        //             child: const Icon(
        //               Icons.close,
        //               color: Colors.white,
        //               size: 30,
        //             ),
        //             onTap: () => clickEventContent(),
        //           )
        //
        //           // IconButton(
        //           //   onPressed: () => clickEventContent(),
        //           //   icon: const Icon(
        //           //     Icons.close,
        //           //     color: Colors.white,
        //           //     size: 30,
        //           //   ),
        //           // ),
        //         ],
        //       ),
        //     ) :
        //     Container(
        //       color: Colors.red,
        //       // padding: EdgeInsets.only(
        //       //   top:30
        //       // ),
        //       // alignment: Alignment.centerRight,
        //       // width: screenWidth,
        //       child:
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           InkWell(
        //             child: const Icon(
        //               Icons.close,
        //               color: Colors.white,
        //               size: 30,
        //             ),
        //             onTap:  () => clickEventContent(),
        //           )
        //         ],
        //       )
        //
        //       // IconButton(
        //       //   onPressed: () => clickEventContent(),
        //       //   icon: const Icon(
        //       //     Icons.close,
        //       //     color: Colors.white,
        //       //     size: 30,
        //       //   ),
        //       // ),
        //     ),
        //
        //   ],
        // ),
    //   ),
    // ) :

  }
  Widget _buildMainColumn(){

    return Container(
      color: customStyleClass.backgroundColorMain,
      child: Stack(
        children: [

          // Main Column
          Column(
            children: [

              SizedBox(
                height: 100,
              ),

              // Spacer
              // SizedBox(
              //   height: screenHeight*0.125,
              // ),

              // Header (image)
              fetchedContentProvider
                  .getFetchedBannerImageIds()
                  .contains(currentAndLikedElementsProvider.currentClubMeEvent.getBannerImageFileName()) ?
              Container(
                color: Colors.black,
                  width: screenWidth,
                  height: screenHeight*0.165,
                  child: Image(
                    image: FileImage(
                        File(
                            "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeEvent.getBannerImageFileName()}"
                        )
                    ),
                    fit: BoxFit.cover,
                  )
              )  :
              SizedBox(
                width: screenWidth,
                height: screenHeight*0.165,
                child: Center(
                  child: CircularProgressIndicator(
                    color: customStyleClass.primeColor,
                  ),
                ),
              ),

              // Main Infos
              Container(
                  width: screenWidth,
                  color: customStyleClass.backgroundColorEventTile,
                  child: Column(
                    children: [

                      Container(
                        width: screenWidth*0.95,
                        padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Flexible(
                                child: Text(
                                  formattedEventTitle,
                                  textAlign: TextAlign.left,
                                  style: customStyleClass.getFontStyle3Bold(),
                                )
                            ),


                            SizedBox(
                                width: screenWidth*0.18,
                                child: Text(
                                    currentAndLikedElementsProvider.currentClubMeEvent.getEventPrice() != 0 ?
                                    priceFormatted : " ",
                                    textAlign: TextAlign.center,
                                    style: customStyleClass.getFontStyle3Bold()
                                )
                            )

                          ],
                        ),
                      ),

                      SizedBox(
                        width: screenWidth*0.95,
                        child: Text(
                            currentAndLikedElementsProvider.currentClubMeEvent.getClubName(),
                            style:customStyleClass.getFontStyle5()
                        ),
                      ),


                      SizedBox(
                        width: screenWidth*0.95,
                        child:Text(
                            formattedDjName,
                            textAlign: TextAlign.left,
                            style: customStyleClass.getFontStyle6Bold()
                        ),
                      ),

                      if(formattedDjName.isNotEmpty)
                        const SizedBox(
                          height: 20,
                        ),

                    // WEEKDAY, ICONS
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 4
                      ),
                      width: screenWidth*0.95,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Text(
                            formattedWeekday,
                           style: customStyleClass.getFontStyle5BoldPrimeColor(),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [

                              // Info
                              if(currentAndLikedElementsProvider.currentClubMeEvent.getTicketLink().isNotEmpty)
                                InkWell(
                                  child: Icon(
                                    CupertinoIcons.ticket,
                                    color: customStyleClass.primeColor,
                                  ),
                                  onTap: () => clickEventTicket(),
                                ),

                              SizedBox(
                              width: screenWidth*0.02,
                              ),

                              InkWell(
                                child: Icon(
                                  Icons.house,
                                  color: customStyleClass.primeColor,
                                ),
                                onTap: () => clickEventGoToClubDetailPage(
                                    context,
                                    currentAndLikedElementsProvider.currentClubMeEvent.getClubId()),
                              ),

                              // Like
                              InkWell(
                                child:Icon(
                                  currentAndLikedElementsProvider.checkIfCurrentEventIsAlreadyLiked() ? Icons.star_outlined : Icons.star_border,
                                  color: customStyleClass.primeColor,
                                ),
                                onTap: () => clickEventLike(currentAndLikedElementsProvider.currentClubMeEvent.getEventId()
                                ),
                              )

                            ],
                          ),
                        ],
                      )
                  ),
                    ],
                  ),
              ),

              // DESCRIPTION, GENRES
              Container(
                child:Column(
                  children: [
                    // Description
                    // Text Info
                    Container(
                      height: screenHeight*0.5,
                      color: customStyleClass.backgroundColorMain,
                      padding: const EdgeInsets.only(
                          top:15,
                          bottom: 15,
                          right:15,
                          left:9
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [

                            // Spacer
                            const SizedBox(
                              height: 20,
                            ),

                            // Description headline
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Beschreibung",
                                style: customStyleClass.getFontStyle1Bold(),
                              ),
                            ),

                            // Description content
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10
                              ),
                              child: Text(
                                currentAndLikedElementsProvider.currentClubMeEvent.getEventDescription(),
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyle4(),
                              ),
                            ),

                            // Spacer
                            const SizedBox(
                              height: 20,
                            ),

                            Divider(
                              color: Colors.grey[900],
                            ),

                            // Spacer
                            const SizedBox(
                              height: 20,
                            ),

                            // Headline genres
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Musikrichtungen",
                                style: customStyleClass.getFontStyle1Bold(),
                              ),
                            ),

                            // Spacer
                            const SizedBox(
                              height: 10,
                            ),

                            // Wrap: Genres
                            Container(
                              width: screenWidth*0.9,
                              alignment: Alignment.center,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  for(String genre in genresToDisplay)
                                    Text(
                                      genre,
                                      textAlign: TextAlign.center,
                                      style: customStyleClass.getFontStyle4(),
                                    )
                                ],
                              ),
                            ),

                            // Spacer
                            const SizedBox(
                              height: 10,
                            ),

                            const Divider(
                              color: Color(0xff121111),
                              indent: 0,
                              endIndent: 0,
                            ),

                            Divider(
                              color: Colors.grey[900],
                            ),

                            _buildContactSection()

                            // // Headline lounges
                            // Container(
                            //   alignment: Alignment.center,
                            //   padding: const EdgeInsets.only(
                            //       bottom: 20
                            //   ),
                            //   child: Text(
                            //     "Lounges",
                            //     style: customStyleClass.getFontStyle3Bold(),
                            //   ),
                            // ),
                            //
                            // // Lounges scrllview
                            // SingleChildScrollView(
                            //   scrollDirection: Axis.horizontal,
                            //   child: Row(
                            //     children: [
                            //       Stack(
                            //         children: [
                            //           SizedBox(
                            //             width: screenWidth*0.5,
                            //             height: screenHeight*0.17,
                            //             child: Image.asset("assets/images/lounge_blue.png"),
                            //           ),
                            //           SizedBox(
                            //             width: screenWidth*0.5,
                            //             height: screenHeight*0.15,
                            //             child: Center(
                            //               child: Text(
                            //                 "Bald verfügbar in der App!",
                            //                 style: customStyleClass.getFontStyle5BoldPrimeColor(),
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       SizedBox(
                            //         width: screenWidth*0.05,
                            //       ),
                            //       Stack(
                            //         children: [
                            //           SizedBox(
                            //             width: screenWidth*0.5,
                            //             height: screenHeight*0.17,
                            //             child: Image.asset("assets/images/lounge_grey2.png"),
                            //           ),
                            //           SizedBox(
                            //             width: screenWidth*0.5,
                            //             height: screenHeight*0.15,
                            //             child: Center(
                            //               child: Text(
                            //                 "Bald verfügbar in der App!",
                            //                 style: customStyleClass.getFontStyle5Bold(),
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       SizedBox(
                            //         width: screenWidth*0.05,
                            //       ),
                            //       Stack(
                            //         children: [
                            //           SizedBox(
                            //             width: screenWidth*0.5,
                            //             height: screenHeight*0.17,
                            //             child: Image.asset("assets/images/lounge_grey2.png"),
                            //           ),
                            //           SizedBox(
                            //             width: screenWidth*0.5,
                            //             height: screenHeight*0.15,
                            //             child: Center(
                            //               child: Text(
                            //                 "Bald verfügbar in der App!",
                            //                 style: customStyleClass.getFontStyle5Bold(),
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // )


                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),



            ]
          ),

          if(currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName().isNotEmpty)
            _buildContentIcon()
        ],
      ),
    );
  }
  Widget _buildContentView(){

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: (isImage || isVideo) ?

      // When image is to be displayed
      isImage ? Stack(
        alignment: Alignment.center,
        children: [

          // File
          SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Image.file(
                file,
              // fit: BoxFit.cover,
            ),
          ),

          Container(
              padding: const EdgeInsets.only(
                  top: 100,
                  right: 10
              ),
              width: screenWidth,
              height: screenHeight,
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  if(stateProvider.getUsingTheAppAsADeveloper())
                    contentDownloadIsLoading ?
                    CircularProgressIndicator(color: customStyleClass.primeColor) :
                    Container(
                      child: InkWell(
                        child:  Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          child:  const Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        onTap: () =>clickEventDownloadContent(),
                      ),
                    ),

                  const SizedBox(
                    width: 10,
                  ),

                  InkWell(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      child:  const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    onTap: () => clickEventContent(),
                  )
                ],
              )
          ),

        ],
      )

      // When video content
          : Stack(
        children: [

          // Video container
          Container(
            // color: Colors.green,
            width: screenWidth,
            child: _chewieController != null &&
                _chewieController!
                    .videoPlayerController.value.isInitialized
                ? SizedBox(
              width: screenWidth,
              child: Chewie(
                controller: _chewieController!,
              ),
            ) :
            SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Center(
                child: Column(
                  children: [

                    CircularProgressIndicator(
                      color: customStyleClass.primeColor,
                    ),
                    Text(
                      "Lädt...",
                      style: customStyleClass.getFontStyle3BoldPrimeColor(),
                    )

                  ],
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.only(
              top: 100,
              right: 10
            ),
            width: screenWidth,
            height: screenHeight,
            alignment: Alignment.topRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                if(stateProvider.getUsingTheAppAsADeveloper())
                  contentDownloadIsLoading ?
                  CircularProgressIndicator(color: customStyleClass.primeColor) :
                  Container(
                    child: InkWell(
                      child:  Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        child:  const Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      onTap: () =>clickEventDownloadContent(),
                    ),
                  ),

                const SizedBox(
                  width: 10,
                ),

                InkWell(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    child:  const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  onTap: () => clickEventContent(),
                )
              ],
            )
          ),

        ],
      ) :

      // Neither image nor video
      Center(
        child: Text(
          "Lädt...",
          style: customStyleClass.getFontStyle3BoldPrimeColor(),
        )

        // Column(
        //   children: [
        //     CircularProgressIndicator(
        //       color: customStyleClass.primeColor,
        //     ),
        //     Text(
        //       "Lädt...",
        //       style: customStyleClass.getFontStyle3BoldPrimeColor(),
        //     )
        //   ],
        // ),
      ),
    );
  }
  Widget _buildContentIcon(){

        if(isImage){

          return Container(
              padding: const EdgeInsets.only(
                  top: 120,
                right: 6
              ),
              // color: Colors.red,
              width: screenWidth,
              height: screenHeight*0.165+100,
              alignment: Alignment.topRight,

              child: InkWell(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45.0),
                  child: Image.file(
                    file,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () => clickEventContent(),
              ),
          );

        }
        if(isVideo){
          return GestureDetector(
            child: Container(
              padding: const EdgeInsets.only(
                top: 120,
                  right: 6
              ),
              width: screenWidth,
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white38,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(45.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45.0),
                  child: Image.memory(
                    videoThumbnail!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            onTap: () => clickEventContent(),
          );
        }

      return GestureDetector(
        child: Container(
          padding: const EdgeInsets.only(
              top: 125,
            right: 15
          ),
          width: screenWidth,
          height: screenHeight,
          alignment: Alignment.topRight,
          child: CircularProgressIndicator(
            color: customStyleClass.primeColor,
          )

        ),
        onTap: () => clickEventContent(),
      );
  }

  Widget _buildContactSection(){


    userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    late ClubMeClub currentClub;

    if(userDataProvider.getUserData().getProfileType() == 0){
      currentClub = fetchedContentProvider.getFetchedClubs().firstWhere(
              (club) => club.getClubId() == currentAndLikedElementsProvider.currentClubMeEvent.getClubId()
      );
    }else{
      currentClub = userDataProvider.getUserClub();
    }





    String ContactZipToDisplay = "";
    String ContactCityToDisplay = "";

    ContactZipToDisplay = currentClub.getContactZip();
    ContactCityToDisplay = currentClub.getContactCity();

    return Column(
      children: [

        // Kontakt headline
        Container(
          width: screenWidth,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
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
                        currentClub.getContactName(),
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle4Bold(),
                      ),
                    ),

                    // Street
                    Container(
                      width: screenWidth*0.6,
                      alignment: Alignment.centerLeft,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            currentClub.getContactStreet(),
                            textAlign: TextAlign.left,
                            style:customStyleClass.getFontStyle4(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:5),
                            child: Text(
                              currentClub.getContactStreetNumber().toString(),
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
                        currentClub.getGeoCoordLat(),
                        currentClub.getGeoCoordLng()),
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



  // CLICK HANDLING
  void clickEventTicket(){


    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: customStyleClass.getFontStyle4BoldPrimeColor(),
      ),
      onPressed: () async {
        final Uri url = Uri.parse(currentAndLikedElementsProvider.currentClubMeEvent.getTicketLink());
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      },
    );

    showDialog(
        context: context,
        builder: (BuildContext context){
          return  TitleContentAndButtonDialog(
              titleToDisplay: "Ticketbuchuchung",
              contentToDisplay: "Dieser Link führt zu einer externen Seite für den Ticket-Verkauf. "
                  "Möchten Sie fortfahren?",
              buttonToDisplay: okButton
          );
        }
    );

  }
  void clickEventShare(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            TitleAndContentDialog(
                titleToDisplay: "Event teilen",
                contentToDisplay: "Das Teilen von Inhalten aus der App ist derzeit noch nicht möglich. Wir bitten um Entschuldigung.")
    );
  }
  void clickEventLike(String eventId){
    if(stateProvider.getIsEventEditable()){
      showDialog<String>(
          context: context,
          builder: (BuildContext context) =>  TitleAndContentDialog(
              titleToDisplay: "Event liken",
              contentToDisplay: "Das Liken des Events ist in dieser Ansicht nicht"
                  "möglich. Wir bitten um Verständnis.")
      );
    }else{
      if(currentAndLikedElementsProvider.getLikedEvents().contains(eventId)){
        currentAndLikedElementsProvider.deleteLikedEvent(eventId);
        _hiveService.deleteFavoriteEvent(eventId);
      }else{
        currentAndLikedElementsProvider.addLikedEvent(eventId);
        _hiveService.insertFavoriteEvent(eventId);
      }
    }
  }
  void clickEventContent(){
    print("clickEventContent");
    setState(() {

      stateProvider.resetOpenEventDetailContentDirectly();

      if(isVideo && isContentShown){
        _controller.pause();
      }else if(isVideo){
        _controller.play();
      }
      isContentShown = !isContentShown;
      // if(isVideo){
      //   _controller.pause();
      // }
    });
  }
  void clickEventBack(){
    Navigator.pop(context);
    // stateProvider.leaveEventDetailPage(context);
  }
  void clickEventDownloadContent() async{
    if(isImage || isVideo){
      String applicationFilesPath = stateProvider.appDocumentsDir.path;
      String marketingFileName = currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName();
      var filePath = '$applicationFilesPath/$marketingFileName';
      setState(() {
        contentDownloadIsLoading = true;
      });
      await Gal.putImage(filePath);
      setState(() {
        contentDownloadIsLoading = false;
      });
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 100,
            color: Colors.white,
            child: const Center(
              child: Text("Bild erfolgreich auf deinem Gerät gespeichert."),
            ),
          );
        },
      );
    }else if(isVideo){
      String applicationFilesPath = stateProvider.appDocumentsDir.path;
      String marketingFileName = currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName();
      var filePath = '$applicationFilesPath/$marketingFileName';
      setState(() {
        contentDownloadIsLoading = true;
      });
      await Gal.putVideo(filePath);
      setState(() {
        contentDownloadIsLoading = false;
      });
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 100,
            color: Colors.white,
            child: const Center(
              child: Text("Video erfolgreich auf deinem Gerät gespeichert."),
            ),
          );
        },
      );
    }else{
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 100,
              color: Colors.white,
              child: const Center(
                child: Text("Der Inhalt ist noch nicht vollständig geladen, bitte hab einen Augenblick Geduld."),
          ),
          );
        },
      );
    }
  }

  void clickEventGoToClubDetailPage(BuildContext context, String clubId){

    currentAndLikedElementsProvider.setCurrentClub(
        fetchedContentProvider.getFetchedClubs().where(
                (club) => club.getClubId() == clubId
        ).first
    );
    // stateProvider.setPageIndex(1);
    // stateProvider.setAccessedEventDetailFrom(0);
    context.push('/club_details');


  }


  // ABSTRACT FUNCTIONS

  void editField(int index, String newValue, StateProvider stateProvider){
    FocusScope.of(context).unfocus();
    currentAndLikedElementsProvider.updateCurrentEvent(index, newValue);
    Navigator.pop(context);
  }


  // FORMAT AND CROP
  void formatPrice(){

    var priceDecimalPosition = currentAndLikedElementsProvider.currentClubMeEvent.getEventPrice().toString().indexOf(".");

    if(priceDecimalPosition + 2 == currentAndLikedElementsProvider.currentClubMeEvent.getEventPrice().toString().length){
      priceFormatted = "${currentAndLikedElementsProvider.currentClubMeEvent.getEventPrice().toString().replaceFirst(".", ",")}0 €";
    }else{
      priceFormatted = "${currentAndLikedElementsProvider.currentClubMeEvent.getEventPrice().toString().replaceFirst(".", ",")} €";
    }
  }
  void formatDjName(){
    String djNameToDisplay = "";

    if(currentAndLikedElementsProvider.currentClubMeEvent.getDjName().length > 42){
      djNameToDisplay = "${currentAndLikedElementsProvider.currentClubMeEvent.getDjName().substring(0, 40)}...";
    }else{
      djNameToDisplay = currentAndLikedElementsProvider.currentClubMeEvent.getDjName();
    }
    formattedDjName = djNameToDisplay;
  }
  void formatWeekday(){

    String weekDayToDisplay = "";

    var hourToDisplay = currentAndLikedElementsProvider.currentClubMeEvent.getEventDate().hour < 10
        ? "0${currentAndLikedElementsProvider.currentClubMeEvent.getEventDate().hour}"
        : "${currentAndLikedElementsProvider.currentClubMeEvent.getEventDate().hour}";

    var minuteToDisplay = currentAndLikedElementsProvider.currentClubMeEvent.getEventDate().minute < 10
    ? "0${currentAndLikedElementsProvider.currentClubMeEvent.getEventDate().minute}"
        : "${currentAndLikedElementsProvider.currentClubMeEvent.getEventDate().minute}";

    weekDayToDisplay = DateFormat('dd.MM.yyyy').format(currentAndLikedElementsProvider.currentClubMeEvent.getEventDate());

    var eventDateWeekday = currentAndLikedElementsProvider.currentClubMeEvent.getEventDate().weekday;
    switch(eventDateWeekday){
      case(1): weekDayToDisplay = "Montag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(2): weekDayToDisplay = "Dienstag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(3): weekDayToDisplay = "Mittwoch, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(4): weekDayToDisplay = "Donnerstag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(5): weekDayToDisplay = "Freitag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(6): weekDayToDisplay = "Samstag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
      case(7): weekDayToDisplay = "Sonntag, $weekDayToDisplay, $hourToDisplay:$minuteToDisplay Uhr";
    }

    formattedWeekday = weekDayToDisplay;
  }
  void formatEventTitle(){
    String titleToDisplay = "";

    if(currentAndLikedElementsProvider.currentClubMeEvent.getEventTitle().length > 42){
      titleToDisplay = "${currentAndLikedElementsProvider.currentClubMeEvent.getEventTitle().substring(0, 40)}...";
    }else{
      titleToDisplay = currentAndLikedElementsProvider.currentClubMeEvent.getEventTitle();
    }

    formattedEventTitle = titleToDisplay;
  }
  void formatEventGenres(){


    /// TODO: Checking is only for the transition phase. Erase later on.
    if(currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres.isNotEmpty ||
    currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().isNotEmpty){

      if(genresToDisplay.isEmpty){

        if(currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres.isNotEmpty){

          for(var i=0; i<currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres.length; i++){

            if(i == currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres.length-1){
              genresToDisplay.add("${currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres[i].displayGenre}");
            }else{
              genresToDisplay.add("${currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres[i].displayGenre},");
            }
          }


        }else{
          final splitNames = currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().split(',');

          for(int i=0; i<splitNames.length;i++){

            if(i==splitNames.length-1){
              genresToDisplay.add(splitNames[i]);
            }else{
              genresToDisplay.add("${splitNames[i]},");
            }
          }
        }
      }

    }else{
      formattedEventGenres = "Es wurden keine Musikrichtungen angegeben";
    }

  }


  // MISC
  _createChewieControllerWithoutAutoplay() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      looping: true,
      autoPlay: false,
      showOptions: false,
      autoInitialize: true,
      allowFullScreen: true,
    );
  }

  _createChewieControllerWithAutoplay() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      looping: true,
      autoPlay: true,
      showOptions: false,
      autoInitialize: true,
      allowFullScreen: true,
    );
  }

  Future<void> prepareContent() async{

    late String filePath;
    late Uint8List? marketingFile;

    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen:  false);

    try{

      // No need to fetch anything if there is nothing to fetch
      if(currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName().isNotEmpty){

        // Could be inlined but the right side is pretty long so I split it.
        String applicationFilesPath = stateProvider.appDocumentsDir.path;
        String marketingFileName = currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName();
        filePath = '$applicationFilesPath/$marketingFileName';

        var checkIfExists = await File(filePath).exists();

        if(checkIfExists){
          file = File(filePath);
        }else{
          // If a file exists, we fetch it
          marketingFile = await _supabaseService.getEventContent(
              currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName()
          );

          file = await File(filePath).writeAsBytes(marketingFile);
        }


        // We can derive the file type from the mime type
        String mimeStr = lookupMimeType(file.path)!;
        var fileType = mimeStr.split("/");

        if(fileType.contains('image')){
          setState(() {
            isImage = true;
          });
        }else if(fileType.contains('video')){

          // INIT VIDEO CONTROLLER
          _controller = VideoPlayerController.file(file);
          await _controller.initialize();

          if(isContentShown){
            _createChewieControllerWithAutoplay();
          }else{
            _createChewieControllerWithoutAutoplay();
          }

          // CREATE THUMBNAIL
          await VideoThumbnail.thumbnailData(
            video: file.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 128,
            quality: 25,
          ).then((response){
            videoThumbnail = response;
          });

          setState(() {
            isVideo = true;
          });
        }
      }
    }catch(e){
      print("EventDetailPage. Fct: prepareContent. Error: $e");
      _supabaseService.createErrorLog("EventDetailPage. Fct: prepareContent. Error: $e");
    }
  }



  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    formatPrice();
    formatDjName();
    formatWeekday();
    formatEventTitle();
    formatEventGenres();


    return Scaffold(

      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,


      appBar: _buildAppBar() ,
      body: isContentShown ? _buildContentView() : _buildMainColumn(),
      bottomNavigationBar: isContentShown ? Container() :
        stateProvider.clubUIActive ?
        CustomBottomNavigationBarClubs() :
        CustomBottomNavigationBar(),
    );
  }

}
