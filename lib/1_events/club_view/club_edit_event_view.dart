import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/models/opening_times.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/supabase_service.dart';

class ClubEditEventView extends StatefulWidget {
  const ClubEditEventView({super.key});

  @override
  State<ClubEditEventView> createState() => _ClubEditEventViewState();
}

class _ClubEditEventViewState extends State<ClubEditEventView> {

  final SupabaseService _supabaseService = SupabaseService();

  late DateTime newSelectedDate;
  late StateProvider stateProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;
  late FetchedContentProvider fetchedContentProvider;
  late UserDataProvider userDataProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  int selectedFirstHour = 0;
  int selectedSecondMinute = 0;

  bool isUploading = false;
  bool isDateSelected = false;
  bool firstElementChanged = false;
  bool secondElementChanged = false;

  String headline = "Event bearbeiten";
  String eventMusicGenresString = "";

  var newDiscountContainerHeightFactor = 0.85;

  bool genreScreenActive = false;

  List<String> musicGenresChosen = [];
  List<String> musicGenresOffer = [
    "Latin", "Rock", "Hip-Hop", "Electronic", "Pop", "Reggaeton", "Afrobeats",
    "R&B", "House", "Techno", "Rap", "90er", "80er", "2000er",
    "Heavy Metal", "Psychedelic", "Balkan"
  ];
  List<String> musicGenresToCompare = [
    "Latin", "Rock", "Hip-Hop", "Electronic", "Pop", "Reggaeton", "Afrobeats",
    "R&B", "House", "Techno", "Rap", "90er", "80er", "2000er",
    "Heavy Metal", "Psychedelic", "Balkan"
  ];

  late TextEditingController _eventTitleController;
  late TextEditingController _eventDJController;
  late TextEditingController _eventPriceController;
  late TextEditingController _eventDescriptionController;
  late FixedExtentScrollController _fixedExtentScrollController1;
  late FixedExtentScrollController _fixedExtentScrollController2;
  late TextEditingController _eventMusicGenresController;
  late TextEditingController _eventTicketLinkController;


  bool isFromTemplate = false;

  bool errorInFileUpload = false;
  bool errorInEventUpload = false;

  int isRepeatedIndex = 0;

  int isRepeated = 0;
  List<String> repetitionAnswers = [
    "Wöchentlich", "Zweiwöchentlich"
  ];
  int isTemplate = 0;

  double discountContainerHeightFactor = 0.52;

  int creationIndex = 0;
  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;

  File? file;
  String fileExtension = "";
  bool isImage = false;
  bool isVideo = false;
  // 0: no content, 1: image, 2: video
  int contentType = 0;
  String? VIDEO_ON;
  ChewieController? _chewieController;
  VideoPlayerController? _controller;

  bool pickHourAndMinuteIsActive = false;
  bool pickGenreIsActive = false;

  String pickedFileNameToDisplay = "";

  String contentFileName = "";

  ByteData? screenshot;

  // INIT

  @override
  void initState(){
    super.initState();
    initControllers();
  }
  void initControllers(){

    stateProvider = Provider.of<StateProvider>(context, listen:  false);
    final tempCurrentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen: false);

    processGenres(tempCurrentAndLikedElementsProvider);

    newSelectedDate = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate();

    selectedHour = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate().hour;
    selectedMinute = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate().minute;

    _eventTitleController = TextEditingController(
        text:tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventTitle());
    _eventDJController = TextEditingController(
        text:  tempCurrentAndLikedElementsProvider.currentClubMeEvent.getDjName());
    _eventPriceController = TextEditingController(
        text: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventPrice().toString());
    _eventDescriptionController = TextEditingController(
        text: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDescription());
    _fixedExtentScrollController1 = FixedExtentScrollController(
        initialItem: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate().hour);
    _fixedExtentScrollController2 = FixedExtentScrollController(
        initialItem: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate().minute);
    _eventTicketLinkController = TextEditingController(
        text: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getTicketLink()
    );

