import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../provider/state_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../shared/custom_bottom_navigation_bar.dart';
import 'package:intl/intl.dart';

import '../shared/custom_text_style.dart';

import 'package:timezone/standalone.dart' as tz;

class EventDetailView extends StatefulWidget {
  const EventDetailView({Key? key}) : super(key: key);

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView>{

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  late Future getEventContent;

  bool isUploading = false;
  bool isDateSelected = false;
  bool isContentShown = false;
  String priceFormatted = "";

  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
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
    // getEventContent = _supabaseService.getEventContent(stateProvider.clubMeEvent.getEventMarketingFileName());
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController!.dispose();
    _chewieController!.setVolume(0.0);

    super.dispose();
  }

  _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      looping: true,
      autoPlay: true,
      showOptions: true,
      autoInitialize: true,
      allowFullScreen: true,
    );
  }


  // CLICK HANDLING
  void clickOnInfo(){
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: Text("Event-Infos!"),
            content: Text(
                stateProvider.clubMeEvent.getEventDescription()
            )
        )
    );
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
      if(stateProvider.getLikedEvents().contains(eventId)){
        stateProvider.deleteLikedEvent(eventId);
        _hiveService.deleteFavoriteEvent(eventId);
      }else{
        stateProvider.addLikedEvent(eventId);
        _hiveService.insertFavoriteEvent(eventId);
      }
    }
  }
  void clickedOnContent(){
    setState(() {
      isContentShown = !isContentShown;
    });
  }


  // ABSTRACT FUNCTIONS
  void leavePage(StateProvider stateProvider){

    // Reset all parameters
    stateProvider.deactivateIsCurrentlyOnlyUpdatingAnEvent();
    stateProvider.deactivateEventEditable();
    stateProvider.resetReviewingANewEvent();

    if(stateProvider.wentFromClubDetailToEventDetail){
      if(stateProvider.clubUIActive){
        context.go("/club_frontpage");
      }else{
        context.go("/club_details");
      }
    }else{
      stateProvider.resetWentFromCLubDetailToEventDetail();
      if(stateProvider.clubUIActive){
        switch(stateProvider.pageIndex){
          case(0): context.go('/club_events');break;
          case(1): context.go('/club_stats'); break;
          case(2): context.go('/club_coupons'); break;
          case(3): context.go('/club_frontpage');break;
          default: context.go('/club_events');break;
        }
      }else{
        switch(stateProvider.pageIndex){
          case(0): context.go('/user_events');break;
          case(1): context.go('/user_clubs'); break;
          case(2): context.go('/user_map'); break;
          case(3): context.go('/user_coupons');break;
          default: context.go('/user_events');break;
        }
      }
    }
  }
  void editField(int index, String newValue, StateProvider stateProvider){
    FocusScope.of(context).unfocus();
    stateProvider.updateCurrentEvent(index, newValue);
    Navigator.pop(context);
  }


  // FORMAT AND CROP
  void formatPrice(){

    var priceDecimalPosition = stateProvider.clubMeEvent.getEventPrice().toString().indexOf(".");

    if(priceDecimalPosition + 2 == stateProvider.clubMeEvent.getEventPrice().toString().length){
      priceFormatted = "${stateProvider.clubMeEvent.getEventPrice().toString().replaceFirst(".", ",")}0 €";
    }else{
      priceFormatted = "${stateProvider.clubMeEvent.getEventPrice().toString().replaceFirst(".", ",")} €";
    }
  }
  void formatDjName(){
    String djNameToDisplay = "";

    if(stateProvider.clubMeEvent.getDjName().length > 42){
      djNameToDisplay = "${stateProvider.clubMeEvent.getDjName().substring(0, 40)}...";
    }else{
      djNameToDisplay = stateProvider.clubMeEvent.getDjName();
    }
    formattedDjName = djNameToDisplay;
  }
  void formatWeekday(){

    String weekDayToDisplay = "";

    var exactOneWeekFromNow = DateTime.now().add(const Duration(days: 7));

    // Get current time for germany
    final berlin = tz.getLocation('Europe/Berlin');
    final todayGermanTZ = tz.TZDateTime.from(DateTime.now(), berlin);

    final exactlyOneWeekFromNowGermanTZ = todayGermanTZ.add(const Duration(days: 7));

    weekDayToDisplay = DateFormat('dd.MM.yyyy').format(stateProvider.clubMeEvent.getEventDate());

    var eventDateWeekday = stateProvider.clubMeEvent.getEventDate().weekday;
    switch(eventDateWeekday){
      case(1): weekDayToDisplay = "Montag, $weekDayToDisplay";
      case(2): weekDayToDisplay = "Dienstag, $weekDayToDisplay";
      case(3): weekDayToDisplay = "Mittwoch, $weekDayToDisplay";
      case(4): weekDayToDisplay = "Donnerstag, $weekDayToDisplay";
      case(5): weekDayToDisplay = "Freitag, $weekDayToDisplay";
      case(6): weekDayToDisplay = "Samstag, $weekDayToDisplay";
      case(7): weekDayToDisplay = "Sonntag, $weekDayToDisplay";
    }

    formattedWeekday = weekDayToDisplay;
  }
  void formatEventTitle(){
    String titleToDisplay = "";

    if(stateProvider.clubMeEvent.getEventTitle().length > 42){
      titleToDisplay = "${stateProvider.clubMeEvent.getEventTitle().substring(0, 40)}...";
    }else{
      titleToDisplay = stateProvider.clubMeEvent.getEventTitle();
    }

    formattedEventTitle = titleToDisplay;
  }
  void formatEventGenres(){
    String genresToDisplay = "";
    if(stateProvider.clubMeEvent.getMusicGenres().substring(stateProvider.clubMeEvent.getMusicGenres().length-1) == ","){
      genresToDisplay = stateProvider.clubMeEvent.getMusicGenres().substring(0, stateProvider.clubMeEvent.getMusicGenres().length-1);
    }else{
      genresToDisplay = stateProvider.clubMeEvent.getMusicGenres();
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

            isContentShown ? Container()
                :SizedBox(
              child: IconButton(
                onPressed: () => leavePage(stateProvider),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                  // size: 20,
                ),
              ),
            ),

            isContentShown ? Container()
                :SizedBox(
              width: screenWidth,
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Deine Events",
                    textAlign: TextAlign.center,
                    style: customTextStyle.size2(),
                  )
                ],
              ),
            ),

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
                GestureDetector(
                    child:Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: stateProvider.getPrimeColor(),
                          // size: customTextStyle.getIconSize1()
                        ),
                        Text(
                          "Info",
                          style: customTextStyle.size5(),
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
                          stateProvider.checkIfCurrentEventIsAlreadyLiked() ? Icons.star_outlined : Icons.star_border,
                          color: stateProvider.getPrimeColor(),
                          // size: customTextStyle.getIconSize1()
                        ),
                        Text(
                          "Like",
                          style: customTextStyle.size5(),
                        )
                      ],
                    ),
                    onTap: () => clickedOnLike(stateProvider, stateProvider.clubMeEvent.getEventId())
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
                          color: stateProvider.getPrimeColor(),
                          // size: customTextStyle.getIconSize1()
                        ),
                        Text(
                          "Share",
                          style: customTextStyle.size5(),
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
          child: Image.asset(
            "assets/images/${stateProvider.clubMeEvent.getBannerId()}",
            fit: BoxFit.cover,
          ),
        ),

        // Main Infos
        Container(
            width: screenWidth,
            height: 180,
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
                                    style: customTextStyle.getFontStyle1Bold(),
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
                                      style: customTextStyle.getFontStyle2BoldLightGrey(),
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
                              stateProvider.clubMeEvent.getClubName(),
                              style: customTextStyle.getFontStyle3Bold(),
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
                                    style: customTextStyle.size5BoldGrey()
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
                        style: customTextStyle.size5Bold(),
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
                              style: customTextStyle.size3Bold(),
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
                                  stateProvider.clubMeEvent.getEventDescription(),
                                  style: customTextStyle.size4(),
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
                              style: customTextStyle.size3Bold(),
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
                                style: customTextStyle.size4(),
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
                stateProvider.clubMeEvent.getEventMarketingFileName().isNotEmpty ?
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
    late Uint8List? videoFile;
    try{

      videoFile = await _supabaseService.getEventContent(stateProvider.clubMeEvent.getEventMarketingFileName());

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      filePath = '$tempPath/${stateProvider.clubMeEvent.getEventMarketingFileName()}';

      file = await File(filePath).writeAsBytes(videoFile!);

      // PlatformFile pFile = result.files.first;
      String mimeStr = lookupMimeType(file!.path)!;
      var fileType = mimeStr.split("/");

      if(fileType.contains('image')){
        print("is image");
        isImage = true;
      }else if(fileType.contains('video')){
        _controller = VideoPlayerController.file(file!);
        await _controller.initialize();
        _createChewieController();
        isVideo = true;
        print("is video");
      }

    }catch(e){
      print("prepareContent:" + e.toString());
    }


  }

  // View when event content is displayed
  Widget _buildContentView(){
    return GestureDetector(
      child: Container(
        // color: Colors.red,
        width: screenWidth,
        height: screenHeight, // *0.902
        child: (isImage || isVideo) ? isImage ?
        Stack(
          alignment: Alignment.center,
          children: [

            // File
            Container(
              width: screenWidth,
              height: screenHeight*1.2,
              child: Image.file(file!),
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
        ) :
        Stack(
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
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

            GestureDetector(
              child: Container(
                height: screenHeight*0.885,
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
        const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      onHorizontalDragDown: (DragDownDetails details){
          clickedOnContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    customTextStyle = CustomTextStyle(context: context);
    stateProvider = Provider.of<StateProvider>(context);

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
      bottomNavigationBar: isContentShown? Container() : CustomBottomNavigationBar(),
    );
  }

}
