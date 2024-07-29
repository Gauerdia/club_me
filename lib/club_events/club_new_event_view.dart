import 'package:chewie/chewie.dart';
import 'package:club_me/models/club_me_event_hive.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/models/event_template.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import '../provider/state_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/cupertino.dart';

class ClubNewEventView extends StatefulWidget {
  const ClubNewEventView({Key? key}) : super(key: key);

  @override
  State<ClubNewEventView> createState() => _ClubNewEventViewState();
}

class _ClubNewEventViewState extends State<ClubNewEventView>{

  String headLine = "Neues Event";

  late DateTime newSelectedDate;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

  final SupabaseService _supabaseService = SupabaseService();
  final HiveService _hiveService = HiveService();

  late TextEditingController _eventDJController;
  late TextEditingController _eventTitleController;
  late TextEditingController _eventPriceController;
  late TextEditingController _eventMusicGenresController;
  late TextEditingController _eventDescriptionController;
  late FixedExtentScrollController _fixedExtentScrollController1;
  late FixedExtentScrollController _fixedExtentScrollController2;

  bool isUploading = false;
  bool isDateSelected = false;
  bool genreScreenActive = false;

  bool isFromTemplate = false;

  bool dateUnfold = false;
  bool djUnfold = false;
  bool titleUnfold = false;
  bool priceUnfold = false;
  bool genresUnfold = false;
  bool descriptionUnfold = false;
  bool contentUnfold = false;
  bool templateUnfold = false;

  bool errorInFileUpload = false;
  bool errorInEventUpload = false;

  int isTemplate = 0;

  double discountContainerHeightFactor = 0.52;
  double newDiscountContainerHeightFactor = 0.2;

  String eventMusicGenresString = "";

  int creationIndex = 0;
  int selectedFirstElement = 0;
  int selectedSecondElement = 0;
  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;

  double originalFoldHeightFactor = 0.08;

  double titleTileHeightFactor = 0.08;
  double dateTileHeightFactor = 0.08;
  double djTileHeightFactor = 0.08;
  double priceTileHeightFactor = 0.08;
  double descriptionTileHeightFactor = 0.08;
  double genreTileHeightFactor = 0.08;
  double contentTileHeightFactor = 0.08;
  double templateTileHeightFactor = 0.08;

  List<String> musicGenresChosen = [];
  List<String> musicGenresOffer = [
    "90s", "Techno", "Rock", "EDM", "80s", "Metal", "Pop"
  ];
  List<String> musicGenresToCompare = [
    "90s", "Techno", "Rock", "EDM", "80s", "Metal", "Pop"
  ];

  File? file;
  String fileExtension = "";
  bool isImage = false;
  bool isVideo = false;
  // 0: no content, 1: image, 2: video
  int contentType = 0;
  String? VIDEO_ON;
  ChewieController? _chewieController;
  VideoPlayerController? _controller;

  String contentFileName = "";

  ByteData? screenshot;

