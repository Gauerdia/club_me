import 'package:chewie/chewie.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:club_me/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import '../../models/hive_models/3_club_me_event_template.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';
import 'dart:io';

import 'package:path/path.dart' as p;

class ClubNewEventView extends StatefulWidget {
  const ClubNewEventView({Key? key}) : super(key: key);

  @override
  State<ClubNewEventView> createState() => _ClubNewEventViewState();
}

class _ClubNewEventViewState extends State<ClubNewEventView>{

  String headLine = "Neues Event";

  var log = Logger();

  late DateTime newSelectedDate;
  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  late TextEditingController _eventDJController;
  late TextEditingController _eventTitleController;
  late TextEditingController _eventPriceController;
  late TextEditingController _eventMusicGenresController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventTicketLinkController;
  late FixedExtentScrollController _fixedExtentScrollController1;
  late FixedExtentScrollController _fixedExtentScrollController2;

  late FixedExtentScrollController _startingHourController;
  late FixedExtentScrollController _startingMinuteController;
  late FixedExtentScrollController _closingHourController;
  late FixedExtentScrollController _closingMinuteController;

  bool isUploading = false;
  bool isDateSelected = false;
  bool genreScreenActive = false;

  bool errorInFileUpload = false;
  bool errorInEventUpload = false;

  int isRepeatedIndex = 0;

  int isRepeated = 0;
  List<String> repetitionAnswers = [
    "Wöchentlich", "Zweiwöchentlich"
  ];
  List<String> minuteValuesToChoose = [
    "0", "15", "30", "45", "59"
  ];

  int isTemplate = 0;
  int isSupposedToBeTemplate = 0;
  int isSupposedToSaveFile = 0;

  String eventMusicGenresString = "";

  int creationIndex = 0;
  int selectedStartingHour = 22;
  int selectedStartingMinute = 0;
  int selectedClosingHour = 5;
  int selectedClosingMinute = 0;

  double originalFoldHeightFactor = 0.08;

  List<String> musicGenresChosen = [];
  List<String> musicGenresOffer = [];


  File? file;
  String fileExtension = "";
  bool isImage = false;
  bool isVideo = false;
  // 0: no content, 1: image, 2: video
  int contentType = 0;
  String? VIDEO_ON;
  ChewieController? _chewieController;
  VideoPlayerController? _controller;

  bool timePickEndActive = false;
  bool pickHourAndMinuteIsActive = false;
  bool pickGenreIsActive = false;

  String pickedFileNameToDisplay = "";

  String contentFileName = "";

  ByteData? screenshot;

  double distanceBetweenTitleAndTextField = 10;



  @override
  void initState(){
    super.initState();
    initControllers();
  }

