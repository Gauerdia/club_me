import 'dart:io';

import 'package:club_me/models/hive_models/0_club_me_user_data.dart';
import 'package:club_me/models/club_password.dart';
import 'package:club_me/models/parser/club_me_password_parser.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../provider/state_provider.dart';
import '../provider/user_data_provider.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../shared/custom_text_style.dart';
import '../shared/dialogs/TitleAndContentDialog.dart';
import '../shared/dialogs/title_content_and_button_dialog.dart';
import '../shared/logger.util.dart';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/people/v1.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  String headLine = "ClubMe";

  final log = getLogger();

  bool showVIP = false;

  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;
  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  int progressIndex = 0;
  int profileType = 0;
  int gender = 0;

  bool agbAccepted = false;
  bool privacyAccepted = false;

  late DateTime newSelectedDate;

  bool isLoading = false;

  bool hasNoAccountYet = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _eMailController = TextEditingController();
  final TextEditingController _clubPasswordController = TextEditingController();

  double distanceBetweenTitleAndTextField = 10;

  GoogleSignIn _googleSignIn = GoogleSignIn();

  // 0: none yet, 1: via mail user, 2: via pw club, 3: google
  int registrationType = 0;

  late ClubMeUserData userDataToRegister;
  String emailToVerify = "";


  // INIT
  @override
  void initState() {
    super.initState();
    newSelectedDate = DateTime(2000, 1, 1);

    fetchUserDataFromHive();

  }





  void checkIfRegistrationIsLegit() async {

    setState(() {
      isLoading = true;
    });

    if(!agbAccepted || !privacyAccepted){
      showDialog(context: context, builder: (BuildContext context){
        return TitleAndContentDialog(
            titleToDisplay: "Konditionen akzeptieren",
            contentToDisplay: "Bitte bestätigen Sie die AGB und die Datenschutzerklärung, um fortzufahren."
        );
      });
    }else{
      if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+").hasMatch(_eMailController.text)){
        await _supabaseService.getUserByEMail(_eMailController.text).then(
                (response) {
              if(response.isNotEmpty){
                showDialog(context: context, builder: (BuildContext context){
                  return TitleAndContentDialog(
                      titleToDisplay: "E-Mail-Adresse existiert bereits",
                      contentToDisplay: "Diese E-Mail-Adresse ist leider bereits vergeben. Wenn du dich erneut anmelden möchtest, nutze bitte den dazu gehörigen Button auf der Registrierungsseite."
                  );
                });
              }else{
                setState(() {
                  isLoading = false;
                });
                processUserRegistration();
              }
            }
        );
      }
      else{
        setState(() {
          isLoading = false;
        });
        showDialog(context: context, builder: (BuildContext context){
          return TitleAndContentDialog(
              titleToDisplay: "Ungültige E-Mail-Adresse",
              contentToDisplay: "Bitte gib eine gültige E-Mail-Adresse an."
          );
        });
      }
    }
  }


  void processUserRegistration() async{

    var uuid = const Uuid();

    ClubMeUserData newUserData = ClubMeUserData(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        birthDate: newSelectedDate,
        eMail: _eMailController.text,
        gender: gender+1,
        userId: uuid.v4(),
        profileType: profileType,
        lastTimeLoggedIn: DateTime.now(),
        userProfileAsClub: false,
        clubId: ''
    );

    try{

      // Make sure that the local user data is clean
      await _hiveService.resetUserData();

      // save user data to all relevant instances
      _hiveService.addUserData(newUserData).then((value) => {
        _supabaseService.insertUserData(newUserData).then((value){
          userDataProvider.setUserData(newUserData);
          setState(() {

            context.go("/user_events");

            // show advertisement
            // progressIndex = 3;
          });
        })
      });

    }catch(e){
      log.d("Error in transferToHiveAndDB: $e");
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

              // TEXT
              Container(
                // color: Colors.red,
                height: 50,
                width: screenWidth,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Text(
                            headLine,
                            textAlign: TextAlign.center,
                            style: customStyleClass.getFontStyleHeadline1Bold()
                        ),
                        if(showVIP)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 15
                          ),
                          child: Text(
                            "VIP",
                            style: customStyleClass.getFontStyleVIPGold(),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),


              // Right icons
              if( progressIndex == 1)
                Container(
                  height: 50,
                  width: screenWidth,
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onTap: () => setState(() {
                      progressIndex = 0;
                      agbAccepted = false;
                      privacyAccepted = false;
                    }),
                  ),
                ),

              // Right icons
              if( progressIndex == 3)
              Container(
                height: 50,
                width: screenWidth,
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onTap: () => clickEventGoFromAdToEvents(),
                ),
              ),

            ],
          ),
        )
    );
  }


  // The main logic
  Widget _buildViewBasedOnIndex(){
    if(hasNoAccountYet){
      switch(progressIndex){
        case(0):
          return _buildChooseRegistrationMethod();
        case(1):
          return _buildRegisterAsUser();
        case(3):
          return _buildShowPremiumAdvantages();
        case(4):
          return _buildGoogleAcceptAGBAndPrivacy();
        default:
          return Container();
      }
    }else{
      return SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Center(
          child: Image.asset(
              "assets/images/ClubMe_Logo_weiß.png"
          ),
        ),
      );
    }
  }

  // main window
  Widget _buildChooseRegistrationMethod(){
    return Container(
      height: screenHeight,
      color: customStyleClass.backgroundColorMain,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Question headline
            Container(
              width: screenWidth*0.9,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight*0.04,
                  horizontal: screenWidth*0.02
              ),
              child: Text(
                "Registrieren",
                textAlign: TextAlign.left,
                style: customStyleClass.getFontStyle1Bold(),
              ),
            ),

            // Google
            if(Platform.isAndroid)
              InkWell(
              child: Center(
                child: Container(
                    alignment: Alignment.centerRight,
                    width: screenWidth*0.9,
                    decoration: BoxDecoration(
                      color: customStyleClass.backgroundColorEventTile,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(10)
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.google,
                          color: Colors.white,
                        ),
                        Text(
                          " Weiter mit Google",
                          style: customStyleClass.getFontStyle3(),
                        )
                      ],
                    )
                ),
              ),
              onTap: () => clickEventGoogleRegistration(),
            ),

            SizedBox(
              height: screenHeight*0.02,
            ),

            // EMAIL
            InkWell(
              child: Center(
                child: Container(
                    alignment: Alignment.centerRight,
                    width: screenWidth*0.9,
                    decoration: BoxDecoration(
                      color: customStyleClass.backgroundColorEventTile,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(10)
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.mail,
                          color: Colors.white,
                        ),
                        Text(
                          " Weiter mit E-Mail",
                          style: customStyleClass.getFontStyle3(),
                        )
                      ],
                    )
                ),
              ),
              onTap: () => clickEventEMailRegistration(),
            ),

            // PW vergessen
            Container(
              padding: const EdgeInsets.only(
                top: 5
              ),
              width: screenWidth*0.9,
              child: InkWell(
                onTap: () => clickEventForgotPassword(),
                child: Text(
                  "Erneut anmelden?",
                  textAlign: TextAlign.left,
                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                ),
              ),
            ),

            SizedBox(
              height: screenHeight*0.04,
            ),

            InkWell(
              child: Center(
                child: Container(
                    alignment: Alignment.centerRight,
                    width: screenWidth*0.9,
                    decoration: BoxDecoration(
                      color: customStyleClass.backgroundColorEventTile,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(10)
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warehouse_sharp,
                          color: Colors.white,
                        ),
                        Text(
                          " Weiter als Club",
                          style: customStyleClass.getFontStyle3(),
                        )
                      ],
                    )
                ),
              ),
              onTap: () => clickEventProceedAsClub(),
            ),

            Container(
              padding: const EdgeInsets.only(
                  top: 5
              ),
              width: screenWidth*0.9,
              child: InkWell(
                onTap: () => clickEventEnterAsDeveloper(),
                child: Text(
                  "Sie sind Entwickler?",
                  textAlign: TextAlign.left,
                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  // The first registration type
  Widget _buildRegisterAsUser(){
    return Container(
      // height: screenHeight,
        width: screenWidth,
        color: customStyleClass.backgroundColorMain,
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
                  Container(
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
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
                        contentPadding: const EdgeInsets.only(
                            left: 20,
                            top:20,
                            bottom:20
                        ),
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
                  Container(
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
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
                        contentPadding: const EdgeInsets.only(
                            left: 20,
                            top:20,
                            bottom:20
                        ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "E-Mail",
                          style: customStyleClass.getFontStyle3(),
                        ),
                        InkWell(
                          child: Icon(
                              Icons.info_outlined,
                              color: customStyleClass.primeColor
                          ),
                          onTap:() => clickEventShowInfo(0),
                        )
                      ],
                    ),
                  ),

                  // Textfield email
                  Container(
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
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
                        contentPadding: const EdgeInsets.only(
                            left: 20,
                            top:20,
                            bottom:20
                        ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Geschlecht",
                          style: customStyleClass.getFontStyle3(),
                        ),
                        InkWell(
                          child: Icon(
                              Icons.info_outlined,
                              color: customStyleClass.primeColor
                          ),
                          onTap: () => clickEventShowInfo(1),
                        )
                      ],
                    ),
                  ),

                  // toggle man, woman, diverse
                  Container(
                    width: screenWidth*0.9,
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
                    child:  Center(
                      child: ToggleSwitch(
                        initialLabelIndex: gender,
                        totalSwitches: 3,
                        activeBgColor: [customStyleClass.primeColor],
                        activeFgColor: Colors.white,
                        inactiveFgColor: customStyleClass.primeColor,
                        inactiveBgColor: customStyleClass.backgroundColorEventTile,
                        labels: const [
                          'Mann',
                          'Frau',
                          "Divers"
                        ],
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

                  // Text: Date
                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Geburtsdatum",
                          style: customStyleClass.getFontStyle3(),
                        ),
                        InkWell(
                          child: Icon(
                            Icons.info_outlined,
                            color: customStyleClass.primeColor,
                          ),
                          onTap: () => clickEventShowInfo(2),
                        )
                      ],
                    ),
                  ),

                  // DATE
                  Container(
                    padding:  EdgeInsets.only(
                        top: distanceBetweenTitleAndTextField
                    ),
                    height: screenHeight*0.12,
                    width: screenWidth*0.9,
                    child: Column(
                      children: [

                        // BUTTON
                        Container(
                          width: screenWidth*0.9,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: screenWidth*0.35,
                            child:OutlinedButton(
                                onPressed: (){
                                  showDatePicker(
                                      context: context,
                                      locale: cupertino.Locale("de", "DE"),
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
                          ),
                        )
                      ],
                    ),
                  ),

                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "AGB",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.02,
                  ),

                  // AGB ROW
                  SizedBox(
                    width: screenWidth*0.9,
                    child: Row(
                      children: [
                        Checkbox(
                            activeColor: customStyleClass.primeColor,
                            value: agbAccepted,
                            onChanged: (bool? newValue){
                              setState(() {
                                agbAccepted = newValue!;
                              });
                            }
                        ),
                        SizedBox(
                          width: screenWidth*0.75,
                          child: Text(
                            "Ich habe die Allgemeinen Geschäftsbedingungen gelesen und akzeptiert.",
                            style: customStyleClass.getFontStyle3(),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    ),
                  ),

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.02,
                  ),

                  // AGB LINK
                  Container(
                    width: screenWidth*0.9,
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Link zu den AGB",
                            style: customStyleClass.getFontStyle5BoldPrimeColor(),
                          ),
                          Icon(
                            Icons.arrow_forward_outlined,
                            color: customStyleClass.primeColor,
                          )
                        ],
                      ),
                      onTap: () => clickEventAGB(),
                    ),
                  ),

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.05,
                  ),

                  Container(
                    width: screenWidth*0.9,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Datenschutz",
                          style: customStyleClass.getFontStyle3(),
                        ),
                      ],
                    ),
                  ),

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.02,
                  ),

                  // DATENSCHUTZ
                  SizedBox(
                    width: screenWidth*0.9,
                    child: Row(
                      children: [
                        Checkbox(
                            activeColor: customStyleClass.primeColor,
                            value: privacyAccepted,
                            onChanged: (bool? newValue){
                              setState(() {
                                privacyAccepted = newValue!;
                              });
                            }
                        ),
                        SizedBox(
                          width: screenWidth*0.75,
                          child: Text(
                            "Ich habe die Datenschutzerklärung gelesen und akzeptiert.",
                            style: customStyleClass.getFontStyle3(),
                          ),
                        )
                      ],
                    ),
                  ),

                  // SPACER
                  SizedBox(
                    height: screenHeight*0.02,
                  ),

                  // LINK DATENSCHUTZ
                  SizedBox(
                    width: screenWidth*0.9,
                    child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Link zu der Datenschutzerklärung",
                            style: customStyleClass.getFontStyle5BoldPrimeColor(),
                          ),
                          Icon(
                            Icons.arrow_forward_outlined,
                            color: customStyleClass.primeColor,
                          )
                        ],
                      ),
                      onTap: () => clickEventPrivacy(),
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

  // After successful registration
  Widget _buildShowPremiumAdvantages(){
    return Container(
      height: screenHeight,
      color: customStyleClass.backgroundColorMain,
      child: Column(
        children: [

          SizedBox(
            height: screenHeight*0.05,
          ),

          Container(
            padding: EdgeInsets.only(
                left: screenWidth*0.02
            ),
            alignment: Alignment.center,
            child: Image.asset(
                "assets/images/premium_advantages.png"
            ),
          )

        ],
      ),
    );
  }



  // GOOGLE AUTH FOR ANDROID
  void processGoogleSignIn() async {

    try{

      //If current device is Web or Android, do not use any parameters except from scopes.
      if (kIsWeb || Platform.isAndroid ) {
        _googleSignIn = GoogleSignIn(
          // clientId: '947015013780-9bhmhmc3qup1ret3v6msat0fighlt19o.apps.googleusercontent.com',
          scopes: [
            'https://www.googleapis.com/auth/userinfo.profile',
            'email',
            PeopleServiceApi.userBirthdayReadScope,
            PeopleServiceApi.userGenderReadScope,
          ],
        );
      }

      // _supabaseService.createErrorLog("iOS Google LogIn: Before GoogleSignIn set. iOS: ${Platform.isIOS}, Android: ${Platform.isAndroid}");

      //If current device IOS or MacOS, We have to declare clientID
      //Please, look STEP 2 for how to get Client ID for IOS
      if (Platform.isIOS || Platform.isMacOS) {
        _googleSignIn = GoogleSignIn(
          clientId: "com.googleusercontent.apps.947015013780-cfmc26giatfe8tsgf0eg3im36h0qsvj0",
          // serverClientId: "com.googleusercontent.apps.947015013780-b475mq5v5u6k0mpju7ik3njm2g6dr8pk",
          hostedDomain: "",
          scopes: [
            'https://www.googleapis.com/auth/userinfo.profile',
            'email',
            PeopleServiceApi.userBirthdayReadScope,
            PeopleServiceApi.userGenderReadScope,
          ],
        );
      }

      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      GoogleSignInAuthentication googleAuth = await googleAccount!.authentication;
      String? accessToken = googleAuth.accessToken;
      String? idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      var supabaseLogIn = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      ).then((response){
        _fetchGenderAndBirthday(googleAccount.email);
      }
      );
    }catch(e){
      _supabaseService.createErrorLog(
          "RegisterView. Fct: processGoogleSignIn. Plattform: iOS(${Platform.isIOS}), Android(${Platform.isAndroid}, Error: $e"
      );
    }
  }
  _fetchGenderAndBirthday(String email) async {
    var httpClient = (await _googleSignIn.authenticatedClient())!;

    var peopleApi = PeopleServiceApi(httpClient);

    final Person person = await peopleApi.people.get(
      'people/me',
      personFields: 'birthdays,genders,names',
    );

    /// Gender
    final String gender = person.genders![0].formattedValue!;

    /// Birthdate
    final date = person.birthdays![0].date!;
    final DateTime birthdayDateTime = DateTime(
      date.year ?? 0,
      date.month ?? 0,
      date.day ?? 0,
    );

    final firstName = person.names?.first.givenName;
    final familyName = person.names?.first.familyName;

    var uuid = const Uuid();

    userDataToRegister = ClubMeUserData(
        firstName: firstName!,
        lastName: familyName!,
        birthDate: birthdayDateTime,
        eMail: email,
        gender: gender == "Male" ? 1 : 2,
        userId: uuid.v4(),
        profileType: profileType,
        lastTimeLoggedIn: DateTime.now(),
        userProfileAsClub: false,
        clubId: ""
    );

    emailToVerify = email;

    setState(() {
      registrationType = 3;
      progressIndex = 4;
    });

  }
  Widget _buildGoogleAcceptAGBAndPrivacy(){
    return Container(
      height: screenHeight,
      color: customStyleClass.backgroundColorMain,
      child: Column(
        children: [

          SizedBox(
            height: screenHeight*0.1,
          ),

          SizedBox(
            width: screenWidth*0.95,
            child: Row(
              children: [
                Checkbox(
                    activeColor: customStyleClass.primeColor,
                    value: agbAccepted,
                    onChanged: (bool? newValue){
                      setState(() {
                        agbAccepted = newValue!;
                      });
                    }
                ),
                SizedBox(
                  width: screenWidth*0.75,
                  child: Text(
                    "Ich habe die Allgemeinen Geschäftsbedingungen gelesen und akzeptiert.",
                    style: customStyleClass.getFontStyle3(),
                    textAlign: TextAlign.left,
                  ),
                )
              ],
            ),
          ),
          Container(
            width: screenWidth*0.9,
            child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Link zu den AGB",
                    style: customStyleClass.getFontStyle5BoldPrimeColor(),
                  ),
                  Icon(
                    Icons.arrow_forward_outlined,
                    color: customStyleClass.primeColor,
                  )
                ],
              ),
              onTap: () => clickEventAGB(),
            ),
          ),

          SizedBox(
            height: screenHeight*0.05,
          ),

          Row(
            children: [
              Checkbox(
                  activeColor: customStyleClass.primeColor,
                  value: privacyAccepted,
                  onChanged: (bool? newValue){
                    setState(() {
                      privacyAccepted = newValue!;
                    });
                  }
              ),
              SizedBox(
                width: screenWidth*0.75,
                child: Text(
                  "Ich habe die Datenschutzerklärung gelesen und akzeptiert.",
                  style: customStyleClass.getFontStyle3(),
                ),
              )
            ],
          ),
          SizedBox(
            width: screenWidth*0.9,
            child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Link zu der Datenschutzerklärung",
                    style: customStyleClass.getFontStyle5BoldPrimeColor(),
                  ),
                  Icon(
                    Icons.arrow_forward_outlined,
                    color: customStyleClass.primeColor,
                  )
                ],
              ),
              onTap: () => clickEventPrivacy(),
            ),
          ),

          SizedBox(
            height: screenHeight*0.1,
          ),

          Container(
            width: screenWidth*0.9,
            alignment: Alignment.centerRight,
            child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Weiter",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  Icon(
                    Icons.arrow_forward_outlined,
                    color: customStyleClass.primeColor,
                  )
                ],
              ),
              onTap: () => googleCheckIfAGBAndPrivacyChecked(),
            ),
          )
        ],
      ),
    );
  }
  void googleCheckIfAGBAndPrivacyChecked(){
    if(!agbAccepted || !privacyAccepted){
      showDialog(context: context, builder: (BuildContext context){
        return TitleAndContentDialog(
            titleToDisplay: "Konditionen akzeptieren",
            contentToDisplay: "Bitte bestätigen Sie unsere AGB und Datenschutzerklärung, um fortzufahren."
        );
      });
    }else{
      googleAuthAGBAndPrivacySuccessful();
    }
  }
  void googleAuthAGBAndPrivacySuccessful(){
    try{
      _hiveService.addUserData(userDataToRegister).then((value) => {
        _supabaseService.getUserByEMail(emailToVerify).then((value){
          if(value.isEmpty){
            _supabaseService.insertUserData(userDataToRegister).then((value){
              userDataProvider.setUserData(userDataToRegister);
              context.go("/user_events");
            });
          }else{
            userDataProvider.setUserData(userDataToRegister);
            context.go("/user_events");
          }
        })
      });
    }catch(e){
      log.d("Error in googleAuthAGBAndPrivacySuccessful: $e");
    }
  }




  Widget _buildBottomNavigationBar(){

    switch(progressIndex){
      case(0):return Container(
        // color: Colors.red,
        width: screenWidth,
        height: 70,
        alignment: Alignment.bottomCenter,
        child: Center(
          child: Image.asset(
            "assets/images/runes_footer.PNG",
            width: 100,
          ),
        ),
      );
      case(1):return Container(
        width: screenWidth,
        height: screenHeight*0.08,
        decoration: BoxDecoration(
            color: customStyleClass.backgroundColorMain,
            border: Border(
                top: BorderSide(
                    color: Colors.grey[900]!
                )
            )
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
          right: 10,
          // bottom: 10
        ),
        child: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Registrieren",
                style: customStyleClass.getFontStyle3BoldPrimeColor(),
              ),
              Icon(
                Icons.arrow_forward_outlined,
                color: customStyleClass.primeColor,
              )
            ],
          ),
          onTap: () => checkIfRegistrationIsLegit()
        ),
      );
      case(3): return Container(
        // color: Colors.red,
        width: screenWidth,
        height: 70,
        alignment: Alignment.bottomCenter,
        child: Center(
          child: Image.asset(
            "assets/images/runes_footer.PNG",
            width: 100,
          ),
        ),
      );
      default: return Container();

    }
  }



  void processContinue(){

    switch(registrationType){
      case(1):
        _hiveService.addUserData(userDataToRegister).then((value) => {
          _supabaseService.getUserByEMail(emailToVerify).then((value){
            if(value.isEmpty){
              _supabaseService.insertUserData(userDataToRegister).then((value){
                userDataProvider.setUserData(userDataToRegister);
                context.go("/user_events");
              });
            }else{
              userDataProvider.setUserData(userDataToRegister);
              context.go("/user_events");
            }
          })
        });
        break;
      case(2):
        _hiveService.addUserData(userDataToRegister).then((value) => {
          _supabaseService.getUserByEMail(emailToVerify).then((value){
            if(value.isEmpty){
              _supabaseService.insertUserData(userDataToRegister).then((value){
                userDataProvider.setUserData(userDataToRegister);
                context.go("/club_events");
              });
            }else{
              userDataProvider.setUserData(userDataToRegister);
              context.go("/club_events");
            }
          })
        });
        break;
      case(3):
        try{
          _hiveService.addUserData(userDataToRegister).then((value) => {
            _supabaseService.getUserByEMail(emailToVerify).then((value){
              if(value.isEmpty){
                _supabaseService.insertUserData(userDataToRegister).then((value){
                  userDataProvider.setUserData(userDataToRegister);
                  context.go("/user_events");
                });
              }else{
                userDataProvider.setUserData(userDataToRegister);
                context.go("/user_events");
              }
            })
          });
          break;

        }catch(e){
          log.d("Error in transferToHiveAndDB: $e");
        }
        break;

    }



  }

  // CLICK

  void clickEventAGB(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleContentAndButtonDialog(
              titleToDisplay: "AGB",
              contentToDisplay: "Dieser Link führt zu unserer Website. Möchten Sie fortfahren?",
              buttonToDisplay: TextButton(onPressed: () async {
                final Uri url = Uri.parse("https://club-me-web-interface.pages.dev/agb");
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              }, child: Text("Ja", style: customStyleClass.getFontStyle3BoldPrimeColor(),)));

        }
    );
  }
  void clickEventPrivacy(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleContentAndButtonDialog(
              titleToDisplay: "Datenschutz",
              contentToDisplay: "Dieser Link führt zu unserer Website. Möchten Sie fortfahren?",
              buttonToDisplay: TextButton(onPressed: () async {
                final Uri url = Uri.parse("https://club-me-web-interface.pages.dev/datenschutz");
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              }, child: Text("Ja", style: customStyleClass.getFontStyle3BoldPrimeColor(),)));

        }
    );
  }


  void clickEventGoogleRegistration(){
      processGoogleSignIn();
  }
  void clickEventEMailRegistration(){
    setState(() {
      progressIndex = 1;
    });
  }
  void clickEventReadPremiumAdvantages(){
    context.go("/user_events");
  }
  void clickEventRegister() async{

    setState(() {
      isLoading = true;
    });

    if(profileType == 0){

      if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+").hasMatch(_eMailController.text)){
        await _supabaseService.getUserByEMail(_eMailController.text).then(
            (response) {
              if(response.isNotEmpty){
                showDialog(context: context, builder: (BuildContext context){
                  return TitleAndContentDialog(
                      titleToDisplay: "E-Mail-Adresse existiert bereits",
                      contentToDisplay: "Diese E-Mail-Adresse ist leider bereits vergeben. Wenn du dich erneut anmelden möchtest, nutze bitte den dazu gehörigen Button auf der Registrierungsseite."
                  );
              });
              }else{

                setState(() {
                  registrationType = 0;
                  progressIndex = 3;
                });

                // transferToHiveAndDB();
              }
            }
        );
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

      setState(() {
        registrationType = 1;
        progressIndex = 3;
      });

      // transferToHiveAndDB();
    }
  }
  void clickEventShowInfo(int index){

    List<String> answers =[
      "Deine E-Mail-Adresse hilft uns, dich wieder in die App zu lassen, falls du irgendwann "
          "dein Handy wechseln solltest.",
      "Dein Geschlecht hilft uns, dir Angebote der Clubs vorzuschlagen, die auf ein bestimmtes "
          "Geschlecht begrenzt sind.",
      "Dein Geburtsdatum hilft uns, dir Angebote der Clubs vorzuschlagen, die auf ein gewisses "
          "Alter begrenzt sind."

    ];

    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        backgroundColor: customStyleClass.backgroundColorMain,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          "Information",
          style: customStyleClass.getFontStyle1Bold(),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Question text
            Text(
              answers[index],
              textAlign: TextAlign.left,
              style: customStyleClass.getFontStyle4(),
            ),

            // Spacer
            SizedBox(
              height: screenHeight*0.03,
            ),

          ],
        ),
      );
    });
  }
  void clickEventForgotPassword(){
    context.push("/forgot_password");
  }
  void clickEventGoFromAdToEvents(){
    context.go("/user_events");
  }
  void clickEventProceedAsClub(){
    context.push("/register_log_in_club");
  }
  void clickEventEnterAsDeveloper(){
    context.push("/enter_as_developer");
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


  // DB FUNCTIONS
  void transferToHiveAndDB() async{

    // If user
    if(profileType == 0){
      var uuid = const Uuid();

      ClubMeUserData newUserData = ClubMeUserData(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          birthDate: newSelectedDate,
          eMail: _eMailController.text,
          gender: gender+1,
          userId: uuid.v4(),
          profileType: profileType,
          lastTimeLoggedIn: DateTime.now(),
          userProfileAsClub: false,
          clubId: ''
      );

      try{

        await _hiveService.resetUserData();

        _hiveService.addUserData(newUserData).then((value) => {
          _supabaseService.insertUserData(newUserData).then((value){
            userDataProvider.setUserData(newUserData);
            setState(() {
              progressIndex = 3;
            });
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
                gender: 1,
                userId: clubMePassword.clubId,
                profileType: 1,
              lastTimeLoggedIn: DateTime.now(),
                userProfileAsClub: false,
                clubId: clubMePassword.clubId
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
  Future<void> fetchUserDataFromHive() async{


    try{
      await _hiveService.getUserData().then((userData) async {

        if(userData.isEmpty){
          log.d("fetchUserDataFromHive: isEmpty");
          setState(() {
            hasNoAccountYet = true;
          });

        }else{
          log.d("fetchUserDataFromHive: isNotEmpty");
          userDataProvider.setUserData(userData[0]);
          if(!stateProvider.activeLogOut){
            if(userData[0].getProfileType() == 0){
              context.go("/user_events");
            }else{
              context.go("/club_events");
            }
          }else{
            isLoading = false;
          }
        }
      });
    }catch(e){
      log.d("Error in fetchUserDataFromHive: $e");
    }
  }

  // MISC
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
