import 'package:club_me/models/discount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../provider/state_provider.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';

class ClubEditDiscountView extends StatefulWidget {
  const ClubEditDiscountView({Key? key}) : super(key: key);

  @override
  State<ClubEditDiscountView> createState() => _ClubEditDiscountState();
}

class _ClubEditDiscountState extends State<ClubEditDiscountView> {

  String headline = "Coupon bearbeiten";

  final SupabaseService _supabaseService = SupabaseService();

  late int hasTimeLimit;
  late int hasUsageLimit;
  late DateTime newSelectedDate;
  late StateProvider stateProvider;
  late CustomTextStyle customTextStyle;
  late double screenWidth, screenHeight;
  late TextEditingController _discountTitleController;
  late TextEditingController _discountDescriptionController;
  late TextEditingController _discountNumberOfUsagesController;
  late FixedExtentScrollController _fixedExtentScrollController1;
  late FixedExtentScrollController _fixedExtentScrollController2;

  int selectedFirstElement = 0;
  int selectedSecondElement = 0;
  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;

  bool isUploading = false;
  bool initFinished = false;
  bool isDateSelected = false;
  bool firstElementChanged = false;
  bool secondElementChanged = false;

  double discountContainerHeightFactor = 0.62;
  double newDiscountContainerHeightFactor = 0.85;


  @override
  void initState(){
    super.initState();
    stateProvider = Provider.of<StateProvider>(context, listen:  false);
    newSelectedDate = stateProvider.clubMeDiscount.getDiscountDate();
    _fixedExtentScrollController1 = FixedExtentScrollController(initialItem: stateProvider.clubMeDiscount.getDiscountDate().hour);
    _fixedExtentScrollController2 = FixedExtentScrollController(initialItem: stateProvider.clubMeDiscount.getDiscountDate().minute);
  }


