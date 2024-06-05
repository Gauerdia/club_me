import 'package:club_me/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../provider/state_provider.dart';
import '../../services/supabase_service.dart';
import 'dart:math' as math;

class ClubNewEventView extends StatefulWidget {
  const ClubNewEventView({Key? key}) : super(key: key);

  @override
  State<ClubNewEventView> createState() => _ClubNewEventViewState();
}

class _ClubNewEventViewState extends State<ClubNewEventView>
    with RestorationMixin{

  String headLine = "Neues Event";

  late StateProvider stateProvider;

  final SupabaseService _supabaseService = SupabaseService();

  final TextEditingController _eventMusicGenresController = TextEditingController();
  final TextEditingController _eventDJController = TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventPriceController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();

  bool isUploading = false;

  bool isDateSelected = false;

  double newDiscountContainerHeightFactor = 0.2;
  double discountContainerHeightFactor = 0.52;

  late double screenHeight, screenWidth;

  int creationIndex = 0;

  String eventMusicGenresString = "";

  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  List<String> musicGenresToCompare = [
    "90s", "Techno", "Rock", "EDM", "80s", "Metal", "Pop"
  ];
  List<String> musicGenresOffer = [
    "90s", "Techno", "Rock", "EDM", "80s", "Metal", "Pop"
  ];
  List<String> musicGenresChosen = [];

  final RestorableDateTime _selectedDate =
  RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
  RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      // print("selected Date");
      isDateSelected = true;
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
      BuildContext context,
      Object? arguments,
      ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2024),
          lastDate: DateTime(2026),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
      });
    }
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
  Widget _buildCheckForEventName(double screenHeight, double screenWidth){
    newDiscountContainerHeightFactor = 0.3;
    discountContainerHeightFactor = 0.52;
    return Stack(
      children: [

        Container(
          width: screenWidth*0.91,
          height: screenHeight*(newDiscountContainerHeightFactor+0.004),//0.204,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    Colors.purple.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        Container(
          width: screenWidth*0.91,
          height: screenHeight*newDiscountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    Colors.purple.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // left highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*newDiscountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[900]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*newDiscountContainerHeightFactor,
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
            height: screenHeight*newDiscountContainerHeightFactor,
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
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [
                // Events headline
                Container(
                  width: screenWidth,
                  // color: Colors.red,
                  padding: EdgeInsets.only(
                      left: screenWidth*0.05,
                      top: screenHeight*0.03
                  ),
                  child: const Text(
                    "Wie soll das Event heißen?",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),

                SizedBox(
                  height: screenHeight*0.02,
                ),

                SizedBox(
                  width: screenWidth*0.8,
                  child: TextField(
                    controller: _eventTitleController,

                  ),
                ),

                SizedBox(
                  height: screenHeight*0.02,
                ),
              ],
            ),
          ),
        ),

        // 'Continue'-Button
        Container(
          width: screenWidth*0.9,
          height: screenHeight*newDiscountContainerHeightFactor,
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
                right: screenWidth*0.03,
                bottom: screenHeight*0.02
            ),
            child: GestureDetector(
              child: Container(
                  width: screenWidth*0.3,
                  height: screenHeight*0.08,
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    gradient: LinearGradient(
                        colors: [
                          // Colors.deepPurple, Colors.deepPurpleAccent
                          Colors.purple,
                          Colors.purpleAccent,
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    ),
                    // border: Border.all(
                    //     color: Colors.purpleAccent
                    // )
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Center(
                    child: Text(
                      "Weiter!",
                      style: TextStyle(
                          color: Colors.white,
                          // fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
              ),
              onTap: (){
                setState(() {
                  iterateScreen();
                  FocusScope.of(context).unfocus();
                });
              },
            ),
          ),
        )

      ],
    );
  }
  Widget _buildCheckForEventDate(double screenHeight, double screenWidth){
    newDiscountContainerHeightFactor = 0.3;
    discountContainerHeightFactor = 0.52;
    return Stack(
      children: [

        Container(
          width: screenWidth*0.91,
          height: screenHeight*(newDiscountContainerHeightFactor+0.004),//0.204,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    Colors.purple.withOpacity(0.4)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        Container(
          width: screenWidth*0.91,
          height: screenHeight*newDiscountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[900]!,
                    Colors.purple.withOpacity(0.2)
                  ],
                  stops: const [0.6, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        // left highlight
        Container(
          width: screenWidth*0.89,
          height: screenHeight*newDiscountContainerHeightFactor,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[600]!, Colors.grey[900]!],
                  stops: const [0.1, 0.9]
              ),
              borderRadius: BorderRadius.circular(
                  15
              )
          ),
        ),

        Padding(
            padding: const EdgeInsets.only(
                left:2
            ),
            child: Container(
              width: screenWidth*0.9,
              height: screenHeight*newDiscountContainerHeightFactor,
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
            height: screenHeight*newDiscountContainerHeightFactor,
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
                borderRadius: BorderRadius.circular(
                    15
                )
            ),
            child: Column(
              children: [
                // Events headline
                Container(
                  width: screenWidth,
                  // color: Colors.red,
                  padding: EdgeInsets.only(
                      left: screenWidth*0.05,
                      top: screenHeight*0.03
                  ),
                  child: const Text(
                    "Wann wird es stattfinden?",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),

                SizedBox(
                  height: screenHeight*0.02,
                ),

                // Datepicker
                SizedBox(
                  width: screenWidth*0.6,
                  height: screenHeight*0.07,
                  child: OutlinedButton(
                      onPressed: (){
                        _restorableDatePickerRouteFuture.present();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedDate.value.toString().substring(0,10),
                            style: TextStyle(
                                fontSize: 18
                            ),
                          ),
                          SizedBox(
                            width: screenWidth*0.02,
                          ),
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.purpleAccent,
                          )
                        ],
                      )
                  ),
                ),

                SizedBox(
                  height: screenHeight*0.02,
                ),
              ],
            ),
          ),
        ),

        Container(
          width: screenWidth*0.9,
          height: screenHeight*newDiscountContainerHeightFactor,
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
                right: screenWidth*0.03,
                bottom: screenHeight*0.02
            ),
            child: GestureDetector(
              child: Container(
                  width: screenWidth*0.3,
                  height: screenHeight*0.08,
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    gradient: LinearGradient(
                        colors: [
                          // Colors.deepPurple, Colors.deepPurpleAccent
                          Colors.purple,
                          Colors.purpleAccent,
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
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    ),
                    // border: Border.all(
                    //     color: Colors.purpleAccent
                    // )
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const Center(
                    child: Text(
                      "Weiter!",
                      style: TextStyle(
                          color: Colors.white,
                          // fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
              ),
              onTap: (){
                setState(() {
                  iterateScreen();
                  FocusScope.of(context).unfocus();
                });
              },
            ),
          ),
        )

      ],
    );
  }
  Widget _buildCheckForEventHour(double screenHeight, double screenWidth){
    newDiscountContainerHeightFactor = 0.35;
    discountContainerHeightFactor = 0.52;
    return Container(
      child: Container(
        child: Stack(
          children: [

            Container(
              width: screenWidth*0.91,
              height: screenHeight*(newDiscountContainerHeightFactor+0.004),//0.204,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.4)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Container(
              width: screenWidth*0.91,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.2)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            // left highlight
            Container(
              width: screenWidth*0.89,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(
                    left:2
                ),
                child: Container(
                  width: screenWidth*0.9,
                  height: screenHeight*newDiscountContainerHeightFactor,
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
                height: screenHeight*newDiscountContainerHeightFactor,
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
                    borderRadius: BorderRadius.circular(
                        15
                    )
                ),
                child: Column(
                  children: [
                    // Events headline
                    Container(
                      width: screenWidth,
                      // color: Colors.red,
                      padding: EdgeInsets.only(
                          left: screenWidth*0.05,
                          top: screenHeight*0.03
                      ),
                      child: const Text(
                        "Um wieviel Uhr beginnt das Event?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),

                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // width: screenWidth*0.2,
                          alignment: Alignment.center,
                          child: DropdownButton<int>(
                            value: selectedHour,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedHour = newValue!;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(
                              24,
                                  (int index) {
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text('$index'),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          // width: screenWidth*0.2,
                          alignment: Alignment.center,
                          child: DropdownButton<int>(
                            value: selectedMinute,
                            onChanged: (int? newValue) {
                              setState(() {
                                selectedMinute = newValue!;
                              });
                            },
                            items: List<DropdownMenuItem<int>>.generate(
                              60,
                                  (int index) {
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text('$index'),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                  ],
                ),
              ),
            ),

            Container(
              width: screenWidth*0.9,
              height: screenHeight*newDiscountContainerHeightFactor,
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                    right: screenWidth*0.03,
                    bottom: screenHeight*0.02
                ),
                child: GestureDetector(
                  child: Container(
                      width: screenWidth*0.3,
                      height: screenHeight*0.08,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        gradient: LinearGradient(
                            colors: [
                              // Colors.deepPurple, Colors.deepPurpleAccent
                              Colors.purple,
                              Colors.purpleAccent,
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        // border: Border.all(
                        //     color: Colors.purpleAccent
                        // )
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const Center(
                        child: Text(
                          "Weiter!",
                          style: TextStyle(
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                  ),
                  onTap: (){
                    setState(() {
                      iterateScreen();
                      FocusScope.of(context).unfocus();
                    });
                  },
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForDJName(double screenHeight, double screenWidth){
    newDiscountContainerHeightFactor = 0.35;
    discountContainerHeightFactor = 0.52;
    return SizedBox(
      child: SizedBox(
        child: Stack(
          children: [
            Container(
              width: screenWidth*0.91,
              height: screenHeight*(newDiscountContainerHeightFactor+0.004),//0.204,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.4)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Container(
              width: screenWidth*0.91,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.2)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            // left highlight
            Container(
              width: screenWidth*0.89,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(
                    left:2
                ),
                child: Container(
                  width: screenWidth*0.9,
                  height: screenHeight*newDiscountContainerHeightFactor,
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
                height: screenHeight*newDiscountContainerHeightFactor,
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
                    borderRadius: BorderRadius.circular(
                        15
                    )
                ),
                child: Column(
                  children: [
                    // Events headline
                    Container(

                      width: screenWidth,
                      // color: Colors.red,
                      padding: EdgeInsets.only(
                          left: screenWidth*0.05,
                          top: screenHeight*0.03
                      ),
                      child: const Text(
                        "Wie heißt der DJ dieses Abends?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                    // TextField
                    SizedBox(
                      width: screenWidth*0.8,
                      child: TextField(
                        controller: _eventDJController,

                      ),
                    ),

                    // Spacer
                    SizedBox(
                      height: screenHeight*0.02,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: screenWidth*0.9,
              height: screenHeight*newDiscountContainerHeightFactor,
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                    right: screenWidth*0.03,
                    bottom: screenHeight*0.02
                ),
                child: GestureDetector(
                  child: Container(
                      width: screenWidth*0.3,
                      height: screenHeight*0.08,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        gradient: LinearGradient(
                            colors: [
                              // Colors.deepPurple, Colors.deepPurpleAccent
                              Colors.purple,
                              Colors.purpleAccent,
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        // border: Border.all(
                        //     color: Colors.purpleAccent
                        // )
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const Center(
                        child: Text(
                          "Weiter!",
                          style: TextStyle(
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                  ),
                  onTap: (){
                    setState(() {
                      iterateScreen();
                      FocusScope.of(context).unfocus();
                    });
                  },
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForMusicGenres(double screenHeight, double screenWidth){
    newDiscountContainerHeightFactor = 0.35;
    discountContainerHeightFactor = 0.52;
    return SizedBox(
      child: SizedBox(
        child: Stack(
          children: [

            Container(
              width: screenWidth*0.91,
              height: screenHeight*(newDiscountContainerHeightFactor+0.004),//0.204,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.4)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Container(
              width: screenWidth*0.91,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.2)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            // left highlight
            Container(
              width: screenWidth*0.89,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(
                    left:2
                ),
                child: Container(
                  width: screenWidth*0.9,
                  height: screenHeight*newDiscountContainerHeightFactor,
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
                height: screenHeight*newDiscountContainerHeightFactor,
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
                    borderRadius: BorderRadius.circular(
                        15
                    )
                ),
                child: Column(
                  children: [
                    // Events headline
                    Container(
                      width: screenWidth,
                      // color: Colors.red,
                      padding: EdgeInsets.only(
                          left: screenWidth*0.05,
                          top: screenHeight*0.03
                      ),
                      child: const Text(
                        "Welche Musikgenres werden aufgelegt?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),

                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                    SizedBox(
                      width: screenWidth*0.8,
                      child: TextField(
                        controller: _eventMusicGenresController,
                      ),
                    ),

                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                  ],
                ),
              ),
            ),

            Container(
              width: screenWidth*0.9,
              height: screenHeight*newDiscountContainerHeightFactor,
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                    right: screenWidth*0.03,
                    bottom: screenHeight*0.02
                ),
                child: GestureDetector(
                  child: Container(
                      width: screenWidth*0.3,
                      height: screenHeight*0.08,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        gradient: LinearGradient(
                            colors: [
                              // Colors.deepPurple, Colors.deepPurpleAccent
                              Colors.purple,
                              Colors.purpleAccent,
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        // border: Border.all(
                        //     color: Colors.purpleAccent
                        // )
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const Center(
                        child: Text(
                          "Weiter!",
                          style: TextStyle(
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                  ),
                  onTap: (){
                    setState(() {
                      iterateScreen();
                      FocusScope.of(context).unfocus();
                    });
                  },
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForEventPrice(double screenHeight, double screenWidth){
    newDiscountContainerHeightFactor = 0.3;
    discountContainerHeightFactor = 0.52;
    return SizedBox(
      child: SizedBox(
        child: Stack(
          children: [

            Container(
              width: screenWidth*0.91,
              height: screenHeight*(newDiscountContainerHeightFactor+0.004),//0.204,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.4)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Container(
              width: screenWidth*0.91,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.2)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            // left highlight
            Container(
              width: screenWidth*0.89,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(
                    left:2
                ),
                child: Container(
                  width: screenWidth*0.9,
                  height: screenHeight*newDiscountContainerHeightFactor,
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
                height: screenHeight*newDiscountContainerHeightFactor,
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
                    borderRadius: BorderRadius.circular(
                        15
                    )
                ),
                child: Column(
                  children: [
                    // Events headline
                    Container(
                      width: screenWidth,
                      // color: Colors.red,
                      padding: EdgeInsets.only(
                          left: screenWidth*0.05,
                          top: screenHeight*0.03
                      ),
                      child: const Text(
                        "Was kostet der Eintritt?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),

                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                    SizedBox(
                      width: screenWidth*0.8,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _eventPriceController,
                      ),
                    ),

                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                  ],
                ),
              ),
            ),

            Container(
              width: screenWidth*0.9,
              height: screenHeight*newDiscountContainerHeightFactor,
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                    right: screenWidth*0.03,
                    bottom: screenHeight*0.02
                ),
                child: GestureDetector(
                  child: Container(
                      width: screenWidth*0.3,
                      height: screenHeight*0.08,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        gradient: LinearGradient(
                            colors: [
                              // Colors.deepPurple, Colors.deepPurpleAccent
                              Colors.purple,
                              Colors.purpleAccent,
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        // border: Border.all(
                        //     color: Colors.purpleAccent
                        // )
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const Center(
                        child: Text(
                          "Weiter!",
                          style: TextStyle(
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                  ),
                  onTap: (){
                    setState(() {
                      iterateScreen();
                      FocusScope.of(context).unfocus();
                    });
                  },
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForEventDescription(double screenHeight, double screenWidth){
    newDiscountContainerHeightFactor = 0.7;
    discountContainerHeightFactor = 0.72;
    return SizedBox(
      child: SizedBox(
        child: Stack(
          children: [
            Container(
              width: screenWidth*0.91,
              height: screenHeight*(newDiscountContainerHeightFactor+0.004),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.4)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Container(
              width: screenWidth*0.91,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.purple.withOpacity(0.2)
                      ],
                      stops: const [0.6, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            // left highlight
            Container(
              width: screenWidth*0.89,
              height: screenHeight*newDiscountContainerHeightFactor,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey[600]!, Colors.grey[900]!],
                      stops: const [0.1, 0.9]
                  ),
                  borderRadius: BorderRadius.circular(
                      15
                  )
              ),
            ),

            Padding(
                padding: const EdgeInsets.only(
                    left:2
                ),
                child: Container(
                  width: screenWidth*0.9,
                  height: screenHeight*newDiscountContainerHeightFactor,
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
                height: screenHeight*newDiscountContainerHeightFactor,
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
                    // Events headline
                    Container(
                      width: screenWidth,
                      // color: Colors.red,
                      padding: EdgeInsets.only(
                          left: screenWidth*0.05,
                          top: screenHeight*0.03
                      ),
                      child: const Text(
                        "Erzähl ein wenig über das Event!",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),

                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                    Container(
                      width: screenWidth*0.8,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: _eventDescriptionController,
                      ),
                    ),

                    SizedBox(
                      height: screenHeight*0.02,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              width: screenWidth*0.9,
              height: screenHeight*newDiscountContainerHeightFactor,
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(
                    right: screenWidth*0.03,
                    bottom: screenHeight*0.02
                ),
                child: GestureDetector(
                  child: Container(
                      width: screenWidth*0.3,
                      height: screenHeight*0.08,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        gradient: LinearGradient(
                            colors: [
                              // Colors.deepPurple, Colors.deepPurpleAccent
                              Colors.purple,
                              Colors.purpleAccent,
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        // border: Border.all(
                        //     color: Colors.purpleAccent
                        // )
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const Center(
                        child: Text(
                          "Weiter!",
                          style: TextStyle(
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                  ),
                  onTap: (){
                    setState(() {
                      iterateScreen();
                      FocusScope.of(context).unfocus();
                    });
                  },
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildCheckForEventName2(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        child: Column(
          children: [

            // Events headline
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                  left: screenWidth*0.05,
                  top: screenHeight*0.03
              ),
              child: const Text(
                "Wie soll das Event heißen?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            SizedBox(
              height: screenHeight*0.05,
            ),

            Container(
              height: screenHeight*0.2,
              width: screenWidth*0.8,
              // color: Colors.red,
              child: TextField(
                controller: _eventTitleController,
                decoration: const InputDecoration(
                    hintText: "z.B. Latino night",
                    border: OutlineInputBorder()
                ),
                maxLength: 35,
              ),
            ),

            SizedBox(
              height: screenHeight*0.1,
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
        child: Column(
          children: [

            // Events headline
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                  left: screenWidth*0.05,
                  top: screenHeight*0.03
              ),
              child: const Text(
                "Wann soll das Event stattfinden?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            SizedBox(
              height: screenHeight*0.05,
            ),

            // Datepicker
            SizedBox(
              width: screenWidth*0.6,
              height: screenHeight*0.07,
              child: OutlinedButton(
                  onPressed: (){
                    _restorableDatePickerRouteFuture.present();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedDate.value.toString().substring(0,10),
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      SizedBox(
                        width: screenWidth*0.02,
                      ),
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.purpleAccent,
                      )
                    ],
                  )
              ),
            ),

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
        child: Column(
          children: [

            // Events headline
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                  left: screenWidth*0.05,
                  top: screenHeight*0.03
              ),
              child: const Text(
                "Um wie viel Uhr soll das Event stattfinden?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            SizedBox(
              height: screenHeight*0.05,
            ),

            // Datepicker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // width: screenWidth*0.2,
                  alignment: Alignment.center,
                  child: DropdownButton<int>(
                    value: selectedHour,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedHour = newValue!;
                      });
                    },
                    items: List<DropdownMenuItem<int>>.generate(
                      24,
                          (int index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text('$index'),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  // width: screenWidth*0.2,
                  alignment: Alignment.center,
                  child: DropdownButton<int>(
                    value: selectedMinute,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedMinute = newValue!;
                      });
                    },
                    items: List<DropdownMenuItem<int>>.generate(
                      60,
                          (int index) {
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text('$index'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

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
        child: Column(
          children: [

            // Events headline
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                  left: screenWidth*0.05,
                  top: screenHeight*0.03
              ),
              child: const Text(
                "Wie heißt/heißen der/die DJ des Events?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            SizedBox(
              height: screenHeight*0.05,
            ),

            Container(
              height: screenHeight*0.2,
              width: screenWidth*0.8,
              child: TextField(
                controller: _eventDJController,
                decoration: const InputDecoration(
                    hintText: "z.B. DJ Zedd",
                    border: OutlineInputBorder()
                ),
                maxLength: 35,
              ),
            ),

            SizedBox(
              height: screenHeight*0.1,
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
        child: Column(
          children: [

            // Events headline
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                  left: screenWidth*0.05,
                  top: screenHeight*0.03
              ),
              child: const Text(
                "Welche Musikgenres werden auf desem Event gespielt?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            SizedBox(
              height: screenHeight*0.05,
            ),

            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                // left: screenWidth*0.05,
                // top: screenHeight*0.03
              ),
              child: const Text(
                "Vorschläge",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            // Tags to use
            musicGenresOffer.isEmpty?
            Container(
              height: screenHeight*0.05,
              child: Center(
                child: Text("Keine Genres mehr verfügbar."),
              ),
            ):Container(
              width: screenWidth,
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
                            decoration: const BoxDecoration(
                              // color: Colors.black45,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.purple,
                                    Colors.purpleAccent,
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
                                  offset: Offset(3, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              item,
                              style: TextStyle(
                                  fontSize: screenHeight*0.015,
                                  fontWeight: FontWeight.bold
                              ),
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

            // Chosen
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                // left: screenWidth*0.05,
                // top: screenHeight*0.03
              ),
              child: const Text(
                "Ausgewählt",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            // Chosen tags
            musicGenresChosen.isEmpty?
            Container(
              height: screenHeight*0.05,
              child: Center(
                child: Text("Noch keine Genres ausgewählt."),
              ),
            ):Container(
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
                            decoration: const BoxDecoration(
                              // color: Colors.black45,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.purple,
                                    Colors.purpleAccent,
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
                              item,
                              style: TextStyle(
                                  fontSize: screenHeight*0.015,
                                  fontWeight: FontWeight.bold
                              ),
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

            // Own Genre
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                // left: screenWidth*0.05,
                  top: screenHeight*0.01,
                  bottom: screenHeight*0.01
              ),
              child: const Text(
                "Eigene Genres hinzufügen",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            // Textfield
            Container(
              // height: screenHeight*0.2,
              // color: Colors.red,
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
                          maxLength: 15,
                        ),
                      ),
                    ),
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
                            size: screenWidth*0.15,
                          )
                      ),
                    )
                  ],
                )
            ),

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
        child: Column(
          children: [

            // Events headline
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                  left: screenWidth*0.05,
                  top: screenHeight*0.03
              ),
              child: const Text(
                "Wie soll der Eintritt des Events kosten (in €)?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // Textfield
            Container(
              // height: screenHeight*0.2,
              width: screenWidth*0.8,
              // color: Colors.red,
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
                // maxLength: 8,
              ),
            ),

            SizedBox(
              height: screenHeight*0.01,
            ),

            SizedBox(
              width: screenWidth*0.8,
              child: const Center(
                child: Text(
                  "Bitte Cent-Beträge mit Punkt statt mit Komma eintragen.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.red
                  ),
                ),
              ),
            ),

            SizedBox(
              height: screenHeight*0.1,
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
        child: Column(
          children: [

            // 'Description' headline
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                  left: screenWidth*0.05,
                  right: screenWidth*0.05,
                  top: screenHeight*0.03
              ),
              child: const Text(
                "Beschreibe dein Event mit ein paar Worten!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
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
                controller: _eventDescriptionController,
                keyboardType:  TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    border: OutlineInputBorder()
                ),
                maxLength: 300,
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.01,
            ),

            // Unfocus - Button
            Container(
              width: screenWidth*0.8,
              alignment: Alignment.bottomRight,
              child: Padding(
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
                    decoration: const BoxDecoration(
                      // color: Colors.black45,
                      borderRadius: BorderRadius.all(
                          Radius.circular(10)
                      ),
                      gradient: LinearGradient(
                          colors: [
                            Colors.purple,
                            Colors.purpleAccent,
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
                      "Fertig",
                      style: TextStyle(
                          fontSize: screenHeight*0.015,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  onTap: ()=> FocusScope.of(context).unfocus(),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckOverview(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        child: Column(
          children: [

            // Events headline
            Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.only(
                  left: screenWidth*0.05,
                  top: screenHeight*0.03,
                  right: screenWidth*0.05
              ),
              child: const Text(
                "Überprüfe, ob alle Angaben korrekt sind!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            SizedBox(
              height: screenHeight*0.05,
            ),

            // 'Title'-text
            Container(
              width: screenWidth*0.8,
              // color: Colors.red,
              child:Text(
                "Titel",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: screenWidth*0.05
                ),
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
              // height: screenHeight*0.2,
              width: screenWidth*0.8,
              // color: Colors.red,
              child: TextField(
                controller: _eventTitleController,
                decoration: const InputDecoration(
                    hintText: "z.B. Latino night",
                    label: Text("Eventtitel"),
                    border: OutlineInputBorder()
                ),
                maxLength: 35,
              ),
            ),

            SizedBox(
              height: screenHeight*0.02,
            ),

            Container(
              width: screenWidth*0.8,
              // color: Colors.red,
              child:Text(
                "Datum und Uhrzeit",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: screenWidth*0.05
                ),
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

            SizedBox(
              height: screenHeight*0.05,
            ),

            // Datepicker
            SizedBox(
              width: screenWidth*0.6,
              height: screenHeight*0.07,
              child: OutlinedButton(
                  onPressed: (){
                    _restorableDatePickerRouteFuture.present();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedDate.value.toString().substring(0,10),
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      SizedBox(
                        width: screenWidth*0.02,
                      ),
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.purpleAccent,
                      )
                    ],
                  )
              ),
            ),

            SizedBox(
              height: screenHeight*0.02,
            ),

            // Starting hour
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: DropdownButton<int>(
                      value: selectedHour,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedHour = newValue!;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(
                        24,
                            (int index) {
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text('$index'),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    // width: screenWidth*0.2,
                    alignment: Alignment.center,
                    child: DropdownButton<int>(
                      value: selectedMinute,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedMinute = newValue!;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(
                        60,
                            (int index) {
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text('$index'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: screenHeight*0.03,
            ),

            SizedBox(
              width: screenWidth*0.8,
              // color: Colors.red,
              child:Text(
                "Genres",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: screenWidth*0.05
                ),
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

            SizedBox(
              height: screenHeight*0.02,
            ),

            musicGenresChosen.isEmpty?
            SizedBox(
              height: screenHeight*0.05,
              child: const Center(
                child: Text("Noch keine Genres ausgewählt."),
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
                            decoration: const BoxDecoration(
                              // color: Colors.black45,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.purple,
                                    Colors.purpleAccent,
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
                              item,
                              style: TextStyle(
                                  fontSize: screenHeight*0.015,
                                  fontWeight: FontWeight.bold
                              ),
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

            SizedBox(
              height: screenHeight*0.02,
            ),

            SizedBox(
              width: screenWidth*0.8,
              // color: Colors.red,
              child:Text(
                "Preis",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: screenWidth*0.05
                ),
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

            SizedBox(
              height: screenHeight*0.03,
            ),

            SizedBox(
              // height: screenHeight*0.2,
              width: screenWidth*0.8,
              // color: Colors.red,
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
                // maxLength: 8,
              ),
            ),

            SizedBox(
              height: screenHeight*0.04,
            ),

            SizedBox(
              width: screenWidth*0.8,
              // color: Colors.red,
              child:Text(
                "Beschreibung",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: screenWidth*0.05
                ),
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

            SizedBox(
              height: screenHeight*0.05,
            ),

            Container(
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
              ),
            ),

            SizedBox(
              height: screenHeight*0.2,
            )

          ],
        ),
      ),
    );
  }

  void createNewEvent(){

    var uuid = const Uuid();
    var uuidV4 = uuid.v4();

    String musicGenresString = "";

    for(String item in musicGenresChosen){
      if(musicGenresString == ""){
        musicGenresString = "$item,";
      }else{
        musicGenresString = "$musicGenresString$item,";
      }
    }

    String selectedHourAsString = "";
    selectedHour.bitLength == 1? selectedHourAsString = "0${selectedHour.toString()}":
    selectedHourAsString = selectedHour.toString();
    String selectedMinuteAsString = "";
    selectedMinute.bitLength == 1 ? selectedMinuteAsString = "0${selectedMinute.toString()}":
    selectedMinuteAsString = selectedMinute.toString();

    DateTime concatenatedDate = DateTime(
        _selectedDate.value.year,
        _selectedDate.value.month,
        _selectedDate.value.day,
        selectedHour,
        selectedMinute
    );

    ClubMeEvent newEvent = ClubMeEvent(
      eventId: uuidV4,
      eventDate: concatenatedDate,
      djName: _eventDJController.text,
      musicGenres: musicGenresString,
      eventTitle: _eventTitleController.text,
      eventStartingHour: "$selectedHourAsString:$selectedMinuteAsString",
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

  void iterateScreen(){

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

  void deiterateScreen(){
    if(creationIndex != 0){
      setState(() {
        creationIndex--;
      });
    }
  }

  @override
  // TODO: implement restorationId
  String? get restorationId => "test";

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      // extendBodyBehindAppBar: true,
      extendBody: true,

      bottomNavigationBar: SizedBox(
        height: screenHeight*0.12,
        child: Stack(
          children: [

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // width: screenWidth*0.89,
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
                      decoration: const BoxDecoration(
                        // color: Colors.black45,
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        gradient: LinearGradient(
                            colors: [
                              Colors.purple,
                              Colors.purpleAccent,
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
                        "Zurück!",
                        style: TextStyle(
                            fontSize: screenHeight*0.02,
                            fontWeight: FontWeight.bold
                        ),
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
                      decoration: const BoxDecoration(
                        // color: Colors.black45,
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        gradient: LinearGradient(
                            colors: [
                              Colors.purple,
                              Colors.purpleAccent,
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
                        style: TextStyle(
                            fontSize: screenHeight*0.02,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    onTap: () => iterateScreen(),
                  )
              ),
            )
          ],

        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(headLine,
          style: const TextStyle(
          ),
        ),
        leading: IconButton(
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


class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange,required this.beforeDecimalRange})
      : assert(decimalRange == null || decimalRange > 0 || beforeDecimalRange == null || beforeDecimalRange > 0 );

  final int decimalRange;
  final int beforeDecimalRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, // unused.
      TextEditingValue newValue,
      ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value;

    if(beforeDecimalRange != null){
      value = newValue.text;

      if(value.contains(".")){
        if(value.split(".")[0].length > beforeDecimalRange){
          truncated = oldValue.text;
          newSelection = oldValue.selection;
        }
      }else{
        if(value.length > beforeDecimalRange){
          truncated = oldValue.text;
          newSelection = oldValue.selection;
        }
      }
    }

    if (decimalRange != null) {
      value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}