import 'package:club_me/models/discount.dart';
import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_two_buttons_dialog.dart';
import 'package:club_me/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../models/hive_models/2_club_me_discount.dart';
import '../../provider/current_and_liked_elements_provider.dart';
import '../../provider/state_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';
import 'components/cover_image_card.dart';

class ClubEditDiscountView extends StatefulWidget {
  const ClubEditDiscountView({Key? key}) : super(key: key);

  @override
  State<ClubEditDiscountView> createState() => _ClubEditDiscountState();
}

class _ClubEditDiscountState extends State<ClubEditDiscountView>
    with TickerProviderStateMixin{

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

  late FixedExtentScrollController _isRepeatedController;

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

  int isRedeemable = 0;

  int isRepeated = 0;
  int isRepeatedIndex = 0;

  int hasUsageLimit = 0;
  int hasUsageLimitIndex = 0;

  bool pickHourAndMinuteIsActive = false;

  double distanceBetweenTitleAndTextField = 10;

  bool showGallery = false;
  int _currentPageIndex = 0;
  late TabController _tabController;
  late PageController _pageViewController;


  // INIT
  @override
  void initState(){
    super.initState();
    initControllers();
  }
  void initControllers(){


    // Get providers to access information
    final currentAndLikedElementsProvider = Provider.of<CurrentAndLikedElementsProvider>(context, listen: false);

    // Set the chosen image to not confuse the user. I don't think all 4 setters are necessary but I wasn't sure which one is.
    int chosenImageIndex = Utils.discountBigImageNames.indexWhere(
            (element) => element == currentAndLikedElementsProvider.currentClubMeDiscount.getBigBannerFileName());
    _currentPageIndex = chosenImageIndex;
    _pageViewController = PageController(initialPage: chosenImageIndex);
    _tabController = TabController(length: Utils.discountBigImageNames.length, vsync: this);
    _tabController.index = chosenImageIndex;

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
        initialItem: Utils.usageLimitAnswers.indexWhere(
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

    _isRepeatedController = FixedExtentScrollController(
        initialItem: isRepeatedIndex
    );

    if(currentAndLikedElementsProvider.currentClubMeDiscount.getIsRedeemable()){
      isRedeemable = 1;
    }

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
                  clickEventClose();
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
  Widget _buildMainView(){
    return Container(
        width: screenWidth,
        height: screenHeight,
        color: customStyleClass.backgroundColorMain,
        child: Center(
            child: showGallery ? _buildGalleryView() : _buildFinalOverview()
        )
    );
  }
  Widget _buildFinalOverview(){

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
                      SizedBox(
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
                      Container(
                        padding:  EdgeInsets.only(
                            top: distanceBetweenTitleAndTextField
                        ),
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: _discountTitleController,
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
                          maxLength: 25,
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

                                  SizedBox(
                                    width: screenWidth*0.28,
                                    child: Text(
                                      "Datum",
                                      style: customStyleClass.getFontStyle3(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),

                                  Container(
                                    padding:  EdgeInsets.only(
                                        top: distanceBetweenTitleAndTextField
                                    ),
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

                                      SizedBox(
                                        width: screenWidth*0.28,
                                        child: Text(
                                          "Zeitlimit",
                                          style: customStyleClass.getFontStyle3(),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),


                                      Container(
                                        padding:  EdgeInsets.only(
                                            top: distanceBetweenTitleAndTextField
                                        ),
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
                                                  });
                                                }else{
                                                  setState(() {
                                                    hasTimeLimit = 0;
                                                  });
                                                }
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
                                    SizedBox(
                                      width: screenWidth*0.28,
                                      child: Text(
                                        "Uhrzeit",
                                        style: customStyleClass.getFontStyle3(),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),

                                    // Button: Time
                                    Container(
                                      padding:  EdgeInsets.only(
                                          top: distanceBetweenTitleAndTextField
                                      ),
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
                      Container(
                        padding:  EdgeInsets.only(
                            top: distanceBetweenTitleAndTextField
                        ),
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
                              });
                            },
                          ),
                        ),
                      ),

                      // Row: ToggleSwitch, TextField - AgeLimit
                      Container(
                        padding: const EdgeInsets.only(
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
                                    padding: const EdgeInsets.only(
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
                                    padding:  EdgeInsets.only(
                                        top: distanceBetweenTitleAndTextField
                                    ),
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
                                            });
                                          }else{
                                            setState(() {
                                              hasAgeLimit = 0;
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
                                  top:33
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
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              border: const OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: customStyleClass.primeColor
                                                  )
                                              ),
                                              counterText: "",
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
                                              "bis",
                                              textAlign: TextAlign.left,
                                              style: customStyleClass.getFontStyle3(),
                                            ),
                                          ),

                                          TextField(
                                            controller: _ageLimitUpperLimitController,
                                            cursorColor: customStyleClass.primeColor,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              border: const OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: customStyleClass.primeColor
                                                  )
                                              ),
                                              counterText: ""
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
                              padding: const EdgeInsets.only(
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
                                    padding:  EdgeInsets.only(
                                        top: distanceBetweenTitleAndTextField
                                    ),
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
                                            });
                                          }else{
                                            setState(() {
                                              hasUsageLimit = 0;
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
                                    children: List<Widget>.generate(Utils.usageLimitAnswers.length, (index){
                                      return Center(
                                        child: Text(
                                          Utils.usageLimitAnswers[index],
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
                        padding: const EdgeInsets.only(
                          top: 20
                        ),
                        child: Text(
                          "Beschreibung des Coupons",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // TextField: Description
                      Container(
                        padding:  EdgeInsets.only(
                            top: distanceBetweenTitleAndTextField
                        ),
                        width: screenWidth*0.9,
                        child: TextField(
                          controller: _discountDescriptionController,
                          cursorColor: customStyleClass.primeColor,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
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
                          maxLength: 300,
                          minLines: 10,
                          style:customStyleClass.getFontStyle4(),
                        ),
                      ),

                      // Text: Description
                      Container(
                        width: screenWidth*0.9,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                            top: 20
                        ),
                        child: Text(
                          "Auswahl des Bildes",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // GALLERY
                      InkWell(
                        child: Container(
                          width: screenWidth*0.9,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Row(
                                  children: [
                                    Text(
                                      "Zur Galerie",
                                      style: customStyleClass.getFontStyle3BoldPrimeColor(),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_outlined,
                                      color: customStyleClass.primeColor,
                                    )
                                  ],
                                ),

                                  Icon(
                                    Icons.check,
                                    color: customStyleClass.primeColor,
                                  )

                              ],
                            ),
                          ),
                        ),
                        onTap: (){
                          setState(() {
                            showGallery = true;
                          });
                        },
                      ),

                      // ToggleSwitch: isRepeated
                      Container(
                        width: screenWidth*0.9,
                        height: screenHeight*0.12,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Column(
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
                                    padding:  EdgeInsets.only(
                                        top: distanceBetweenTitleAndTextField
                                    ),
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

                            if(isRepeated != 0)
                              SizedBox(
                                width: screenWidth*0.45,
                                child: CupertinoPicker(
                                    scrollController: _isRepeatedController,
                                    itemExtent: 50,
                                    onSelectedItemChanged: (int index){
                                      setState(() {
                                        isRepeatedIndex = index;
                                      });
                                    },
                                    children: List<Widget>.generate(Utils.repetitionAnswers.length, (index){
                                      return Center(
                                        child: Text(
                                          Utils.repetitionAnswers[index],
                                          style: customStyleClass.getFontStyle3(),
                                        ),
                                      );
                                    })
                                ),
                              ),

                          ],
                        ),
                      ),

                      // switch between discount and information
                      if(stateProvider.getUsingTheAppAsADeveloper())
                        Container(
                          width: screenWidth*0.9,
                          // height: screenHeight*0.12,
                          alignment: Alignment.centerLeft,
                          padding:  EdgeInsets.only(
                              top: distanceBetweenTitleAndTextField
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Column(
                                children: [

                                  // Text: "repeat coupon"
                                  Container(
                                    width: screenWidth*0.9,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Admin: Coupon oder Angebot?",
                                      style: customStyleClass.getFontStyle3(),
                                    ),
                                  ),

                                  Container(
                                      padding:  EdgeInsets.only(
                                          top: distanceBetweenTitleAndTextField
                                      ),
                                      width: screenWidth*0.9,
                                      alignment: Alignment.centerLeft,
                                      child: ToggleSwitch(
                                        minHeight: screenHeight*0.07,
                                        initialLabelIndex: isRedeemable,
                                        totalSwitches: 2,
                                        activeBgColor: [customStyleClass.primeColor],
                                        activeFgColor: Colors.white,
                                        inactiveFgColor: Colors.white,
                                        inactiveBgColor: customStyleClass.backgroundColorEventTile,
                                        labels: const [
                                          'Angebot',
                                          'Coupon',
                                        ],
                                        onToggle: (index) {
                                          setState(() {
                                            isRedeemable == 0 ? isRedeemable = 1 : isRedeemable = 0;
                                          });
                                        },
                                      )
                                  ),
                                ],
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
                        "Bitte trage mit Hoch- und Herunterwischen die Uhrzeit ein, bis wann der Coupon verfügbar ist.",
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
                                  borderRadius: const BorderRadius.all(Radius.circular(10))
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
  Widget _buildNavigationBar(){
    return Container(
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
      child: isUploading ? const CircularProgressIndicator()
          : showGallery ?
      GestureDetector(
        child: Container(
          height: 80,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
              bottom: 10
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              Text(
                "Bild auswählen",
                style: customStyleClass.getFontStyle3BoldPrimeColor(),
              ),

              Icon(
                Icons.arrow_forward_outlined,
                color: customStyleClass.primeColor,
              )

            ],
          ),
        ),
        onTap: () => clickEventChooseImage(),
      ) :GestureDetector(
        child: Container(
          height: 80,
          alignment: Alignment.center,
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
        ),
        onTap: () => finishUpdateDiscount(),
      ),
    );
  }
  Widget _buildGalleryView(){
    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Column(
        children: [

          Text(
            "Bitte wähle ein Coverbild aus",
            style: customStyleClass.getFontStyle1Bold(),
          ),

          SizedBox(
            width: screenWidth,
            height: screenHeight*0.65,
            child: PageView(
              controller: _pageViewController,
              onPageChanged: _handlePageViewChanged,
              children: <Widget>[

                for(var i = 0; i<Utils.discountBigImageNames.length;i++)
                  Center(
                      child: CoverImageCard(fileName: Utils.discountBigImageNames[i])
                  ),
              ],
            ),
          ),

          Container(
            height: screenHeight*0.1,
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_arrow_left_sharp,
                  size: 50,
                  color: _currentPageIndex > 0 ? customStyleClass.primeColor: Colors.grey,
                ),
                Icon(
                  Icons.keyboard_arrow_right_sharp,
                  size: 50,
                  color: _currentPageIndex < (Utils.discountBigImageNames.length-1) ? customStyleClass.primeColor: Colors.grey,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }


  // MISC
  void clickEventClose(){

    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleContentAndButtonDialog(
              titleToDisplay: "Bearbeitung abbrechen",
              contentToDisplay: "Bist du sicher, dass du die Bearbeitung abbrechen möchtest?",
              buttonToDisplay: TextButton(
                child: Text(
                  "Ja",
                  style: customStyleClass.getFontStyle3(),
                ),
                onPressed: () => context.go("/club_coupons"),
              ));

        }
    );
  }
  void clickEventChooseImage(){
    setState(() {
      showGallery = false;
    });
  }

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
      String pickerValueWithoutX = Utils.usageLimitAnswers[hasUsageLimitIndex]
          .substring(0, Utils.usageLimitAnswers[hasUsageLimitIndex].length - 1);
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

        bigBannerFileName: Utils.discountBigImageNames[_currentPageIndex],
        smallBannerFileName: Utils.discountSmallImageNames[_currentPageIndex],
        openingTimes: currentAndLikedElementsProvider.currentClubMeDiscount.getOpeningTimes(),
        showDiscountInApp: currentAndLikedElementsProvider.currentClubMeDiscount.getShowDiscountInApp(),
        specialOccasionActive: false,
        isRedeemable: isRedeemable == 0 ? false : true

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
          return TitleAndContentDialog(
              titleToDisplay: "Fehler aufgetreten",
              contentToDisplay: "Verzeihung, es ist ein Fehler aufgetreten.");
        });
      }
    });
  }
  void _handlePageViewChanged(int currentPageIndex) {
    setState(() {
      _tabController.index = currentPageIndex;
      _currentPageIndex = currentPageIndex;
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
      body: _buildMainView(),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

}
