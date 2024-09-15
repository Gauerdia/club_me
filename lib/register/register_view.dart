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
    return Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff2b353d),
                Color(0xff11181f)
              ],
              stops: [0.15, 0.6]
          ),
        ),
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

                  // Textfield first name
                  SizedBox(
                    height: screenHeight*0.15,
                    width: screenWidth*0.8,
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                          hintText: "Mario",
                          border: OutlineInputBorder(),
                        label: Text("Vorname")
                      ),
                      style: customStyleClass.getFontStyle3(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                  // Textfield last name
                  SizedBox(
                    height: screenHeight*0.15,
                    width: screenWidth*0.8,
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                          hintText: "Müller",
                          border: OutlineInputBorder(),
                          label: Text("Nachname")
                      ),
                      style: customStyleClass.getFontStyle3(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                  // Textfield email
                  SizedBox(
                    height: screenHeight*0.15,
                    width: screenWidth*0.8,
                    child: TextFormField(
                      controller: _eMailController,
                      decoration: const InputDecoration(
                          hintText: "max.mustermann@gmail.com",
                          border: OutlineInputBorder(),
                          label: Text("E-Mail")
                      ),
                      style: customStyleClass.getFontStyle3(),
                      autofocus: true,
                      maxLength: 35,
                    ),
                  ),

                  // toggle man, woman, diverse
                  SizedBox(
                    width: screenWidth*0.8,
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
                        minWidth: screenWidth*0.25,
                        onToggle: (index) {
                          setState(() {
                            gender = index!;
                          });
                        },
                      ),
                    ),
                  ),

                  // Spacer
                  SizedBox(
                    height: screenHeight*0.04,
                  ),

                  Text(
                    "Geburtstag"
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
                              firstDate: DateTime(1960),
                              lastDate: DateTime(2025),
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
                              style: customStyleClass.getFontStyle3Bold(),
                            ),
                            // Spacer
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            // Calendar icon
                            Icon(
                                Icons.calendar_month_outlined,
                                color: primeColor,
                                size: customStyleClass.getFontSize3() //screenHeight*stateProvider.getIconSizeFactor()
                            )
                          ],
                        )
                    ),
                  ),

                  // Spacer
                  SizedBox(
                    height: screenHeight*0.04,
                  ),

                ]
            )
        )
    );
  }

  Widget _buildRegisterAsClub(){
    return Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff2b353d),
                Color(0xff11181f)
              ],
              stops: [0.15, 0.6]
          ),
        ),
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
                      decoration: const InputDecoration(
                          hintText: "1234",
                          border: OutlineInputBorder(),
                          label: Text("Passwort")
                      ),
                      style: customStyleClass.getFontStyle3(),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff2b353d),
              Color(0xff11181f)
            ],
            stops: [0.15, 0.6]
        ),
      ),
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
                      Icons.arrow_back_ios
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

  Widget _buildNavigationBar(){
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

          // Main Background
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
          isLoading?
              SizedBox(
                width: screenWidth,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
              : Padding(
            padding: EdgeInsets.only(
                top: screenHeight*0.02
              // right: screenWidth*0.04,
              // bottom: screenHeight*0.015,
            ),
            child: Align(
                alignment: AlignmentDirectional.center,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth*0.055,
                        vertical: screenHeight*0.02
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(10)
                      ),
                      gradient: LinearGradient(
                          colors: [
                            customStyleClass.primeColorDark,
                            customStyleClass.primeColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.2, 0.9]
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
                      "Registrieren" ,
                      style: customStyleClass.getFontStyle4Bold(),
                    ),
                  ),
                  onTap: () => clickOnRegister(),
                )
            ),
          )
        ],

      ),
    );
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
      bottomNavigationBar: _buildNavigationBar(),
    );
  }
}
