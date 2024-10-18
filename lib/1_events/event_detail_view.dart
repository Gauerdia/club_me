import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../provider/current_and_liked_elements_provider.dart';
import '../provider/state_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import '../shared/custom_text_style.dart';

class EventDetailView extends StatefulWidget {
  const EventDetailView({Key? key}) : super(key: key);

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView>{

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  late Future getEventContent;

  String titleToDisplay = "Events";

  bool isUploading = false;
  bool isDateSelected = false;
  bool isContentShown = false;
  String priceFormatted = "";

  bool showVIP = true;

  double mainInfosContainerHeight = 110;

  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  late FetchedContentProvider fetchedContentProvider;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late String formattedEventTitle, formattedDjName, formattedEventGenres, formattedEventPrice, formattedWeekday;

  late File file;
  bool isImage = false;
  bool isVideo = false;
  String fileExtension = "";

  ChewieController? _chewieController;
  late VideoPlayerController _controller;

  @override
  void initState(){

    super.initState();
    stateProvider = Provider.of<StateProvider>(context, listen:  false);
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
  Widget _buildMainColumn(){

    return Container(
      color: customStyleClass.backgroundColorMain,
      child: Stack(
        children: [

          // Main Column
          Column(
            children: [

              // Spacer
              SizedBox(
                height: screenHeight*0.125,
              ),

              // Header (image)
              fetchedContentProvider.getFetchedBannerImageIds().contains(currentAndLikedElementsProvider.currentClubMeEvent.getBannerImageFileName()) ?
              SizedBox(
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
                  height: screenHeight*0.14,
                  color: customStyleClass.backgroundColorEventTile,
                  child: Stack(
                    children: [

                      Column(
                        children: [

                          // Title + Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              // Title
                              SizedBox(
                                width: screenWidth*0.7,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: screenWidth*0.02
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      formattedEventTitle,
                                      style: customStyleClass.getFontStyle3Bold(),
                                    ),
                                  ),
                                ),
                              ),

                              // Price
                              currentAndLikedElementsProvider.currentClubMeEvent.getEventPrice() != 0 ?SizedBox(
                                width: screenWidth*0.2,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: screenHeight*0.01
                                  ),
                                  child: Align(
                                    child: Text(
                                        priceFormatted,
                                        textAlign: TextAlign.center,
                                        style: customStyleClass.getFontStyle3Bold()
                                    ),
                                  ),
                                ),
                              ):SizedBox(
                                width: screenWidth*0.2,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: screenHeight*0.01
                                  ),
                                  child: Text(
                                      " ",
                                      textAlign: TextAlign.center,
                                      style: customStyleClass.getFontStyle3Bold()
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),

                      // Location
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth*0.02,
                            top: 26
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              currentAndLikedElementsProvider.currentClubMeEvent.getClubName(),
                              style:customStyleClass.getFontStyle5()
                          ),
                        ),
                      ),

                      // DJ
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth*0.02,
                            top: 46
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              formattedDjName,
                              textAlign: TextAlign.left,
                              style: customStyleClass.getFontStyle6Bold()
                          ),
                        ),
                      ),

                      // When
                      SizedBox(
                        height: screenHeight*0.14,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth*0.02,
                              bottom: screenHeight*0.01
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              formattedWeekday,
                              style: customStyleClass.getFontStyle5BoldPrimeColor(),
                            ),
                          ),
                        ),
                      ),

                      // Icons
                      Container(
                        height: screenHeight*0.14,
                        alignment: Alignment.bottomRight,
                        padding: EdgeInsets.only(
                            bottom: screenHeight*0.01,
                            right: screenWidth*0.02
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                // Info
                                if(currentAndLikedElementsProvider.currentClubMeEvent.getTicketLink().isNotEmpty)
                                  GestureDetector(
                                    child: Column(
                                      children: [
                                        Icon(
                                          CupertinoIcons.ticket,
                                          color: customStyleClass.primeColor,
                                        ),
                                      ],
                                    ),
                                    onTap: () => clickEventTicket(),
                                  ),
                                SizedBox(
                                  width: screenWidth*0.02,
                                ),

                                // Like
                                GestureDetector(
                                  child: Column(
                                    children: [
                                      Icon(
                                        currentAndLikedElementsProvider.checkIfCurrentEventIsAlreadyLiked() ? Icons.star_outlined : Icons.star_border,
                                        color: customStyleClass.primeColor,
                                      ),
                                    ],
                                  ),
                                  onTap: () => clickEventLike(currentAndLikedElementsProvider.currentClubMeEvent.getEventId()
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth*0.02,
                                ),

                                // Share
                                GestureDetector(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.share,
                                        color: customStyleClass.primeColor,
                                      ),
                                    ],
                                  ),
                                  onTap: () => clickEventShare(),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  )
              ),

              // Description
              SizedBox(
                  width: screenWidth,
                  child: Stack(
                    children: [

                      // Text Info
                      Container(
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

                              // Description headline
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "Beschreibung",
                                  style: customStyleClass.getFontStyle3Bold(),
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

                              // Headline genres
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "Musikrichtungen",
                                  style: customStyleClass.getFontStyle3Bold(),
                                ),
                              ),

                              // Genres
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10
                                ),
                                child: Text(
                                  formattedEventGenres,
                                  style: customStyleClass.getFontStyle4(),
                                ),
                              ),

                              const Divider(
                                color: Color(0xff121111),
                                indent: 0,
                                endIndent: 0,
                              ),

                              Divider(
                                color: Colors.grey[900],
                              ),

                              // Headline lounges
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(
                                    bottom: 20
                                ),
                                child: Text(
                                  "Lounges",
                                  style: customStyleClass.getFontStyle3Bold(),
                                ),
                              ),



                              // Lounges scrllview
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        SizedBox(
                                          width: screenWidth*0.5,
                                          height: screenHeight*0.17,
                                          child: Image.asset("assets/images/lounge_blue.png"),
                                        ),
                                        SizedBox(
                                          width: screenWidth*0.5,
                                          height: screenHeight*0.15,
                                          child: Center(
                                            child: Text(
                                              "Bald verfügbar in der App!",
                                              style: customStyleClass.getFontStyle5BoldPrimeColor(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: screenWidth*0.05,
                                    ),
                                    Stack(
                                      children: [
                                        SizedBox(
                                          width: screenWidth*0.5,
                                          height: screenHeight*0.17,
                                          child: Image.asset("assets/images/lounge_grey2.png"),
                                        ),
                                        SizedBox(
                                          width: screenWidth*0.5,
                                          height: screenHeight*0.15,
                                          child: Center(
                                            child: Text(
                                              "Bald verfügbar in der App!",
                                              style: customStyleClass.getFontStyle5Bold(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: screenWidth*0.05,
                                    ),
                                    Stack(
                                      children: [
                                        SizedBox(
                                          width: screenWidth*0.5,
                                          height: screenHeight*0.17,
                                          child: Image.asset("assets/images/lounge_grey2.png"),
                                        ),
                                        SizedBox(
                                          width: screenWidth*0.5,
                                          height: screenHeight*0.15,
                                          child: Center(
                                            child: Text(
                                              "Bald verfügbar in der App!",
                                              style: customStyleClass.getFontStyle5Bold(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )


                            ],
                          ),
                        ),
                      ),

                    ],
                  )
              ),

            ],
          ),

          // Switch Icon
          if(currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName().isNotEmpty)
            GestureDetector(
              child: Container(
                padding: EdgeInsets.only(
                  top: screenHeight*0.13,
                ),
                width: screenWidth,
                alignment: Alignment.topRight,
                child: ClipRRect(
                  child: Image.asset(
                    "assets/images/ClubMe_Logo_weiß.png",
                    width: 60,
                    height: 60,
                    // fit: BoxFit.cover,
                  ),
                ),
              ),
              onTap: () => clickEventContent(),
            )
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
            height: screenHeight*1.2,
            child: Image.file(file),
          ),

          // Icon
          // GestureDetector(
          //   child: Container(
          //     alignment: Alignment.bottomRight,
          //     child: ClipRRect(
          //       borderRadius: const BorderRadius.only(
          //           topRight: Radius.circular(15),
          //           topLeft: Radius.circular(15)
          //       ),
          //       child: Image.asset(
          //         "assets/images/ClubMe_Logo_weiß.png",
          //         width: 60,
          //         height: 60,
          //         // fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          //   onTap: () => clickEventContent(),
          // )

        ],
      )

      // When video content
          : Stack(
        children: [

          // Video container
          SizedBox(
            width: screenWidth,
            height: screenHeight*0.85,
            child: _chewieController != null &&
                _chewieController!
                    .videoPlayerController.value.isInitialized
                ? SizedBox(
              width: screenWidth,
              height: screenHeight*0.97,
              child: Chewie(
                controller: _chewieController!,
              ),
            ) :
            SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Center(
                child: CircularProgressIndicator(
                  color: customStyleClass.primeColor,
                ),
              ),
            ),
          ),

          // GestureDetector(
          //   child: Container(
          //     height: screenHeight*0.91,
          //     width: screenWidth*0.95,
          //     alignment: Alignment.bottomRight,
          //     child: ClipRRect(
          //       borderRadius: const BorderRadius.only(
          //           topRight: Radius.circular(15),
          //           topLeft: Radius.circular(15)
          //       ),
          //       child: Image.asset(
          //         "assets/images/club_me_icon_round.png",
          //         scale: 15,
          //         // fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          //   onTap: () => clickEventContent(),
          // )
        ],
      ) :
      Center(
        child: CircularProgressIndicator(
          color: customStyleClass.primeColor,
        ),
      ),
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
              contentToDisplay: "Dieser Link führt Sie weiter zu der Seite, wo Sie direkt ein Ticket kaufen können."
                  "Ist das in Ordnung für Sie?",
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
                contentToDisplay: "Die Funktion, ein Event zu teilen, ist derzeit noch "
                    "nicht implementiert. Wir bitten um Verständnis.")
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
    setState(() {
      isContentShown = !isContentShown;
      if(isVideo){
        _controller.pause();
      }
    });
  }
  void clickEventBack(){
    stateProvider.leaveEventDetailPage(context);
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
    String genresToDisplay = "";

    if(currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().isNotEmpty){
      if(
      currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().substring(currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().length-1) == ","){
        genresToDisplay = currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().substring(0, currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().length-1);
      }else{
        genresToDisplay = currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres();
      }
      formattedEventGenres = genresToDisplay;
    }else{
      formattedEventGenres = "Es wurden keine Musikrichtungen angegeben";
    }

  }


  // MISC
  _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      looping: true,
      autoPlay: false,
      showOptions: true,
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

        // If a file exists, we fetch it
        marketingFile = await _supabaseService.getEventContent(
            currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName()
        );

        // Could be inlined but the right side is pretty long so I split it.
        String applicationFilesPath = stateProvider.appDocumentsDir.path;
        String marketingFileName = currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName();

        filePath = '$applicationFilesPath/$marketingFileName';
        file = await File(filePath).writeAsBytes(marketingFile);

        // We can derive the file type from the mime type
        String mimeStr = lookupMimeType(file.path)!;
        var fileType = mimeStr.split("/");

        if(fileType.contains('image')){
          setState(() {
            isImage = true;
          });
        }else if(fileType.contains('video')){
          _controller = VideoPlayerController.file(file);
          await _controller.initialize();
          _createChewieController();
          setState(() {
            isVideo = true;
          });
        }
      }
    }catch(e){}
  }



  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);
    stateProvider = Provider.of<StateProvider>(context);
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