  void initControllers(){
    final stateProvider = Provider.of<StateProvider>(context, listen:  false);

    // If there is a current template, we use it
    if (stateProvider.getCurrentEventTemplate() != null){

      // BASE INFO
      _eventDJController = TextEditingController(
          text: stateProvider.getCurrentEventTemplate()!.getDjName()
      );
      _eventTitleController = TextEditingController(
          text: stateProvider.getCurrentEventTemplate()!.getEventTitle()
      );
      _eventDescriptionController = TextEditingController(
          text: stateProvider.getCurrentEventTemplate()!.getEventDescription()
      );
      _eventPriceController = TextEditingController(
          text: stateProvider.getCurrentEventTemplate()!.getEventPrice().toString()
      );
      _eventTicketLinkController = TextEditingController(
        text: stateProvider.getCurrentEventTemplate()!.getEventTitle()
      );
      newSelectedDate = stateProvider.getCurrentEventTemplate()!.getEventDate();
      _eventTicketLinkController = TextEditingController(
          text: stateProvider.getCurrentEventTemplate()!.getTicketLink()
      );

      // GENRES
      _eventMusicGenresController = TextEditingController();
      final split = stateProvider.getCurrentEventTemplate()!.getMusicGenres().split(',');
      for(int i=0; i< split.length; i++){
        musicGenresChosen.add(split[i]);
        musicGenresOffer.removeWhere((element) => element == split[i]);
      }

      // STARTING/CLOSING HOURS
      selectedStartingHour = stateProvider.getCurrentEventTemplate()!.getEventDate().hour;
      selectedStartingMinute = stateProvider.getCurrentEventTemplate()!.getEventDate().minute;
      _startingHourController = FixedExtentScrollController(initialItem: selectedStartingHour);
      _startingMinuteController = FixedExtentScrollController(initialItem: selectedStartingMinute);
      if(stateProvider.getCurrentEventTemplate()!.getClosingDate() != null){
        selectedClosingHour = stateProvider.getCurrentEventTemplate()!.getClosingDate()!.hour;
        selectedClosingMinute = stateProvider.getCurrentEventTemplate()!.getClosingDate()!.minute;
        _closingHourController = FixedExtentScrollController(
            initialItem: stateProvider.getCurrentEventTemplate()!.getClosingDate()!.hour
        );
        _closingMinuteController = FixedExtentScrollController(
            initialItem: stateProvider.getCurrentEventTemplate()!.getClosingDate()!.minute
        );
      }
      else{
        _closingHourController = FixedExtentScrollController(initialItem: 0);
        _closingMinuteController = FixedExtentScrollController(initialItem: 0);
      }


      // REPETITION
      if(stateProvider.getCurrentEventTemplate()?.getIsRepeatedDays() != 0){
        isRepeated = 1;
        switch(stateProvider.getCurrentEventTemplate()?.getIsRepeatedDays()){
          case(7): isRepeatedIndex = 0;break;
          case(14): isRepeatedIndex =1;break;
        }
      }

      // File
      if(stateProvider.getCurrentEventTemplate()!.getFileName() != null){

        file = File(
            "${stateProvider.appDocumentsDir.path}/${stateProvider.getCurrentEventTemplate()!.getFileName()}"
        );

        var fileExtension = p.extension(file!.path);

        var uuid = const Uuid();
        var uuidV4 = uuid.v4();

        pickedFileNameToDisplay = uuidV4;
        contentFileName = "$uuidV4.$fileExtension";
      }

      isTemplate = 1;
      stateProvider.resetCurrentEventTemplate();


    }else{
      _eventDJController = TextEditingController();
      _eventTitleController = TextEditingController();
      _eventPriceController = TextEditingController();
      _eventTicketLinkController = TextEditingController();
      _eventMusicGenresController = TextEditingController();
      _eventDescriptionController = TextEditingController();
      _eventTicketLinkController = TextEditingController();
      _fixedExtentScrollController1 = FixedExtentScrollController(initialItem: 0);
      _fixedExtentScrollController2 = FixedExtentScrollController(initialItem: 0);

      _startingHourController = FixedExtentScrollController(initialItem: selectedStartingHour);
      _startingMinuteController = FixedExtentScrollController(initialItem: selectedStartingMinute);
      _closingHourController = FixedExtentScrollController(initialItem: selectedClosingHour);
      _closingMinuteController = FixedExtentScrollController(initialItem: selectedClosingMinute);

      newSelectedDate = DateTime.now();
    }

    for(var element in Utils.genreListForCreating){
      musicGenresOffer.add(element);
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

            // Icon: Back
            Container(
              alignment: Alignment.centerRight,
              height: 50,
              child: IconButton(
                icon: const Icon(
                    Icons.clear_rounded,
                  color: Colors.white,
                ),
                onPressed: () => clickEventClose()
              ),
            ),

            // Text: Headline
            SizedBox(
              width: screenWidth,
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    headLine,
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
  Widget _buildNavigationBar(){
    return (isVideo || isImage) ?
    Container(
      width: screenWidth,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: customStyleClass.backgroundColorMain,
          border: Border(
              top: BorderSide(
                  color: Colors.grey[900]!
              )
          )
      ),
      padding: const EdgeInsets.only(
        right: 10,
      ),
      child: Container(
        width: screenWidth*0.9,
        height: 80,
        alignment: Alignment.center,
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

    // No image, no video
    Container(
      width: screenWidth,
      height: 80,
      decoration: BoxDecoration(
          color: customStyleClass.backgroundColorMain,
          border: Border(
              top: BorderSide(
                  color: Colors.grey[900]!
              )
          )
      ),
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.only(
          right: 10,
          bottom: 10
      ),
      child: isUploading ? CircularProgressIndicator(color: customStyleClass.primeColor)
      : GestureDetector(
        child: Container(
          height: 80,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Erstellen",
                style: customStyleClass.getFontStyle3BoldPrimeColor(),
              ),
              Icon(
                Icons.arrow_forward_outlined,
                color: customStyleClass.primeColor,
              )
            ],
          ),
        ),
        onTap: () => clickEventCreateEvent(),
      ),
    );
  }
  Widget _buildMainView(){
    return Container(
        color: customStyleClass.backgroundColorMain,
        width: screenWidth,
        height: screenHeight,
        child: Center(
          child: isImage ?
          _buildImagePreview()
              : isVideo ?
          _buildVideoPreview()
              :_buildCheckOverview(),
        )

    );
  }
  Widget _buildCheckOverview(){

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

                      // Text: Please insert
                      SizedBox(
                        width: screenWidth*0.9,
                        child: Text(
                          "Bitte gib die passenden Daten zu deinem Event ein!",
                          textAlign: TextAlign.center,
                          style: customStyleClass.getFontStyle1Bold(),
                        ),
                      ),

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.05,
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
                        padding:  EdgeInsets.only(
                            top: distanceBetweenTitleAndTextField
                        ),
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
                            border: const OutlineInputBorder(),
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
                        child: Container(
                          padding:  EdgeInsets.only(
                              top: distanceBetweenTitleAndTextField
                          ),
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
                      ),

                      // Row: Datepicker,
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

                                  // OutlinedButton
                                  Container(
                                    padding:  EdgeInsets.only(
                                        top: distanceBetweenTitleAndTextField
                                    ),
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
                                            if( pickedDate == null){return;}
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

                          ],
                        ),
                      ),

