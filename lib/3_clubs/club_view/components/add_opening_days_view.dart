import 'package:club_me/models/special_opening_times.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../provider/state_provider.dart';
import '../../../provider/user_data_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../shared/custom_bottom_navigation_bar_clubs.dart';
import '../../../shared/custom_text_style.dart';
import '../../../shared/dialogs/title_content_and_button_dialog.dart';

class AddOpeningDaysView extends StatefulWidget {
  const AddOpeningDaysView({super.key});

  @override
  State<AddOpeningDaysView> createState() => _AddOpeningDaysViewState();
}

class _AddOpeningDaysViewState extends State<AddOpeningDaysView> {

  String headLine = "Öffnungstag hinzufügen";

  bool initDone = false;
  bool sendClicked = false;

  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;
  late CustomStyleClass customStyleClass;
  late double screenWidth, screenHeight;

  bool showAddNewSpecialOpeningTime = true;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  late FixedExtentScrollController _openingHourController;
  late FixedExtentScrollController _openingMinuteController;
  late FixedExtentScrollController _closingHourController;
  late FixedExtentScrollController _closingMinuteController;

  int selectedDay = 1, selectedMonth = 1, selectedYear = 2024;
  int selectedOpeningHour = 0, selectedOpeningMinute = 0;
  int selectedClosingHour = 0, selectedClosingMinute = 0;

  final SupabaseService _supabaseService = SupabaseService();


  @override
  void initState(){
    super.initState();

    _dayController = FixedExtentScrollController();
    _monthController = FixedExtentScrollController();
    _yearController = FixedExtentScrollController();

    _openingHourController = FixedExtentScrollController();
    _openingMinuteController = FixedExtentScrollController();
    _closingHourController = FixedExtentScrollController();
    _closingMinuteController = FixedExtentScrollController();

  }

