import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:club_me/models/event.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_two_buttons_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../models/genres_to_display.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/fetched_content_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/dialogs/title_content_and_button_dialog.dart';
import '../../utils/utils.dart';

class ClubEditEventView extends StatefulWidget {
  const ClubEditEventView({super.key});

  @override
  State<ClubEditEventView> createState() => _ClubEditEventViewState();
}

class _ClubEditEventViewState extends State<ClubEditEventView> {

  String headline = "Event bearbeiten";

  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  final SupabaseService _supabaseService = SupabaseService();

  // FORM VALUES

  int selectedFirstHour = 0;
  int selectedSecondMinute = 0;

  List<String> minuteValuesToChoose = [
    "0", "15", "30", "59"
  ];

  bool isUploading = false;
  bool isDateSelected = false;
  bool firstElementChanged = false;
  bool secondElementChanged = false;
  bool showMarketingContent = false;
  bool marketingContentAlreadyExists = false;

  late DateTime newSelectedDate;

  String eventMusicGenresString = "";

  List<String> musicGenresOffer = [];
  List<String> musicGenresChosen = [];
  List<String> musicGenresToDisplay = [];

  late TextEditingController _eventDJController;
  late TextEditingController _eventTitleController;
  late TextEditingController _eventPriceController;
  late TextEditingController _eventTicketLinkController;
  late TextEditingController _eventDescriptionController;
  late FixedExtentScrollController _isRepeatedController;

  late FixedExtentScrollController _selectedClosingHourController;
  late FixedExtentScrollController _selectedClosingMinuteController;
  late FixedExtentScrollController _selectedStartingHourController;
  late FixedExtentScrollController _selectedStartingMinuteController;

  bool isFromTemplate = false;
  bool errorInFileUpload = false;
  bool errorInEventUpload = false;

  int isRepeated = 0;
  int isTemplate = 0;
  int isRepeatedIndex = 0;
  List<String> repetitionAnswers = [
    "Wöchentlich", "Zweiwöchentlich"
  ];


  int selectedStartingHour = TimeOfDay.now().hour;
  int selectedStartingMinute = TimeOfDay.now().minute;

  int selectedClosingHour = 0;
  int selectedClosingMinute = 0;

  bool timePickEndActive = false;

  File? file;
  String fileExtension = "";
  bool isImage = false;
  bool isVideo = false;

  // 0: no content, 1: image, 2: video
  int contentType = 0;
  ChewieController? _chewieController;
  VideoPlayerController? _controller;

  bool pickGenreIsActive = false;
  bool pickHourAndMinuteIsActive = false;

  String contentFileName = "";
  String pickedFileNameToDisplay = "";

  double distanceBetweenTitleAndTextField = 10;

  bool closingTimeWasChanged = false;


  // INIT
  @override
  void initState(){
    super.initState();
    initControllers();
  }
  void initControllers(){

    stateProvider = Provider.of<StateProvider>(context, listen:  false);
    final tempCurrentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen: false);

    for(var element in Utils.genreListForCreating){
      musicGenresOffer.add(element);
    }

    processGenres(tempCurrentAndLikedElementsProvider);

    _eventTitleController = TextEditingController(
        text:tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventTitle());
    _eventDJController = TextEditingController(
        text:  tempCurrentAndLikedElementsProvider.currentClubMeEvent.getDjName());
    _eventPriceController = TextEditingController(
        text: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventPrice().toString());
    _eventDescriptionController = TextEditingController(
        text: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDescription());
    _eventTicketLinkController = TextEditingController(
        text: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getTicketLink()
    );

    newSelectedDate = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate();

    selectedStartingHour = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate().hour;
    selectedStartingMinute = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate().minute;
    _selectedStartingHourController = FixedExtentScrollController(
        initialItem: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate().hour
    );
    _selectedStartingMinuteController = FixedExtentScrollController(
        initialItem: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventDate().minute
    );

    // CLOSING DATE
    if(tempCurrentAndLikedElementsProvider.currentClubMeEvent.getClosingDate() != null){
      _selectedClosingHourController = FixedExtentScrollController(
          initialItem: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getClosingDate()!.hour
      );
      _selectedClosingMinuteController = FixedExtentScrollController(
          initialItem: tempCurrentAndLikedElementsProvider.currentClubMeEvent.getClosingDate()!.minute
      );
      selectedClosingMinute = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getClosingDate()!.minute;
      selectedClosingHour = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getClosingDate()!.hour;
      closingTimeWasChanged = true;
    }else{
      _selectedClosingHourController = FixedExtentScrollController(
          initialItem: selectedClosingHour
      );
      _selectedClosingMinuteController = FixedExtentScrollController(
          initialItem: selectedClosingMinute
      );
    }

