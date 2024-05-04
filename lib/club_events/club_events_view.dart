import 'package:club_me/models/event.dart';
import 'package:club_me/shared/custom_bottom_navigation_bar_clubs.dart';
import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:datepicker_dropdown/order_format.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/state_provider.dart';

class ClubEventsView extends StatelessWidget {
  ClubEventsView({Key? key}) : super(key: key);

  String headLine = "Your events";

  final TextEditingController _textEditingControllerClub = TextEditingController(text: "Untergrund");
  final TextEditingController _textEditingControllerTitle = TextEditingController();
  final TextEditingController _textEditingControllerDJName = TextEditingController();
  final TextEditingController _textEditingControllerDescription = TextEditingController();
  final TextEditingController _textEditingControllerPrice = TextEditingController();

  int _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;

  void toggleNewIsActive(){

  }

  @override
  Widget build(BuildContext context) {

    final stateProvider = Provider.of<StateProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

        extendBodyBehindAppBar: true,
        extendBody: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(headLine,
            style: TextStyle(
              // color: Colors.purpleAccent
            ),
          ),

          actions: [
            GestureDetector(
              onTap: () => stateProvider.toggleClubEventViewNewActive(),
              child: Container(
                  width: screenWidth*0.15,
                  height: screenHeight*0.04,
                  decoration: BoxDecoration(
                      color: Color(0xff11181f),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          topLeft: Radius.circular(15)
                      ),
                      border: Border(
                          top: BorderSide(
                              color: stateProvider.clubEventViewNewActive ? Colors.purpleAccent : const Color(0xff11181f)),
                          bottom: BorderSide(
                              color: stateProvider.clubEventViewNewActive ? Colors.purpleAccent : const Color(0xff11181f))
                      )
                  ),
                  child: Center(
                    child: Text(
                      "New",
                      style: TextStyle(
                          color: stateProvider.clubEventViewNewActive ? Colors.purpleAccent : Colors.white
                      ),
                    ),
                  )
              ),
            ),
            GestureDetector(
              onTap: () => stateProvider.toggleClubEventViewNewActive(),
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Container(
                    width: screenWidth*0.15,
                    height: screenHeight*0.04,
                    decoration: BoxDecoration(
                        color: const Color(0xff11181f),
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(15),
                            topRight: Radius.circular(15)
                        ),
                        border: Border(
                            top: BorderSide(
                                color: stateProvider.clubEventViewNewActive ? const Color(0xff11181f) : Colors.purpleAccent
                            ),
                            bottom: BorderSide(
                                color: stateProvider.clubEventViewNewActive ? const Color(0xff11181f) : Colors.purpleAccent
                            )
                        )
                    ),
                    child: Center(
                      child: Text(
                        "Old",
                        style: TextStyle(
                            color: stateProvider.clubEventViewNewActive ? Colors.white : Colors.purpleAccent
                        ),
                      ),
                    )
                ),
              )
            )
          ],

        ),
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
            child: SingleChildScrollView(
                child: stateProvider.clubEventViewNewActive?
                    _buildNewEventView(screenHeight, screenWidth, context, stateProvider)
                    : _buildOldEventView(screenHeight, screenWidth, context, stateProvider)
            )
        )
    );
  }

  Widget _buildNewEventView(double screenHeight, screenWidth, BuildContext context, StateProvider stateProvider){

    return Column(
        children: [

          SizedBox(
            height: screenHeight*0.15,
          ),

          // Events headline
          Container(
            width: screenWidth,
            // color: Colors.red,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                top: screenHeight*0.01
            ),
            child: const Text(
              "Neues Event",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 24
              ),
            ),
          ),

          // White line
          Divider(
            height:10,
            thickness: 1,
            color: Colors.white,
            indent: 20,
            endIndent: 270,
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          // Events headline
          Container(
            width: screenWidth,
            // color: Colors.red,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                top: screenHeight*0.01
            ),
            child: const Text(
              "Titel",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 24
              ),
            ),
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          Container(
            width: screenWidth*0.92,
            child: TextField(
              controller: _textEditingControllerTitle,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Gib deinem Event einen Namen!',
              ),
            ),
          ),


          SizedBox(
            height: screenHeight*0.02,
          ),

          // Events headline
          Container(
            width: screenWidth,
            // color: Colors.red,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                top: screenHeight*0.01
            ),
            child: const Text(
              "Name des Clubs",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 24
              ),
            ),
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          Container(
            width: screenWidth*0.92,
            child: TextField(
              controller: _textEditingControllerClub,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          // Events headline
          Container(
            width: screenWidth,
            // color: Colors.red,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                top: screenHeight*0.01
            ),
            child: const Text(
              "Datum",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 24
              ),
            ),
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          // Dropdowndatepicker
          Container(
            width: screenWidth*0.92,
            child: DropdownDatePicker(
              dateformatorder: OrderFormat.DMY,
              startYear: 2024,
              endYear: 2030,
              textStyle: TextStyle(
                  color: Colors.white
              ),
              onChangedDay: (value) {
                _selectedDay = int.parse(value!);
                print('onChangedDay: $value');
              },
              onChangedMonth: (value) {
                _selectedMonth = int.parse(value!);
                print('onChangedMonth: $value');
              },
              onChangedYear: (value) {
                _selectedYear = int.parse(value!);
                print('onChangedYear: $value');
              },
            ),
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          // Events headline
          Container(
            width: screenWidth,
            // color: Colors.red,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                top: screenHeight*0.01
            ),
            child: const Text(
              "Name des DJs",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 24
              ),
            ),
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          Container(
            width: screenWidth*0.92,
            child: TextField(
              controller: _textEditingControllerDJName,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Wie heißt der DJ?"
              ),
            ),
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          // Events headline
          Container(
            width: screenWidth,
            // color: Colors.red,
            padding: EdgeInsets.only(
                left: screenWidth*0.05,
                top: screenHeight*0.01
            ),
            child: const Text(
              "Beschreibung des Events",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 24
              ),
            ),
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          Container(
            width: screenWidth*0.92,
            // height: screenHeight*0.4,
            child: TextField(
              controller: _textEditingControllerDescription,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Erzähl ein wenig über deine Veranstaltung!",
              ),
            ),
          ),

          SizedBox(
            height: screenHeight*0.02,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                "Eintrittspreis",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 24
                ),
              ),
              SizedBox(
                  width: screenWidth*0.24,
                  child: Row(
                    children: [
                      SizedBox(
                        width: screenWidth*0.18,
                        child: TextField(
                          controller: _textEditingControllerPrice,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24
                          ),
                        ),
                      ),
                      const Text(
                        "€",
                        style: TextStyle(
                            fontSize: 24
                        ),
                      )
                    ],
                  )
              ),
            ],
          ),

          SizedBox(
            height: screenHeight*0.04,
          ),

          // Check it out button
          Padding(
            padding: EdgeInsets.only(right: 7, bottom: 7),
            child: Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.all(
                          Radius.circular(10)
                      ),
                      border: Border.all(
                          color: Colors.purpleAccent
                      )
                  ),
                  padding: EdgeInsets.all(10),
                  child: const Text(
                    "Event erstellen!",
                    style: TextStyle(
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 22
                    ),
                  ),
                ),
                onTap: (){
                  stateProvider.setCurrentEvent(getMockEvent());
                  context.go("/event_details");

                },
              ),
            ),
          ),

          SizedBox(
            height: screenHeight*0.3,
          )

        ]
    );
  }

  ClubMeEvent getMockEvent(){
    return ClubMeEvent(
        title: _textEditingControllerTitle.text,
        clubName: _textEditingControllerClub.text,
        DjName: _textEditingControllerDJName.text,
        date: _selectedDay.toString() + "." + _selectedMonth.toString() + "." + _selectedYear.toString(),
        price: _textEditingControllerPrice.text,
        imagePath: "assets/images/img_6.png",
        description: "Tauch ein in die Nacht und erlebe die ultimative Disco-Party!"
            "Bist du bereit, die Nacht zum Tag zu machen? Dann ist diese Disco genau das Richtige für dich!"
            "Feiere mit uns zu den besten Hits der 70er, 80er und 90er Jahre."
            "Egal ob Discofox, Boogie oder einfach nur Tanzen - hier ist für jeden etwas dabei."
            "Unsere erfahrenen DJs sorgen für eine ausgelassene Stimmung und bringen dich garantiert zum Schwitzen."
            "Lasse dich von den bunten Lichtern und den pulsierenden Beats mitreißen und genieße die unvergessliche Atmosphäre."
            "Ob alleine, mit Freunden oder deinem Partner - hier ist jeder willkommen."
            "Komm vorbei und erlebe eine Nacht voller Spaß, Musik und Tanz!"
            "Dresscode:"
            "Zeige deinen ganz eigenen Style!"
            "Von bunten Outfits bis hin zu klassischen Disco-Looks - alles ist erlaubt.",
        musicGenres: "90s",
        hours: "22:00 - 03:00 Uhr"
    );
  }

  Widget _buildOldEventView(double screenHeight, screenWidth, BuildContext context, StateProvider stateProvider){
    return Column(
      children: [
        SizedBox(
          height: screenHeight*0.15,
        ),

        // Events headline
        Container(
          width: screenWidth,
          // color: Colors.red,
          padding: EdgeInsets.only(
              left: screenWidth*0.05,
              top: screenHeight*0.01
          ),
          child: const Text(
            "Deine vergangenen Events",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 24
            ),
          ),
        ),

        // White line
        Divider(
          height:10,
          thickness: 1,
          color: Colors.white,
          indent: 20,
          endIndent: 270,
        ),

        SizedBox(
          height: screenHeight*0.12,
        ),


        Text(
          "Du hast noch keine Events eingestellt!",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 16
          ),
        ),

      ],
    );
  }

}