import 'package:club_me/models/club_me_user_data.dart';
import 'package:club_me/models/club_password.dart';
import 'package:club_me/models/parser/club_me_password_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:uuid/uuid.dart';

import '../provider/state_provider.dart';
import '../provider/user_data_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';
import '../shared/logger.util.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  String headLine = "Registrierung";

  final log = getLogger();

  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;
  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  int progressIndex = 0;
  int profileType = 0;
  int gender = 0;

  late DateTime newSelectedDate;

  bool isLoading = false;

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _eMailController = TextEditingController();
  final TextEditingController _clubPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    newSelectedDate = DateTime.now();
  }

  Widget _buildBottomNavigationBar2(){

    return progressIndex == 0 ?
     Container() :
        progressIndex == 1 ?
        Container(
          width: screenWidth,
          height: screenHeight*0.06,
          decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                  top: BorderSide(
                      color: Colors.grey[500]!
                  )
              )
          ),

          // color: Colors.green,
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.only(
              right: 10,
              bottom: 10
          ),
          child: GestureDetector(
            child: Text(
              "Registrieren!",
              style: customStyleClass.getFontStyle3BoldPrimeColor(),
            ),
            onTap: () => clickOnRegister(),
          ),
        ) :
        Container(
          width: screenWidth,
          height: screenHeight*0.06,
          decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                  top: BorderSide(
                      color: Colors.grey[500]!
                  )
              )
          ),

          // color: Colors.green,
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.only(
              right: 10,
              bottom: 10
          ),
          child: GestureDetector(
            child: Text(
              "Registrieren!",
              style: customStyleClass.getFontStyle3BoldPrimeColor(),
            ),
            onTap: () => clickOnRegister(),
          ),
        );
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

  Widget _buildViewBasedOnIndex(){
    switch(progressIndex){
      case(0):
        return _buildChooseUserOrClub();
      case(1):
        return _buildRegisterAsUser();
      case(2):
        return _buildRegisterAsClub();
      default:
        return Container();
    }
  }

  Widget _buildRegisterAsUser(){
    return SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
                children: [

                  // Question headline
                  Container(
                    width: screenWidth*0.9,
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight*0.04,
                        horizontal: screenWidth*0.02
                    ),
                    child: Text(
                      "Erzähl uns ein wenig über dich!",
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle2Bold(),
                    ),
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Vorname",
                      style: customStyleClass.getFontStyle3(),
                    ),
                  ),

                  // Textfield first name
                  SizedBox(
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    child: TextField(
                      controller: _firstNameController,
                      cursorColor: customStyleClass.primeColor,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        hintText: "z.B. Max",
                        border: const OutlineInputBorder(),
                      ),
                      style: customStyleClass.getFontStyle4(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Nachname",
                      style: customStyleClass.getFontStyle3(),
                    ),
                  ),

                  // Textfield last name
                  SizedBox(
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    child: TextField(
                      controller: _lastNameController,
                      cursorColor: customStyleClass.primeColor,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        hintText: "z.B. Mustermann",
                        border: const OutlineInputBorder(),
                      ),
                      style: customStyleClass.getFontStyle4(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "E-Mail",
                      style: customStyleClass.getFontStyle3(),
                    ),
                  ),

                  // Textfield email
                  SizedBox(
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    child: TextFormField(
                      controller: _eMailController,
                      cursorColor: customStyleClass.primeColor,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        hintText: "z.B. max.mustermann@gmx.de",
                        border: const OutlineInputBorder(),
                      ),
                      style: customStyleClass.getFontStyle4(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Geschlecht",
                      style: customStyleClass.getFontStyle3(),
                    ),
                  ),

                  // toggle man, woman, diverse
                  SizedBox(
                    width: screenWidth*0.9,
                    child:  Center(
                      child: ToggleSwitch(
                        initialLabelIndex: gender,
                        totalSwitches: 3,
                        activeBgColor: [primeColor],
                        activeFgColor: Colors.black,
                        inactiveFgColor: primeColor,
                        inactiveBgColor: Color(0xff11181f),
                        labels: const [
                          'Mann',
                          'Frau',
                          "Divers"
                        ],
                        // fontSize: screenHeight*stateProvider.getFontSizeFactor3(),
                        minWidth: screenWidth*0.9,
                        minHeight: screenHeight*0.07,
                        onToggle: (index) {
                          setState(() {
                            gender = index!;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight*0.05,
                  ),

                  // Text: Title
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Geburtsdatum",
                      style: customStyleClass.getFontStyle3(),
                    ),
                  ),

                  SizedBox(
                    height: screenHeight*0.12,
                    child: Column(
                      children: [

                        SizedBox(
                          height: screenHeight*0.01,
                        ),

                        SizedBox(
                          width: screenWidth*0.32,
                          child:OutlinedButton(
                              onPressed: (){
                                showDatePicker(
                                    context: context,
                                    locale: const Locale("de", "DE"),
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1949),
                                    lastDate: DateTime(2010),
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
                                  minimumSize: Size(
                                      screenHeight*0.05,
                                      screenHeight*0.07
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)
                                  )
                              ),
                              child: Text(
                                formatSelectedDate(),
                                style: customStyleClass.getFontStyle4(),
                              )
                          ),
                        )
                      ],
                    ),
                  ),

                  // Spacer
                  SizedBox(
                    height: screenHeight*0.1,
                  ),

                ]
            )
        )
    );
  }

  Widget _buildRegisterAsClub(){
    return Container(
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
                      "Gib bitte dein Club-Passwort ein!",
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle1Bold(),
                    ),
                  ),

                  // Textfield email
                  SizedBox(
                    height: screenHeight*0.15,
                    width: screenWidth*0.8,
                    child: TextField(
                      controller: _clubPasswordController,
                      cursorColor: customStyleClass.primeColor,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: customStyleClass.primeColor
                            )
                        ),
                        hintText: "z.B. passwort1234",
                        border: const OutlineInputBorder(),
                      ),
                      style: customStyleClass.getFontStyle4(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                ]
            )
        )
    );
  }

  void clickOnRegister() async{

    setState(() {
      isLoading = true;
    });

    if(profileType == 0){

      if(RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
          .hasMatch(_eMailController.text)){
        transferToHiveAndDB();
      }else{
        setState(() {
          isLoading = false;
        });
        showDialog(context: context, builder: (BuildContext context){
          return AlertDialog(
              title: const Text("E-Mail Adresse"),
              content: Text(
                "Bitte gib eine gültige E-Mail-Adresse ein!",
                textAlign: TextAlign.left,
                style: customStyleClass.getFontStyle4(),
              )
          );
        });
      }
    }else{
      transferToHiveAndDB();
    }
  }

  void transferToHiveAndDB() async{

    // If user
    if(profileType == 0){
      var uuid = const Uuid();

      ClubMeUserData newUserData = ClubMeUserData(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          birthDate: newSelectedDate,
          eMail: _eMailController.text,
          gender: gender,
          userId: uuid.v4(),
          profileType: profileType);

      try{

        await _hiveService.resetUserData();

        _hiveService.addUserData(newUserData).then((value) => {
          _supabaseService.insertUserDate(newUserData).then((value){
            userDataProvider.setUserData(newUserData);
            if(newUserData.getProfileType() == 0){
              context.go("/user_events");
            }else{
              context.go("/club_events");
            }
          })
        });

      }catch(e){
        log.d("Error in transferToHiveAndDB: $e");
      }

    // If club
    }else{
      try{
        await _supabaseService.checkIfClubPwIsLegit(_clubPasswordController.text).then((value){
          if(value.isEmpty){
            showErrorDialog();
          }else{

            ClubMePassword clubMePassword = parseClubMePassword(value[0]);

            ClubMeUserData newUserData = ClubMeUserData(
                firstName: "...",
                lastName: "...",
                birthDate: DateTime.now(),
                eMail: "...",
                gender: 0,
                userId: clubMePassword.clubId,
                profileType: 1
            );
            _hiveService.addUserData(newUserData).then((value){
              userDataProvider.setUserData(newUserData);
              context.go("/club_events");
            });
          }
          setState(() {
            isLoading = false;
          });
        });

      }catch(e){
        log.d("Error in transferToHiveAndDB: $e");
      }
    }
  }

  void showErrorDialog(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          title: const Text("Fehler"),
          content: Text(
            "Tut uns leid. Leider war eine Registrierung nicht möglich.",
            textAlign: TextAlign.left,
            style: customStyleClass.getFontStyle4(),
          )
      );
    });
  }

  void iterateProgressIndex(){
    setState(() {
      if(progressIndex == 0){
        if(profileType == 0){
          progressIndex = 1;
        }else{
          progressIndex = 2;
        }
      }else{

      }
    });
  }

  Widget _buildChooseUserOrClub(){
    return Container(
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
                "Möchtest du dich als Club oder als User registrieren?",
                textAlign: TextAlign.center,
                style: customStyleClass.getFontStyle1Bold(),
              ),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.05,
            ),


            GestureDetector(
              child: Container(
                  width: screenWidth*0.8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          primeColorDark,
                          primeColor,
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
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10)
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: Text(
                        "Normaler Nutzer",
                        style: customStyleClass.getFontStyle5Bold()
                    ),
                  )
              ),
              onTap: (){
                profileType = 0;
                iterateProgressIndex();
                // stateProvider.setClubUiActive(true);
                // fetchClubAndProceed(clubId);
              },
            ),

            SizedBox(
              height: screenHeight*0.02,
            ),

            GestureDetector(
              child: Container(
                  width: screenWidth*0.8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          primeColorDark,
                          primeColor,
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
                    borderRadius: const BorderRadius.all(
                        Radius.circular(10)
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: Text(
                        "Clubbesitzer",
                        style: customStyleClass.getFontStyle5Bold()
                    ),
                  )
              ),
              onTap: (){
                profileType = 1;
                iterateProgressIndex();
                // stateProvider.setClubUiActive(true);
                // fetchClubAndProceed(clubId);
              },
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

  AppBar _buildAppBar(){
    return AppBar(
        backgroundColor: Colors.transparent,
        title: SizedBox(
          width: screenWidth,
          child: Stack(
            children: [

              // TEXT
              Container(
                width: screenWidth,
                padding: EdgeInsets.only(
                    top: screenHeight*0.01
                ),
                child: Center(
                  child: Text(headLine,
                      textAlign: TextAlign.center,
                      style: customStyleClass.getFontStyle2()
                  ),
                ),
              ),

              // ICON
              Container(
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                      Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => _goBack(),
                ),
              )
            ],
          ),
        )
    );
  }

  void _goBack(){
    context.go("/");
  }

  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(),
      body: _buildViewBasedOnIndex(),
      bottomNavigationBar: _buildBottomNavigationBar2(),
    );
  }
}
