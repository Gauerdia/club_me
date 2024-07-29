import 'package:club_me/models/club_me_discount_template.dart';
import 'package:club_me/models/discount.dart';
import 'package:club_me/services/hive_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final HiveService _hiveService = HiveService();

  late TextEditingController _discountTitleController;
  late TextEditingController _discountAgeLimitController;
  late TextEditingController _discountDescriptionController;
  late TextEditingController _discountNumberOfUsagesController;

  late FixedExtentScrollController _fixedExtentScrollController1;
  late FixedExtentScrollController _fixedExtentScrollController2;

  bool isUploading = false;
  bool isDateSelected = false;

  int isTemplate = 0;

  bool dateUnfold = false;
  bool titleUnfold = false;
  bool genderUnfold = false;
  bool ageLimitUnfold = false;
  bool timeLimitUnfold = false;
  bool usageLimitUnfold = false;
  bool descriptionUnfold = false;
  bool templateUnfold = false;

  int hasTimeLimit = 0;
  int hasUsageLimit = 0;
  int hasAgeLimit = 0;
  int creationIndex = 0;
  int targetGender = 0;
  int ageLimitIsUpperLimit = 0;
  int selectedFirstElement = 0;
  int selectedSecondElement = 0;
  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;



  // double discountContainerHeightFactor = 0.62;
  double newDiscountContainerHeightFactor = 0.3;

  double originalFoldHeightFactor = 0.08;
  double titleTileHeightFactor = 0.08;
  double originalTitleTileHeightFactor = 0.08;
  double dateTileHeightFactor = 0.08;
  double originalDateTileHeightFactor = 0.08;
  double timeLimitTileHeightFactor = 0.08;
  double usageLimitTileHeightFactor = 0.08;
  double ageLimitTileHeightFactor = 0.08;
  double genderTileHeightFactor = 0.08;
  double descriptionTileHeightFactor = 0.08;
  double templateTileHeightFactor = 0.08;


  @override
  void initState() {
    super.initState();

    final stateProvider = Provider.of<StateProvider>(context, listen:  false);
    if (stateProvider.getCurrentDiscountTemplate() != null){

      ClubMeDiscountTemplate? currentDiscount = stateProvider.getCurrentDiscountTemplate();

      _discountTitleController = TextEditingController(
        text: currentDiscount?.getDiscountTitle()
      );
      _discountAgeLimitController = TextEditingController(
          text: currentDiscount?.getTargetAge().toString()
      );
      _discountDescriptionController = TextEditingController(
          text: currentDiscount?.getDiscountDescription()
      );
       _discountNumberOfUsagesController = TextEditingController(
           text: currentDiscount?.getNumberOfUsages().toString()
       );
       newSelectedDate = currentDiscount!.getDiscountDate();
       hasTimeLimit = currentDiscount.getHasTimeLimit() ? 1:0;
       selectedHour = currentDiscount.getDiscountDate().hour;
       selectedFirstElement = currentDiscount.getDiscountDate().hour;
       selectedSecondElement = currentDiscount.getDiscountDate().minute;
       selectedMinute = currentDiscount.getDiscountDate().minute;
       hasUsageLimit = currentDiscount.getHasUsageLimit() ? 1:0;
       targetGender = currentDiscount.getTargetGender();
       hasAgeLimit = currentDiscount.getTargetAge() != 0 ? 1:0;

       isTemplate = 1;
    }else{
      _discountTitleController = TextEditingController();
      _discountAgeLimitController = TextEditingController();
      _discountDescriptionController = TextEditingController();
      _discountNumberOfUsagesController = TextEditingController();
      newSelectedDate = DateTime.now();
    }


  }

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
        discountDescription: _discountDescriptionController.text,
        targetGender: targetGender,
        targetAge: hasAgeLimit == 1? int.parse(_discountAgeLimitController.text) : 0,
        targetAgeIsUpperLimit: hasAgeLimit == 1 ? ageLimitIsUpperLimit == 0 ? true : false : false
    );

    if(isTemplate == 1){
      addDiscountToTemplates(clubMeDiscount);
    }

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

  void addDiscountToTemplates(ClubMeDiscount discount){
    ClubMeDiscountTemplate clubMeDiscountTemplate = ClubMeDiscountTemplate(
        discountTitle: discount.getDiscountTitle(),
        numberOfUsages: discount.getNumberOfUsages(),
        discountDate: discount.getDiscountDate(),
        hasTimeLimit: discount.getHasTimeLimit(),
        hasUsageLimit: discount.getHasUsageLimit(),
        discountDescription: discount.getDiscountDescription(),
        targetGender: targetGender,
        targetAge: discount.getTargetAge(),
        targetAgeIsUpperLimit: discount.getTargetAgeIsUpperLimit()
    );

    _hiveService.addDiscountTemplate(clubMeDiscountTemplate);
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
                              titleTileHeightFactor = originalTitleTileHeightFactor;
                              titleUnfold = false;
                            }else{
                              titleTileHeightFactor = originalTitleTileHeightFactor*3.5;
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
                  "Wie soll der Coupon heißen?",
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
                    controller: _discountTitleController,
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
                          "Datum",
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
                              dateTileHeightFactor = originalDateTileHeightFactor;
                              dateUnfold = false;
                            }else{
                              dateTileHeightFactor = originalDateTileHeightFactor*3.5;
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
                  "Wann soll der Coupon verfügbar sein?",
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

              ],
            ),
          ),
        )

      ],
    );
  }

  Widget _buildTimeLimitTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(timeLimitTileHeightFactor+0.004),
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
          height: screenHeight*timeLimitTileHeightFactor,
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
          height: screenHeight*timeLimitTileHeightFactor,
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
              height: screenHeight*timeLimitTileHeightFactor,
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
            height: screenHeight*timeLimitTileHeightFactor,
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

                // Headline + Icon
                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Zeitlimit",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            timeLimitUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(timeLimitUnfold){
                              timeLimitTileHeightFactor = originalFoldHeightFactor;
                              timeLimitUnfold = false;
                            }else{
                              if( hasTimeLimit == 1){
                                timeLimitTileHeightFactor = originalFoldHeightFactor*4.5;
                              }else{
                                timeLimitTileHeightFactor = originalFoldHeightFactor*3;
                              }

                              timeLimitUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                timeLimitUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                timeLimitUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                timeLimitUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // QUestion
                timeLimitUnfold ? Text(
                  "Ist der Coupon zeitlich begrenzt?",
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Toggle switch
                timeLimitUnfold ?SizedBox(
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
                            setState(() {
                              hasTimeLimit = 1;
                              timeLimitTileHeightFactor = originalFoldHeightFactor*4.5;
                            });
                          }else{
                            setState(() {
                              hasTimeLimit = 0;
                              timeLimitTileHeightFactor = originalFoldHeightFactor*3;
                            });
                          }
                          print('switched to: $index');
                        });
                      },
                    ),
                  ),
                ):Container(),

                (timeLimitUnfold && hasTimeLimit == 1) ? Text(
                  "Bis wie viel Uhr soll der Coupon gültig sein?",
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                (timeLimitUnfold && hasTimeLimit == 1) ?SizedBox(
                  height: screenHeight*0.02,
                ):Container(),

                // Dropdown
                (timeLimitUnfold && hasTimeLimit == 1) ? SizedBox(
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
                ): Container(),

              ],
            ),
          ),
        )

      ],
    );
  }

  Widget _buildUsageLimitTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(usageLimitTileHeightFactor+0.004),
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
          height: screenHeight*usageLimitTileHeightFactor,
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
          height: screenHeight*usageLimitTileHeightFactor,
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
              height: screenHeight*usageLimitTileHeightFactor,
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
            height: screenHeight*usageLimitTileHeightFactor,
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
                          "Nutzungslimit",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            usageLimitUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(usageLimitUnfold){
                              usageLimitTileHeightFactor = originalDateTileHeightFactor;
                              usageLimitUnfold = false;
                            }else{
                              if(hasUsageLimit == 1){
                                usageLimitTileHeightFactor = originalDateTileHeightFactor*6;
                              }else{
                                usageLimitTileHeightFactor = originalDateTileHeightFactor*3.5;
                              }
                              usageLimitUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                usageLimitUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                usageLimitUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                usageLimitUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                usageLimitUnfold ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10
                  ),
                  child: Text(
                    "Darf der Coupon nur begrenzt oft genutzt werden?",
                    textAlign: TextAlign.center,
                    style: customTextStyle.getFontStyle3(),
                  ),
                ):Container(),

                // Toggle switch
                usageLimitUnfold ?SizedBox(
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
                            setState(() {
                              hasUsageLimit = 1;
                              usageLimitTileHeightFactor = originalFoldHeightFactor*6;
                            });
                          }else{
                            setState(() {
                              hasUsageLimit = 0;
                              usageLimitTileHeightFactor = originalFoldHeightFactor*3.5;
                            });
                          }
                          print('switched to: $index');
                        });
                      },
                    ),
                  ),
                ):Container(),

                (usageLimitUnfold && hasUsageLimit == 1) ? Text(
                  "Wie oft darf der Coupon pro Person verwendet werden?",
                  textAlign: TextAlign.center,
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                (usageLimitUnfold && hasUsageLimit == 1)  ?SizedBox(
                  height: screenHeight*0.02,
                ):Container(),

                // Textfield
                (usageLimitUnfold && hasUsageLimit == 1) ? SizedBox(
                  width: screenWidth*0.2,
                  child: hasUsageLimit == 1 ?
                  SizedBox(
                    // width: screenWidth*0.1,
                    child: TextField(
                        textAlign: TextAlign.center,
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder()
                        ),
                        controller: _discountNumberOfUsagesController,
                        style: customTextStyle.sizeNumberFieldItem()
                    ),
                  ):Container(),
                ):Container()
              ],
            ),
          ),
        )

      ],
    );
  }

  Widget _buildGenderTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(genderTileHeightFactor+0.004),
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
          height: screenHeight*genderTileHeightFactor,
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
          height: screenHeight*genderTileHeightFactor,
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
              height: screenHeight*genderTileHeightFactor,
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
            height: screenHeight*genderTileHeightFactor,
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
                          "Geschlecht",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            genderUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(genderUnfold){
                              genderTileHeightFactor = originalDateTileHeightFactor;
                              genderUnfold = false;
                            }else{
                              genderTileHeightFactor = originalDateTileHeightFactor*3.5;
                              genderUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                genderUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                genderUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                genderUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                genderUnfold ? Text(
                  "Welchen Geschlechtern soll der Coupon vorgeschlagen werden?",
                  textAlign: TextAlign.center,
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                genderUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),


                // toggle yes,no: gender
                genderUnfold ?
                SizedBox(
                  width: screenWidth*0.8,
                  child:  Center(
                    child: ToggleSwitch(
                      initialLabelIndex: targetGender,
                      totalSwitches: 3,
                      activeBgColor: [customTextStyle.primeColor],
                      activeFgColor: Colors.white,
                      inactiveBgColor: const Color(0xff11181f),
                      labels: const [
                        'Allen',
                        'Männern',
                        'Frauen',
                      ],
                      fontSize: screenHeight*stateProvider.getFontSizeFactor6(),
                      minWidth: screenWidth*0.25,
                      onToggle: (index) {
                        setState(() {
                          targetGender = index!;
                          print('switched taget gender to: $index');
                        });
                      },
                    ),
                  ),
                ):Container()

              ],
            ),
          ),
        )

      ],
    );
  }

  Widget _buildAgeLimitTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(ageLimitTileHeightFactor+0.004),
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
          height: screenHeight*ageLimitTileHeightFactor,
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
          height: screenHeight*ageLimitTileHeightFactor,
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
              height: screenHeight*ageLimitTileHeightFactor,
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
            height: screenHeight*ageLimitTileHeightFactor,
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

                // Text + Icon
                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Alter",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            ageLimitUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(ageLimitUnfold){
                              ageLimitTileHeightFactor = originalDateTileHeightFactor;
                              ageLimitUnfold = false;
                            }else{
                              if(hasAgeLimit == 1){
                                ageLimitTileHeightFactor = originalDateTileHeightFactor*7.5;
                              }else{
                                ageLimitTileHeightFactor = originalDateTileHeightFactor*3.5;
                              }
                              ageLimitUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                ageLimitUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                ageLimitUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Spacer
                ageLimitUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // Question
                ageLimitUnfold ? Text(
                  "Soll es eine Altersbeschränkung geben?",
                  textAlign: TextAlign.center,
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Toggle switch
                ageLimitUnfold ?SizedBox(
                  width: screenWidth*0.4,
                  height: screenHeight*0.1,
                  child:  Center(
                    child: ToggleSwitch(
                      initialLabelIndex: hasAgeLimit,
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
                          if(hasAgeLimit == 0){
                            setState(() {
                              hasAgeLimit = 1;
                              ageLimitTileHeightFactor = originalDateTileHeightFactor*7.5;
                            });
                          }else{
                            setState(() {
                              hasAgeLimit = 0;
                              ageLimitTileHeightFactor = originalDateTileHeightFactor*3.5;
                            });
                          }
                        });
                      },
                    ),
                  ),
                ):Container(),

                // Spacer
                ageLimitUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // Question
                (ageLimitUnfold && hasAgeLimit == 1) ? Text(
                  "Ab welchem Alter soll die Beschränkung gelten?",
                  textAlign: TextAlign.center,
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                (ageLimitUnfold && hasAgeLimit == 1) ?SizedBox(
                  height: screenHeight*0.02,
                ):Container(),

                // Textfield
                (ageLimitUnfold && hasAgeLimit == 1) ?SizedBox(
                  width: screenWidth*0.2,
                  child: hasAgeLimit == 1 ?
                  SizedBox(
                    // width: screenWidth*0.1,
                    child: TextField(
                        textAlign: TextAlign.center,
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: _discountAgeLimitController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder()
                        ),
                        style: customTextStyle.sizeNumberFieldItem()
                    ),
                  ):Container(),
                ):Container(),

                // Spacer
                (ageLimitUnfold && hasAgeLimit == 1) ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // Question
                (ageLimitUnfold && hasAgeLimit == 1) ? Text(
                  "Soll die Beschränkung ab oder bis zu diesem Alter gelten?",
                  textAlign: TextAlign.center,
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                (ageLimitUnfold && hasAgeLimit == 1) ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // toggle yes,no: ageLimitIsUpperLimit
                ageLimitUnfold ? hasAgeLimit == 1 ?
                SizedBox(
                  width: screenWidth*0.8,
                  child:  Center(
                    child: ToggleSwitch(
                      initialLabelIndex: ageLimitIsUpperLimit,
                      totalSwitches: 2,
                      activeBgColor: [customTextStyle.primeColor],
                      activeFgColor: Colors.white,
                      inactiveBgColor: const Color(0xff11181f),
                      labels: const [
                        'Ab diesem Alter',
                        'Bis zu diesem Alter',
                      ],
                      fontSize: screenHeight*stateProvider.getFontSizeFactor6(),
                      minWidth: screenWidth*0.45,
                      onToggle: (index) {
                        setState(() {
                          ageLimitIsUpperLimit = index!;
                        });
                      },
                    ),
                  ),
                ):Container():Container(),

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
                              descriptionTileHeightFactor = originalDateTileHeightFactor;
                              descriptionUnfold = false;
                            }else{
                              descriptionTileHeightFactor = originalDateTileHeightFactor*7;
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

                descriptionUnfold ? Text(
                  "Erzähl deinen Kunden ein wenig über den Coupon!",
                  textAlign: TextAlign.center,
                  style: customTextStyle.getFontStyle3(),
                ):Container(),

                // Spacer
                descriptionUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),


                descriptionUnfold ? SizedBox(
                  width: screenWidth*0.8,
                  child: TextField(
                    controller: _discountDescriptionController,
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

  Widget _buildTemplateTile(){
    return Stack(
      children: [

        // Colorful accent
        Container(
          width: screenWidth*0.91,
          height: screenHeight*(templateTileHeightFactor+0.004),
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
          height: screenHeight*templateTileHeightFactor,
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
          height: screenHeight*templateTileHeightFactor,
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
              height: screenHeight*templateTileHeightFactor,
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
            height: screenHeight*templateTileHeightFactor,
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

                // Text+Icon
                Container(
                  width: screenWidth*0.8,
                  padding: EdgeInsets.only(
                      top: screenHeight*0.01
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Vorlage",
                          textAlign: TextAlign.left,
                          style: customTextStyle.size1Bold()
                      ),
                      IconButton(
                        icon: Icon(
                            templateUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down
                        ),
                        onPressed: (){
                          setState(() {
                            if(templateUnfold){
                              templateTileHeightFactor = originalFoldHeightFactor;
                              templateUnfold = false;
                            }else{
                              templateTileHeightFactor = originalFoldHeightFactor*4;
                              templateUnfold = true;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),

                // Spacer
                templateUnfold ?SizedBox(
                  height: screenHeight*0.01,
                ):Container(),

                // White line
                templateUnfold ?
                const Divider(
                  height:10,
                  thickness: 1,
                  color: Colors.grey,
                  // indent: screenWidth*0.06,
                  // endIndent: screenWidth*0.75,
                ): Container(),

                // Explanation
                templateUnfold ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10
                    ),
                    child: Text(
                      "Möchtest du den Coupon als Vorlage speichern?",
                      textAlign: TextAlign.center,
                      style: customTextStyle.getFontStyle3(),
                    )
                ):Container(),

                // Spacer
                templateUnfold ?SizedBox(
                  height: screenHeight*0.03,
                ):Container(),

                // Toggle
                templateUnfold ?SizedBox(
                  width: screenWidth*0.4,
                  height: screenHeight*0.1,
                  child:  Center(
                    child: ToggleSwitch(
                      initialLabelIndex: isTemplate,
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
                          isTemplate == 0 ? isTemplate = 1 : isTemplate = 0;
                        });
                      },
                    ),
                  ),
                ):Container(),

              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildFinalOverview2(){

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
                "Bitte gib die passenden Daten zu deinem Coupon an!",
                textAlign: TextAlign.center,
                style: customTextStyle.size1Bold(),
              ),
            ),

            _buildTitleTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            _buildDateTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            _buildTimeLimitTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            _buildUsageLimitTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            _buildGenderTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            _buildAgeLimitTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            _buildDescriptionTile(),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

            isTemplate == 1 ? Container() : _buildTemplateTile(),

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

          // Right button
          isUploading ? Padding(
            padding: EdgeInsets.only(
                top: screenHeight*0.02
              // right: screenWidth*0.05,
              // bottom: screenHeight*0.03
            ),
            child: const Align(
              alignment: AlignmentDirectional.center,
              child: CircularProgressIndicator(),
            ),
          ):Padding(
            padding: EdgeInsets.only(
                top: screenHeight*0.02
              // right: screenWidth*0.04,
              // bottom: screenHeight*0.015
            ),
            child: Align(
                alignment: AlignmentDirectional.center,
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
                      "Coupon kreieren!",
                      // creationIndex == 5 ? "Abschicken!":"Weiter!",
                      style:customTextStyle.size4Bold(),
                    ),
                  ),
                  onTap: () => iterateScreen(),
                )
            ),
          )

          // Left button
          // creationIndex != 0 ? Padding(
          //   padding: EdgeInsets.only(
          //       left: screenWidth*0.04,
          //       bottom: screenHeight*0.015
          //   ),
          //   child: Align(
          //       alignment: AlignmentDirectional.bottomStart,
          //       child: GestureDetector(
          //         child: Container(
          //           padding: EdgeInsets.symmetric(
          //               horizontal: screenWidth*0.035,
          //               vertical: screenHeight*0.02
          //           ),
          //           decoration: BoxDecoration(
          //             borderRadius: const BorderRadius.all(
          //                 Radius.circular(10)
          //             ),
          //             gradient: LinearGradient(
          //                 colors: [
          //                   customTextStyle.primeColorDark,
          //                   customTextStyle.primeColor,
          //                 ],
          //                 begin: Alignment.topLeft,
          //                 end: Alignment.bottomRight,
          //                 stops: const [0.2, 0.9]
          //             ),
          //             boxShadow: const [
          //               BoxShadow(
          //                 color: Colors.black54,
          //                 spreadRadius: 1,
          //                 blurRadius: 7,
          //                 offset: Offset(3, 3),
          //               ),
          //             ],
          //           ),
          //           child: Text(
          //             "Zurück!",
          //             style: customTextStyle.size4Bold(),
          //           ),
          //         ),
          //         onTap: () => deiterateScreen(),
          //       )
          //   ),
          // ): Container(),


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
                  onPressed: () => clickedOnAbort(),
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

    if(_discountTitleController.text == "" || _discountDescriptionController.text == ""){
      showDialogOfMissingValue();
    }else{
      clickedOnFinalNextButton();
    }


    // if( (creationIndex == 0 && _discountTitleController.text == "") ||
    //     (creationIndex == 4 && _discountDescriptionController.text == "")
    //   ){
    //   showDialogOfMissingValue();
    // }else{
    //   if(creationIndex != 5){
    //     setState(() {
    //       creationIndex++;
    //     });
    //   }else{
    //     clickedOnFinalNextButton();
    //   }
    // }
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
  void clickedOnAbort(){

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              title: Text("Abbrechen"),
              content: Text("Bist du sicher, dass du abbrechen möchtest?"),
              actions: [

                TextButton(
                  child: Text("Zurück"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                ),

                TextButton(
                  child: Text("Ja"),
                  onPressed: (){
                    switch(stateProvider.pageIndex){
                      case(2): context.go('/club_coupons');
                      case(3): context.go('/club_frontpage');
                      default: context.go('/club_frontpage');
                    }
                  },
                ),

              ]
          );
        }
    );
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
              // child: _buildCreationStep()
            child: _buildFinalOverview2()
          )

      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