  // BUILD
  Widget _buildMainColumn(){
    return Column(
      children: [

        // Headline 'Please check if everything is fine'
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
            controller: _discountTitleController,
            decoration: const InputDecoration(
                hintText: "z.B. Latino night",
                label: Text("Coupon-Titel"),
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
                  Text(
                    formatSelectedDate(),
                    style: customTextStyle.size3(),
                  ),
                  SizedBox(
                    width: screenWidth*0.02,
                  ),
                  Icon(
                    Icons.calendar_month_outlined,
                    color: stateProvider.getPrimeColor(),
                  )
                ],
              )
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.05,
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

        // Textfield, Description
        SizedBox(
          width: screenWidth*0.8,
          child: TextField(
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
          height: screenHeight*0.05,
        ),

        // Text description
        SizedBox(
          width: screenWidth*0.8,
          child:Text(
              "Zeitlimit",
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

        // toggle yes,no
        Padding(
          padding: EdgeInsets.only(
              top: screenHeight*0.02
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: screenWidth*0.4,
                height: screenHeight*0.08,
                child:  Center(
                  child: ToggleSwitch(
                    initialLabelIndex: hasTimeLimit,
                    totalSwitches: 2,
                    activeBgColor: [stateProvider.getPrimeColor()],
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
                width: screenWidth*0.4,
                child: hasTimeLimit == 1? SizedBox(
                  // width: screenWidth*0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(
                        width: screenWidth*0.17,
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
                        width: screenWidth*0.17,
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


                      // Container(
                      //   // width: screenWidth*0.3,
                      //   alignment: Alignment.center,
                      //   child: DropdownButton<int>(
                      //     value: selectedHour,
                      //     itemHeight: screenHeight*0.08,
                      //     onChanged: (int? newValue) {
                      //       setState(() {
                      //         selectedHour = newValue!;
                      //       });
                      //     },
                      //     items: List<DropdownMenuItem<int>>.generate(
                      //       24,
                      //           (int index) {
                      //         return DropdownMenuItem<int>(
                      //           value: index,
                      //           child: Center(
                      //             child: Text(
                      //               '$index',
                      //               style: TextStyle(
                      //                   fontSize: screenWidth*0.08
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // ),


                      // Container(
                      //   // width: screenWidth*0.2,
                      //   alignment: Alignment.center,
                      //   child: DropdownButton<int>(
                      //     value: selectedMinute,
                      //     itemHeight: screenHeight*0.08,
                      //     onChanged: (int? newValue) {
                      //       setState(() {
                      //         selectedMinute = newValue!;
                      //       });
                      //     },
                      //     items: List<DropdownMenuItem<int>>.generate(
                      //       60,
                      //           (int index) {
                      //         return DropdownMenuItem<int>(
                      //           value: index,
                      //           child: Center(
                      //             child: Text(
                      //               '$index',
                      //               style: TextStyle(
                      //                   fontSize: screenWidth*0.08
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ) :Row(mainAxisAlignment: MainAxisAlignment.center,children: [],),
              )
            ],
          ),
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.05,
        ),

        // Text description
        SizedBox(
          width: screenWidth*0.8,
          child:Text(
              "Nutzungslimit",
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

        // toggle yes,no
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: screenWidth*0.4,
              height: screenHeight*0.1,
              child:  Center(
                child: ToggleSwitch(
                  initialLabelIndex: hasUsageLimit,
                  totalSwitches: 2,
                  activeBgColor: [stateProvider.getPrimeColor()],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Color(0xff11181f),
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
              width: screenWidth*0.4,
              child: hasUsageLimit == 1 ?
              SizedBox(
                width: screenWidth*0.05,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  controller: _discountNumberOfUsagesController,
                  style: TextStyle(
                      fontSize: screenWidth*0.1
                  ),
                ),
              ):Container(),
            )
          ],
        ),

        // Spacer
        SizedBox(
          height: screenHeight*0.05,
        ),

      ],
    );
  }
  Widget _buildNavBar(double screenHeight, double screenWidth){
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
              onTap: () => finishUpdateDiscount(),
            ),
          )
        )
    );
  }


  // MISC
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
  void finishUpdateDiscount() async{

    late DateTime concatenatedDate;

    int firstElementToSave = 0;
    int secondElementToSave = 0;

    if(!firstElementChanged){
      firstElementToSave = stateProvider.clubMeDiscount.getDiscountDate().hour;
    }else{
      firstElementToSave = selectedFirstElement;
    }

    if(!secondElementChanged){
      secondElementToSave = stateProvider.clubMeDiscount.getDiscountDate().minute;
    }else{
      secondElementToSave = selectedSecondElement;
    }


    stateProvider.clubMeDiscount.setDiscountTitle(_discountTitleController.text);
    stateProvider.clubMeDiscount.setDiscountDescription(_discountDescriptionController.text);

    int numberOfUsageForDb = 0;
    if(hasUsageLimit != 0){
      numberOfUsageForDb = int.parse(_discountNumberOfUsagesController.text);
    }

    stateProvider.clubMeDiscount.setNumberOfUsages(numberOfUsageForDb);

    stateProvider.clubMeDiscount.setHasUsageLimit(hasUsageLimit == 0 ? false:true);
    stateProvider.clubMeDiscount.setHasTimeLimit(hasTimeLimit == 0 ? false:true);

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
          firstElementToSave,
          secondElementToSave
      );
    }

    stateProvider.clubMeDiscount.setDiscountDate(concatenatedDate);

    ClubMeDiscount clubMeDiscount = ClubMeDiscount(
        discountId: stateProvider.clubMeDiscount.getDiscountId(),
        clubId: stateProvider.clubMeDiscount.getClubId(),
        clubName: stateProvider.clubMeDiscount.getClubName(),
        discountTitle: _discountTitleController.text,
        numberOfUsages: int.parse(_discountNumberOfUsagesController.text),
        discountDate: concatenatedDate,
        bannerId: stateProvider.clubMeDiscount.getBannerId(),
        howOftenRedeemed: stateProvider.clubMeDiscount.getHowOftenRedeemed(),
        hasTimeLimit: hasTimeLimit == 0 ? false : true,
        hasUsageLimit: hasUsageLimit == 0 ? false : true,
        discountDescription: _discountDescriptionController.text,
        targetGender: stateProvider.clubMeDiscount.getTargetGender()
    );

    // print(
    //  "${_discountTitleController.text}, ${concatenatedDate}, ${_discountDescriptionController.text},"
    //  "$hasTimeLimit,${firstElementToSave}, ${secondElementToSave}, $hasUsageLimit, ${_discountNumberOfUsagesController.text}"
    // );

    setState(() {
      isUploading = true;
    });

    _supabaseService.updateCompleteDiscount(clubMeDiscount).then((value){
      if(value == 0){
        stateProvider.updateSpecificDiscount(clubMeDiscount.getDiscountId(), clubMeDiscount);
        Navigator.pop(context);
      }else{
        setState(() {
          isUploading = false;
        });
        showDialog(context: context, builder: (BuildContext context){
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
        });
      }
    });

  }
  void leavePage(StateProvider stateProvider){

    // Reset values ?

    context.go("/club_coupons");
  }


  @override
  Widget build(BuildContext context) {

    customTextStyle = CustomTextStyle(context: context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);

    // Set the fundamental values
    if(!initFinished){
      newSelectedDate = stateProvider.clubMeDiscount.getDiscountDate();

      // Get all values
      if(stateProvider.clubMeDiscount.getHasTimeLimit()){
        hasTimeLimit = 1;
      }else{
        hasTimeLimit = 0;
      }
      if(stateProvider.clubMeDiscount.getHasUsageLimit()){
        hasUsageLimit = 1;
      }else{
        hasUsageLimit = 0;
      }

      selectedMinute = stateProvider.clubMeDiscount.getDiscountDate().minute;
      selectedHour = stateProvider.clubMeDiscount.getDiscountDate().hour;

      _discountTitleController = TextEditingController(text: stateProvider.clubMeDiscount.getDiscountTitle());
      _discountDescriptionController = TextEditingController(text: stateProvider.clubMeDiscount.getDiscountDescription());
      _discountNumberOfUsagesController = TextEditingController(text: stateProvider.clubMeDiscount.getNumberOfUsages().toString());

      initFinished = true;
    }

    return Scaffold(
      appBar: AppBar(
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

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
        ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
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
            child: SizedBox(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left:2,
                      top: 2
                  ),
                  child: SizedBox(
                    width: screenWidth*0.9,
                    child: _buildMainColumn(),
                  ),
                ),
              ),
            ),
          ),
      ),
      bottomNavigationBar: _buildNavBar(screenHeight, screenWidth),
    );
  }

}