  @override
  void initState(){
    super.initState();

    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    if (stateProvider.getClubMeEventHive() != null){

      _eventDJController = TextEditingController(
          text: stateProvider.getClubMeEventHive()?.getDjName()
      );
      _eventTitleController = TextEditingController(
          text: stateProvider.getClubMeEventHive()?.getEventTitle()
      );
      _eventPriceController = TextEditingController(
          text: stateProvider.getClubMeEventHive()!.getEventPrice().toString()
      );

      final split = stateProvider.getClubMeEventHive()!.getMusicGenres().split(',');
      for(int i=0; i< split.length; i++){
        musicGenresChosen.add(split[i]);
        musicGenresOffer.removeWhere((element) => element == split[i]);
      }

      // _eventMusicGenresController = TextEditingController(
      //     text: stateProvider.getClubMeEventHive()?.getMusicGenres()
      // );
      _eventDescriptionController = TextEditingController(
          text: stateProvider.getClubMeEventHive()?.getEventDescription()
      );

      selectedFirstElement = stateProvider.getClubMeEventHive()!.getEventDate().hour;
      selectedSecondElement = stateProvider.getClubMeEventHive()!.getEventDate().minute;
      newSelectedDate = stateProvider.getClubMeEventHive()!.getEventDate();

      _eventMusicGenresController = TextEditingController();

      isFromTemplate = true;
      stateProvider.resetClubMeEventHive();
    }else{
      _eventDJController = TextEditingController();
      _eventTitleController = TextEditingController();
      _eventPriceController = TextEditingController();
      _eventMusicGenresController = TextEditingController();
      _eventDescriptionController = TextEditingController();
      _fixedExtentScrollController1 = FixedExtentScrollController();
      _fixedExtentScrollController2 = FixedExtentScrollController();
      newSelectedDate = DateTime.now();
    }
  }


  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      title: SizedBox(
        width: screenWidth,
        child: Stack(
          children: [

            // Icon
            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: IconButton(
                icon: const Icon(
                    Icons.clear_rounded
                ),
                onPressed: () => clickedOnAbort()
              ),
            ),

            // Headline
            SizedBox(
              width: screenWidth,
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    headLine,
                    textAlign: TextAlign.center,
                    style: customTextStyle.size2(),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(){
    return SizedBox(
      height: screenHeight*0.12,
      child: Stack(
        children: [

          // Top accent
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight*0.105,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                  )
              ),
            ),
          ),

          // Main Background
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight*0.1,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[800]!.withOpacity(0.7),
                        Colors.grey[900]!
                      ],
                      stops: const [0.1,0.9]
                  ),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)
                  )
              ),
            ),
          ),

          (isVideo || isImage) ? Padding(
            padding: EdgeInsets.only(),
            child: _buildButtonRow(),
          ) : Container(),

          // Right button
          isUploading ? Padding(
            padding: EdgeInsets.only(
                right: screenWidth*0.05,
                bottom: screenHeight*0.03
            ),
            child: const Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: CircularProgressIndicator(),
            ),
          ): (isVideo == false && isImage == false) ? Padding(
            padding: EdgeInsets.only(
              top: screenHeight*0.02
                // right: screenWidth*0.04,
                // bottom: screenHeight*0.015,
            ),
            child: Align(
                alignment: AlignmentDirectional.center,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth*0.055,
                        vertical: screenHeight*0.02
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(10)
                      ),
                      gradient: LinearGradient(
                          colors: [
                            customTextStyle.primeColorDark,
                            customTextStyle.primeColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.2, 0.9]
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      genreScreenActive ? "Zurück" : "Abschicken",
                      style: customTextStyle.size4Bold(),
                    ),
                  ),
                  onTap: () => iterateScreen(),
                )
            ),
          ): Container()
        ],

      ),
    );
  }


  Widget _buildCheckOverview(){

    _fixedExtentScrollController1 = FixedExtentScrollController(initialItem: selectedFirstElement);
    _fixedExtentScrollController2 = FixedExtentScrollController(initialItem: selectedSecondElement);

    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            // Events headline
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Bitte gib die passenden Daten zu deinem Event an!",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            _buildTitleTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            _buildDJTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            _buildDateTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            _buildPriceTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            _buildDescriptionTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            _buildGenresTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            _buildContentTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            isFromTemplate ? Container() : _buildTemplateTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.2,
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForMusicGenres(){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            // 'Which genres' headline
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Welche Musikgenres werden auf desem Event gespielt?",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Propositions
            Container(
              width: screenWidth,
              padding: const EdgeInsets.only(
              ),
              child: Text(
                "Vorschläge",
                textAlign: TextAlign.center,
                style: customTextStyle.size2Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            // Tags to use
            musicGenresOffer.isEmpty?
            Container(
              height: screenHeight*0.05,
              child: Center(
                child: Text(
                    "Keine Genres mehr verfügbar.",
                  style: customTextStyle.size4Bold(),
                ),
              ),
            ):SizedBox(
              width: screenWidth*0.9,
              child: Wrap(
                direction: Axis.horizontal,
                children: musicGenresOffer.map((item){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight*0.01,
                          horizontal: screenWidth*0.01
                        ),
                        child: GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth*0.035,
                                vertical: screenHeight*0.02
                            ),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              gradient: LinearGradient(
                                  colors: [
                                    customTextStyle.primeColorDark,
                                    customTextStyle.primeColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [0.2, 0.9]
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              item,
                              style: customTextStyle.size6Bold(),
                            ),
                          ),
                          onTap: (){
                            setState(() {
                              musicGenresOffer.remove(item);
                              musicGenresChosen.add(item);
                              if(eventMusicGenresString.isEmpty){
                                eventMusicGenresString = "$item,";
                              }else{
                                eventMusicGenresString = "${eventMusicGenresString},$item,";
                              }
                            });
                          },
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            // Chosen
            Container(
              width: screenWidth,
              padding: const EdgeInsets.only(
                // left: screenWidth*0.05,
                // top: screenHeight*0.03
              ),
              child: Text(
                "Ausgewählt",
                textAlign: TextAlign.center,
                style: customTextStyle.size2Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            // Chosen tags
            musicGenresChosen.isEmpty?
            SizedBox(
              height: screenHeight*0.05,
              child: Center(
                child: Text(
                    "Noch keine Genres ausgewählt.",
                  style: customTextStyle.size4Bold(),
                ),
              ),
            ):SizedBox(
              width: screenWidth*0.9,
              child: Wrap(
                direction: Axis.horizontal,
                children: musicGenresChosen.map((item){
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight*0.01,
                            horizontal: screenWidth*0.01
                        ),
                        child: GestureDetector(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth*0.035,
                                vertical: screenHeight*0.02
                            ),
                            decoration:  BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              gradient: LinearGradient(
                                  colors: [
                                    customTextStyle.primeColorDark,
                                    customTextStyle.primeColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [0.2, 0.9]
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: Offset(3, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Text(
                              item,
                              style: customTextStyle.size6Bold(),
                            ),
                          ),
                          onTap: (){
                            setState(() {
                              if(musicGenresToCompare.contains(item)){
                                musicGenresOffer.add(item);
                              }
                              musicGenresChosen.remove(item);
                              eventMusicGenresString.replaceFirst("$item,", "");
                            });
                          },
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            // Own Genre
            Container(
              width: screenWidth,
              padding: EdgeInsets.only(
                // left: screenWidth*0.05,
                top: screenHeight*0.01,
                bottom: screenHeight*0.01
              ),
              child: Text(
                "Eigene Genres hinzufügen",
                textAlign: TextAlign.center,
                style: customTextStyle.size2Bold(),
              ),
            ),

            // Textfield + icon
            Container(
              padding: EdgeInsets.only(
                  bottom: screenHeight*0.025
              ),
              width: screenWidth*0.85,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight*0.03
                    ),
                    child: SizedBox(
                      width: screenWidth*0.65,
                      child: TextField(
                        controller: _eventMusicGenresController,
                        decoration: const InputDecoration(
                            hintText: "z.B. Pop",
                            border: OutlineInputBorder()
                        ),
                        style: customTextStyle.size3(),
                        maxLength: 15,
                      ),
                    ),
                  ),
                  // Icon
                  Center(
                    child: IconButton(
                        onPressed: (){
                          setState(() {
                            musicGenresChosen.add("${_eventMusicGenresController.text}");
                            _eventMusicGenresController.text = "";
                            FocusScope.of(context).unfocus();
                          });
                        },
                        icon: Icon(
                          Icons.send,
                          size: screenHeight*stateProvider.getIconSizeFactor(),
                          color: customTextStyle.primeColor,
                        )
                    ),
                  )
                ],
              )
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.1,
            )

          ],
        ),
      ),
    );
  }
  Widget _buildTitleTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(titleTileHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*titleTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*titleTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[600]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*titleTileHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*titleTileHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // Title + icon
                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Titel",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            titleUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(titleUnfold){
                              titleTileHeightFactor = originalFoldHeightFactor;
                              titleUnfold = false;
                            }else{
                              titleTileHeightFactor = originalFoldHeightFactor*3.5;
                              titleUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                titleUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                titleUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                titleUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                titleUnfold ? Text(
                  "Wie soll das Event heißen?",
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                titleUnfold ?SizedBox(
                  height: screenHeight*0.02,
                ):Container(),

                // Textfield
                titleUnfold ? Container(
                  width: screenWidth*0.8,
                  child: TextField(
                    controller: _eventTitleController,
                    decoration: const InputDecoration(
                      hintText: "z.B. 2-für-1 Mojitos",
                      label: Text("Eventtitel"),
                      border: OutlineInputBorder(),
                    ),
                    style: customTextStyle.size4(),
                    maxLength: 35,
                  ),
                ): Container(),

              ],
            ),
          ),
        )

      ],
    );
  }
  Widget _buildDJTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(djTileHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*djTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*djTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[600]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*djTileHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*djTileHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // Title + icon
                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "DJ",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            djUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(djUnfold){
                              djTileHeightFactor = originalFoldHeightFactor;
                              djUnfold = false;
                            }else{
                              djTileHeightFactor = originalFoldHeightFactor*3.5;
                              djUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                djUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                djUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                djUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                djUnfold ? Text(
                  "Wie heißt der DJ auf diesem Event?",
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                djUnfold ?SizedBox(
                  height: screenHeight*0.02,
                ):Container(),

                // Textfield
                djUnfold ? Container(
                  width: screenWidth*0.8,
                  child: TextField(
                    controller: _eventDJController,
                    decoration: const InputDecoration(
                      hintText: "z.B. DJ Guetta",
                      label: Text("DJ-Name(n)"),
                      border: OutlineInputBorder(),
                    ),
                    style: customTextStyle.size4(),
                    maxLength: 35,
                  ),
                ): Container(),

              ],
            ),
          ),
        )

      ],
    );
  }
  Widget _buildDateTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(dateTileHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*dateTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*dateTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[600]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*dateTileHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*dateTileHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Datum und Uhrzeit",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            dateUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(dateUnfold){
                              dateTileHeightFactor = originalFoldHeightFactor;
                              dateUnfold = false;
                            }else{
                              dateTileHeightFactor = originalFoldHeightFactor*5;
                              dateUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                dateUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                dateUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                dateUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                dateUnfold ? Text(
                  "Wann soll das Event stattfinden?",
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                dateUnfold ?SizedBox(
                  height: screenHeight*0.02,
                ):Container(),


                dateUnfold ?SizedBox(
                  width: screenWidth*0.6,
                  height: screenHeight*0.07,
                  child: OutlinedButton(
                      onPressed: (){
                        showDatePicker(
                            context: context,
                            locale: const Locale("de", "DE"),
                            initialDate: newSelectedDate,
                            firstDate: DateTime(2018),
                            lastDate: DateTime(2030),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.dark(),
                                child: child!,
                              );
                            }).then((pickedDate){
                          if( pickedDate == null){
                            return;
                          }
                          setState(() {
                            newSelectedDate = pickedDate;
                          });
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Date as Text
                          Text(
                            formatSelectedDate(),
                            style: customTextStyle.size3(),
                          ),
                          // Spacer
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          // Calendar icon
                          Icon(
                            Icons.calendar_month_outlined,
                            color: customTextStyle.primeColor,
                          )
                        ],
                      )
                  ),
                ):Container(),

                // Spacer
                dateUnfold ?SizedBox(
                  height: screenHeight*0.02,
                ):Container(),

                dateUnfold ? Text(
                  "Um wie viel Uhr beginnt das Event?",
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                dateUnfold ?SizedBox(
                  height: screenHeight*0.02,
                ):Container(),

                // Starting hour
                dateUnfold ?SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: screenWidth*0.2,
                        child: CupertinoPicker(
                            scrollController: _fixedExtentScrollController1,
                            itemExtent: 50,
                            onSelectedItemChanged: (int index){
                              setState(() {
                                selectedFirstElement = index;
                              });
                            },
                            children: List<Widget>.generate(24, (index){
                              return Center(
                                child: Text(
                                  index < 10 ?
                                  "0${index.toString()}" :
                                  index.toString(),
                                  style: const TextStyle(
                                      fontSize: 24
                                  ),
                                ),
                              );
                            })
                        ),
                      ),
                      const Text(
                        ":",
                        style: TextStyle(
                            fontSize: 22
                        ),
                      ),
                      SizedBox(
                        width: screenWidth*0.2,
                        child: CupertinoPicker(
                            scrollController: _fixedExtentScrollController2,
                            itemExtent: 50,
                            onSelectedItemChanged: (int index){
                              setState(() {
                                selectedSecondElement=index*15;
                              });
                            },
                            children: List<Widget>.generate(4, (index){
                              return Center(
                                child: Text(
                                  index == 0
                                      ? "00"
                                      :(index*15).toString(),
                                  style: const TextStyle(
                                      fontSize: 24
                                  ),
                                ),
                              );
                            })
                        ),
                      ),
                    ],
                  ),
                ):Container(),

              ],
            ),
          ),
        )

      ],
    );
  }
  Widget _buildPriceTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(priceTileHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*priceTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*priceTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[600]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*priceTileHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*priceTileHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // Title + icon
                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Preis",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            priceUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(priceUnfold){
                              priceTileHeightFactor = originalFoldHeightFactor;
                              priceUnfold = false;
                            }else{
                              priceTileHeightFactor = originalFoldHeightFactor*3.5;
                              priceUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                priceUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                priceUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                priceUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                priceUnfold ? Text(
                  "Wie teuer soll das Event sein?",
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                priceUnfold ?SizedBox(
                  height: screenHeight*0.02,
                ):Container(),

                // Textfield
                priceUnfold ? Container(
                  width: screenWidth*0.4,
                  child: TextField(
                    controller: _eventPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder()
                    ),
                    style: customTextStyle.size4(),
                    maxLength: 5,
                  ),
                ): Container(),

              ],
            ),
          ),
        )

      ],
    );
  }
  Widget _buildGenresTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(genreTileHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*genreTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*genreTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[600]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*genreTileHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*genreTileHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // Title + icon
                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Musikrichtungen",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            genresUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(genresUnfold){
                              genreTileHeightFactor = originalFoldHeightFactor;
                              genresUnfold = false;
                            }else{
                              genreTileHeightFactor = originalFoldHeightFactor*5.5;
                              genresUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                genresUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                genresUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                genresUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                genresUnfold ? musicGenresChosen.isEmpty ?
                SizedBox(
                  height: screenHeight*0.05,
                  child: Center(
                    child: Text(
                        "Noch keine Genres ausgewählt.",
                        style: customTextStyle.size4()
                    ),
                  ),
                ):Container(
                  padding: EdgeInsets.only(
                      // left: screenWidth*0.1
                  ),
                  width: screenWidth,
                  child: Center(
                    child:  Wrap(
                      direction: Axis.horizontal,
                      children: musicGenresChosen.map((item){
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight*0.01,
                                  horizontal: screenWidth*0.01
                              ),
                              child: GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth*0.035,
                                      vertical: screenHeight*0.02
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)
                                    ),
                                    gradient: LinearGradient(
                                        colors: [
                                          customTextStyle.primeColorDark,
                                          customTextStyle.primeColor,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        stops: const [0.2, 0.9]
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black54,
                                        spreadRadius: 1,
                                        blurRadius: 7,
                                        offset: Offset(3, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                      item,
                                      style: customTextStyle.size6Bold()
                                  ),
                                ),
                                onTap: (){
                                  setState(() {
                                    if(musicGenresToCompare.contains(item)){
                                      musicGenresOffer.add(item);
                                    }
                                    musicGenresChosen.remove(item);
                                    eventMusicGenresString.replaceFirst("$item,", "");
                                  });
                                },
                              ),
                            )
                          ],
                        );
                      }).toList(),
                    ),
                  )
                ): Container(),

                // Spacer
                genresUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // Icon
                genresUnfold ? GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(
                        5
                    ),
                    decoration: BoxDecoration(
                        color: customTextStyle.primeColorDark,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(45)
                        ),
                        border: Border.all(color: Colors.white)
                    ),
                    child: const Icon(
                        Icons.add
                    ),
                  ),
                  onTap: (){
                    setState(() {
                      genreScreenActive = true;
                    });
                  },
                ):Container(),

              ],
            ),
          ),
        )

      ],
    );
  }
  Widget _buildDescriptionTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(descriptionTileHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*descriptionTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*descriptionTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[600]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*descriptionTileHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*descriptionTileHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Beschreibung",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            descriptionUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(descriptionUnfold){
                              descriptionTileHeightFactor = originalFoldHeightFactor;
                              descriptionUnfold = false;
                            }else{
                              descriptionTileHeightFactor = originalFoldHeightFactor*7.5;
                              descriptionUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                descriptionUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                descriptionUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                descriptionUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // Explanation
                descriptionUnfold ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10
                  ),
                  child: Text(
                      "Erzähl deinen Kunden ein wenig über das Event!",
                      textAlign: TextAlign.center,
                      style: customTextStyle.getFontStyle3(),
                  )
                ):Container(),

                // Spacer
                descriptionUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),


                descriptionUnfold ? SizedBox(
                  width: screenWidth*0.8,
                  child: TextField(
                    controller: _eventDescriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder()
                    ),
                    maxLength: 300,
                    minLines: 10,
                    style:customTextStyle.size4(),
                  ),
                ):Container(),


              ],
            ),
          ),
        )

      ],
    );
  }
  Widget _buildContentTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(contentTileHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*contentTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*contentTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[600]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*contentTileHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*contentTileHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // Text+Icon
                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Bild/Video",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            contentUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(contentUnfold){
                              contentTileHeightFactor = originalFoldHeightFactor;
                              contentUnfold = false;
                            }else{
                              contentTileHeightFactor = originalFoldHeightFactor*4;
                              contentUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                contentUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                contentUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                contentUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // Explanation
                (contentUnfold && file == null) ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10
                    ),
                    child: Text(
                      "Möchtest du ein Bild oder ein Video für das Event hinzufügen?",
                      textAlign: TextAlign.center,
                      style: customTextStyle.getFontStyle3(),
                    )
                ):Container(),

                // Spacer
                contentUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // Add content icon
                (contentUnfold && file == null) ? SizedBox(
                  width: screenWidth*0.8,
                  child: GestureDetector(
                    child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff11181f)
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Center(
                            child: GradientIcon(
                              icon: Icons.add,
                              gradient: LinearGradient(
                                  colors: [Colors.teal, Colors.tealAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [0.5, 0.55]
                              ),
                              size: 40,
                            ),
                          ),
                        )
                    ),
                    onTap: () => clickedOnChooseContent()
                  ),
                ):Container(),

                // Show uploaded content
                (contentUnfold && file != null) ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        // The image
                        contentType == 1 ? GestureDetector(
                          child: SizedBox(
                            width: 100,
                            child: Image.file(file!),
                          ),
                          onTap: (){
                            setState(() {
                              isImage = true;
                            });
                          },
                        ):Container(),
                        
                          // Video screenshot
                          contentType == 2 ? GestureDetector(
                            child: Image.memory(screenshot!.buffer.asUint8List()),
                            onTap: (){
                              setState(() {
                                isVideo = true;
                              });
                            },
                          ):Container(),

                          IconButton(onPressed: (){
                            setState(() {
                              file = null;
                            });
                          }, icon: const Icon(CupertinoIcons.trash, color: Colors.red, size: 42,))
                      ],
                    )
                ):Container(),

              ],
            ),
          ),
        )
      ],
    );
  }
  Widget _buildTemplateTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(templateTileHeightFactor+0.004),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(15)
          ),
        ),

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*templateTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    customTextStyle.primeColorDark.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*templateTileHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[600]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // light grey highlight
        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*templateTileHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            )
        ),

        // main Div
        Padding(
          padding: const EdgeInsets.only(
              left:2,
              top: 2
          ),
          child: Container(
            width: screenWidth*0.9,
            height: screenHeight*templateTileHeightFactor,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!.withOpacity(0.7),
                      Colors.grey[900]!
                    ],
                    stops: [0.1,0.9]
                ),
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [

                // Text+Icon
                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Vorlage",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            templateUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(templateUnfold){
                              templateTileHeightFactor = originalFoldHeightFactor;
                              templateUnfold = false;
                            }else{
                              templateTileHeightFactor = originalFoldHeightFactor*4;
                              templateUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                templateUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                templateUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Explanation
                templateUnfold ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10
                    ),
                    child: Text(
                      "Möchtest du das Event als Vorlage speichern?",
                      textAlign: TextAlign.center,
                      style: customTextStyle.getFontStyle3(),
                    )
                ):Container(),

                // Spacer
                templateUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // Explanation
                (templateUnfold && file == null) ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10
                    ),
                    child: Text(
                      "Möchtest du dieses Event als Vorlage speichern?",
                      textAlign: TextAlign.center,
                      style: customTextStyle.getFontStyle3(),
                    )
                ):Container(),

                // Spacer
                templateUnfold ?SizedBox(
                  width: screenWidth*0.4,
                  height: screenHeight*0.1,
                  child:  Center(
                    child: ToggleSwitch(
                      initialLabelIndex: isTemplate,
                      totalSwitches: 2,
                      activeBgColor: [customTextStyle.primeColor],
                      activeFgColor: Colors.white,
                      inactiveBgColor: const Color(0xff11181f),
                      labels: const [
                        'Nein',
                        'Ja',
                      ],
                      onToggle: (index) {
                        setState(() {
                          isTemplate == 0 ? isTemplate = 1 : isTemplate = 0;
                        });
                      },
                    ),
                  ),
                ):Container(),

              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildImagePreview(){
    return Stack(
      children: [

        // Image container
        SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Image.file(file!),
        ),

      ],
    );
  }

  Widget _buildVideoPreview(){
    return Stack(
      children: [

        // Video container
        Padding(
          padding: EdgeInsets.only(
              bottom: screenHeight*0.15
          ),
          child: SizedBox(
            width: screenWidth,
            height: screenHeight*0.75,
            child: _chewieController != null &&
                _chewieController!
                    .videoPlayerController.value.isInitialized
                ? SizedBox(
              width: screenWidth,
              height: screenHeight*0.95,
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
        )

        // ButtonRow
        // Container(
        //   width: screenWidth,
        //   height: screenHeight,
        //   alignment: Alignment.bottomCenter,
        //   padding: const EdgeInsets.only(bottom: 20),
        //   child: _buildButtonRow(),
        // )


      ],
    );
  }

  Widget _buildButtonRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [

        // Left button
        Padding(
          padding: EdgeInsets.only(
              top: screenHeight*0.02
            // right: screenWidth*0.04,
            // bottom: screenHeight*0.015,
          ),
          child: Align(
              alignment: AlignmentDirectional.center,
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth*0.055,
                      vertical: screenHeight*0.02
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10)
                    ),
                    gradient: LinearGradient(
                        colors: [
                          customTextStyle.primeColorDark,
                          customTextStyle.primeColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.2, 0.9]
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(3, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Text(
                    "Abbrechen",
                    style: customTextStyle.size4Bold(),
                  ),
                ),
                onTap: () => deselectContent(),
              )
          ),
        ),

        // right button
        Padding(
          padding: EdgeInsets.only(
              top: screenHeight*0.02
            // right: screenWidth*0.04,
            // bottom: screenHeight*0.015,
          ),
          child: Align(
              alignment: AlignmentDirectional.center,
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth*0.055,
                      vertical: screenHeight*0.02
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10)
                    ),
                    gradient: LinearGradient(
                        colors: [
                          customTextStyle.primeColorDark,
                          customTextStyle.primeColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.2, 0.9]
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(3, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Text(
                    "Übernehmen",
                    style: customTextStyle.size4Bold(),
                  ),
                ),
                onTap: () => selectContent(),
              )
          ),
        ),

      ],
    );
  }

  // MISC
  void selectContent() async{

    if(isVideo){
      screenshot = await genThumbnailFile(file!.path);
      contentType = 2;
    }
    if(isImage){
      contentType = 1;
    }

    setState(() {

      var uuid = const Uuid();
      var uuidV4 = uuid.v4();

      contentFileName = "$uuidV4.$fileExtension";

      // _controller.dispose();
      // _chewieController!.dispose();
      if(_controller != null){
        _controller!.pause();
      }
      if(_chewieController != null){
        _chewieController!.pause();
        _chewieController!.setVolume(0.0);
      }

      isImage = false;
      isVideo = false;
    });
  }
  void deselectContent(){
    setState(() {
      file = null;
      isImage = false;
      isVideo = false;
      contentType = 0;
      contentFileName = "";
    });
  }
  void iterateScreen(){

    if(genreScreenActive){
      setState(() {
        genreScreenActive = false;
      });
    }else{
      setState(() {
        isUploading = true;
      });
      createNewEvent();
    }

  }

  void createNewEvent(){

    // Get an unique id for the element
    var uuid = const Uuid();
    var uuidV4 = uuid.v4();

    // Start to format the genres
    String musicGenresString = "";
    // Add the genres to a string
    for(String item in musicGenresChosen){
      if(musicGenresString == ""){
        musicGenresString = "$item,";
      }else{
        musicGenresString = "$musicGenresString$item,";
      }
    }
    // Cut the last comma
    if (musicGenresString != null && musicGenresString.isNotEmpty) {
      musicGenresString = musicGenresString.substring(0, musicGenresString.length - 1);
    }

    // Format the date
    DateTime concatenatedDate = DateTime(
        newSelectedDate.year,
        newSelectedDate.month,
        newSelectedDate.day,
        selectedFirstElement,
        selectedSecondElement
    );

    // Put everything together
    ClubMeEvent newEvent = ClubMeEvent(
      eventId: uuidV4,
      eventDate: concatenatedDate,
      djName: _eventDJController.text,
      musicGenres: musicGenresString,
      eventTitle: _eventTitleController.text,
      eventPrice: double.parse(_eventPriceController.text.replaceAll(",", ".")),
      eventDescription: _eventDescriptionController.text,

      clubId: stateProvider.getClubId(),
      clubName: stateProvider.getClubName(),
      bannerId: stateProvider.getUserClubEventBannerId(),

      eventMarketingFileName: file != null ? contentFileName : "",
      eventMarketingCreatedAt: DateTime.now(),
      priorityScore: 0.0
    );

    if(isTemplate == 1){
      addEventToTemplates(newEvent);
    }

    if( file != null){
      _supabaseService.insertEventContent(file, contentFileName, uuidV4, stateProvider).then((value) => {

      if(value == 0){
          _supabaseService.insertEvent(newEvent, stateProvider).then((value) => {
        if(value == 0){
          setState(() {
            stateProvider.setCurrentEvent(newEvent);
            stateProvider.addEventToFetchedEvents(newEvent);
            context.go('/event_details');
          })
        }else{
          setState(() {
            isUploading = false;
            showErrorBottomSheet(0);
          })
        }
      })
      }else{
        setState(() {
          isUploading = false;
          showErrorBottomSheet(1);
        })
      }
      });
    }else{
      _supabaseService.insertEvent(newEvent, stateProvider).then((value) => {
        if(value == 0){
          setState(() {
            stateProvider.setCurrentEvent(newEvent);
            stateProvider.addEventToFetchedEvents(newEvent);
            context.go('/event_details');
          })
        }else{
          setState(() {
            isUploading = false;
            showErrorBottomSheet(0);
          })
        }
      });
    }
  }
  void addEventToTemplates(ClubMeEvent clubMeEvent){

    ClubMeEventHive clubMeEventHive = ClubMeEventHive(
        eventTitle: clubMeEvent.getEventTitle(),
        djName: clubMeEvent.getDjName(),
        eventDate: clubMeEvent.getEventDate(),
        eventPrice: clubMeEvent.getEventPrice(),
        eventDescription: clubMeEvent.getEventDescription(),
        musicGenres: clubMeEvent.getMusicGenres(),
    );

    EventTemplate eventTemplate = EventTemplate(clubMeEventHive: clubMeEventHive);
    _hiveService.addEventTemplate(eventTemplate);
  }

  void showErrorBottomSheet(int errorCode){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return SizedBox(
            height: screenHeight*0.1,
            child: Center(
              child: Text(
                  errorCode == 0 ?
                  "Verzeihung, etwas ist beim Anlegen des Events schiefgegangen!"
                      : "Verzeihung, etwas ist beim Datei-Upload schiefgegangen!"
              ),
            ),
          );
        }
    );
  }
  void showDialogOfMissingValue(){
    showDialog(context: context,
        builder: (BuildContext context){
          return const AlertDialog(
              title: Text("Fehlende Werte"),
              content: Text("Bitte füllen Sie die leeren Felder aus, bevor Sie weitergehen.")
          );
        });
  }
  void clickedOnAbort(){

    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Abbrechen"),
          content: Text("Bist du sicher, dass du abbrechen möchtest?"),
          actions: [

            TextButton(
              child: Text("Zurück"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),

            TextButton(
              child: Text("Ja"),
              onPressed: (){
                switch(stateProvider.pageIndex){
                  case(0): context.go('/club_events');
                  case(3): context.go('/club_frontpage');
                  default: context.go('/club_frontpage');
                }
              },
            ),

          ]
        );
      }
    );
  }
  void clickedOnChooseContent() async{

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false
      // type: FileType.image
      // type: FileType.custom,
      // allowedExtensions: imageFormats
    );
    if (result != null) {

      file = File(result.files.single.path!);
      PlatformFile pFile = result.files.first;
      String mimeStr = lookupMimeType(file!.path)!;
      var fileType = mimeStr.split("/");
      fileExtension = pFile.extension.toString();

      if(fileType.contains('image')){
        isImage = true;
      }
      else if(fileType.contains('video')){

        // file = File(result.files.single.path!);
        _controller = VideoPlayerController.file(file!);
        await _controller!.initialize();
        _createChewieController();
        isVideo = true;
      }
      setState(() {});
    }
  }

  _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      looping: true,
      autoPlay: true,
      showOptions: true,
      autoInitialize: true,
      allowFullScreen: true,
    );
  }

  String formatSelectedDate(){

    String tempDay = "";
    String tempMonth = "";
    String tempYear = "";

    if(newSelectedDate.day.toString().length == 1){
      tempDay = "0${newSelectedDate.day}";
    }else{
      tempDay = "${newSelectedDate.day}";
    }

    if(newSelectedDate.month.toString().length == 1){
      tempMonth = "0${newSelectedDate.month}";
    }else{
      tempMonth = "${newSelectedDate.month}";
    }

    if(newSelectedDate.year.toString().length == 1){
      tempYear = "0${newSelectedDate.year}";
    }else{
      tempYear = "${newSelectedDate.year}";
    }

    return "$tempDay.$tempMonth.$tempYear";
  }

  Future<ByteData> genThumbnailFile(String path) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 100,
      quality: 75,
    );
    File file = File(fileName!);
    Uint8List bytes = file.readAsBytesSync();
    return ByteData.view(bytes.buffer);
  }


  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      extendBody: true,

      bottomNavigationBar: _buildNavigationBar(),
      appBar: _buildAppBar(),
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
          child: Center(
              child: genreScreenActive ?
              _buildCheckForMusicGenres()
                  : isImage ?
                  _buildImagePreview()
              : isVideo ?
              _buildVideoPreview()
            :_buildCheckOverview(),
          )

      ),
    );
  }

}