  // BUILD
  AppBar _buildAppBar(){
    return AppBar(
      backgroundColor: customStyleClass.backgroundColorMain,
      surfaceTintColor: customStyleClass.backgroundColorMain,
      title: SizedBox(
        width: screenWidth,
        child: Stack(
          children: [
            Container(
                alignment: Alignment.bottomCenter,
                height: 50,
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(headLine,
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyleHeadline1Bold()
                    ),
                  ],
                )
            ),

            Container(
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.white,
                      ),
                      onPressed: (){
                        context.go('/club_frontpage');
                      },
                    ),
                  ],
                )
            ),

          ],
        ),
      ),

    );
  }

  Widget _buildMainColumn(){
    return SingleChildScrollView(
        physics: const ScrollPhysics(),
      child: Column(
      children: [

        SizedBox(
          height: screenHeight*0.02,
        ),

        _buildListView(),

        if(!showAddNewSpecialOpeningTime)
        GestureDetector(
          child: Container(
            width: screenWidth*0.9,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  "Weitere Sonderöffnungszeit",
                  style: customStyleClass.getFontStyle2Bold(),
                ),
                Icon(
                  Icons.add,
                  size: 28,
                  color: customStyleClass.primeColor,
                )
              ],
            ),
          ),
          onTap: () => clickEventToggleShowAddDay(),
        ),

        if(showAddNewSpecialOpeningTime)
        Container(
          child: Column(
            children: [

              Text(
                "Wähle ein Datum aus, das du hinzufügen möchtest.",
                style: customStyleClass.getFontStyle2(),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 10,
              ),


              // PICKER: DAY, MONTH, YEAR
              SizedBox(
                height: screenHeight*0.1,
                // color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // day
                    SizedBox(
                      width: screenWidth*0.2,
                      child: CupertinoPicker(
                          scrollController: _dayController,
                          itemExtent: 50,
                          onSelectedItemChanged: (int index){
                            setState(() {
                              selectedDay = index;
                            });
                          },
                          children: List<Widget>.generate(31, (index){
                            return Center(
                              child: Text(
                                index < 9 ?
                                "0${(index+1).toString()}" :
                                (index+1).toString(),
                                style: customStyleClass.getFontStyle3(),
                              ),
                            );
                          })
                      ),
                    ),

                    Text(
                      ".",
                      style: customStyleClass.getFontStyle3(),
                    ),

                    // month
                    SizedBox(
                      width: screenWidth*0.2,
                      child: CupertinoPicker(
                          scrollController: _monthController,
                          itemExtent: 50,
                          onSelectedItemChanged: (int index){
                            setState(() {
                              selectedMonth = index;
                            });
                          },
                          children: List<Widget>.generate(12, (index){
                            return Center(
                              child: Text(
                                index < 9 ?
                                "0${(index+1).toString()}" :
                                (index+1).toString(),
                                style: customStyleClass.getFontStyle3(),
                              ),
                            );
                          })
                      ),
                    ),

                    Text(
                      ".",
                      style: customStyleClass.getFontStyle3(),
                    ),

                    // year
                    SizedBox(
                      width: screenWidth*0.2,
                      child: CupertinoPicker(
                          scrollController: _yearController,
                          itemExtent: 50,
                          onSelectedItemChanged: (int index){
                            setState(() {
                              selectedYear = index;
                            });
                          },
                          children: [
                            Center(
                              child: Text(
                                "2024",
                                style: customStyleClass.getFontStyle3(),
                              ),
                            ),
                            Center(
                              child: Text(
                                "2025",
                                style: customStyleClass.getFontStyle3(),
                              ),
                            ),
                            Center(
                              child: Text(
                                "2026",
                                style: customStyleClass.getFontStyle3(),
                              ),
                            ),
                          ]
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                "Wähle eine Öffnungszeit aus.",
                style: customStyleClass.getFontStyle2(),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 10,
              ),


              // Opening hour
              SizedBox(
                  height: screenHeight*0.1,
                  // color: Colors.red,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(
                          width: screenWidth*0.2,
                          child: CupertinoPicker(
                              scrollController: _openingHourController,
                              itemExtent: 50,
                              onSelectedItemChanged: (int index){
                                setState(() {
                                  selectedOpeningHour = index;
                                });
                              },
                              children: List<Widget>.generate(24, (index){
                                return Center(
                                  child: Text(
                                    index < 10 ?
                                    "0${(index).toString()}" :
                                    (index).toString(),
                                    style: customStyleClass.getFontStyle3(),
                                  ),
                                );
                              })
                          ),
                        ),

                        Text(
                          ".",
                          style: customStyleClass.getFontStyle3(),
                        ),

                        SizedBox(
                          width: screenWidth*0.2,
                          child: CupertinoPicker(
                              scrollController: _openingMinuteController,
                              itemExtent: 50,
                              onSelectedItemChanged: (int index){
                                setState(() {
                                  selectedOpeningMinute = index;
                                });
                              },
                              children: [
                                Center(
                                  child: Text(
                                    "00",
                                    style: customStyleClass.getFontStyle3(),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "30",
                                    style: customStyleClass.getFontStyle3(),
                                  ),
                                )
                              ]
                          ),
                        ),

                      ]
                  )
              ),

              const SizedBox(
                height: 10,
              ),


              Text(
                "Wähle aus, wann das Event endet.",
                style: customStyleClass.getFontStyle2(),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 10,
              ),

              // Closing hour
              SizedBox(
                  height: screenHeight*0.1,
                  // color: Colors.red,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(
                          width: screenWidth*0.2,
                          child: CupertinoPicker(
                              scrollController: _closingHourController,
                              itemExtent: 50,
                              onSelectedItemChanged: (int index){
                                setState(() {
                                  selectedClosingHour = index;
                                });
                              },
                              children: List<Widget>.generate(24, (index){
                                return Center(
                                  child: Text(
                                    index < 10 ?
                                    "0${(index).toString()}" :
                                    (index).toString(),
                                    style: customStyleClass.getFontStyle3(),
                                  ),
                                );
                              })
                          ),
                        ),

                        Text(
                          ".",
                          style: customStyleClass.getFontStyle3(),
                        ),

                        SizedBox(
                          width: screenWidth*0.2,
                          child: CupertinoPicker(
                              scrollController: _closingMinuteController,
                              itemExtent: 50,
                              onSelectedItemChanged: (int index){
                                setState(() {
                                  selectedClosingMinute = index;
                                });
                              },
                              children: [
                                Center(
                                  child: Text(
                                    "00",
                                    style: customStyleClass.getFontStyle3(),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "30",
                                    style: customStyleClass.getFontStyle3(),
                                  ),
                                )
                              ]
                          ),
                        ),

                      ]
                  )
              ),

              const SizedBox(
                height: 10,
              ),

              SizedBox(
                child: InkWell(
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
                  onTap: () => clickEventAddNewSpecialDay(),
                ),
              )

            ],
          ),
        ),

        // Spacer
        SizedBox(height: screenHeight*0.1,),


      ],
      )
    );
  }


  String formatDateToDisplay(SpecialDays specialDays){

    String dayToDisplay = specialDays.day! < 10 ? "0${specialDays.day}" : specialDays.day.toString();
    String monthToDisplay = specialDays.month! < 10 ? "0${specialDays.month}" : specialDays.month.toString();

    return "$dayToDisplay.$monthToDisplay.${specialDays.year}";

  }

  String formatOpeningHour(SpecialDays specialDays){
    if(specialDays.openingHalfAnHour == 1){
      return specialDays.openingHour! < 10 ? "0${specialDays.openingHour}:30" : "${specialDays.openingHour.toString()}:30";
    }else{
      return specialDays.openingHour! < 10 ? "0${specialDays.openingHour}:00" : "${specialDays.openingHour.toString()}:00";
    }
  }
  String formatClosingHour(SpecialDays specialDays){
    if(specialDays.closingHalfAnHour == 1){
      return specialDays.closingHour! < 10 ? "0${specialDays.closingHour}:30" : "${specialDays.closingHour.toString()}:30";
    }else{
      return specialDays.closingHour! < 10 ? "0${specialDays.closingHour}:00" : "${specialDays.closingHour.toString()}:00";
    }
  }

  Widget _buildListView(){
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: userDataProvider.getUserClub().getSpecialOpeningTimes().specialDays!.length,
        itemBuilder: ((context, index){

          return Center(
            child: Container(
              // color: Colors.red,
                padding: const EdgeInsets.only(
                    bottom: 15
                ),
                width: screenWidth*0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      children: [

                        // Offer number + delete icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: screenWidth*0.5,
                                child: Text(
                                  formatDateToDisplay(userDataProvider.getUserClub().getSpecialOpeningTimes().specialDays![index]),
                                  style: customStyleClass.getFontStyle2Bold(),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            )

                          ],
                        ),

                        // Opens
                        Container(
                          // color: Colors.red,
                          alignment: Alignment.centerLeft,
                          // width: screenWidth*0.9,
                          child: SizedBox(
                            width: screenWidth*0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Öffnet um:",
                                  style: customStyleClass.getFontStyle3(),
                                ),

                                Text(
                                  formatOpeningHour(userDataProvider.getUserClub().getSpecialOpeningTimes().specialDays![index]),
                                  style: customStyleClass.getFontStyle3(),
                                )

                              ],
                            ),
                          ),
                        ),

                        // Closes
                        Container(
                          // color: Colors.red,
                          alignment: Alignment.centerLeft,
                          // width: screenWidth*0.9,
                          child: SizedBox(
                            width: screenWidth*0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Schließt um:",
                                  style: customStyleClass.getFontStyle3(),
                                ),

                                Text(
                                  formatClosingHour(userDataProvider.getUserClub().getSpecialOpeningTimes().specialDays![index]),
                                  style: customStyleClass.getFontStyle3(),
                                )

                              ],
                            ),
                          ),
                        ),

                      ],
                    ),

                    InkWell(
                      child: Icon(
                        Icons.delete,
                        color: customStyleClass.primeColor,
                      ),
                      onTap: () => clickEventDeleteSpecialDay(index),
                    )


                  ],
                )
            ),
          );
        }
        )
    );
  }


  void clickEventToggleShowAddDay(){
    setState(() {
      showAddNewSpecialOpeningTime = true;
    });
  }

  void clickEventDeleteSpecialDay(int indexToDelete){
    showDialog(context: context, builder: (BuildContext context){
      return TitleContentAndButtonDialog(
          titleToDisplay: "Öffnungszeit löschen",
          contentToDisplay: "Möchtest du diese Öffnungszeit löschen?",
          buttonToDisplay: TextButton(
              onPressed: () => deleteSpecialDay(indexToDelete),
              child: Text(
                "Ja",
                textAlign: TextAlign.center,
                style: customStyleClass.getFontStyle4BoldPrimeColor(),
              ))
      );
    });

  }


  void deleteSpecialDay(int indexToDelete){
    SpecialOpeningTimes specialOpeningTimes = SpecialOpeningTimes(
        specialDays: []
    );

    // Create a replica of the current state
    for(var i = 0; i<userDataProvider.getUserClub().getSpecialOpeningTimes().specialDays!.length;i++){
      if(i != indexToDelete){
        specialOpeningTimes.specialDays!.add(userDataProvider.getUserClub().getSpecialOpeningTimes().specialDays![i]);
      }
    }

    // Send to server
    _supabaseService.updateSpecialOpeningTimes(specialOpeningTimes, userDataProvider.getUserClubId()).then(
            (response) => {
          if(response == 0){
            setState(() {
              userDataProvider.getUserClub().setSpecialOpeningTimes(specialOpeningTimes);
              showAddNewSpecialOpeningTime = false;
            })
          }else{
            setState(() {
              showAddNewSpecialOpeningTime = false;
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context){
                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text("Ein Fehler ist aufgetreten"),
                      ),
                    );
                  }
              );
            })
          }
        }
    );
    Navigator.pop(context);
  }

  void clickEventAddNewSpecialDay(){

    SpecialOpeningTimes specialOpeningTimes = SpecialOpeningTimes(
      specialDays: []
    );

    // Create a replica of the current state
    for(var element in userDataProvider.getUserClub().getSpecialOpeningTimes().specialDays!){
      specialOpeningTimes.specialDays!.add(element);
    }

    int yearToSave = 0;

    switch(selectedYear){
      case(0): yearToSave = 2024;break;
      case(1): yearToSave = 2025;break;
      case(2): yearToSave = 2026; break;
      default: yearToSave = 2024;break;
    }

    SpecialDays specialDays = SpecialDays(
      day: selectedDay+1,
      month: selectedMonth+1,
      year: yearToSave,
      openingHour: selectedOpeningHour,
      openingHalfAnHour: selectedOpeningMinute,
      closingHour: selectedClosingHour,
      closingHalfAnHour: selectedClosingMinute
    );

    // Add the new element
    specialOpeningTimes.specialDays!.add(specialDays);

    // Send to server
    _supabaseService.updateSpecialOpeningTimes(specialOpeningTimes, userDataProvider.getUserClubId()).then(
        (response) => {
          if(response == 0){
            setState(() {
              userDataProvider.getUserClub().setSpecialOpeningTimes(specialOpeningTimes);
              showAddNewSpecialOpeningTime = false;
            })
          }else{
            setState(() {
              showAddNewSpecialOpeningTime = false;
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context){
                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text("Ein Fehler ist aufgetreten"),
                      ),
                    );
                  }
              );
            })
          }
        }
    );


  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    stateProvider = Provider.of<StateProvider>(context);
    customStyleClass = CustomStyleClass(context: context);
    userDataProvider = Provider.of<UserDataProvider>(context);

    return Scaffold(

        extendBody: true,
        resizeToAvoidBottomInset: true,

        bottomNavigationBar: CustomBottomNavigationBarClubs(),
        appBar: _buildAppBar(),
        body: Container(
            color: customStyleClass.backgroundColorMain,
            width: screenWidth,
            height: screenHeight,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child:_buildMainColumn(),
            )
        )
    );
  }
}