                      // Row: closing Hours/Minutes
                      Container(

                        width: screenWidth*0.9,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // Hour and minute
                            SizedBox(
                              height: screenHeight*0.12,
                              child: Column(
                                children: [

                                  // Text: Time
                                  SizedBox(
                                    width: screenWidth*0.4,
                                    child: Text(
                                      "Start-Uhrzeit",
                                      style: customStyleClass.getFontStyle3(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),

                                  // OutlinedButton
                                  Container(
                                    padding:  EdgeInsets.only(
                                        top: distanceBetweenTitleAndTextField
                                    ),
                                    width: screenWidth*0.4,
                                    child: OutlinedButton(
                                        onPressed: () => setState(() {
                                          pickHourAndMinuteIsActive = true;
                                        }),
                                        style: OutlinedButton.styleFrom(
                                            minimumSize: Size(screenHeight*0.05,screenHeight*0.07),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            )
                                        ),
                                        child: Text(
                                          formatSelectedHourAndMinute(selectedStartingHour, selectedStartingMinute),
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

                                  // Text: Time
                                  SizedBox(
                                    width: screenWidth*0.4,
                                    child: Text(
                                      "End-Uhrzeit",
                                      style: customStyleClass.getFontStyle3(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),

                                  // OutlinedButton
                                  Container(
                                    padding:  EdgeInsets.only(
                                        top: distanceBetweenTitleAndTextField
                                    ),
                                    width: screenWidth*0.4,
                                    child: OutlinedButton(
                                        onPressed: () => setState(() {
                                          pickHourAndMinuteIsActive = true;
                                          timePickEndActive = true;
                                        }),
                                        style: OutlinedButton.styleFrom(
                                            minimumSize: Size(screenHeight*0.05,screenHeight*0.07),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            )
                                        ),
                                        child: Text(
                                          formatSelectedHourAndMinute(selectedClosingHour, selectedClosingMinute),
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
                      Column(
                        children: [

                          // Text: Price
                          SizedBox(
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
                            child: SizedBox(
                              width: screenWidth*0.3,
                              child: TextField(
                                controller: _eventPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

                      // Text: Description
                      Container(
                        padding: const EdgeInsets.only(
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
                      Container(
                        padding:  EdgeInsets.only(
                            top: distanceBetweenTitleAndTextField
                        ),
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: _eventDescriptionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          cursorColor: customStyleClass.primeColor,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
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
                              SizedBox(
                                width: screenWidth*0.1,
                                child: Icon(
                                  Icons.file_present,
                                  size: 32,
                                  color: customStyleClass.primeColor,
                                ),
                              ),
                              SizedBox(
                                width: screenWidth*0.6,
                                child: Text(
                                  pickedFileNameToDisplay,
                                  style: customStyleClass.getFontStyle3(),
                                ),
                              ),
                              SizedBox(
                                width: screenWidth*0.1,
                                child: InkWell(
                                  child: Icon(
                                    Icons.delete,
                                    size: 32,
                                    color: customStyleClass.primeColor,
                                  ),
                                  onTap: () => setState(() {file = null;}),
                                ),
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
                              onPressed: () => clickEventChooseContent(),
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
                      Container(
                        padding:  EdgeInsets.only(
                            top: distanceBetweenTitleAndTextField
                        ),
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: _eventTicketLinkController,
                          cursorColor: customStyleClass.primeColor,
                          decoration: InputDecoration(
                            hintText: " z.B. https://www.eventbrite.com",
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
                        ),
                      ),

                      // Text: 'Repeat event'
                      Container(
                        padding: const EdgeInsets.only(
                          top: 15
                        ),
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Event wiederholen",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // ToggleSwitch: isRepeated
                      Container(
                        width: screenWidth*0.9,
                        height: screenHeight*0.09,
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
                                  activeFgColor: Colors.white,
                                  inactiveFgColor: Colors.white,
                                  inactiveBgColor: customStyleClass.backgroundColorEventTile,
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

                            // CupertinoPicker
                            if(isRepeated != 0)
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 10
                                ),
                                width: screenWidth*0.4,
                                height: screenHeight*0.1,
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
                      if(isTemplate == 0)
                        Container(
                          width: screenWidth*0.9,
                          alignment: Alignment.centerLeft,
                          padding:  EdgeInsets.only(
                              top: distanceBetweenTitleAndTextField
                          ),
                          child: SizedBox(
                            width: screenWidth*0.45,
                            child: Text(
                              "Als Vorlage speichern",
                              style: customStyleClass.getFontStyle3(),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),

                      // ToggleSwitch isTemplate
                      if(isTemplate == 0)
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
                                initialLabelIndex: isSupposedToBeTemplate,
                                totalSwitches: 2,
                                activeBgColor: [customStyleClass.primeColor],
                                activeFgColor: Colors.white,
                                inactiveFgColor: Colors.white,
                                inactiveBgColor: customStyleClass.backgroundColorEventTile,
                                labels: const [
                                  'Nein',
                                  'Ja',
                                ],
                                onToggle: (index) {
                                  setState(() {
                                    isSupposedToBeTemplate == 0 ? isSupposedToBeTemplate = 1 : isSupposedToBeTemplate = 0;
                                  });
                                },
                              )
                          ),
                        ),
                      ),

                      if(isTemplate == 0 && isSupposedToBeTemplate != 0 && file != null)
                        Container(
                          width: screenWidth*0.9,
                          alignment: Alignment.centerLeft,
                          padding:  EdgeInsets.only(
                              top: distanceBetweenTitleAndTextField
                          ),
                          child: SizedBox(
                            width: screenWidth*0.45,
                            child: Text(
                              "Bild/Video auch als Vorlage speichern",
                              style: customStyleClass.getFontStyle3(),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),

                      if(isTemplate == 0 && isSupposedToBeTemplate != 0 && file != null)
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
                                  initialLabelIndex: isSupposedToSaveFile,
                                  totalSwitches: 2,
                                  activeBgColor: [customStyleClass.primeColor],
                                  activeFgColor: Colors.white,
                                  inactiveFgColor: Colors.white,
                                  inactiveBgColor: customStyleClass.backgroundColorEventTile,
                                  labels: const [
                                    'Nein',
                                    'Ja',
                                  ],
                                  onToggle: (index) {
                                    setState(() {
                                      isSupposedToSaveFile == 0 ? isSupposedToSaveFile = 1 : isSupposedToSaveFile = 0;
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
                    timePickEndActive = false;
                  });
                },
              ),

            // window to ask for hours and minutes
            if(pickHourAndMinuteIsActive)
              Center(
                child: Container(
                  width: screenWidth*0.9,
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

                      // Text: Starting time
                      Text(
                        "Startuhrzeit",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle1(),
                      ),

                      // Text: Please insert
                      Text(
                        "Bitte trage mit Hoch- und Herunterwischen die Uhrzeit ein, zu der das Event beginnt.",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle4(),
                      ),

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.03,
                      ),

                      // Cupertino Picker
                      SizedBox(
                        height: screenHeight*0.1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            SizedBox(
                              width: screenWidth*0.2,
                              child: CupertinoPicker(
                                  scrollController:
                                  timePickEndActive ?
                                  _closingHourController :
                                  _startingHourController,
                                  itemExtent: 50,
                                  onSelectedItemChanged: (int index){
                                    setState(() {
                                      if(timePickEndActive){
                                        selectedClosingHour = index;
                                      }else{
                                        selectedStartingHour = index;
                                      }
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
                                  scrollController: timePickEndActive? _closingMinuteController : _startingMinuteController,
                                  itemExtent: 50,
                                  onSelectedItemChanged: (int index){
                                    setState(() {
                                      if(timePickEndActive){
                                        selectedClosingMinute = int.parse(minuteValuesToChoose[index]);
                                      }else{
                                        selectedStartingMinute = int.parse(minuteValuesToChoose[index]);
                                      }
                                    });
                                  },
                                  children: List<Widget>.generate(5, (index){
                                    return Center(
                                      child: Text(
                                        index == 0
                                            ? "00"
                                            :(minuteValuesToChoose[index]).toString(),
                                        style: customStyleClass.getFontStyle3(),
                                      ),
                                    );
                                  })
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Button: "Finished"
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
                                  borderRadius: const BorderRadius.all(Radius.circular(10))
                              ),
                              child: Text(
                                "Fertig",
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyle4BoldPrimeColor(),
                              ),
                            ),
                            onTap: () => setState(() {pickHourAndMinuteIsActive = false; timePickEndActive = false;}),
                          )
                      ),

                    ],
                  ),
                ),
              ),

            // window to pick genres
            if(pickGenreIsActive)
              Center(
                child: Container(
                  width: screenWidth*0.9,
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

                      // Text: Genres
                      Text(
                        "Musikrichtungen",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle1(),
                      ),

                      // Text: Please insert
                      Text(
                        "Füge Musikrichtungen hinzu oder lösche sie per einfachem Klick!",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle4(),
                      ),

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.03,
                      ),

                      // dynamic elements
                      Column(
                        children: [

                          // Text: Proposed genres
                          Text(
                            "Vorgeschlagene Musikrichtungen",
                            style: customStyleClass.getFontStyle4Bold(),
                          ),

                          // Wrap: Proposed genres
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

                          // Text: Chosen genres
                          Text(
                            "Ausgewählte Musikrichtungen",
                            style: customStyleClass.getFontStyle4Bold(),
                          ),

                          // Wrap: Chosen genres
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

                          // Text: Nothing picked
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

                        ],
                      ),

                      // Button: "Finished"
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
                                  borderRadius: const BorderRadius.all(Radius.circular(10))
                              ),
                              child: Text(
                                "Fertig",
                                textAlign: TextAlign.center,
                                style: customStyleClass.getFontStyle4BoldPrimeColor(),
                              ),
                            ),
                            onTap: () => setState(() {pickGenreIsActive = false;}),
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
  Widget _buildImagePreview(){
    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Image.file(file!),
    );
  }
  Widget _buildVideoPreview(){
    return Padding(
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
    );
  }

  // Clicks
  void removeGenresFromList(String genreToRemove){
    setState(() {
      musicGenresChosen.removeWhere((element) => element == genreToRemove);
      if(Utils.genreListForCreating.contains(genreToRemove) && !musicGenresOffer.contains(genreToRemove)){
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
        musicGenresOffer.remove(genreToAdd);
    });
  }
  void showDialogToAddGenres(){
    setState(() {
      pickGenreIsActive = true;
    });
  }
  void clickEventCreateEvent(){
    if(_eventTitleController.text != "" ){
      setState(() {
        isUploading = true;
        createNewEvent();
      });
    }else{
      showDialogOfMissingValue();
    }
  }
  void clickEventClose(){

    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleContentAndButtonDialog(
              titleToDisplay: "Abbrechen",
              contentToDisplay: "Bist du sicher, dass du abbrechen möchtest?",
              buttonToDisplay: TextButton(
                child: Text(
                  "Ja",
                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                ),
                onPressed: (){
                  stateProvider.resetCurrentEventTemplate();
                  switch(stateProvider.pageIndex){
                    case(0): context.go('/club_events');
                    case(3): context.go('/club_frontpage');
                    default: context.go('/club_frontpage');
                  }
                },
              )
          );
        });
  }
  void clickEventChooseContent() async{

    try{

      FilePickerResult? result = await FilePicker.platform.pickFiles(
          withData: true,
          allowMultiple: false,
        type: FileType.media,
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

    }catch(e){
      _supabaseService.createErrorLog(
        "Error in ClubNewEventView. Fct: clickEventChooseContent. Error: ${e.toString()}"
      );
    }

  }

  // MISC
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
        musicGenresString = "$musicGenresString $item,";
      }
    }
    // Cut the last comma
    if (musicGenresString.isNotEmpty) {
      musicGenresString = musicGenresString.substring(0, musicGenresString.length - 1);
    }

    // Format the starting Date
    DateTime concatenatedDate = DateTime(
        newSelectedDate.year,
        newSelectedDate.month,
        newSelectedDate.day,
        selectedStartingHour,
        selectedStartingMinute
    );

    DateTime concatenatedClosingDate = DateTime(
        newSelectedDate.year,
        newSelectedDate.month,
        selectedStartingHour > selectedClosingHour ?
          newSelectedDate.day+1:
          newSelectedDate.day,
        selectedClosingHour,
        selectedClosingMinute
    );

    // Format the closing date

    String ticketLinkToSave = "";
    if(_eventTicketLinkController.text.contains("http")){
      ticketLinkToSave = _eventTicketLinkController.text;
    }else{
      if(_eventTicketLinkController.text != ""){
        ticketLinkToSave = "https://${_eventTicketLinkController.text}";
      }
    }

    int daysToRepeat = 0;
    if(isRepeated != 0){
      switch(isRepeatedIndex){
        case(0): daysToRepeat = 7;break;
        case(1): daysToRepeat = 14;break;
        default: daysToRepeat = 0;break;
      }
    }

    // Put everything together
    ClubMeEvent newEvent = ClubMeEvent(

      eventId: uuidV4,
      priorityScore: 0.0,
      eventDate: concatenatedDate,
      musicGenres: musicGenresString,
      eventMarketingCreatedAt: file != null ? DateTime.now(): null,
      eventMarketingFileName: file != null ? contentFileName : "",

      djName: _eventDJController.text,
      ticketLink: ticketLinkToSave,
      eventTitle: _eventTitleController.text,
      eventDescription: _eventDescriptionController.text,
      eventPrice: _eventPriceController.text.isNotEmpty ?  double.parse(_eventPriceController.text.replaceAll(",", ".")): 0,

      clubId: userDataProvider.getUserClubId(),
      clubName: userDataProvider.getUserClubName(),
      bannerImageFileName: userDataProvider.getUserClub().getBigLogoFileName(),
      openingTimes: userDataProvider.getUserClubOpeningTimes(),

      isRepeatedDays: isRepeated != 0 ? daysToRepeat : 0,
      closingDate: concatenatedClosingDate

    );

    // Is supposed to be saved as a template?
    if(isSupposedToBeTemplate != 0){
      addEventToTemplates(newEvent);
    }

    // Is there a file to upload?
    if( file != null){
      _supabaseService.insertEventContent(file, contentFileName, uuidV4, stateProvider).then((value) => {

      // Has the upload been successful?
      if(value == 0){
          _supabaseService.insertEvent(newEvent, userDataProvider).then((value) => {
        if(value == 0){
          setState(() {
            currentAndLikedElementsProvider.setCurrentEvent(newEvent);
            fetchedContentProvider.addEventToFetchedEvents(newEvent);
            stateProvider.setAccessedEventDetailFrom(5);
            // stateProvider.resetEventTemplates();
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
      _supabaseService.insertEvent(newEvent, userDataProvider).then((value) => {

        // Has the entry been successfuL?
        if(value == 0){
          setState(() {
            currentAndLikedElementsProvider.setCurrentEvent(newEvent);
            fetchedContentProvider.addEventToFetchedEvents(newEvent);
            stateProvider.setAccessedEventDetailFrom(5);
            // stateProvider.resetEventTemplates();
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
  void addEventToTemplates(ClubMeEvent clubMeEvent) async{

    // Get an unique id for the element
    var uuid = const Uuid();
    var uuidV4 = uuid.v4();

    final String dirPath = stateProvider.appDocumentsDir.path;

    if(isSupposedToSaveFile != 0){
      await File("$dirPath/$contentFileName").writeAsBytes(file!.readAsBytesSync()).then((onValue){
        log.d("ClubNewEvent, Fct: addEventToTemplates: Finished successfully. Path: $dirPath/$contentFileName");
        fetchedContentProvider.addFetchedBannerImageId(contentFileName);
      });
    }

    ClubMeEventTemplate clubMeEventTemplate = ClubMeEventTemplate(
        eventTitle: clubMeEvent.getEventTitle(),
        djName: clubMeEvent.getDjName(),
        eventDate: clubMeEvent.getEventDate(),
        eventPrice: clubMeEvent.getEventPrice(),
        eventDescription: clubMeEvent.getEventDescription(),
        musicGenres: clubMeEvent.getMusicGenres(),
      templateId: uuidV4,
      ticketLink: clubMeEvent.getTicketLink(),
      isRepeatedDays: clubMeEvent.getIsRepeatedDays(),
      closingDate: clubMeEvent.getClosingDate(),
      fileName: isSupposedToSaveFile != 0 ? contentFileName : null
    );

    _hiveService.addClubMeEventTemplate(clubMeEventTemplate).then(
        (response){
          if(response == 0){
            stateProvider.addEventTemplate(clubMeEventTemplate);
          }else{
            showErrorBottomSheet(
              2
            );
          }
        }
    );
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
                  "Verzeihung, etwas ist beim Anlegen des Events schiefgegangen!":
                      errorCode == 2 ?
                          "Verzeihung, beim Anlegen der Vorlage ist etwas schiefgegangen":
                       "Verzeihung, etwas ist beim Datei-Upload schiefgegangen!"
              ),
            ),
          );
        }
    );
  }
  void showDialogOfMissingValue(){
    showDialog(context: context,
        builder: (BuildContext context){
          return TitleAndContentDialog(
              titleToDisplay: "Fehlende Werte",
              contentToDisplay: "Bitte füllen Sie mindestens die folgenden Felder aus, bevor Sie weitergehen: \n\n Titel");
        });
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
  String formatSelectedHourAndMinute(int selectedHour, int selectedMinute){
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


  @override
  Widget build(BuildContext context) {

    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);
    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    userDataProvider = Provider.of<UserDataProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      extendBody: true,

      bottomNavigationBar: _buildNavigationBar(),
      appBar: _buildAppBar(),
      body: _buildMainView(),
    );
  }

}