    if(tempCurrentAndLikedElementsProvider.currentClubMeEvent.getIsRepeatedDays() != 0){
      isRepeated = 1;
      switch(tempCurrentAndLikedElementsProvider.currentClubMeEvent.getIsRepeatedDays()){
        case(7): isRepeatedIndex = 0;break;
        case(14): isRepeatedIndex = 1; break;
      }
    }

  }


  // BUILD


  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title: SizedBox(
        width: screenWidth,
        child: Stack(
          children: [

            // Icon
            Container(
              alignment: Alignment.centerRight,
              height: 50,
              child: IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: Colors.white,
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
                    headline,
                    textAlign: TextAlign.center,
                    style: customStyleClass.getFontStyleHeadline1Bold(),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _buildNavigationBar2(){
    return (isVideo || isImage) ?
    Container(
      width: screenWidth,
      height: screenHeight*0.08,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: customStyleClass.backgroundColorMain,
          border: Border(
              top: BorderSide(
                  color: Colors.grey[900]!
              )
          )
      ),
      child: SizedBox(
        width: screenWidth*0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Text(
                "Abbrechen",
                style: customStyleClass.getFontStyle3BoldPrimeColor(),
              ),
              onTap: () => deselectContent(),
            ),
            GestureDetector(
              child: Text(
                "Übernehmen",
                style: customStyleClass.getFontStyle3BoldPrimeColor(),
              ),
              onTap: () => selectContent(),
            ),
          ],
        ),
      ),
    ):
    Container(
      width: screenWidth,
      height: screenHeight*0.08,
      decoration: BoxDecoration(
          color: customStyleClass.backgroundColorMain,
          border: Border(
              top: BorderSide(
                  color: Colors.grey[900]!
              )
          )
      ),

      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(
          right: 10,
          // bottom: 10
      ),
      child: isUploading ? CircularProgressIndicator()
          : GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Abschicken",
              style: customStyleClass.getFontStyle3BoldPrimeColor(),
            ),
            Icon(
              Icons.arrow_forward_outlined,
              color: customStyleClass.primeColor,
            )
          ],
        ),
        onTap: () => clickEventUpdateEvent(),
      ),
    );
  }
  Widget _buildCheckOverview2(){

    return SizedBox(
        height: screenHeight,
        child: Stack(
          children: [

            // Main view
            SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                    children: [

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.05,
                      ),

                      // headline
                      Container(
                        width: screenWidth*0.9,
                        child: Text(
                          "Bitte gib die passenden Daten zu deinem Event ein!",
                          textAlign: TextAlign.center,
                          style: customStyleClass.getFontStyle1Bold(),
                        ),
                      ),

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.03,
                      ),

                      // Text: Title
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Titel des Events",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // Textfield: Title
                      Container(
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: _eventTitleController,
                          cursorColor: customStyleClass.primeColor,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 20,
                                top:20,
                                bottom:20
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customStyleClass.primeColor
                                )
                            ),
                            hintText: "z.B. Mixed Music",
                            border: OutlineInputBorder(),
                          ),
                          style: customStyleClass.getFontStyle4(),
                          maxLength: 35,
                        ),
                      ),

                      // Title: DJ
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "DJ des Events",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // Textfield: DJ
                      Center(
                        child: SizedBox(
                          width: screenWidth*0.9,
                          child: TextField(
                            controller: _eventDJController,
                            cursorColor: customStyleClass.primeColor,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  left: 20,
                                  top:20,
                                  bottom:20
                              ),
                              hintText: "z.B. DJ David Guetta",
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: customStyleClass.primeColor
                                  )
                              ),
                            ),
                            style: customStyleClass.getFontStyle4(),
                            maxLength: 35,
                          ),
                        ),
                      ),

                      // Row: Datepicker, Hour/Minute, Price
                      Container(
                        width: screenWidth*0.9,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // Datepicker
                            SizedBox(
                              height: screenHeight*0.12,
                              child: Column(
                                children: [

                                  // Text: Date
                                  SizedBox(
                                    width: screenWidth*0.4,
                                    child: Text(
                                      "Datum",
                                      style: customStyleClass.getFontStyle3(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),


                                  // OutlinedButton with Text
                                  SizedBox(
                                    width: screenWidth*0.4,
                                    child:OutlinedButton(
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
                                        style: OutlinedButton.styleFrom(
                                            minimumSize: Size(screenHeight*0.05,screenHeight*0.07),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            )
                                        ),
                                        child: Text(
                                          formatSelectedDate(),
                                          style: customStyleClass.getFontStyle4(),
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),

                            // Hour and minute
                            SizedBox(
                              height: screenHeight*0.12,
                              child: Column(
                                children: [

                                  SizedBox(
                                    width: screenWidth*0.4,
                                    child: Text(
                                      "Uhrzeit",
                                      style: customStyleClass.getFontStyle3(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),

                                  // SizedBox(
                                  //   height: screenHeight*0.01,
                                  // ),

                                  SizedBox(
                                    width: screenWidth*0.4,
                                    child: OutlinedButton(
                                        onPressed: () => {
                                          setState(() {
                                            pickHourAndMinuteIsActive = true;
                                          })
                                        },
                                        style: OutlinedButton.styleFrom(
                                            minimumSize: Size(screenHeight*0.05,screenHeight*0.07),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            )
                                        ),
                                        child: Text(
                                          formatSelectedHourAndMinute(),
                                          style: customStyleClass.getFontStyle4(),
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),

                      // Price text field
                      Container(
                        // padding: const EdgeInsets.only(
                        //     top: 5
                        // ),
                        child: Column(
                          children: [

                            // Text: Price
                            Container(
                              width: screenWidth*0.9,
                              child: Text(
                                "Eintrittspreis",
                                style: customStyleClass.getFontStyle3(),
                                textAlign: TextAlign.left,
                              ),
                            ),

                            // Spacer
                            SizedBox(
                              height: screenHeight*0.007,
                            ),

                            // Textfield: Price
                            Container(
                              width: screenWidth*0.9,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: screenWidth*0.3,
                                // height: screenHeight*0.085,
                                child: TextField(
                                  controller: _eventPriceController,
                                  keyboardType: TextInputType.number,
                                  cursorColor: customStyleClass.primeColor,
                                  decoration: InputDecoration(
                                    hintText: "z.B. 10",
                                    contentPadding: const EdgeInsets.only(
                                        left: 20,
                                        top:20,
                                        bottom:20
                                    ),
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: customStyleClass.primeColor
                                        )
                                    ),
                                  ),
                                  style: customStyleClass.getFontStyle4(),
                                  maxLength: 5,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // Text: Description
                      Container(
                        padding: EdgeInsets.only(
                            top: 10
                        ),
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Beschreibung des Events",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // Textfield: Description
                      SizedBox(
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: _eventDescriptionController,
                          keyboardType: TextInputType.multiline,
                          cursorColor: customStyleClass.primeColor,
                          maxLines: null,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 20,
                                top:20,
                                bottom:20,
                              right: 10
                            ),
                            border: OutlineInputBorder(),
                            hintText: "Erzähe deinen Kunden etwas über das Event...",
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customStyleClass.primeColor
                                )
                            ),
                          ),
                          maxLength: 300,
                          minLines: 10,
                          style:customStyleClass.getFontStyle4(),
                        ),
                      ),

                      // Text: Genres
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Musikrichtungen",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // Wrap: Genres
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          children: [
                            for(String genre in musicGenresChosen)
                              InkWell(
                                child: Padding(
                                  padding:const EdgeInsets.only(
                                      right: 5,
                                      top: 12
                                  ),
                                  child: Text(
                                    genre,
                                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                                  ),
                                ),
                                onTap: () => removeGenresFromList(genre),
                              ),
                            IconButton(
                                onPressed: () => showDialogToAddGenres(),
                                icon: Icon(
                                  Icons.add,
                                  size: 30,
                                  color: customStyleClass.primeColor,
                                )
                            )
                          ],
                        ),
                      ),

                      // Text: Image or Video
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Bild oder Video",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // Show icon, name and erase-icon when file selected
                      if(file != null)
                        SizedBox(
                          width: screenWidth*0.9,
                          height: screenHeight*0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.file_present,
                                size: 32,
                                color: customStyleClass.primeColor,
                              ),
                              Text(
                                pickedFileNameToDisplay,
                                style: customStyleClass.getFontStyle3(),
                              ),
                              IconButton(
                                  onPressed: () {setState(() {
                                    file = null;
                                  });},
                                  icon: Icon(
                                    Icons.delete,
                                    size: 32,
                                    color: customStyleClass.primeColor,
                                  )
                              )
                            ],
                          ),
                        ),

                      // Show 'add' icon when no file selected
                      if(file == null)
                        Container(
                          width: screenWidth*0.9,
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                              onPressed: () => clickedOnChooseContent(),
                              icon: Icon(
                                Icons.add,
                                size: 30,
                                color: customStyleClass.primeColor,
                              )
                          ),
                        ),

                      // Text: Ticket Link
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Link zu Tickets",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // TextField: Ticket
                      SizedBox(
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: _eventTicketLinkController,
                          cursorColor: customStyleClass.primeColor,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                left: 20,
                                top:20,
                                bottom:20
                            ),
                            hintText: "https://www.eventbrite.com",
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: customStyleClass.primeColor
                                )
                            ),
                          ),
                          style: customStyleClass.getFontStyle4(),
                          maxLength: 35,
                        ),
                      ),

                      // Text: 'Repeat event'
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: screenWidth*0.45,
                          child: Text(
                            "Event wiederholen",
                            style: customStyleClass.getFontStyle4(),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),

                      // ToggleSwitch: isRepeated
                      Container(
                        width: screenWidth*0.9,
                        height: screenHeight*0.1,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: screenWidth*0.3,
                                child: ToggleSwitch(
                                  minHeight: screenHeight*0.06,
                                  initialLabelIndex: isRepeated,
                                  totalSwitches: 2,
                                  activeBgColor: [customStyleClass.primeColor],
                                  activeFgColor: Colors.black,
                                  inactiveFgColor: customStyleClass.primeColor,
                                  inactiveBgColor: const Color(0xff11181f),
                                  labels: const [
                                    'Nein',
                                    'Ja',
                                  ],
                                  onToggle: (index) {
                                    setState(() {
                                      isRepeated == 0 ? isRepeated = 1 : isRepeated = 0;
                                    });
                                  },
                                )
                            ),

                            if(isRepeated != 0)
                              SizedBox(
                                width: screenWidth*0.4,
                                child: CupertinoPicker(
                                    scrollController: _fixedExtentScrollController1,
                                    itemExtent: 50,
                                    onSelectedItemChanged: (int index){
                                      setState(() {
                                        isRepeatedIndex = index;
                                      });
                                    },
                                    children: List<Widget>.generate(repetitionAnswers.length, (index){
                                      return Center(
                                        child: Text(
                                          repetitionAnswers[index],
                                          style: customStyleClass.getFontStyle3(),
                                        ),
                                      );
                                    })
                                ),
                              ),

                          ],
                        ),
                      ),

                      // Text: Template
                      if(isTemplate != 0)
                        Container(
                          width: screenWidth*0.9,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: screenWidth*0.45,
                            child: Text(
                              "Als Vorlage speichern",
                              style: customStyleClass.getFontStyle4(),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),

                      // ToggleSwitch isTemplate
                      if(isTemplate != 0)
                        Container(
                          width: screenWidth*0.9,
                          height: screenHeight*0.1,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: screenWidth*0.45,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                                width: screenWidth*0.3,
                                child: ToggleSwitch(
                                  minHeight: screenHeight*0.06,
                                  initialLabelIndex: isTemplate,
                                  totalSwitches: 2,
                                  activeBgColor: [customStyleClass.primeColor],
                                  activeFgColor: Colors.black,
                                  inactiveFgColor: customStyleClass.primeColor,
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
                                )
                            ),
                          ),
                        ),

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.15,
                      ),

                    ]
                )
            ),

            // opacity blocker
            if(pickHourAndMinuteIsActive || pickGenreIsActive)
              GestureDetector(
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  color: Colors.black.withOpacity(0.7),
                ),
                onTap: () {
                  setState(() {
                    pickHourAndMinuteIsActive = false;
                    pickGenreIsActive = false;
                  });
                },
              ),

            // window to ask for hours and minutes
            if(pickHourAndMinuteIsActive)
              Center(
                child: Container(
                  width: screenWidth*0.9,
                  // height: screenHeight*0.3,
                  padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20
                  ),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                          color: Colors.grey[200]!
                      )
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Question text
                      Text(
                        "Startuhrzeit",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle1(),
                      ),

                      // Question text
                      Text(
                        "Bitte trage mit Hoch- und Herunterwischen die Uhrzeit ein, zu der das Event beginnt.",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle4(),
                      ),

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.03,
                      ),

                      // Cupertino picker
                      SizedBox(
                        height: screenHeight*0.1,
                        // color: Colors.red,
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
                                      selectedHour = index;
                                    });
                                  },
                                  children: List<Widget>.generate(24, (index){
                                    return Center(
                                      child: Text(
                                        index < 10 ?
                                        "0${index.toString()}" :
                                        index.toString(),
                                        style: customStyleClass.getFontStyle3(),
                                      ),
                                    );
                                  })
                              ),
                            ),
                            Text(
                              ":",
                              style: customStyleClass.getFontStyle3(),
                            ),
                            SizedBox(
                              width: screenWidth*0.2,
                              child: CupertinoPicker(
                                  scrollController: _fixedExtentScrollController2,
                                  itemExtent: 50,
                                  onSelectedItemChanged: (int index){
                                    setState(() {
                                      selectedMinute = index*15;
                                    });
                                  },
                                  children: List<Widget>.generate(4, (index){
                                    return Center(
                                      child: Text(
                                        index == 0
                                            ? "00"
                                            :(index*15).toString(),
                                        style: customStyleClass.getFontStyle3(),
                                      ),
                                    );
                                  })
                              ),
                            ),
                          ],
                        ),
                      ),

                      // "Finished" button
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
                                "Fertig",
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyle4BoldPrimeColor(),
                              ),
                            ),
                            onTap: () => {
                              setState(() {
                                pickHourAndMinuteIsActive = false;
                              })
                            },
                          )
                      ),

                    ],
                  ),
                ),
              ),

            if(pickGenreIsActive)
              Center(
                child: Container(
                  width: screenWidth*0.9,
                  // height: screenHeight*0.3,
                  padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20
                  ),
                  decoration: BoxDecoration(
                      color: customStyleClass.backgroundColorMain,
                      border: Border.all(
                          color: Colors.grey[200]!
                      )
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Question text
                      Text(
                        "Musikrichtungen",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle1(),
                      ),

                      // Question text
                      Text(
                        "Füge Musikrichtungen hinzu oder lösche sie per einfachem Klick!",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle4(),
                      ),

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.03,
                      ),

                      Column(
                        children: [

                          // headline
                          Text(
                            "Vorgeschlagene Musikrichtungen",
                            style: customStyleClass.getFontStyle4Bold(),
                          ),

                          // offered genres
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10
                            ),
                            child: Wrap(
                              children: [
                                for(var element in musicGenresOffer)
                                  GestureDetector(
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          right: 10
                                      ),
                                      child: Text(
                                        element,
                                        style: customStyleClass.getFontStyle3BoldPrimeColor(),
                                      ),
                                    ),
                                    onTap: () => addGenreToChosenGenres(element),
                                  )
                              ],
                            ),
                          ),

                          // Headline
                          Text(
                            "Ausgewählte Musikrichtungen",
                            style: customStyleClass.getFontStyle4Bold(),
                          ),

                          // chosen music genres
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10
                            ),
                            child: Wrap(
                              children: [
                                for(var element in musicGenresChosen)
                                  GestureDetector(
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          right: 10
                                      ),
                                      child: Text(
                                        element,
                                        style: customStyleClass.getFontStyle3BoldPrimeColor(),
                                      ),
                                    ),
                                    onTap: () => removeGenresFromList(element),
                                  ),
                              ],
                            ),
                          ),

                          if(musicGenresChosen.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 15
                              ),
                              child: Text(
                                "Noch keine Musikrichtungen ausgewählt",
                                style: customStyleClass.getFontStyle5(),
                              ),
                            ),

                          // // headline
                          // Text(
                          //   "Eigene Musikrichtungen",
                          //   style: customStyleClass.getFontStyle4Bold(),
                          // ),
                          //
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          //
                          // // textfield own genres
                          // Row(
                          //   children: [
                          //     SizedBox(
                          //       // height: screenHeight*0.08,
                          //       width: screenWidth*0.5,
                          //       // color: Colors.green,
                          //       child: TextField(
                          //         controller: _eventMusicGenresController,
                          //         keyboardType: TextInputType.number,
                          //         cursorColor: customStyleClass.primeColor,
                          //         decoration: InputDecoration(
                          //           border: const OutlineInputBorder(),
                          //           focusedBorder: OutlineInputBorder(
                          //               borderSide: BorderSide(
                          //                   color: customStyleClass.primeColor
                          //               )
                          //           ),
                          //         ),
                          //         style: customStyleClass.getFontStyle4(),
                          //         maxLength: 15,
                          //       ),
                          //     ),
                          //     Container(
                          //         height: screenHeight*0.08,
                          //         // color: Colors.red,
                          //         alignment: Alignment.topCenter,
                          //         child: SizedBox(
                          //           // height: screenHeight*0.4,
                          //           // color: Colors.green,
                          //             child: IconButton(
                          //                 onPressed: () => addOwnGenreToChosenGenres(),
                          //                 icon: Icon(
                          //                   Icons.add,
                          //                   size: 35,
                          //                   color: customStyleClass.primeColor,
                          //                 )
                          //             )
                          //         )
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),

                      // "Finished" button
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
                                "Fertig",
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyle4BoldPrimeColor(),
                              ),
                            ),
                            onTap: () => {
                              setState(() {
                                pickGenreIsActive = false;
                              })
                            },
                          )
                      ),

                    ],
                  ),
                ),
              )

          ],
        )
    );
  }
  AlertDialog _buildErrorDialog(){
    return const AlertDialog(
      title: Text("Fehler aufgetreten"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Question text
          Text(
            "Verzeihung, es ist ein Fehler aufgetreten.",
            textAlign: TextAlign.left,
          ),
        ],
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
                style: customStyleClass.getFontStyle1Bold(),
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
                style: customStyleClass.getFontStyle2Bold(),
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
                  style: customStyleClass.getFontStyle4Bold(),
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
                                    customStyleClass.primeColorDark,
                                    customStyleClass.primeColor,
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
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              item,
                              style: customStyleClass.getFontStyle6Bold(),
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
                style: customStyleClass.getFontStyle2Bold(),
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
                  style: customStyleClass.getFontStyle4Bold(),
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
                                    customStyleClass.primeColorDark,
                                    customStyleClass.primeColor,
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
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              item,
                              style: customStyleClass.getFontStyle6Bold(),
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
                style: customStyleClass.getFontStyle2Bold(),
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
                          cursorColor: customStyleClass.primeColor,
                          decoration: const InputDecoration(
                              hintText: "z.B. Pop",
                              border: OutlineInputBorder()
                          ),
                          style: customStyleClass.getFontStyle3(),
                          maxLength: 15,
                        ),
                      ),
                    ),
                    // Icon
                    Center(
                      child: IconButton(
                          onPressed: (){
                            setState(() {
                              musicGenresChosen.add(_eventMusicGenresController.text);
                              _eventMusicGenresController.text = "";
                              FocusScope.of(context).unfocus();
                            });
                          },
                          icon: Icon(
                            Icons.send,
                            size:
                            customStyleClass.getFontSize4(),
                            //screenHeight*stateProvider.getIconSizeFactor(),
                            color: customStyleClass.primeColor,
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
      ],
    );
  }


  // CLICK EVENTS


  void clickedOnAbort(){

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              backgroundColor: Color(0xff121111),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  // side: BorderSide(
                  //     color: customStyleClass.primeColor
                  // )
              ),
              title: Text(
                "Abbrechen",
                style: customStyleClass.getFontStyle1Bold(),
              ),
              content: Text(
                "Bist du sicher, dass du abbrechen möchtest?",
                textAlign: TextAlign.left,
                style: customStyleClass.getFontStyle4(),
              ),
              actions: [

                TextButton(
                  child: Text(
                    "Zurück",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),

                TextButton(
                  child: Text(
                    "Ja",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onPressed: () => resetAndGoBackToEvents(),
                ),

              ]
          );
        }
    );
  }
  void clickedOnChooseContent() async{

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false
    );
    if (result != null) {

      file = File(result.files.single.path!);
      PlatformFile pFile = result.files.first;
      String mimeStr = lookupMimeType(file!.path)!;
      var fileType = mimeStr.split("/");
      fileExtension = pFile.extension.toString();

      pickedFileNameToDisplay = result.files.single.name;

      if(fileType.contains('image')){
        isImage = true;
      }
      else if(fileType.contains('video')){
        _controller = VideoPlayerController.file(file!);
        await _controller!.initialize();
        _createChewieController();
        isVideo = true;
      }
      setState(() {});
    }
  }
  void clickEventProcessNewEvent(){

  }
  void clickEventUpdateEvent(){
    setState(() {
      isUploading = true;
      finishUpdateEvent();
    });
  }
  void resetAndGoBackToEvents(){
    // TODO: context.go doesnt work !? Need to investigate
    stateProvider.resetCurrentEventTemplate();
    context.push('/club_events');
  }


  // LOGIC


  void removeGenresFromList(String genreToRemove){
    setState(() {
      musicGenresChosen.removeWhere((element) => element == genreToRemove);
      if(musicGenresToCompare.contains(genreToRemove) && !musicGenresOffer.contains(genreToRemove)){
        musicGenresOffer.add(genreToRemove);
      }
    });
  }
  void addOwnGenreToChosenGenres(){
    setState(() {
      musicGenresChosen.add(_eventMusicGenresController.text);
      _eventMusicGenresController.text = "";
    });
  }
  void addGenreToChosenGenres(String genreToAdd){
    setState(() {
      musicGenresChosen.add(genreToAdd);
      if(musicGenresOffer.contains(genreToAdd)){
        musicGenresOffer.remove(genreToAdd);
      }
    });
  }
  void processGenres(CurrentAndLikedElementsProvider tempCurrentAndLikedElementsProvider){

    String genresString = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getMusicGenres();

    final split = genresString.split(',');
    final Map<int, String> values = {
      for (int i = 0; i< split.length; i++)
        i: split[i]
    };

    values.forEach((key, value) {
      musicGenresToCompare.add(value);
      musicGenresChosen.add(value);
    });

  }
  void finishUpdateEvent() async{

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
    if (musicGenresString.isNotEmpty) {
      musicGenresString = musicGenresString.substring(0, musicGenresString.length - 1);
    }

    // Format the date
    DateTime concatenatedDate = DateTime(
        newSelectedDate.year,
        newSelectedDate.month,
        newSelectedDate.day,
        selectedHour,
        selectedMinute
    );

    String ticketLinkToSave = "";
    if(_eventTicketLinkController.text.contains("http")){
      ticketLinkToSave = _eventTicketLinkController.text;
    }else{
      ticketLinkToSave = "https://${_eventTicketLinkController.text}";
    }

    int daysToRepeat = 0;
    if(isRepeated != 0){
      switch(isRepeatedIndex){
        case(0): daysToRepeat = 7;break;
        case(1): daysToRepeat = 14;break;
        default: daysToRepeat = 0;break;
      }
    }


    ClubMeEvent updatedEvent = ClubMeEvent(

      eventDate: concatenatedDate,
      musicGenres: musicGenresString,

      djName: _eventDJController.text,
      ticketLink: ticketLinkToSave,
      eventTitle: _eventTitleController.text,
      eventDescription: _eventDescriptionController.text,
      eventPrice: double.parse(_eventPriceController.text.replaceAll(",", ".")),

      eventMarketingCreatedAt: file != null ? DateTime.now(): null,
      eventMarketingFileName: file != null ? contentFileName : "",

      isRepeatedDays: isRepeated != 0 ? daysToRepeat : 0,

      eventId: currentAndLikedElementsProvider.currentClubMeEvent.getEventId(),
      clubName: currentAndLikedElementsProvider.currentClubMeEvent.getClubName(),
      bannerId: currentAndLikedElementsProvider.currentClubMeEvent.getBannerId(),
      clubId: currentAndLikedElementsProvider.currentClubMeEvent.getClubId(),
      priorityScore: currentAndLikedElementsProvider.currentClubMeEvent.getPriorityScore(),
      openingTimes: userDataProvider.getUserClubOpeningTimes(),

    );

    setState(() {
      isUploading = true;
    });

    // Is there a file to upload?
    if( file != null){
      _supabaseService
          .insertEventContent(
          file,
          contentFileName,
          currentAndLikedElementsProvider.currentClubMeEvent.getEventId(),
          stateProvider
      )
          .then((value) => {

        // Has the upload been successful?
        _supabaseService.updateCompleteEvent(updatedEvent).then((value){
          if(value == 0){
            fetchedContentProvider.updateSpecificEvent(
                currentAndLikedElementsProvider.currentClubMeEvent.getEventId(),
                updatedEvent
            );
            Navigator.pop(context);
          }else{
            setState(() {
              isUploading = false;
            });
            showDialog(context: context, builder: (BuildContext context){
              return _buildErrorDialog();
            });
          }
        })
      });
    }else{
      _supabaseService.updateCompleteEvent(updatedEvent).then((value){
        if(value == 0){
          fetchedContentProvider.updateSpecificEvent(
              currentAndLikedElementsProvider.currentClubMeEvent.getEventId(),
              updatedEvent
          );
          Navigator.pop(context);
        }else{
          setState(() {
            isUploading = false;
          });
          showDialog(context: context, builder: (BuildContext context){
            return _buildErrorDialog();
          });
        }
      });
    }
  }


  // MISC


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
  void showDialogToAddGenres(){
    setState(() {
      pickGenreIsActive = true;
    });
  }
  String formatSelectedHourAndMinute(){
    String hourToDisplay = "", minuteToDisplay = "";

    if(selectedHour < 10){
      hourToDisplay = "0$selectedHour";
    }else{
      hourToDisplay = selectedHour.toString();
    }
    if(selectedMinute < 10){
      minuteToDisplay = "0$selectedMinute";
    }else{
      minuteToDisplay = selectedMinute.toString();
    }

    return "$hourToDisplay:$minuteToDisplay";
  }
  void selectContent() async{

    if(isVideo){
      contentType = 2;
    }
    if(isImage){
      contentType = 1;
    }

    setState(() {

      var uuid = const Uuid();
      var uuidV4 = uuid.v4();

      contentFileName = "$uuidV4.$fileExtension";

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
  void leavePage(){

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              title: const Text("Abbrechen"),
              content: const Text("Bist du sicher, dass du abbrechen möchtest?"),
              actions: [

                TextButton(
                  child: const Text("Zurück"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),

                TextButton(
                  child: const Text("Ja"),
                  onPressed: (){
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),

              ]
          );
        }
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






  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);


    return Scaffold(
      appBar: _buildAppBar(),
      body: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Center(
            child: genreScreenActive ?
            _buildCheckForMusicGenres()
                : isImage ?
            _buildImagePreview()
                : isVideo ?
            _buildVideoPreview()
                :_buildCheckOverview2(),
          )

      ),
      bottomNavigationBar: _buildNavigationBar2(),
    );
  }
}
