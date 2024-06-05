import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../provider/state_provider.dart';
import '../../services/supabase_service.dart';
import '../custom_text_style.dart';

class DiscountDetailView extends StatefulWidget {
  const DiscountDetailView({Key? key}) : super(key: key);

  @override
  State<DiscountDetailView> createState() => _DiscountDetailViewState();
}

class _DiscountDetailViewState extends State<DiscountDetailView>
    with RestorationMixin{

  final SupabaseService _supabaseService = SupabaseService();

  late int hasTimeLimit;
  late int hasUsageLimit;

  bool initFinished = false;

  bool isUploading = false;
  bool isDateSelected = false;

  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;

  late StateProvider stateProvider;

  late TextEditingController _discountTitleController;
  late TextEditingController _discountDescriptionController;
  late TextEditingController _discountNumberOfUsagesController;

  late CustomTextStyle customTextStyle;

  var newDiscountContainerHeightFactor = 0.85;
  var discountContainerHeightFactor = 0.62;


  @override
  // TODO: implement restorationId
  String? get restorationId => "test";

  late final RestorableDateTime _selectedDate =
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
  static Route<DateTime> _datePickerRoute(BuildContext context, Object? arguments,) {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
        ));
      });
    }
  }

  void leavePage(StateProvider stateProvider){

    // Reset values ?

    context.go("/club_coupons");
  }

  void finishUpdateDiscount() async{

    late DateTime concatenatedDate;

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
          _selectedDate.value.year,
          _selectedDate.value.month,
          _selectedDate.value.day,
          23,
          59
      );
    }else{
      concatenatedDate = DateTime(
          _selectedDate.value.year,
          _selectedDate.value.month,
          _selectedDate.value.day,
          selectedHour,
          selectedMinute
      );
    }

    stateProvider.clubMeDiscount.setDiscountDate(concatenatedDate);

    try{
      setState(() {
        isUploading = true;
      });
      _supabaseService.updateCompleteDiscount(stateProvider);
      context.go('/club_coupons');
    }catch(e){
      print("Error in buildNewDiscount: $e");
      showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext){
          return const Text("Sorry, something went wrong!");
        });
    }
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
          Container(
              width: screenWidth*0.9,
              height: screenHeight*newDiscountContainerHeightFactor,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(
                  // right: screenWidth*0.01,
                  // bottom: screenHeight*0.01
                ),
                child: GestureDetector(
                  child: Container(
                      width: screenWidth*0.35,
                      height: screenHeight*0.07,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              stateProvider.getPrimeColorDark(),
                              stateProvider.getPrimeColor(),
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
                        borderRadius: const BorderRadius.all(
                            Radius.circular(10)
                        ),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: const Center(
                        child: Text(
                          "Abschließen!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                  ),
                  onTap: () => finishUpdateDiscount(),
                ),
              )
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);

    customTextStyle = CustomTextStyle(context: context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if(!initFinished){
      _selectedDate.value = stateProvider.clubMeDiscount.getDiscountDate();

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

        bottomNavigationBar: _buildNavBar(screenHeight, screenWidth),

        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: const Text("Discount Details"),

            leading: GestureDetector(
              child:
              const Icon(
                Icons.clear_rounded,
                color: Colors.grey,
                // size: 20,
              ),
              onTap: (){
                leavePage(stateProvider);
              },
            )

        ),

        body: SizedBox(
          height: screenHeight,
          width: screenWidth,
          child: SingleChildScrollView(
            child: SizedBox(
              // padding: EdgeInsets.only(top: screenHeight*0.05),
              height: screenHeight*1,
              child: Center(
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
                                stateProvider.getPrimeColor().withOpacity(0.4)
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
                                stateProvider.getPrimeColor().withOpacity(0.2)
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

                            // Headline 'Please check if everything is fine'
                            Container(
                              width: screenWidth,
                              // color: Colors.red,
                              padding: EdgeInsets.only(
                                  left: screenWidth*0.05,
                                  top: screenHeight*0.03
                              ),
                              child: const Text(
                                "Überprüfe bitte, ob alles korrekt ist!",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            // Headline Title
                            Container(
                              width: screenWidth,
                              // color: Colors.red,
                              padding: EdgeInsets.only(
                                  left: screenWidth*0.05,
                                  top: screenHeight*0.03
                              ),
                              child: Text(
                                "Titel",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: screenWidth*0.05,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            // Textfield
                            SizedBox(
                              width: screenWidth*0.8,
                              child: TextField(
                                controller: _discountTitleController,
                              ),
                            ),

                            // Headline
                            Container(
                              width: screenWidth,
                              // color: Colors.red,
                              padding: EdgeInsets.only(
                                  left: screenWidth*0.05,
                                  top: screenHeight*0.03
                              ),
                              child: Text(
                                "Datum",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: screenWidth*0.05,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            // Date
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
                                        _selectedDate.value.toString().substring(0, 10),
                                        style: const TextStyle(
                                            fontSize: 18
                                        ),
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

                            // Headline
                            Container(
                              width: screenWidth,
                              // color: Colors.red,
                              padding: EdgeInsets.only(
                                  left: screenWidth*0.05,
                                  top: screenHeight*0.03
                              ),
                              child: Text(
                                "Beschreibung",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: screenWidth*0.05,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),

                            // Textfield
                            SizedBox(
                              width: screenWidth*0.8,
                              child: TextField(
                                controller: _discountDescriptionController,
                              ),
                            ),

                            SizedBox(
                              height: screenHeight*0.02,
                            ),

                            // Headline 'Time limit'
                            Container(
                              width: screenWidth,
                              // color: Colors.red,
                              padding: EdgeInsets.only(
                                  left: screenWidth*0.05,
                                  top: screenHeight*0.03
                              ),
                              child: Text(
                                "Zeitlimit",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: screenWidth*0.05,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
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
                                          Container(
                                            // width: screenWidth*0.3,
                                            alignment: Alignment.center,
                                            child: DropdownButton<int>(
                                              value: selectedHour,
                                              itemHeight: screenHeight*0.08,
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
                                                    child: Center(
                                                      child: Text(
                                                        '$index',
                                                        style: TextStyle(
                                                            fontSize: screenWidth*0.08
                                                        ),
                                                      ),
                                                    ),
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
                                              itemHeight: screenHeight*0.08,
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
                                                    child: Center(
                                                      child: Text(
                                                        '$index',
                                                        style: TextStyle(
                                                            fontSize: screenWidth*0.08
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ) :Row(mainAxisAlignment: MainAxisAlignment.center,children: [],),
                                  )
                                ],
                              ),
                            ),

                            // Headline 'Usage limit'
                            Container(
                              width: screenWidth,
                              // color: Colors.red,
                              padding: EdgeInsets.only(
                                  left: screenWidth*0.05,
                                  top: screenHeight*0.03
                              ),
                              child: Text(
                                "Nutzungslimit",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: screenWidth*0.05,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
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
                            )

                          ],
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),
        )
    );
  }

}
