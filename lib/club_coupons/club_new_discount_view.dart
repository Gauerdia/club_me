import 'package:club_me/models/discount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../provider/state_provider.dart';
import '../services/supabase_service.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../shared/custom_text_style.dart';

class ClubNewDiscountView extends StatefulWidget {
  const ClubNewDiscountView({Key? key}) : super(key: key);

  @override
  State<ClubNewDiscountView> createState() => _ClubNewDiscountViewState();
}

class _ClubNewDiscountViewState extends State<ClubNewDiscountView>{

  String headLine = "Neuer Coupon";

  late DateTime newSelectedDate;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenWidth, screenHeight;
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _discountTitleController = TextEditingController();
  final TextEditingController _discountDescriptionController = TextEditingController();
  final TextEditingController _discountNumberOfUsagesController = TextEditingController();
  FixedExtentScrollController _fixedExtentScrollController1 = FixedExtentScrollController();
  FixedExtentScrollController _fixedExtentScrollController2 = FixedExtentScrollController();

  bool isUploading = false;
  bool isDateSelected = false;

  int hasTimeLimit = 0;
  int hasUsageLimit = 0;
  int creationIndex = 0;
  int selectedFirstElement = 0;
  int selectedSecondElement = 0;
  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;
  double discountContainerHeightFactor = 0.52;
  double newDiscountContainerHeightFactor = 0.2;


