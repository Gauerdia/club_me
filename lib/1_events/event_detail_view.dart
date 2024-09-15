import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
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

  double mainInfosContainerHeight = 150;

  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  late String formattedEventTitle, formattedDjName, formattedEventGenres, formattedEventPrice, formattedWeekday;

  late File file;
  bool isImage = false;
  bool isVideo = false;
  String fileExtension = "";

  String? VIDEO_ON;
  ChewieController? _chewieController;
  late VideoPlayerController _controller;

  @override
  void initState(){

    super.initState();
    stateProvider = Provider.of<StateProvider>(context, listen:  false);
    prepareContent();
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


  // CLICK HANDLING
  void clickOnInfo(){


    Widget okButton = TextButton(
      child: Text(
        "OK",
        style: customStyleClass.getFontStyle4(),
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
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              "Ticketbuchuchung",
              style: customStyleClass.getFontStyle1(),
            ),
            content: Text(
              "Dieser Link führt Sie weiter zu der Seite, wo Sie direkt ein Ticket kaufen können."
                  "Ist das in Ordnung für Sie?",
              style: customStyleClass.getFontStyle4(),
            ),
            actions: [
              okButton
            ],
          );
        }
    );

    // showDialog<String>(
    //     context: context,
    //     builder: (BuildContext context) => AlertDialog(
    //         title: Text("Event-Infos!"),
    //         content: Text(
    //             currentAndLikedElementsProvider.currentClubMeEvent.getEventDescription()
    //         )
    //     )
    // );
  }
  void clickedOnImIn(){
    print("clickedOnImIn");
  }
  void clickedOnShare(BuildContext context){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
            title: Text("Teilen noch nicht möglich!"),
            content: Text("Die Funktion, ein Event zu teilen, ist derzeit noch"
                "nicht implementiert. Wir bitten um Verständnis.")
        )
    );
  }
  void clickedOnLike(StateProvider stateProvider, String eventId){
    if(stateProvider.getIsEventEditable()){
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => const AlertDialog(
              title: Text("Liken des Events"),
              content: Text("Das Liken des Events ist in dieser Ansicht nicht"
                  "möglich. Wir bitten um Verständnis.")
          )
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
  void clickedOnContent(){
    setState(() {
      isContentShown = !isContentShown;
      if(isVideo){
        _controller.pause();
      }
    });
  }


  // ABSTRACT FUNCTIONS
  void leavePage(){
    stateProvider.leaveEventDetailPage(context);
  }
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
    if(currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().substring(currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().length-1) == ","){
      genresToDisplay = currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().substring(0, currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres().length-1);
    }else{
      genresToDisplay = currentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres();
    }
    formattedEventGenres = genresToDisplay;
  }


  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: SizedBox(
        width: screenWidth,
        height: 50,
        child: Stack(
          children: [

            // Show "back" button when no content displayed
            isContentShown ? Container()
                :SizedBox(
              child: IconButton(
                onPressed: () => leavePage(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
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
                  Text(
                    titleToDisplay,
                    textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle1()
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
                onPressed: () => clickedOnContent(),
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
  Widget _buildIconRow(StateProvider stateProvider, BuildContext context){
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                // Info
                if(currentAndLikedElementsProvider.currentClubMeEvent.getTicketLink().isNotEmpty)
                GestureDetector(
                    child:Column(
                      children: [
                        Icon(
                          CupertinoIcons.ticket,
                          color: customStyleClass.primeColor,
                        ),
                      ],
                    ),
                    onTap: () => clickOnInfo()
                ),

                SizedBox(
                  width: screenWidth*0.02,
                ),

                // Like
                GestureDetector(
                    child:Column(
                      children: [
                        Icon(
                          currentAndLikedElementsProvider.checkIfCurrentEventIsAlreadyLiked() ? Icons.star_outlined : Icons.star_border,
                          color: customStyleClass.primeColor,
                        ),
                      ],
                    ),
                    onTap: () => clickedOnLike(stateProvider, currentAndLikedElementsProvider.currentClubMeEvent.getEventId())
                ),

                SizedBox(
                  width: screenWidth*0.02,
                ),

                // Share
                GestureDetector(
                    child:Column(
                      children: [
                        Icon(
                          Icons.share,
                          color: customStyleClass.primeColor,
                        ),
                      ],
                    ),
                    onTap: () => clickedOnShare(context)
                ),

                SizedBox(
                  width: screenWidth*0.02,
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
  Widget _buildMainColumn(){

    return Column(
      children: [

        // Spacer
        SizedBox(
          height: screenHeight*0.14,
        ),

        // Header (image)
        SizedBox(
          width: screenWidth,
          height: screenHeight*0.2,
          child:
          Image(
            image: FileImage(
                File(
                    "${stateProvider.appDocumentsDir.path}/${currentAndLikedElementsProvider.currentClubMeEvent.getBannerId()}"
                )
            ),
            fit: BoxFit.cover,
          )
        ),

        // Main Infos
        Container(
            width: screenWidth,
            height: mainInfosContainerHeight,
            decoration: BoxDecoration(
                border: const Border(
                    bottom: BorderSide(color: Colors.white60)
                ),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[850]!, Colors.grey[700]!],
                    stops: const [0.4, 0.8]
                )
            ),
            child: Stack(
              children: [

                // Key information
                Column(
                  // mainAxisAlignment: MainAxisAlignment.,
                  children: [

                    // Title + price
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: screenWidth*0.75,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10,
                                left: 10
                            ),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  child: Text(
                                    formattedEventTitle,
                                    style: customStyleClass.getFontStyle1Bold(),
                                  ),
                                  onTap: (){
                                  },
                                )
                            ),
                          ),
                        ),

                        // Price
                        SizedBox(
                          width: screenWidth*0.25,
                          child:Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10,
                                  right: 15
                              ),
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    child:Text(
                                      priceFormatted,
                                      style: customStyleClass.getFontStyle2BoldLightGrey(),
                                    ),
                                    onTap: (){
                                    },
                                  )
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    // Location
                    SizedBox(
                      height: 30.w,//screenHeight*0.035,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            child: Text(
                              currentAndLikedElementsProvider.currentClubMeEvent.getClubName(),
                              style: customStyleClass.getFontStyle3Bold(),
                            ),
                            onTap: (){
                              // if(stateProvider.getIsEventEditable()){
                              //   showEditDialog(1, stateProvider, screenHeight, screenWidth);
                              // }
                            },
                          ),
                        ),
                      ),
                    ),

                    // DJ
                    Row(
                      children: [
                        Container(
                          width: screenWidth*0.7,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              // top: 3,
                                left: 10
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                child: Text(
                                    formattedDjName,
                                    style: customStyleClass.getFontStyle5BoldGrey()
                                ),
                                onTap: (){
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),

                // When
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth*0.02,
                      bottom: screenHeight*0.01
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: GestureDetector(
                      child: Text(
                        formattedWeekday,
                        style: customStyleClass.getFontStyle5Bold(),
                      ),
                      onTap: (){
                        // if(stateProvider.getIsEventEditable()){
                        //   showEditDialog(6, stateProvider, screenHeight, screenWidth);
                        // }
                      },
                    ),
                  ),
                ),

                // Icons
                SizedBox(
                    width: screenWidth,
                    height: screenHeight*0.21,
                    child: _buildIconRow(stateProvider, context)
                ),

              ],
            )
        ),

        // Description + event content icon
        Container(
            // height: screenHeight*0.4,
            width: screenWidth,
            child: Stack(
              children: [

                // Text Info
                Container(
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
                        GestureDetector(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Beschreibung",
                              style: customStyleClass.getFontStyle3Bold(),
                            ),
                          ),
                          onTap: (){
                          },
                        ),

                        // Description content
                        GestureDetector(
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight*0.02
                                ),
                                child: Text(
                                  currentAndLikedElementsProvider.currentClubMeEvent.getEventDescription(),
                                  style: customStyleClass.getFontStyle4(),
                                ),
                              )
                          ),
                          onTap: (){
                          },
                        ),

                        // Headline genres
                        GestureDetector(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Musikrichtungen",
                              style: customStyleClass.getFontStyle3Bold(),
                            ),
                          ),
                          onTap: (){
                          },
                        ),

                        // Genres
                        GestureDetector(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight*0.02
                              ),
                              child: Text(
                                formattedEventGenres,
                                style: customStyleClass.getFontStyle4(),
                              ),
                            ),
                          ),
                          onTap: (){
                          },
                        )

                      ],
                    ),
                  ),
                ),

                // Switch Icon
                currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName().isNotEmpty ?
                    GestureDetector(
                      child: Container(
                        // color: Colors.grey,
                        height: screenHeight*0.36, //
                        width: screenWidth,
                        alignment: Alignment.bottomRight,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15)
                          ),
                          child: Image.asset(
                            "assets/images/club_me_icon_round.png",
                            scale: 15,
                            // fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onTap: () => clickedOnContent(),
                    )
                    : Container(),

              ],
            )
        ),
      ],
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
    }catch(e){
      print("prepareContent:" + e.toString());
    }


  }

  // View when event content is displayed
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
          GestureDetector(
            child: Container(
              alignment: Alignment.bottomRight,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)
                ),
                child: Image.asset(
                  "assets/images/club_me_icon_round.png",
                  scale: 15,
                  // fit: BoxFit.cover,
                ),
              ),
            ),
            onTap: () => clickedOnContent(),
          )

        ],
      )

      // When video content
      : Stack(
        children: [

          // Video container
          Container(
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

          GestureDetector(
            child: Container(
              height: screenHeight*0.91,
              width: screenWidth*0.95,
              alignment: Alignment.bottomRight,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)
                ),
                child: Image.asset(
                  "assets/images/club_me_icon_round.png",
                  scale: 15,
                  // fit: BoxFit.cover,
                ),
              ),
            ),
            onTap: () => clickedOnContent(),
          )
        ],
      ) :
      Center(
        child: CircularProgressIndicator(
          color: customStyleClass.primeColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);
    stateProvider = Provider.of<StateProvider>(context);

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
      body: isContentShown? _buildContentView(): _buildMainColumn(),
      bottomNavigationBar: isContentShown ? Container() :
        stateProvider.clubUIActive ?
        CustomBottomNavigationBarClubs() :
        CustomBottomNavigationBar(),
    );
  }

}
