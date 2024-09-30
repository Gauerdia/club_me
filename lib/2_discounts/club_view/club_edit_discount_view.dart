import 'package:club_me/models/discount.dart';
import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/state_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';
import '../shared/creation_and_editing_arrays.dart';

class ClubEditDiscountView extends StatefulWidget {
  const ClubEditDiscountView({Key? key}) : super(key: key);

  @override
  State<ClubEditDiscountView> createState() => _ClubEditDiscountState();
}

class _ClubEditDiscountState extends State<ClubEditDiscountView> {

  String headline = "Coupon bearbeiten";

  final SupabaseService _supabaseService = SupabaseService();

  late int hasTimeLimit;
  late DateTime newSelectedDate;
  late FetchedContentProvider fetchedContentProvider;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenWidth, screenHeight;
  late TextEditingController _discountTitleController;
  late TextEditingController _discountDescriptionController;

  late FixedExtentScrollController _fixedExtentScrollController1;
  late FixedExtentScrollController _fixedExtentScrollController2;

  late FixedExtentScrollController _usageLimitPickerController;

  late TextEditingController _ageLimitLowerLimitController;
  late TextEditingController _ageLimitUpperLimitController;

  late CurrentAndLikedElementsProvider currentAndLikedElementsProvider;

  int selectedHour = 0;
  int selectedMinute = 0;
  int hasAgeLimit = 0;
  int creationIndex = 0;
  int targetGender = 0;
  int ageLimitIsUpperLimit = 0;

  bool isUploading = false;
  bool initFinished = false;
  bool isDateSelected = false;
  bool firstElementChanged = false;
  bool secondElementChanged = false;

  int isRepeated = 0;
  int isRepeatedIndex = 0;

  int hasUsageLimit = 0;
  int hasUsageLimitIndex = 0;


  @override
  void initState(){
    super.initState();
    initControllers();
  }

  void initControllers(){

    // Get providers to access information
    final currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen: false);

    _discountTitleController = TextEditingController(
        text: currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountTitle()
    );

    newSelectedDate = currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountDate();

    if(currentAndLikedElementsProvider.currentClubMeDiscount.getHasTimeLimit()){
      hasTimeLimit = 1;
    }else{
      hasTimeLimit = 0;
    }

    selectedHour = currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountDate().hour;
    selectedMinute = currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountDate().minute;

    // TODO: Are these necessary?
    _fixedExtentScrollController1 = FixedExtentScrollController(
        initialItem: currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountDate().hour);
    _fixedExtentScrollController2 = FixedExtentScrollController(
        initialItem: currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountDate().minute);


    targetGender = currentAndLikedElementsProvider.currentClubMeDiscount.getTargetGender();


    if(currentAndLikedElementsProvider.currentClubMeDiscount.getHasAgeLimit()){
      hasAgeLimit = 1;
    }else{
      hasAgeLimit = 0;
    }

    _ageLimitLowerLimitController = TextEditingController(
        text: currentAndLikedElementsProvider.currentClubMeDiscount.getAgeLimitLowerLimit().toString()
    );
    _ageLimitUpperLimitController = TextEditingController(
        text: currentAndLikedElementsProvider.currentClubMeDiscount.getAgeLimitUpperLimit().toString()
    );

    if(currentAndLikedElementsProvider.currentClubMeDiscount.getHasUsageLimit()){
      hasUsageLimit = 1;
    }else{
      hasUsageLimit = 0;
    }

    _usageLimitPickerController = FixedExtentScrollController(
        initialItem: usageLimitAnswers.indexWhere(
                (element) => element == "${currentAndLikedElementsProvider.currentClubMeDiscount.getNumberOfUsages()}x"
        )
    );

    _discountDescriptionController = TextEditingController(
        text: currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountDescription()
    );