  // BUILD
  void buildNewDiscount(
      StateProvider stateProvider,
      TextEditingController titleController,
      TextEditingController numberOfUsagesController,
      DateTime discountDate
      )async{

    var uuid = const Uuid();
    var uuidV4 = uuid.v4();

    int numberOfUsageForDb = 0;

    if(hasUsageLimit != 0){
      numberOfUsageForDb = int.parse(numberOfUsagesController.text);
    }

    ClubMeDiscount clubMeDiscount = ClubMeDiscount(
        discountId: uuidV4.toString(),
        clubName: stateProvider.getClubName(),
        discountTitle: titleController.text,
        numberOfUsages: numberOfUsageForDb,
        discountDate: discountDate,
        bannerId: stateProvider.userClub.getEventBannerId(),
        clubId: stateProvider.getClubId(),
        howOftenRedeemed: 0,
        hasTimeLimit: hasTimeLimit == 0? false : true,
        hasUsageLimit: hasUsageLimit == 0? false:true,
        discountDescription: _discountDescriptionController.text
    );

    try{
      await _supabaseService.insertDiscount(clubMeDiscount).then((value){
        if(value == 0){
          stateProvider.addDiscountToFetchedDiscounts(clubMeDiscount);
          stateProvider.sortFetchedDiscounts();
          context.go('/club_coupons');
        }else{
          showModalBottomSheet(
              context: context,
              builder: (BuildContext buildContext){
                return const Text("Sorry, something went wrong");
              }
          );
        }
      });
    }catch(e){
      print("Error in buildNewDiscount: $e");
    }
  }
  Widget _buildCreationStep(double screenHeight, double screenWidth){

    switch(creationIndex){

    // Title
      case(0):
        return _buildCheckForName2(screenHeight, screenWidth);
      case(1):
        return _buildCheckForDate2(screenHeight, screenWidth);
      case(2):
        return _buildCheckForTimeLimit2(screenHeight, screenWidth);
      case(3):
        return _buildCheckForUsageLimit2(screenHeight, screenWidth);
      case(4):
        return _buildCheckForDescription2(screenHeight, screenWidth);
      case(5):
        return _buildFinalOverview2(screenHeight, screenWidth);
      default:
        return Container();

    }
  }
  Widget _buildCheckForName2(double screenHeight, double screenWidth){
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
                  "Wie soll der Coupon heißen?",
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
              height: screenHeight*0.2,
              width: screenWidth*0.8,
              child: TextField(
                autofocus: true,
                controller: _discountTitleController,
                decoration: const InputDecoration(
                  hintText: "z.B. 2 für 1 Mojito",
                  border: OutlineInputBorder(),
                ),
                style: customTextStyle.size3(),
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
  Widget _buildCheckForDate2(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        child: Column(
          children: [

            // Events headline
            Container(
              width: screenWidth,
              // color: Colors.red,
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
                      // Date as Text
                      Text(
                        formatSelectedDate(),
                        style: customTextStyle.size3Bold(),
                      ),
                      // Spacer
                      SizedBox(
                        width: screenWidth*0.02,
                      ),
                      // Calendar icon
                      Icon(
                          Icons.calendar_month_outlined,
                          color: customTextStyle.primeColor,
                          size: screenHeight*stateProvider.getIconSizeFactor()
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
  Widget _buildCheckForTimeLimit2(double screenHeight, double screenWidth){
    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
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
                "Soll der Coupon am Eventtag zeitlich begrenzt werden?",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // toggle yes,no
            SizedBox(
              width: screenWidth*0.8,
              child:  Center(
                child: ToggleSwitch(
                  initialLabelIndex: hasTimeLimit,
                  totalSwitches: 2,
                  activeBgColor: [customTextStyle.primeColor],
                  activeFgColor: Colors.white,
                  inactiveBgColor: const Color(0xff11181f),
                  labels: const [
                    'Nein',
                    'Ja',
                  ],
                  fontSize: screenHeight*stateProvider.getFontSizeFactor3(),
                  minWidth: screenWidth*0.25,
                  onToggle: (index) {
                    setState(() {
                      if(hasTimeLimit == 0){
                        hasTimeLimit = 1;
                      }else{
                        hasTimeLimit = 0;
                      }
                      print('switched to: $index');
                    });
                  },
                ),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // Headline
            hasTimeLimit == 1?Container(
              width: screenWidth,
              // color: Colors.red,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.03,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Bis zu welcher Uhrzeit ist der Coupon gültig?",
                textAlign: TextAlign.center,
                style: customTextStyle.size2Bold(),
              ),
            ):Container(),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            // Dropdown
            hasTimeLimit == 1? SizedBox(
              width: screenWidth*0.8,
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
                              index == 0 ?
                              "00" :
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
            ) :Container(),

            // Spacer
            SizedBox(
              height: screenHeight*0.1,
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForUsageLimit2(double screenHeight, double screenWidth){
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
                "Soll die Anzahl der Nutzungen beschränkt werden?",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // toggle yes,no
            SizedBox(
              width: screenWidth*0.8,
              child:  Center(
                child: ToggleSwitch(
                  initialLabelIndex: hasUsageLimit,
                  totalSwitches: 2,
                  activeBgColor: [customTextStyle.primeColor],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Color(0xff11181f),
                  labels: const [
                    'Nein',
                    'Ja',
                  ],
                  fontSize: screenHeight*stateProvider.getFontSizeFactor3(),
                  minWidth: screenWidth*0.25,
                  onToggle: (index) {
                    setState(() {
                      if(hasUsageLimit == 0){
                        hasUsageLimit = 1;
                      }else{
                        hasUsageLimit = 0;
                      }
                      print('switched to: $index');
                    });
                  },
                ),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // Headline
            hasUsageLimit == 1 ?
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Wie oft kann der Coupon verwendet werden?",
                textAlign: TextAlign.center,
                style: customTextStyle.size2Bold(),
              ),
            ) :Container(),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            // Textfield
            hasUsageLimit == 1 ?
            SizedBox(
              width: screenWidth*0.4,
              child: TextField(
                  textAlign: TextAlign.center,
                  autofocus: true,
                  maxLength: 3,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder()
                  ),
                  controller: _discountNumberOfUsagesController,
                  style: customTextStyle.sizeNumberFieldItem()
              ),
            ):Container(),

            // Spacer
            SizedBox(
              height: screenHeight*0.4,
            )

          ],
        ),
      ),
    );
  }
  Widget _buildCheckForDescription2(double screenHeight, double screenWidth){
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
                "Beschreibe dein Event mit ein paar Worten!",
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
              child: TextField(
                autofocus: true,
                controller: _discountDescriptionController,
                keyboardType:  TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "An diesem Abend werdet ihr die besten DJs..."
                ),
                maxLength: 300,
                style: customTextStyle.size4(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.01,
            ),

            // 'Close' button
            // Container(
            //   width: screenWidth*0.8,
            //   alignment: Alignment.bottomRight,
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(
            //         vertical: screenHeight*0.01,
            //         horizontal: screenWidth*0.01
            //     ),
            //     child: GestureDetector(
            //       child: Container(
            //         padding: EdgeInsets.symmetric(
            //             horizontal: screenWidth*0.035,
            //             vertical: screenHeight*0.02
            //         ),
            //         decoration: BoxDecoration(
            //           borderRadius: const BorderRadius.all(
            //               Radius.circular(10)
            //           ),
            //           gradient: LinearGradient(
            //               colors: [
            //                 primeColorDark,
            //                 primeColor,
            //               ],
            //               begin: Alignment.topLeft,
            //               end: Alignment.bottomRight,
            //               stops: [0.2, 0.9]
            //           ),
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black54,
            //               spreadRadius: 1,
            //               blurRadius: 7,
            //               offset: Offset(3, 3), // changes position of shadow
            //             ),
            //           ],
            //         ),
            //         child: Text(
            //           "Fertig",
            //           style: customTextStyle.size5Bold(),
            //         ),
            //       ),
            //       onTap: ()=> FocusScope.of(context).unfocus(),
            //     ),
            //   ),
            // ),

            // Spacer
            SizedBox(
              height: screenHeight*0.45,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFinalOverview2(double screenHeight, double screenWidth){

    _fixedExtentScrollController1 = FixedExtentScrollController(initialItem: selectedFirstElement);
    _fixedExtentScrollController2 = FixedExtentScrollController(initialItem: selectedSecondElement);

    return SizedBox(
      height: screenHeight,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [

            // Headline 'Please check if everything is fine'
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Überprüfe bitte, ob alles korrekt ist!",
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
                controller: _discountTitleController,
                decoration: const InputDecoration(
                  hintText: "z.B. 2-für-1 Mojitos",
                  label: Text("Eventtitel"),
                  border: OutlineInputBorder(),
                ),
                style: customTextStyle.size4(),
                maxLength: 35,
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.02,
            ),

            // Date and Time text
            Container(
              width: screenWidth*0.8,
              child:Text(
                "Datum",
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
                      // Date as Text
                      Text(
                        newSelectedDate.toString().substring(0,10),
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
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // 'Time limit' headline
            Container(
              width: screenWidth*0.8,
              padding: const EdgeInsets.only(
                // left: screenWidth*0.05,
                // top: screenHeight*0.03
              ),
              child: Text(
                "Zeitlimit",
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

            // toggle yes,no
            Padding(
              padding: EdgeInsets.only(
                  top: screenHeight*0.02
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  // Toggle switch
                  SizedBox(
                    width: screenWidth*0.4,
                    height: screenHeight*0.08,
                    child:  Center(
                      child: ToggleSwitch(
                        initialLabelIndex: hasTimeLimit,
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
                            if(hasTimeLimit == 0){
                              hasTimeLimit = 1;
                            }else{
                              hasTimeLimit = 0;
                            }
                            print('switched to: $index');
                          });
                        },
                      ),
                    ),
                  ),
                  // Dropdown
                  SizedBox(
                    width: screenWidth*0.5,
                    child: hasTimeLimit == 1? SizedBox(
                      child:
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
                                      index == 0 ?
                                      "00" :
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
                    ) :const Row(mainAxisAlignment: MainAxisAlignment.center,children: [],),
                  )
                ],
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // 'Usage limit' text
            SizedBox(
              width: screenWidth*0.8,
              child:Text(
                "Nutzungslimit",
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

            // toggle yes,no
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                // Toggle switch
                SizedBox(
                  width: screenWidth*0.4,
                  height: screenHeight*0.1,
                  child:  Center(
                    child: ToggleSwitch(
                      initialLabelIndex: hasUsageLimit,
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
                          if(hasUsageLimit == 0){
                            hasUsageLimit = 1;
                          }else{
                            hasUsageLimit = 0;
                          }
                          print('switched to: $index');
                        });
                      },
                    ),
                  ),
                ),

                // Textfield
                SizedBox(
                  width: screenWidth*0.2,
                  child: hasUsageLimit == 1 ?
                  SizedBox(
                    // width: screenWidth*0.1,
                    child: TextField(
                        textAlign: TextAlign.center,
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                        controller: _discountNumberOfUsagesController,
                        style: customTextStyle.sizeNumberFieldItem()
                    ),
                  ):Container(),
                )
              ],
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),

            // 'Description' text
            Container(
              width: screenWidth*0.8,
              // color: Colors.red,
              child:Text(
                "Beschreibung",
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

            // 'Description'-Textfield
            SizedBox(
              width: screenWidth*0.8,
              child: TextField(
                controller: _discountDescriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    border: OutlineInputBorder()
                ),
                maxLength: 300,
                style: customTextStyle.size4(),
              ),
            ),

            // 'Close' button
            // Container(
            //   width: screenWidth*0.8,
            //   alignment: Alignment.bottomRight,
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(
            //         vertical: screenHeight*0.01,
            //         // horizontal: screenWidth*0.01
            //     ),
            //     child: GestureDetector(
            //       child: Container(
            //         padding: EdgeInsets.symmetric(
            //             horizontal: screenWidth*0.035,
            //             vertical: screenHeight*0.02
            //         ),
            //         decoration: BoxDecoration(
            //           borderRadius: const BorderRadius.all(
            //               Radius.circular(10)
            //           ),
            //           gradient: LinearGradient(
            //               colors: [
            //                 primeColorDark,
            //                 primeColor,
            //               ],
            //               begin: Alignment.topLeft,
            //               end: Alignment.bottomRight,
            //               stops: [0.2, 0.9]
            //           ),
            //           boxShadow: const [
            //             BoxShadow(
            //               color: Colors.black54,
            //               spreadRadius: 1,
            //               blurRadius: 7,
            //               offset: Offset(3, 3), // changes position of shadow
            //             ),
            //           ],
            //         ),
            //         child: Text(
            //           "Fertig",
            //           style: customTextStyle.size4Bold(),
            //         ),
            //       ),
            //       onTap: ()=> FocusScope.of(context).unfocus(),
            //     ),
            //   ),
            // ),

            // Spacer
            SizedBox(
              height: screenHeight*0.15,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBottomNavigationBar(){
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

          // Main background
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
                      creationIndex == 5 ? "Abschicken!":"Weiter!",
                      style:customTextStyle.size4Bold(),
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
                child: IconButton(
                  icon: const Icon(
                      Icons.clear_rounded
                  ),
                  onPressed: (){
                    switch(stateProvider.pageIndex){
                      case(2): context.go('/club_coupons');
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
                      ),
                    ],
                  )
              )
            ],
          )
      ),
    );
  }

  // MISC FCTS
  void iterateScreen(){

    if( (creationIndex == 0 && _discountTitleController.text == "") ||
        (creationIndex == 4 && _discountDescriptionController.text == "")
      ){
      showDialogOfMissingValue();
    }else{
      if(creationIndex != 5){
        setState(() {
          creationIndex++;
        });
      }else{
        clickedOnFinalNextButton();
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
  void showDialogOfMissingValue(){
    showDialog(context: context,
        builder: (BuildContext context){
          return const AlertDialog(
              title: Text("Fehlende Werte"),
              content: Text("Bitte füllen Sie die leeren Felder aus, bevor Sie weitergehen.")
          );
        });
  }
  void clickedOnFinalNextButton(){

    late DateTime concatenatedDate;

    // If there is no limit we use the latest hour possible
    if(hasTimeLimit == 0){
      concatenatedDate = DateTime(
          newSelectedDate.year,
          newSelectedDate.month,
          newSelectedDate.day,
          23,
          59
      );
    }else{
      concatenatedDate = DateTime(
          newSelectedDate.year,
          newSelectedDate.month,
          newSelectedDate.day,
          selectedFirstElement,
          selectedSecondElement
      );
    }

    isUploading = true;

    buildNewDiscount(
        stateProvider,
        _discountTitleController,
        _discountNumberOfUsagesController,
      concatenatedDate
    );
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
