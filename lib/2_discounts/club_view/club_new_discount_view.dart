import 'package:club_me/2_discounts/club_view/components/cover_image_card.dart';
import 'package:club_me/models/discount.dart';
import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/services/check_and_fetch_service.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_two_buttons_dialog.dart';
import 'package:club_me/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/hive_models/1_club_me_discount_template.dart';
import '../../provider/state_provider.dart';
import '../../provider/user_data_provider.dart';
import '../../services/supabase_service.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../shared/custom_text_style.dart';

class ClubNewDiscountView extends StatefulWidget {
  const ClubNewDiscountView({Key? key}) : super(key: key);

  @override
  State<ClubNewDiscountView> createState() => _ClubNewDiscountViewState();
}

class _ClubNewDiscountViewState extends State<ClubNewDiscountView>
    with TickerProviderStateMixin{

  String headline = "Neuer Coupon";

  late DateTime newSelectedDate;

  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;


  late double screenWidth, screenHeight;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();
  final CheckAndFetchService _checkAndFetchService = CheckAndFetchService();


  late TextEditingController _discountTitleController;
  late TextEditingController _discountDescriptionController;
  late TextEditingController _discountNumberOfUsagesController;

  late TextEditingController _ageLimitLowerLimitController;
  late TextEditingController _ageLimitUpperLimitController;

  late FixedExtentScrollController _fixedExtentScrollController1;
  late FixedExtentScrollController _fixedExtentScrollController2;

  bool isUploading = false;
  bool isDateSelected = false;

  bool showGallery = false;
  bool galleryImageChosen = false;

  int isTemplate = 0;
  int isSupposedToBeTemplate = 0;


  int hasTimeLimit = 0;

  int hasAgeLimit = 0;
  int creationIndex = 0;
  int targetGender = 0;
  int ageLimitIsUpperLimit = 0;

  int selectedHour = 0;
  int selectedMinute = 0;

  int isRepeated = 0;
  int isRepeatedIndex = 0;

  int hasUsageLimit = 0;
  int hasUsageLimitIndex = 0;

  bool pickHourAndMinuteIsActive = false;

  double distanceBetweenTitleAndTextField = 10;


  int _currentPageIndex = 0;
  late TabController _tabController;
  late PageController _pageViewController;


  // INIT
  @override
  void initState() {
    super.initState();
    initControllers();

    _pageViewController = PageController();
    _tabController = TabController(length: Utils.discountBigImageNames.length, vsync: this);

  }
  void initControllers(){
    final stateProvider = Provider.of<StateProvider>(context, listen:  false);

    // If we chose a template, we set a current template and hence we have to
    // set up the controllers with values
    if (stateProvider.getCurrentDiscountTemplate() != null){

      ClubMeDiscountTemplate? currentDiscount = stateProvider.getCurrentDiscountTemplate();

      _discountTitleController = TextEditingController(
          text: currentDiscount?.getDiscountTitle()
      );

      newSelectedDate = currentDiscount!.getDiscountDate();

      hasTimeLimit = currentDiscount.getHasTimeLimit() ? 1 : 0;


      _fixedExtentScrollController1 = FixedExtentScrollController(initialItem: 0);
      _fixedExtentScrollController2 = FixedExtentScrollController(initialItem: 0);

      selectedHour = currentDiscount.getDiscountDate().hour;
      selectedMinute = currentDiscount.getDiscountDate().minute;

      targetGender = currentDiscount.getTargetGender();

      hasAgeLimit = currentDiscount.getHasAgeLimit()? 1 : 0;

      _ageLimitLowerLimitController = TextEditingController(
          text: currentDiscount.getAgeLimitLowerLimit().toString()
      );
      _ageLimitUpperLimitController = TextEditingController(
          text: currentDiscount.getAgeLimitUpperLimit().toString()
      );

      hasUsageLimit = currentDiscount.getHasUsageLimit() ? 1 : 0;

      _discountNumberOfUsagesController = TextEditingController(
          text: currentDiscount.getNumberOfUsages().toString()
      );

      _discountDescriptionController = TextEditingController(
          text: currentDiscount.getDiscountDescription()
      );

      isRepeated = currentDiscount.getIsRepeated() ? 1 : 0;

      switch(currentDiscount.getIsRepeatedDays()){
        case(7):
          isRepeatedIndex = 0;
          break;
        case(14):
          isRepeatedIndex = 1;
          break;
      }

      isTemplate = 1;

    }else{

      _discountTitleController = TextEditingController();

      newSelectedDate = DateTime.now();

      _ageLimitLowerLimitController = TextEditingController(text: "18");
      _ageLimitUpperLimitController = TextEditingController(text: "99");

      _discountDescriptionController = TextEditingController();

      _discountNumberOfUsagesController = TextEditingController();

      _fixedExtentScrollController1 = FixedExtentScrollController(initialItem: 0);
      _fixedExtentScrollController2 = FixedExtentScrollController(initialItem: 0);

    }
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

              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => clickEventClose(),
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
                        style: customStyleClass.getFontStyleHeadline1Bold(),
                      ),
                    ],
                  )
              )
            ],
          )
      ),
    );
  }
  Widget _buildMainView(){
    return Container(
        color: customStyleClass.backgroundColorMain,
        width: screenWidth,
        height: screenHeight,
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
                        width: screenWidth*0.9,
                        padding:  EdgeInsets.only(
                            top: distanceBetweenTitleAndTextField
                        ),
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
                              alignment: Alignment.centerLeft,
                              height: screenHeight*0.12,
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

                                      // TEXT: time limit
                                      SizedBox(
                                        width: screenWidth*0.28,
                                        child: Text(
                                          "Zeitlimit",
                                          style: customStyleClass.getFontStyle3(),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),

                                      // TOGGLE SWITCH
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
                                      width: screenWidth*0.28,
                                      padding:  EdgeInsets.only(
                                          top: distanceBetweenTitleAndTextField
                                      ),
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
                            fontSize: customStyleClass.getFontSize4(),
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
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  children: [

                                    // Text: AgeLimit
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Alterbeschränkung",
                                        style: customStyleClass.getFontStyle3(),
                                      ),
                                    ),

                                    // Toggle switch
                                    Container(
                                      padding:  EdgeInsets.only(
                                          top: distanceBetweenTitleAndTextField
                                      ),
                                      width: screenWidth*0.45,
                                      alignment: Alignment.centerLeft,
                                      child: ToggleSwitch(
                                        minHeight: screenHeight*0.07,
                                        initialLabelIndex: hasAgeLimit,
                                        totalSwitches: 2,
                                        activeBgColor: [customStyleClass.primeColor],
                                        activeFgColor: Colors.white,
                                        inactiveFgColor: Colors.white,
                                        inactiveBgColor:customStyleClass.backgroundColorEventTile,
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

                            // Text, TextField: From - To
                            if(hasAgeLimit != 0)
                              Container(
                                padding:  EdgeInsets.only(
                                    top: distanceBetweenTitleAndTextField+5
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
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
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
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
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


                            SizedBox(
                              width: screenWidth*0.45,
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
                                      inactiveBgColor:customStyleClass.backgroundColorEventTile,
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
                                child: CupertinoPicker(
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
                        child: Text(
                          "Beschreibung des Coupons",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ),

                      // TextField: Description
                      Container(
                        width: screenWidth*0.9,
                        padding:  EdgeInsets.only(
                            top: distanceBetweenTitleAndTextField
                        ),
                        child: TextField(
                          controller: _discountDescriptionController,
                          cursorColor: customStyleClass.primeColor,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Erzähle deinen Kunden etwas über den Coupon!",
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

                                if(galleryImageChosen)
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
                                    scrollController: _fixedExtentScrollController1,
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

                      // Text: "Save as template"
                      if(isTemplate != 1)
                        Container(
                          width: screenWidth*0.9,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [

                              // TEXT
                              Container(
                                  width: screenWidth*0.9,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Als Vorlage speichern",
                                    style: customStyleClass.getFontStyle3(),
                                  )
                              ),

                              // TOGGLESWITCH
                              Container(
                                padding:  EdgeInsets.only(
                                    top: distanceBetweenTitleAndTextField
                                ),
                                width: screenWidth*0.9,
                                alignment: Alignment.centerLeft,
                                child: ToggleSwitch(
                                  minHeight: screenHeight*0.07,
                                  initialLabelIndex: isSupposedToBeTemplate,
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
                                      isSupposedToBeTemplate == 0 ? isSupposedToBeTemplate = 1 : isSupposedToBeTemplate = 0;
                                    });
                                  },
                                ),
                              )

                            ],
                          ),
                        ),


                      // Spacer
                      SizedBox(
                        height: screenHeight*0.2,
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

                      // Cupertino pickers
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
                                      selectedMinute=index*15;
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
  Widget _buildBottomNavigationBar(){
    return Container(
      width: screenWidth,
      height: 80,
      decoration: BoxDecoration(
          color: customStyleClass.backgroundColorMain,
          border: Border(
              top: BorderSide(
                  color: Colors.grey[900]!
              )
          )
      ),

      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(
          right: 10,
          // bottom: 10
      ),
      child: showGallery ?
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
          ):
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
        onTap: () => clickEventProcessNewDiscount(),
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
            // color: Colors.green,
            height: screenHeight*0.15,
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

  // DB
  void buildNewDiscount(
      StateProvider stateProvider,
      TextEditingController titleController,
      TextEditingController numberOfUsagesController,
      DateTime discountDate
      )async{

    var uuid = const Uuid();
    var uuidV4 = uuid.v4();

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

        discountId: uuidV4.toString(),
        clubId: userDataProvider.getUserClubId(),
        clubName: userDataProvider.getUserClubName(),
        bannerId: userDataProvider.getUserClubEventBannerId(),

        discountTitle: titleController.text,
        discountDate: discountDate,
        discountDescription: _discountDescriptionController.text,

        hasTimeLimit:  hasTimeLimit  == 0 ? false : true,
        hasUsageLimit: hasUsageLimit == 0 ? false : true,
        hasAgeLimit:   hasAgeLimit   == 0 ? false : true,

        priorityScore: 0,
        howOftenRedeemed: 0,
        targetGender: targetGender,
        numberOfUsages: numberOfUsageForDb,

        ageLimitLowerLimit: int.parse(_ageLimitLowerLimitController.text),
        ageLimitUpperLimit: int.parse(_ageLimitUpperLimitController.text),

         isRepeatedDays: isRepeatedDaysToSave,
        bigBannerFileName: Utils.discountBigImageNames[_currentPageIndex],
        smallBannerFileName: Utils.discountSmallImageNames[_currentPageIndex]
    );

    if(isSupposedToBeTemplate == 1){
      addDiscountToTemplates(clubMeDiscount);
    }

    try{
      await _supabaseService.insertDiscount(clubMeDiscount).then((value){
        if(value == 0){
          fetchedContentProvider.addDiscountToFetchedDiscounts(clubMeDiscount);
          fetchedContentProvider.sortFetchedDiscounts();
          stateProvider.resetCurrentDiscountTemplate();
          stateProvider.resetDiscountTemplates();
          _checkAndFetchService.checkAndFetchDiscountImageAfterCreation
            (clubMeDiscount.getBigBannerFileName(),
              stateProvider,
              fetchedContentProvider
          );
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
  void addDiscountToTemplates(ClubMeDiscount discount){

    var uuid = const Uuid();
    var uuidV4 = uuid.v4();

    ClubMeDiscountTemplate clubMeDiscountTemplate = ClubMeDiscountTemplate(
        discountTitle: discount.getDiscountTitle(),
        numberOfUsages: discount.getNumberOfUsages(),
        discountDate: discount.getDiscountDate(),
        hasTimeLimit: discount.getHasTimeLimit(),
        hasUsageLimit: discount.getHasUsageLimit(),
        discountDescription: discount.getDiscountDescription(),
        targetGender: targetGender,
        hasAgeLimit: discount.getHasAgeLimit(),
        ageLimitLowerLimit: discount.getAgeLimitLowerLimit(),
        ageLimitUpperLimit: discount.getAgeLimitUpperLimit(),
        isRepeatedDays: discount.getIsRepeatedDays(),
        templateId:  uuidV4.toString(),
    );

    _hiveService.addDiscountTemplate(clubMeDiscountTemplate);
  }


  // CLICK EVENT
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
                  style: customStyleClass.getFontStyle3(),
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
              secondButtonToDisplay: TextButton(
                child: Text(
                  "Ja",
                  style: customStyleClass.getFontStyle3(),
                ),
                onPressed: (){
                  stateProvider.resetCurrentDiscountTemplate();
                  switch(stateProvider.pageIndex){
                    case(2): context.go('/club_discounts');
                    case(3): context.go('/club_frontpage');
                    default: context.go('/club_frontpage');
                  }
                },
              ));
        }
    );
  }
  void clickEventChooseImage(){
    setState(() {
      showGallery = false;
      galleryImageChosen = true;
    });
  }
  void clickEventProcessNewDiscount(){

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

    setState(() {
      isUploading = true;
    });

    if(_discountTitleController.text.isEmpty){
      showDialogOfMissingValue();
    }else{

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

      setState(() {
        isUploading = true;
      });

      buildNewDiscount(
          stateProvider,
          _discountTitleController,
          _discountNumberOfUsagesController,
          concatenatedDate
      );
    }
  }


  // FORMAT
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


  // MISC
  void showDialogOfMissingValue(){
    showDialog(context: context,
        builder: (BuildContext context){
          return TitleAndContentDialog(
              titleToDisplay: "Fehlende Werte",
              contentToDisplay: "Bitte fülle die leeren Felder aus, bevor du weitergehst.");
        });
  }
  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }


  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    customStyleClass = CustomStyleClass(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      extendBody: true,

      appBar: _buildAppBar(),
      body: _buildMainView(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