    if(currentAndLikedElementsProvider.currentClubMeDiscount.getIsRepeatedDays() != 0){
      isRepeated = 1;
      switch(currentAndLikedElementsProvider.currentClubMeDiscount.getIsRepeatedDays()){
        case(7): isRepeatedIndex = 0;break;
        case(14): isRepeatedIndex = 1; break;
      }
    }

  }

  bool pickHourAndMinuteIsActive = false;
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

            // Iconbutton
            Container(
              alignment: Alignment.centerRight,
              height: 50,
              child: IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  color: Colors.white,
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
                    style: customStyleClass.getFontStyle1(),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _buildFinalOverview3(){

    return SizedBox(
        height: screenHeight,
        child: Stack(
          children: [

            // main view
            SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                    children: [

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.05,
                      ),

                      // Text: Headline
                      Container(
                        width: screenWidth*0.9,
                        child: Text(
                          "Bitte gib die passenden Daten zu deinem Coupons ein!",
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
                          "Titel des Coupons",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // TextField: Title
                      SizedBox(
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: _discountTitleController,
                          cursorColor: customStyleClass.primeColor,
                          decoration: InputDecoration(
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

                      // Row: Datepicker, ToggleSwitch TimeLimit, TimeLimit
                      Container(
                        width: screenWidth*0.9,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // Datepicker
                            Container(
                              height: screenHeight*0.12,
                              alignment: Alignment.centerLeft,
                              width: screenWidth*0.3,
                              child: Column(
                                children: [

                                  Container(
                                    width: screenWidth*0.28,
                                    child: Text(
                                      "Datum",
                                      style: customStyleClass.getFontStyle3(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),

                                  SizedBox(
                                    width: screenWidth*0.28,
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
                                          style: customStyleClass.getFontStyle5(),
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ),

                            // Column: Text,ToggleSwitch: TimeLimit
                            SizedBox(
                                height: screenHeight*0.12,
                                width: screenWidth*0.3,
                                child: Column(
                                    children: [

                                      Container(
                                        width: screenWidth*0.28,
                                        child: Text(
                                          "Zeitlimit",
                                          style: customStyleClass.getFontStyle3(),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),


                                      SizedBox(
                                        width: screenWidth*0.28,
                                        child:  Center(
                                          child: ToggleSwitch(
                                            minHeight: screenHeight*0.07,
                                            initialLabelIndex: hasTimeLimit,
                                            totalSwitches: 2,
                                            activeBgColor: [customStyleClass.primeColor],
                                            activeFgColor: Colors.white,
                                            inactiveBgColor: customStyleClass.backgroundColorEventTile,
                                            inactiveFgColor: Colors.white,
                                            labels: const [
                                              'Nein',
                                              'Ja',
                                            ],
                                            onToggle: (index) {
                                              setState(() {
                                                if(hasTimeLimit == 0){
                                                  setState(() {
                                                    hasTimeLimit = 1;
                                                    // timeLimitTileHeightFactor = originalFoldHeightFactor*4.5;
                                                  });
                                                }else{
                                                  setState(() {
                                                    hasTimeLimit = 0;
                                                    // timeLimitTileHeightFactor = originalFoldHeightFactor*3;
                                                  });
                                                }
                                                print('switched to: $index');
                                              });
                                            },
                                          ),
                                        ),
                                      ),

                                    ]
                                )
                            ),

                            // Column: Button: Hour and minute
                            if(hasTimeLimit != 0)
                              Container(
                                alignment: Alignment.centerRight,
                                height: screenHeight*0.12,
                                width: screenWidth*0.3,
                                child: Column(
                                  children: [

                                    // Text: Time
                                    Container(
                                      width: screenWidth*0.28,
                                      child: Text(
                                        "Uhrzeit",
                                        style: customStyleClass.getFontStyle3(),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),

                                    // Button: Time
                                    SizedBox(
                                      width: screenWidth*0.28,
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
                                            style: customStyleClass.getFontStyle5(),
                                          )
                                      ),
                                    )
                                  ],
                                ),
                              ),

                            // Spacer
                            if(hasTimeLimit == 0)
                              SizedBox(
                                height: screenHeight*0.12,
                                width: screenWidth*0.3,
                              )
                          ],
                        ),
                      ),

                      // Text: Gender
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Geschlecht",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // ToggleSwitch: Gender
                      SizedBox(
                        width: screenWidth*0.9,
                        // height: screenHeight*0.1,
                        child:  Center(
                          child: ToggleSwitch(
                            minHeight: screenHeight*0.07,
                            initialLabelIndex: targetGender,
                            totalSwitches: 3,
                            activeBgColor: [customStyleClass.primeColor],
                            activeFgColor: Colors.white,
                            inactiveFgColor: Colors.white,
                            inactiveBgColor: customStyleClass.backgroundColorEventTile,
                            labels: const [
                              'Alle',
                              'Männer',
                              'Frauen',
                            ],
                            fontSize:
                            customStyleClass.getFontSize4(),
                            minWidth: screenWidth*0.9,
                            onToggle: (index) {
                              setState(() {
                                targetGender = index!;
                                print('switched taget gender to: $index');
                              });
                            },
                          ),
                        ),
                      ),


                      // Row: ToggleSwitch, TextField - AgeLimit
                      Container(
                        padding: EdgeInsets.only(
                          top:30
                        ),
                        width: screenWidth*0.9,
                        height: screenHeight*0.18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Container(
                              width: screenWidth*0.4,
                              // height: screenHeight*0.12,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: [

                                  // Text: AgeLimit
                                  Container(
                                    // width: screenWidth*0.9,
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        top: 20
                                    ),
                                    child: Text(
                                      "Alterbeschränkung",
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),

                                  Container(
                                    width: screenWidth*0.45,
                                    alignment: Alignment.centerLeft,
                                    child: ToggleSwitch(
                                      minHeight: screenHeight*0.07,
                                      initialLabelIndex: hasAgeLimit,
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
                                          if(hasAgeLimit == 0){
                                            setState(() {
                                              hasAgeLimit = 1;
                                              // ageLimitTileHeightFactor = originalDateTileHeightFactor*7.5;
                                            });
                                          }else{
                                            setState(() {
                                              hasAgeLimit = 0;
                                              // ageLimitTileHeightFactor = originalDateTileHeightFactor*3.5;
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  ),

                                ],
                              )
                            ),

                            // TextField, Text: AgeLimit
                            if(hasAgeLimit != 0)
                              Container(
                                padding: const EdgeInsets.only(
                                  top:25
                                ),
                                alignment: Alignment.centerRight,
                                width: screenWidth*0.45,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Text, Textfield: From
                                    SizedBox(
                                      width: screenWidth*0.15,
                                      child: Column(
                                        children: [

                                          SizedBox(
                                            width: screenWidth*0.15,
                                            child: Text(
                                              "von",
                                              textAlign: TextAlign.left,
                                              style: customStyleClass.getFontStyle3(),
                                            ),
                                          ),

                                          TextField(
                                            controller: _ageLimitLowerLimitController,
                                            cursorColor: customStyleClass.primeColor,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: customStyleClass.primeColor
                                                  )
                                              ),
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                            ], //
                                            style: customStyleClass.getFontStyle4(),
                                            maxLength: 2,
                                          )
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10
                                      ),
                                      child: Text(
                                        "-",
                                        style: customStyleClass.getFontStyle3(),
                                      ),
                                    ),

                                    // Text, Textfield: From
                                    SizedBox(
                                      width: screenWidth*0.15,
                                      child: Column(
                                        children: [

                                          SizedBox(
                                            width: screenWidth*0.15,
                                            child: Text(
                                              "Bis",
                                              textAlign: TextAlign.left,
                                              style: customStyleClass.getFontStyle3(),
                                            ),
                                          ),

                                          TextField(
                                            controller: _ageLimitUpperLimitController,
                                            cursorColor: customStyleClass.primeColor,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: customStyleClass.primeColor
                                                  )
                                              ),
                                            ),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                            ], //
                                            style: customStyleClass.getFontStyle4(),
                                            maxLength: 2,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )

                          ],
                        ),
                      ),

                      // Row: ToggleSwitch, TextField - UsageLimit
                      SizedBox(
                        width: screenWidth*0.9,
                        height: screenHeight*0.16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [


                            Container(
                              width: screenWidth*0.45,
                              padding: EdgeInsets.only(
                                top:15
                              ),
                              child: Column(
                                children: [

                                  // Text: UsageLimit
                                  Container(
                                    width: screenWidth*0.45,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Nutzungsbeschränkung",
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),

                                  Container(
                                    width: screenWidth*0.45,
                                    // height: screenHeight*0.12,
                                    alignment: Alignment.centerLeft,
                                    child: ToggleSwitch(
                                      minHeight: screenHeight*0.07,
                                      initialLabelIndex: hasUsageLimit,
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
                                          if(hasUsageLimit == 0){
                                            setState(() {
                                              hasUsageLimit = 1;
                                              // ageLimitTileHeightFactor = originalDateTileHeightFactor*7.5;
                                            });
                                          }else{
                                            setState(() {
                                              hasUsageLimit = 0;
                                              // ageLimitTileHeightFactor = originalDateTileHeightFactor*3.5;
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  ),

                                ],
                              ),
                            ),


                            // TextField, Text: AgeLimit
                            if(hasUsageLimit != 0)
                              Container(
                                padding: const EdgeInsets.only(
                                  // top: 20
                                ),
                                alignment: Alignment.centerRight,
                                width: screenWidth*0.45,
                                // height: screenHeight*0.12,
                                child: CupertinoPicker(
                                    scrollController: _usageLimitPickerController,
                                    itemExtent: 50,
                                    onSelectedItemChanged: (int index){
                                      setState(() {
                                        hasUsageLimitIndex = index;
                                      });
                                    },
                                    children: List<Widget>.generate(usageLimitAnswers.length, (index){
                                      return Center(
                                        child: Text(
                                          usageLimitAnswers[index],
                                          style: customStyleClass.getFontStyle3(),
                                        ),
                                      );
                                    })
                                ),
                              ),

                          ],
                        ),
                      ),

                      // Text: Description
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(
                          top: 20
                        ),
                        child: Text(
                          "Beschreibung des Coupons",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // TextField: Description
                      SizedBox(
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: _discountDescriptionController,
                          cursorColor: customStyleClass.primeColor,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
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



                      // ToggleSwitch: isRepeated
                      Container(
                        width: screenWidth*0.9,
                        height: screenHeight*0.12,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Container(
                              child:Column(
                                children: [

                                  // Text: "repeat coupon"
                                  Container(
                                    width: screenWidth*0.45,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Coupon wiederholen",
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),

                                  Container(
                                    width: screenWidth*0.45,
                                      alignment: Alignment.centerLeft,
                                      child: ToggleSwitch(
                                        minHeight: screenHeight*0.07,
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

                                ],
                              ),
                            ),

                            if(isRepeated != 0)
                              Container(
                                // padding: const EdgeInsets.only(
                                //     top: 20
                                // ),
                                width: screenWidth*0.45,
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

                      // Spacer
                      SizedBox(
                        height: screenHeight*0.07,
                      )

                    ]
                )
            ),

            // opacity blocker
            if(pickHourAndMinuteIsActive)
              GestureDetector(
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  color: Colors.black.withOpacity(0.7),
                ),
                onTap: () {
                  setState(() {
                    pickHourAndMinuteIsActive = false;
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

          ],
        )
    );
  }
  Widget _buildNavigationBar2(){
    return Container(
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
      padding: const EdgeInsets.only(
          right: 10,
      ),
      child: isUploading ? const CircularProgressIndicator()
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
        onTap: () => finishUpdateDiscount(),
      ),
    );
  }

  // MISC
  void leavePage(){

    // Reset values ?

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
                style: customStyleClass.getFontStyle4(),
              ),
              actions: [

                TextButton(
                  child: Text(
                      "Zurück",
                    style: customStyleClass.getFontStyle3(),
                  ),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),

                TextButton(
                  child: Text(
                      "Ja",
                    style: customStyleClass.getFontStyle3(),
                  ),
                  onPressed: () => context.go("/club_coupons"),
                ),

              ]
          );
        }
    );
  }


  // void clickedOnAbort(){
  //
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context){
  //         return AlertDialog(
  //             backgroundColor: Color(0xff121111),
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20.0),
  //                 // side: BorderSide(
  //                 //     color: customStyleClass.primeColor
  //                 // )
  //             ),
  //             title: Text(
  //               "Abbrechen",
  //               style: customStyleClass.getFontStyle1Bold(),
  //             ),
  //             content: Text(
  //               "Bist du sicher, dass du abbrechen möchtest?",
  //               textAlign: TextAlign.left,
  //               style: customStyleClass.getFontStyle4(),
  //             ),
  //             actions: [
  //
  //               TextButton(
  //                 child: Text(
  //                   "Zurück",
  //                   style: customStyleClass.getFontStyle3(),
  //                 ),
  //                 onPressed: (){
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //
  //               TextButton(
  //                 child: Text(
  //                   "Ja",
  //                   style: customStyleClass.getFontStyle3(),
  //                 ),
  //                 onPressed: (){
  //                   stateProvider.resetCurrentEventTemplate();
  //                   switch(stateProvider.pageIndex){
  //                     case(0): context.go('/club_discounts');
  //                     case(3): context.go('/club_frontpage');
  //                     default: context.go('/club_frontpage');
  //                   }
  //                 },
  //               ),
  //
  //             ]
  //         );
  //       }
  //   );
  // }
  void finishUpdateDiscount() async{

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
          selectedHour,
          selectedMinute
      );
    }

    currentAndLikedElementsProvider.currentClubMeDiscount.setDiscountDate(concatenatedDate);

    // Format usage limit if necessary
    int numberOfUsageForDb = 0;
    if(hasUsageLimit != 0){
      String pickerValueWithoutX = usageLimitAnswers[hasUsageLimitIndex]
          .substring(0, usageLimitAnswers[hasUsageLimitIndex].length - 1);
      numberOfUsageForDb = int.parse(pickerValueWithoutX);
    }


    int isRepeatedDaysToSave = 0;
    if(isRepeated != 0){
      switch(isRepeatedIndex){
        case(0): isRepeatedDaysToSave = 7;break;
        case(1): isRepeatedDaysToSave = 14;break;
      }
    }


    ClubMeDiscount clubMeDiscount = ClubMeDiscount(

        discountId: currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountId(),
        clubId: currentAndLikedElementsProvider.currentClubMeDiscount.getClubId(),
        clubName: currentAndLikedElementsProvider.currentClubMeDiscount.getClubName(),
        bannerId: currentAndLikedElementsProvider.currentClubMeDiscount.getBannerId(),

        discountTitle: _discountTitleController.text,
        discountDate: concatenatedDate,
        discountDescription: _discountDescriptionController.text,

        targetGender: targetGender,
        numberOfUsages: numberOfUsageForDb,
        priorityScore: currentAndLikedElementsProvider.currentClubMeDiscount.getPriorityScore(),
        howOftenRedeemed: currentAndLikedElementsProvider.currentClubMeDiscount.getHowOftenRedeemed(),
        isRepeatedDays: isRepeatedDaysToSave,

        hasAgeLimit: hasAgeLimit == 0 ? false : true,
        hasTimeLimit: hasTimeLimit == 0 ? false : true,
        hasUsageLimit: hasUsageLimit == 0 ? false : true,

        ageLimitLowerLimit: int.parse(_ageLimitLowerLimitController.text),
        ageLimitUpperLimit: int.parse(_ageLimitUpperLimitController.text),

      bigBannerFileName: ""

    );

    // Update the in-app elements to display the updated values correctly
    currentAndLikedElementsProvider.setCurrentDiscount(clubMeDiscount);
    fetchedContentProvider.updateSpecificDiscount(
        currentAndLikedElementsProvider.currentClubMeDiscount.getDiscountId(),
        clubMeDiscount
    );

    setState(() {
      isUploading = true;
    });

    _supabaseService.updateCompleteDiscount(clubMeDiscount).then((value){
      if(value == 0){
        fetchedContentProvider.updateSpecificDiscount(clubMeDiscount.getDiscountId(), clubMeDiscount);
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


  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
          width: screenWidth,
          height: screenHeight,
          color: customStyleClass.backgroundColorMain,
          child: Center(
              child: _buildFinalOverview3()
          )
      ),
      bottomNavigationBar: _buildNavigationBar2(),
    );
  }

}
