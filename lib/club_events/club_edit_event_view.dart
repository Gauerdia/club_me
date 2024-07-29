import 'package:club_me/models/event.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/custom_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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

  bool genreScreenActive = false;

  bool dateUnfold = false;
  bool djUnfold = false;
  bool titleUnfold = false;
  bool priceUnfold = false;
  bool genresUnfold = false;
  bool descriptionUnfold = false;

  double originalFoldHeightFactor = 0.08;

  double titleTileHeightFactor = 0.08;
  double djTileHeightFactor = 0.08;
  double dateTileHeightFactor = 0.08;
  double priceTileHeightFactor = 0.08;
  double descriptionTileHeightFactor = 0.08;
  double genreTileHeightFactor = 0.08;

  List<String> musicGenresChosen = [];
  List<String> musicGenresOffer = [
    "90s", "Techno", "Rock", "EDM", "80s", "Metal", "Pop"
  ];
  List<String> musicGenresToCompare = [
    "90s", "Techno", "Rock", "EDM", "80s", "Metal", "Pop"
  ];


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
                onPressed: (){
                  leavePage();
                },
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
                child: Text(
                  genreScreenActive ? "Zurück!" : "Abschließen!",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              onTap: () => {
                if(genreScreenActive){
                  setState(() {
                    genreScreenActive = false;
                  })
                }else{
                  finishUpdateEvent()
                }
              },
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

            _buildGenresTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            _buildDescriptionTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.1,
            ),


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

  // MISC
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

      eventMarketingFileName: "",
      eventMarketingCreatedAt: null,

      priorityScore: stateProvider.clubMeEvent.getPriorityScore()
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
      body: genreScreenActive ?  _buildCheckForMusicGenres() :_buildMainView(),
      bottomNavigationBar: _buildNavBar(),
    );
  }
}
