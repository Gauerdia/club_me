import 'package:club_me/models/event.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/supabase_service.dart';

class ClubEditEventView extends StatefulWidget {
  const ClubEditEventView({super.key});

  @override
  State<ClubEditEventView> createState() => _ClubEditEventViewState();
}

class _ClubEditEventViewState extends State<ClubEditEventView> {

  final SupabaseService _supabaseService = SupabaseService();

  late DateTime newSelectedDate;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenHeight, screenWidth;

  int selectedFirstElement = 0;
  int selectedSecondElement = 0;

  bool isUploading = false;
  bool isDateSelected = false;
  bool firstElementChanged = false;
  bool secondElementChanged = false;

  String headline = "Event bearbeiten";
  String eventMusicGenresString = "";

  var newDiscountContainerHeightFactor = 0.85;

  List<String> musicGenresChosen = [];
  List<String> musicGenresToCompare = [];

  late TextEditingController _eventTitleController;
  late TextEditingController _eventDJController;
  late TextEditingController _eventPriceController;
  late TextEditingController _eventDescriptionController;
  late FixedExtentScrollController _fixedExtentScrollController1;
  late FixedExtentScrollController _fixedExtentScrollController2;
  late TextEditingController _eventMusicGenresController = TextEditingController();


  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      title: SizedBox(
        width: screenWidth,
        child: Stack(
          children: [

            // Iconbutton
            Container(
              alignment: Alignment.centerLeft,
              height: 50,
              child: IconButton(
                icon: const Icon(
                    Icons.clear_rounded
                ),
                onPressed: () => leavePage(),
              ),
            ),

            // Headline text
            SizedBox(
              width: screenWidth,
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    headline,
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
  Widget _buildNavBar(){
    return Container(
        height: screenHeight*0.1,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30)
            ),
            border: Border(
                top: BorderSide(color: Colors.grey)
            ),
            color: Color(0xff11181f)
        ),
        child: Align(
          // alignment: Alignment.center,
          child: isUploading?
          const Center(
            child: CircularProgressIndicator(),
          ):

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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(3, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: const Text(
                  "Abschließen!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              onTap: () => finishUpdateEvent(),
            ),
          )

        )
    );
  }
  Widget _buildMainView(){
    return Container(
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

            // 'DJ'-text
            Container(
              width: screenWidth*0.8,
              child:Text(
                "DJs",
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

            // 'DJs' - TextField
            Container(
              width: screenWidth*0.8,
              child: TextField(
                controller: _eventDJController,
                decoration: const InputDecoration(
                    hintText: "z.B. DJ Khaleed",
                    label: Text("DJ-Namen"),
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
                        formatSelectedDate(),
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
                            firstElementChanged = true;
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
                            secondElementChanged = true;
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
                              // if(musicGenresToCompare.contains(item)){
                              //   // musicGenresOffer.add(item);
                              // }
                              musicGenresChosen.remove(item);
                              // eventMusicGenresString.replaceFirst("$item,", "");
                            });
                          },
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),

            // Textfield + icon
            Container(
                padding: EdgeInsets.only(
                    bottom: screenHeight*0.025,
                  left: screenWidth*0.02
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
                              musicGenresChosen.add(_eventMusicGenresController.text);
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


  // MISC
  void leavePage(){
    Navigator.pop(context);
  }
  void processGenres(){

    String genresString = stateProvider.clubMeEvent.getMusicGenres();

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
  void finishUpdateEvent() async{

    String musicGenresString = "";
    int firstElementToSave = 0;
    int secondElementToSave = 0;

    if(!firstElementChanged){
      firstElementToSave = stateProvider.clubMeEvent.getEventDate().hour;
    }else{
      firstElementToSave = selectedFirstElement;
    }

    if(!secondElementChanged){
      secondElementToSave = stateProvider.clubMeEvent.getEventDate().minute;
    }else{
      secondElementToSave = selectedSecondElement;
    }

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
        firstElementToSave,
        secondElementToSave
    );

    ClubMeEvent updatedEvent = ClubMeEvent(
        eventId: stateProvider.clubMeEvent.getEventId(),
        eventTitle: _eventTitleController.text,
        clubName: stateProvider.clubMeEvent.getClubName(),
        djName: _eventDJController.text,
        eventDate: concatenatedDate,
        eventPrice: double.parse(_eventPriceController.text.replaceAll(",", ".")),
        bannerId: stateProvider.clubMeEvent.getBannerId(),
        eventDescription: _eventDescriptionController.text,
        musicGenres: musicGenresString,
        clubId: stateProvider.clubMeEvent.getClubId(),

      storyId: "",
      storyCreatedAt: null
    );

    setState(() {
      isUploading = true;
    });

    _supabaseService.updateCompleteEvent(updatedEvent).then((value){
      if(value == 0){
        stateProvider.updateSpecificEvent(stateProvider.clubMeEvent.getEventId(), updatedEvent);
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


  @override
  void initState(){
    super.initState();
    stateProvider = Provider.of<StateProvider>(context, listen:  false);

    processGenres();
    newSelectedDate = stateProvider.clubMeEvent.getEventDate();
    _eventTitleController = TextEditingController(text:stateProvider.clubMeEvent.getEventTitle());
    _eventDJController = TextEditingController(text:  stateProvider.clubMeEvent.getDjName());
    _eventPriceController = TextEditingController(text: stateProvider.clubMeEvent.getEventPrice().toString());
    _eventDescriptionController = TextEditingController(text: stateProvider.clubMeEvent.getEventDescription());
   _fixedExtentScrollController1 = FixedExtentScrollController(initialItem: stateProvider.clubMeEvent.getEventDate().hour);
    _fixedExtentScrollController2 = FixedExtentScrollController(initialItem: stateProvider.clubMeEvent.getEventDate().minute);

  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    customTextStyle = CustomTextStyle(context: context);


    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildMainView(),
      bottomNavigationBar: _buildNavBar(),
    );
  }
}
