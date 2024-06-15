import 'package:club_me/models/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../provider/state_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';
import 'archive/club_new_event_view.dart';

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

  final TextEditingController _eventDJController = TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventPriceController = TextEditingController();
  final TextEditingController _eventMusicGenresController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  FixedExtentScrollController _fixedExtentScrollController1 = FixedExtentScrollController();
  FixedExtentScrollController _fixedExtentScrollController2 = FixedExtentScrollController();

  bool isUploading = false;
  bool isDateSelected = false;

  double discountContainerHeightFactor = 0.52;
  double newDiscountContainerHeightFactor = 0.2;

  String eventMusicGenresString = "";

  int creationIndex = 0;
  int selectedFirstElement = 0;
  int selectedSecondElement = 0;
  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;

  List<String> musicGenresChosen = [];
  List<String> musicGenresOffer = [
    "90s", "Techno", "Rock", "EDM", "80s", "Metal", "Pop"
  ];
  List<String> musicGenresToCompare = [
    "90s", "Techno", "Rock", "EDM", "80s", "Metal", "Pop"
  ];


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


  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      title: SizedBox(
        width: screenWidth,
        child: Stack(
          children: [

            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: IconButton(
                icon: const Icon(
                    Icons.clear_rounded
                ),
                onPressed: (){
                  switch(stateProvider.pageIndex){
                    case(0): context.go('/club_events');
                    case(3): context.go('/club_frontpage');
                    default: context.go('/club_frontpage');
                  }
                },
              ),
            ),

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

          // Left button
          creationIndex != 0 ? Padding(
            padding: EdgeInsets.only(
                left: screenWidth*0.04,
                bottom: screenHeight*0.015
            ),
            child: Align(
                alignment: AlignmentDirectional.bottomStart,
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
                      "Zurück!",
                      style: customTextStyle.size4Bold(),
                    ),
                  ),
                  onTap: () => deiterateScreen(),
                )
            ),
          ): Container(),

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
          ):Padding(
            padding: EdgeInsets.only(
                right: screenWidth*0.04,
                bottom: screenHeight*0.015
            ),
            child: Align(
                alignment: AlignmentDirectional.bottomEnd,
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
                          stops: [0.2, 0.9]
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
                      creationIndex == 7 ? "Abschicken!":"Weiter!",
                      style: customTextStyle.size4Bold(),
                    ),
                  ),
                  onTap: () => iterateScreen(),
                )
            ),
          )
        ],

      ),
    );
  }
  Widget _buildCreationStep(double screenHeight, double screenWidth){

    switch(creationIndex){

      // Title
      case(0):
        return _buildCheckForEventName2(screenHeight, screenWidth);

      // Date
      case(1):
        return _buildCheckForEventDate2(screenHeight, screenWidth);

      //   Hour
      case(2):
        return _buildCheckForEventHour2(screenHeight, screenWidth);

      // DJ Name
      case(3):
        return _buildCheckForDJName2(screenHeight, screenWidth);

      // Music Genres
      case(4):
        return _buildCheckForMusicGenres2(screenHeight, screenWidth);

        // Price
      case(5):
        return _buildCheckForEventPrice2(screenHeight, screenWidth);

        // Description
      case(6):
        return _buildCheckForEventDescription2(screenHeight, screenWidth);
      case(7):
        return _buildCheckOverview(screenHeight, screenWidth);
      default:
        return Container();
    }
  }
  Widget _buildCheckForEventName2(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            // Question headline
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Wie soll das Event heißen?",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Textfield
            SizedBox(
              height: screenHeight*0.2,
              width: screenWidth*0.8,
              child: TextField(
                controller: _eventTitleController,
                decoration: const InputDecoration(
                  hintText: "z.B. Latino night",
                  border: OutlineInputBorder()
                ),
                style: customTextStyle.size3(),
                autofocus: true,
                maxLength: 35,
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.5,
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForEventDate2(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            // Question headline
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Wann soll das Event stattfinden?",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Datepicker
            SizedBox(
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
                      Text(
                        formatSelectedDate(),
                        style: customTextStyle.size3Bold(),
                      ),
                      SizedBox(
                        width: screenWidth*0.02,
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        color: customTextStyle.primeColor,
                        size: screenHeight*stateProvider.getIconSizeFactor(),
                      )
                    ],
                  )
              ),
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
  Widget _buildCheckForEventHour2(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            // Question headline
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Um wie viel Uhr soll das Event stattfinden?",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Dropdown buttons
            Row(
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

            // Spacer
            SizedBox(
              height: screenHeight*0.1,
            )

          ],
        ),
      ),
    );
  }
  Widget  _buildCheckForDJName2(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            // Question headline
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Wie heißt/heißen der/die DJ des Events?",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Textfield
            SizedBox(
              height: screenHeight*0.2,
              width: screenWidth*0.8,
              child: TextField(
                controller: _eventDJController,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: "z.B. DJ Zedd",
                    border: OutlineInputBorder()
                ),
                style:customTextStyle.size3Bold(),
                maxLength: 35,
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.5,
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForMusicGenres2(double screenHeight, double screenWidth){
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
  Widget _buildCheckForEventPrice2(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            // Question headline
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Wie viel soll der Eintritt des Events kosten (in €)?",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Textfield
            SizedBox(
              width: screenWidth*0.8,
              child: TextFormField(
                controller: _eventPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'(^\d*[\.\,]?\d{0,2})')),
                  DecimalTextInputFormatter(decimalRange: 2, beforeDecimalRange: 3)],
                decoration: const InputDecoration(
                    border: OutlineInputBorder()
                ),
                textAlign: TextAlign.center,
                autofocus: true,
                maxLength: 6,
                style: customTextStyle.sizeNumberFieldItem()
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.01,
            ),

            // "Bitte mit Punkt" in red
            SizedBox(
              width: screenWidth*0.8,
              child: Center(
                child: Text(
                  "Bitte Cent-Beträge mit Punkt statt mit Komma eintragen.",
                  textAlign: TextAlign.center,
                  style: customTextStyle.size6Red()
                ),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.5,
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForEventDescription2(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            // 'Description' headline
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Beschreibe dein Event mit ein paar Worten!",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold()
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Textfield
            SizedBox(
              width: screenWidth*0.8,
              child: TextField(
                maxLength: 300,
                maxLines: null,
                autofocus: true,
                style: customTextStyle.size4(),
                controller: _eventDescriptionController,
                keyboardType:  TextInputType.multiline,
                decoration: const InputDecoration(
                    border: OutlineInputBorder()
                ),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.01,
            ),
            // Spacer
            SizedBox(
              height: screenHeight*0.45,
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildCheckOverview(double screenHeight, double screenWidth){

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
                "Überprüfe, ob alle Angaben korrekt sind!",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // 'Title'-text
            Container(
              width: screenWidth*0.8,
              child:Text(
                "Titel",
                textAlign: TextAlign.left,
                style: customTextStyle.size2(),
              ),
            ),

            // White line
            Divider(
              height:10,
              thickness: 1,
              color: Colors.white,
              indent: screenWidth*0.1,
              endIndent: screenWidth*0.8,
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // 'EventTitle' - TextField
            Container(
              width: screenWidth*0.8,
              child: TextField(
                controller: _eventTitleController,
                decoration: const InputDecoration(
                    hintText: "z.B. Latino night",
                    label: Text("Eventtitel"),
                    border: OutlineInputBorder()
                ),
                maxLength: 35,
                style: customTextStyle.size4(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            // Date and time
            SizedBox(
              width: screenWidth*0.8,
              child:Text(
                "Datum und Uhrzeit",
                textAlign: TextAlign.left,
                style: customTextStyle.size2(),
              ),
            ),

            // White line
            Divider(
              height:10,
              thickness: 1,
              color: Colors.white,
              indent: screenWidth*0.1,
              endIndent: screenWidth*0.8,
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Datepicker
            SizedBox(
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
                      Text(
                        newSelectedDate.toString().substring(0,10),
                        style: customTextStyle.size3(),
                      ),
                      SizedBox(
                        width: screenWidth*0.02,
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        color: customTextStyle.primeColor,
                      )
                    ],
                  )
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            // Starting hour
            SizedBox(
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
                        children: List<Widget>.generate(60, (index){
                          return Center(
                            child: Text(
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
                              (index*15).toString(),
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
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // Genres text
            SizedBox(
              width: screenWidth*0.8,
              child:Text(
                "Genres",
                textAlign: TextAlign.left,
                style: customTextStyle.size2()
              ),
            ),

            // White line
            Divider(
              height:10,
              thickness: 1,
              color: Colors.white,
              indent: screenWidth*0.1,
              endIndent: screenWidth*0.8,
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            musicGenresChosen.isEmpty?
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
                left: screenWidth*0.1
              ),
              width: screenWidth,
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
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            // Price text
            SizedBox(
              width: screenWidth*0.8,
              child:Text(
                "Preis",
                textAlign: TextAlign.left,
                style:customTextStyle.size2()
              ),
            ),

            // White line
            Divider(
              height:10,
              thickness: 1,
              color: Colors.white,
              indent: screenWidth*0.1,
              endIndent: screenWidth*0.8,
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // Textfield price
            SizedBox(
              width: screenWidth*0.8,
              child: TextField(
                controller: _eventPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[.0-9]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text;
                    return text.isEmpty
                        ? newValue
                        : double.tryParse(text) == null
                        ? oldValue
                        : newValue;
                  }),
                ], //
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  label: Text("Eintrittspreis"),
                ),
                maxLength: 6,
                style: customTextStyle.sizeNumberFieldItem()
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.04,
            ),

            // Text description
            SizedBox(
              width: screenWidth*0.8,
              child:Text(
                "Beschreibung",
                textAlign: TextAlign.left,
                style: customTextStyle.size2()
              ),
            ),

            // White line
            Divider(
              height:10,
              thickness: 1,
              color: Colors.white,
              indent: screenWidth*0.1,
              endIndent: screenWidth*0.8,
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Textfield description
            SizedBox(
              width: screenWidth*0.8,
              child: TextField(
                controller: _eventDescriptionController,
                keyboardType:  TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: "z.B. Latino night",
                    border: OutlineInputBorder()
                ),
                maxLength: 300,
                style: customTextStyle.size4()
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.2,
            )

          ],
        ),
      ),
    );
  }


  // MISC
  void iterateScreen(){

    if(
    (creationIndex == 0 && _eventTitleController.text == "") ||
        (creationIndex == 3 && _eventDJController.text == "") ||
        (creationIndex == 4 && musicGenresChosen.isEmpty) ||
        (creationIndex == 5 && _eventPriceController.text == "") ||
        (creationIndex == 6 && _eventDescriptionController.text == "")
    ){
      showDialogOfMissingValue();
    }else{
      if(creationIndex != 7){
        setState(() {
          creationIndex++;
        });
      }else{
        setState(() {
          isUploading = true;
        });
        createNewEvent();
      }
    }
  }
  void deiterateScreen(){
    if(creationIndex != 0){
      setState(() {
        creationIndex--;
      });
    }
  }
  void createNewEvent(){

    var uuid = const Uuid();
    var uuidV4 = uuid.v4();

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

    DateTime concatenatedDate = DateTime(
        newSelectedDate.year,
        newSelectedDate.month,
        newSelectedDate.day,
        selectedFirstElement,
        selectedSecondElement
    );

    ClubMeEvent newEvent = ClubMeEvent(
      eventId: uuidV4,
      eventDate: concatenatedDate,
      djName: _eventDJController.text,
      musicGenres: musicGenresString,
      eventTitle: _eventTitleController.text,
      eventStartingHour: "$selectedFirstElement:$selectedSecondElement",
      eventPrice: double.parse(_eventPriceController.text.replaceAll(",", ".")),
      eventDescription: _eventDescriptionController.text,

      clubId: stateProvider.getClubId(),
      clubName: stateProvider.getClubName(),
      bannerId: stateProvider.getUserClubEventBannerId(),
    );

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
          showErrorBottomSheet();
        })
      }
    });

  }
  void showErrorBottomSheet(){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return SizedBox(
            height: screenHeight*0.1,
            child: const Center(
              child: Text("Verzeihung, etwas ist schiefgegangen!"),
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


  @override
  void initState() {
    super.initState();
    newSelectedDate = DateTime.now();
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
              child: _buildCreationStep(screenHeight, screenWidth)
          )

      ),
    );
  }

}