    // EVENT MARKETING FILE
    if(tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName().isNotEmpty){
      marketingContentAlreadyExists = true;
      pickedFileNameToDisplay = tempCurrentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName();
    }

    // REPETITION
    if(tempCurrentAndLikedElementsProvider.currentClubMeEvent.getIsRepeatedDays() != 0){
      isRepeated = 1;
      switch(tempCurrentAndLikedElementsProvider.currentClubMeEvent.getIsRepeatedDays()){
        case(7): isRepeatedIndex = 0;break;
        case(14): isRepeatedIndex = 1; break;
      }
    }

    _isRepeatedController = FixedExtentScrollController(
      initialItem: isRepeatedIndex
    );



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
                  onPressed: () => clickEventClose()
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
  Widget _buildNavigationBar(){


    return

      // Displaying either an image or a video?
      (isVideo || isImage) ? Container(
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
              onTap: () => clickEventDeselectContent(),
            ),
            GestureDetector(
              child: Text(
                "Übernehmen",
                style: customStyleClass.getFontStyle3BoldPrimeColor(),
              ),
              onTap: () => clickEventSelectContent(),
            ),
          ],
        ),
      ),
    ):

    // No image nor video?
    Container(
      width: screenWidth,
      height: 80,
      alignment: Alignment.centerRight,
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
      child:
      // Currently uploading?
      isUploading ?
      const CircularProgressIndicator() :

      // Waiting for request to upload
      GestureDetector(
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
  Widget _buildSwitchBetweenImageVideoAndForm(){
    return SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Center(
          child: isImage ?
          _buildImagePreview()
              : isVideo ?
          _buildVideoPreview():
          _buildEditEventForm(),
        )
    );
  }
  Widget _buildEditEventForm(){

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

                      // Text: headline
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
                            top: Utils.creationScreensDistanceBetweenTitleAndTextField
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

                      // Text: DJ
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
                          width: screenWidth*0.9,
                          padding:  EdgeInsets.only(
                              top: Utils.creationScreensDistanceBetweenTitleAndTextField
                          ),
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

                      // Row: Datepicker
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
                                          closingTimeWasChanged ?
                                          formatSelectedHourAndMinute(selectedClosingHour, selectedClosingMinute):
                                            "--.--",
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
                        width: screenWidth*0.9,
                        padding:  EdgeInsets.only(
                            top: Utils.creationScreensDistanceBetweenTitleAndTextField
                        ),
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
                                // onTap: () => removeGenresFromList(genre),
                              ),
                            IconButton(
                                onPressed: () => showDialogToAddGenres(),
                                icon: Icon(
                                  musicGenresChosen.isEmpty ? Icons.add : Icons.edit,
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
                      if(file != null || marketingContentAlreadyExists)
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

                              Flexible(
                                  child: InkWell(
                                      child:Text(
                                        pickedFileNameToDisplay,
                                        textAlign: TextAlign.center,
                                        style: customStyleClass.getFontStyle3(),
                                      ),
                                    onTap: () => clickEventShowContent(),
                                  ),
                              ),
                              IconButton(
                                  onPressed: () => setState(() {file = null;marketingContentAlreadyExists = false;}),
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
                            top: Utils.creationScreensDistanceBetweenTitleAndTextField
                        ),
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
                        height: screenHeight*0.1,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // ToggleSwitch: IsRepeated
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

                            // Cupertinopicker: When isRepeated is toggled
                            if(isRepeated != 0)
                              SizedBox(
                                width: screenWidth*0.4,
                                child: CupertinoPicker(
                                    scrollController: _isRepeatedController,
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
                          child: SizedBox(
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
              _buildPickHourAndMinuteScreen(),

            // window to pick genres
            if(pickGenreIsActive)
              _buildPickGenresScreen()


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
  Widget _buildPickGenresScreen(){
    return Container(
      width: screenWidth,
      height: screenHeight,
      color: customStyleClass.backgroundColorMain,
      padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20
      ),
      child: SingleChildScrollView(
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
                Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Ausgewählte Musikrichtungen",
                        style: customStyleClass.getFontStyle4Bold(),
                      ),
                    ),

                    if(musicGenresChosen.isNotEmpty)
                      Container(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          child: Icon(
                            Icons.info,
                            color: customStyleClass.primeColor,
                          ),
                          onTap: () =>clickEventInfoFromChosenList(),
                        ),
                      )
                  ],
                ),

                // Wrap: Chosen genres
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10
                  ),
                  child: Wrap(
                    children: [
                      for(var element in musicGenresChosen)
                        _buildChosenGenreTile(element)
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

            SizedBox(
              height: screenHeight*0.15,
            )

          ],
        ),
      ),
    );
  }
  Widget _buildPickHourAndMinuteScreen(){
    return  Center(
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
                        _selectedClosingHourController :
                        _selectedStartingHourController,
                        itemExtent: 50,
                        onSelectedItemChanged: (int index){
                          setState(() {
                            if(timePickEndActive){
                              selectedClosingHour = index;
                              closingTimeWasChanged = true;
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
                        scrollController: timePickEndActive? _selectedClosingMinuteController : _selectedStartingMinuteController,
                        itemExtent: 50,
                        onSelectedItemChanged: (int index){
                          setState(() {
                            if(timePickEndActive){
                              selectedClosingMinute = int.parse(minuteValuesToChoose[index]);
                              closingTimeWasChanged = true;
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
    );
  }
  Widget _buildChosenGenreTile(String genreToDisplay){

    var index = musicGenresChosen.indexWhere((element) => element == genreToDisplay);

    return Card(
      color: customStyleClass.backgroundColorEventTile,
      child: ListTile(
        title: Text(
          genreToDisplay,
          style: customStyleClass.getFontStyle3BoldPrimeColor(),
        ),
        subtitle: Text(
          musicGenresToDisplay[index],
          style: customStyleClass.getFontStyle5(),
        ),
        trailing: Wrap(
          children: [
            InkWell(
              child: Icon(
                Icons.edit,
                color: customStyleClass.primeColor,
              ),
              onTap: () => clickEventEditGenreFromChosenList(genreToDisplay),
            ),
            InkWell(
              child: Icon(
                Icons.delete,
                color: customStyleClass.primeColor,
              ),
              onTap: () => clickEventRemoveGenreFromChosenList(genreToDisplay),
            )
          ],
        ),
      ),
    );
  }
  TitleAndContentDialog _buildErrorDialog(){
    return TitleAndContentDialog(
        titleToDisplay: "Fehler aufgetreten", contentToDisplay: "Verzeihung, es ist ein Fehler aufgetreten.");
  }


  // CLICK EVENTS
  void clickEventClose(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleContentAndTwoButtonsDialog(
              titleToDisplay: "Abbrechen",
              contentToDisplay: "Bist du sicher, dass du abbrechen möchtest?",
              firstButtonToDisplay: TextButton(
                child: Text(
                  "Zurück",
                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              secondButtonToDisplay: TextButton(
                child: Text(
                  "Ja",
                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                ),
                onPressed: () => resetAndGoBackToEvents(),
              )
          );
        }
    );
  }
  void clickEventChooseContent() async{

    // Launch filePicker and wait for the user to pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true,
        allowMultiple: false,
        type: FileType.media,
    );

    // Once a file is picked, proceed
    if (result != null) {

      file = File(result.files.single.path!);
      PlatformFile pFile = result.files.first;
      String mimeStr = lookupMimeType(file!.path)!;
      var fileType = mimeStr.split("/");
      fileExtension = pFile.extension.toString();

      pickedFileNameToDisplay = result.files.single.name;

      // We need to set different values depending if it's an image or video
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
  void clickEventUpdateEvent(){
    setState(() {
      isUploading = true;
      finishUpdateEvent();
    });
  }
  void resetAndGoBackToEvents(){
    stateProvider.resetCurrentEventTemplate();
    Navigator.pop(context);
    Navigator.pop(context);
  }
  void clickEventInfoFromChosenList(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleAndContentDialog(
            titleToDisplay: "Information",
            contentToDisplay: "Der türkise Titel zeigt die Musikrichtung an, nach der die Nutzer suchen können.\n\n"
                " Die weiße Schrift darunter wird innerhalb der Events angezeigt. Diese kannst du frei anpassen, wenn"
                " du zum Beispiel detailliertere Angaben zu den Musikrichtungen des Events machen möchtest.",
          );
        });
  }
  void clickEventEditGenreFromChosenList(String genreToEdit){

    var index = musicGenresChosen.indexWhere((element) => element == genreToEdit);

    var genreToDisplayController = TextEditingController(
        text: musicGenresToDisplay[index]
    );

    showDialog(
        context: context,
        builder: (BuildContext context){

          return AlertDialog(
            backgroundColor: customStyleClass.backgroundColorMain,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.white)
            ),
            title: Text(
              "Angezeigte Musikrichtung ändern",
              style: customStyleClass.getFontStyle3Bold(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  "Möchtest du den Text anpassen, der als Musikrichtung angezeigt wird?",
                  style: customStyleClass.getFontStyle3(),
                ),

                const SizedBox(
                  height: 30,
                ),

                TextField(
                  autofocus: true,
                  controller:genreToDisplayController,
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
                ),

              ],
            ),
            actions: [
              TextButton(
                  onPressed: (){

                    // If they delete everything, ignore them
                    if(genreToDisplayController.text.isNotEmpty){
                      setState(() {
                        var index = musicGenresChosen.indexWhere((element) => element == genreToEdit);
                        musicGenresToDisplay[index] = genreToDisplayController.text;
                      });
                    }

                    Navigator.pop(context);
                  },
                  child: Text(
                    "Fertig",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  )
              )
            ],
          );
        }
    );
  }
  void clickEventRemoveGenreFromChosenList(String genreToRemove){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleContentAndButtonDialog(
              titleToDisplay: "Abbrechen",
              contentToDisplay: "Bist du sicher, dass du diese Musikrichtung löschen möchtest?",
              buttonToDisplay: TextButton(
                child: Text(
                  "Ja",
                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                ),
                onPressed: (){
                  removeGenresFromList(genreToRemove);
                  Navigator.pop(context);
                },
              )
          );
        }
    );
  }
  void clickEventShowContent() async{

    setState(() {
      showMarketingContent = true;
    });

    String applicationFilesPath = stateProvider.appDocumentsDir.path;
    String marketingFileName = currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName();
    var filePath = '$applicationFilesPath/$marketingFileName';

    var checkIfExists = await File(filePath).exists();


    if(checkIfExists){
      file = File(filePath);
    }else{

      var marketingFile = await _supabaseService.getEventContent(
          currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName()
      );

      file = await File(filePath).writeAsBytes(marketingFile);
    }

    // We can derive the file type from the mime type
    String mimeStr = lookupMimeType(file!.path)!;
    var fileType = mimeStr.split("/");

    if(fileType.contains('image')) {
      isImage = true;
    }else if(fileType.contains('video')){
      isVideo = true;
    }

    setState(() {});
  }
  void clickEventSelectContent() async{

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
  void clickEventDeselectContent(){
    setState(() {
      file = null;
      isImage = false;
      isVideo = false;
      contentType = 0;
      contentFileName = "";
    });
  }


  // LOGIC
  void removeGenresFromList(String genreToRemove){
    setState(() {

      var index = musicGenresChosen.indexWhere((element) => element == genreToRemove);

      musicGenresChosen.removeAt(index);
      musicGenresToDisplay.removeAt(index);

      if(Utils.genreListForCreating.contains(genreToRemove) && !musicGenresOffer.contains(genreToRemove)){
        var index2 = Utils.genreListForCreating.indexWhere((element) => element == genreToRemove);
        musicGenresOffer.insert(index2, genreToRemove);
      }
    });
  }
  void addGenreToChosenGenres(String genreToAdd){
    setState(() {
      musicGenresChosen.add(genreToAdd);
      musicGenresToDisplay.add(genreToAdd);
        musicGenresOffer.remove(genreToAdd);
    });
  }
  void processGenres(CurrentAndLikedElementsProvider tempCurrentAndLikedElementsProvider){

    for(int i=0;i<tempCurrentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres.length;i++){

      musicGenresChosen.add(
          tempCurrentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres[i].filterGenre!);

      musicGenresOffer.remove(
          tempCurrentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres[i].filterGenre!
      );
      musicGenresToDisplay.add(
          tempCurrentAndLikedElementsProvider.currentClubMeEvent.getMusicGenresToDisplay().genres[i].displayGenre!);
    }
  }
  void finishUpdateEvent() async{

    // Start to format the genres
    String musicGenresString = "";
    String musicGenresToDisplayToSave = "";

    // Add the genres to a string
    for(int i = 0; i<musicGenresChosen.length; i++){
      if(musicGenresString == ""){
        musicGenresString = "${musicGenresChosen[i]},";
        musicGenresToDisplayToSave = "${musicGenresToDisplay[i]},";
      }else{
        musicGenresString = "$musicGenresString ${musicGenresChosen[i]},";
        musicGenresToDisplayToSave = "$musicGenresToDisplayToSave ${musicGenresToDisplay[i]},";
      }
    }

    // Cut the last comma
    if (musicGenresString.isNotEmpty) {
      musicGenresString = musicGenresString.substring(0, musicGenresString.length - 1);
    }
    if(musicGenresToDisplayToSave.isNotEmpty){
      musicGenresToDisplayToSave = musicGenresToDisplayToSave.substring(0, musicGenresToDisplayToSave.length - 1);
    }

    // Cut the occasional first comma
    if(musicGenresString.isNotEmpty && musicGenresString[0] == ","){
      musicGenresString = musicGenresString.substring(1, musicGenresString.length);
    }
    if(musicGenresToDisplayToSave.isNotEmpty && musicGenresToDisplayToSave[0] == ","){
      musicGenresToDisplayToSave = musicGenresToDisplayToSave.substring(1, musicGenresToDisplayToSave.length);
    }


    GenresToDisplay genresToDisplay = GenresToDisplay();

    for(int i=0;i<musicGenresToDisplay.length;i++){
      Genres currentGenre = Genres(
          filterGenre: musicGenresChosen[i],
          displayGenre: musicGenresToDisplay[i]
      );
      genresToDisplay.genres.add(currentGenre);
    }


    // Format the date
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
        newSelectedDate.day+1: newSelectedDate.day,
        selectedClosingHour,
        selectedClosingMinute
    );

    // Adjust the ticket link if it lacks crucial parts
    String ticketLinkToSave = "";
    if(_eventTicketLinkController.text.contains("http")){
      ticketLinkToSave = _eventTicketLinkController.text;
    }else{
      if(_eventTicketLinkController.text != ""){
        ticketLinkToSave = "https://${_eventTicketLinkController.text}";
      }
    }

    // Set days to repeat
    int daysToRepeat = 0;
    if(isRepeated != 0){
      switch(isRepeatedIndex){
        case(0): daysToRepeat = 7;break;
        case(1): daysToRepeat = 14;break;
        default: daysToRepeat = 0;break;
      }
    }

    DateTime? eventMarketingCreatedAtToSubmit;
    String contentFileNameToSubmit;

    // There is a file? Create the entries accordingly
    if(file != null){
      eventMarketingCreatedAtToSubmit = DateTime.now();
      contentFileNameToSubmit = contentFileName;
    }
    // No file? Might be, that there is already something online
    else{
      if(!marketingContentAlreadyExists){
        eventMarketingCreatedAtToSubmit = null;
        contentFileNameToSubmit = "";
      }else{
        eventMarketingCreatedAtToSubmit = currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingCreatedAt();
        contentFileNameToSubmit = currentAndLikedElementsProvider.currentClubMeEvent.getEventMarketingFileName();
      }
    }

    // Create new event instance
    ClubMeEvent updatedEvent = ClubMeEvent(

      eventDate: concatenatedDate,
      musicGenres: musicGenresString,
      musicGenresToDisplay: genresToDisplay,
      musicGenresToFilter: musicGenresString,

      djName: _eventDJController.text,
      ticketLink: ticketLinkToSave,
      eventTitle: _eventTitleController.text,
      eventDescription: _eventDescriptionController.text,
      eventPrice: double.parse(_eventPriceController.text.replaceAll(",", ".")),

      eventMarketingCreatedAt: eventMarketingCreatedAtToSubmit,
      eventMarketingFileName: contentFileNameToSubmit,

      isRepeatedDays: isRepeated != 0 ? daysToRepeat : 0,

      eventId: currentAndLikedElementsProvider.currentClubMeEvent.getEventId(),
      clubName: currentAndLikedElementsProvider.currentClubMeEvent.getClubName(),
      bannerImageFileName: currentAndLikedElementsProvider.currentClubMeEvent.getBannerImageFileName(),
      clubId: currentAndLikedElementsProvider.currentClubMeEvent.getClubId(),
      priorityScore: currentAndLikedElementsProvider.currentClubMeEvent.getPriorityScore(),
      openingTimes: userDataProvider.getUserClubOpeningTimes(),

      closingDate: closingTimeWasChanged ? concatenatedClosingDate : null,
      showEventInApp: currentAndLikedElementsProvider.currentClubMeEvent.getShowEventInApp(),
      specialOccasionActive: false,
      specialOccasionIndex: currentAndLikedElementsProvider.currentClubMeEvent.getSpecialOccasionIndex()

    );

    // Toggle switch to avoid double clicks
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
      ).then((value) => {

        // Has the upload been successful?
        _supabaseService.updateCompleteEvent(updatedEvent).then((value){
          if(value == 0){
            fetchedContentProvider.updateSpecificEvent(
                currentAndLikedElementsProvider.currentClubMeEvent.getEventId(),
                updatedEvent
            );
            Navigator.pop(context);
          }else{
            setState(() {isUploading = false;});
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
  void _createChewieController() {
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
    setState(() {pickGenreIsActive = true;});
  }


  // FORMAT
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

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);


    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildSwitchBetweenImageVideoAndForm(),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }
}
