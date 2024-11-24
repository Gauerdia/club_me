import 'package:club_me/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:provider/provider.dart';

import '../../models/hive_models/0_club_me_user_data.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {

  late double screenHeight, screenWidth;

  bool showVIP = false;

  final TextEditingController _forgotPasswordEMailController = TextEditingController();
  final TextEditingController _forgotPasswordNameController = TextEditingController();
  final TextEditingController _oneTimePasswordCOntroller = TextEditingController();

  final SupabaseService _supabaseService = SupabaseService();
  final HiveService _hiveService = HiveService();

  double distanceBetweenTitleAndTextField = 10;

  bool showSuccessfullySent = false;

  late CustomStyleClass customStyleClass;

  void clickEventSendEMailForAccountRecovery(){

    if(_forgotPasswordEMailController.text.isEmpty || _forgotPasswordNameController.text.isEmpty){

      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: customStyleClass.backgroundColorMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            "Leere/s Feld/er",
            style: customStyleClass.getFontStyle1Bold(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Question text
              Text(
                "Bitte fülle beide Felder aus, um weiterzuverfahren.",
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

    }else{

      _supabaseService.checkIfEMailExists(_forgotPasswordEMailController.text).then(
          (response){
            if(response.isEmpty){

              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30
                    ),
                    width: screenWidth,
                    color: customStyleClass.backgroundColorEventTile,
                    child: Center(
                      child: Text(
                        'Leider ist uns kein Nutzer mit dieser E-Mail-Adresse bekannt.',
                        style: customStyleClass.getFontStyle3(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              );

            }else{
              setState(() {
                _supabaseService.saveForgotPassword(
                    _forgotPasswordEMailController.text,
                    _forgotPasswordNameController.text
                );
                showSuccessfullySent = true;
              });
            }
          }
      );
    }
  }
  void clickEventCheckPasswordForAccountRecovery(){

    UserDataProvider userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    if(_oneTimePasswordCOntroller.text.isNotEmpty){
      _supabaseService.checkOneTimePassword(_oneTimePasswordCOntroller.text).then((response){
        if(response.isNotEmpty){
          ClubMeUserData clubMeUserData = ClubMeUserData(
            firstName: response.first['first_name'],
            lastName: response.first['last_name'],
            birthDate: DateTime.parse(response.first['birth_date']),
            eMail: response.first['e_mail'],
            gender: response.first['gender'],
            userId: response.first['user_id'],
            profileType: 0,
            lastTimeLoggedIn: response.first['last_time_logged_in']  != null ?
            DateTime.parse(response.first['last_time_logged_in']): response.first['last_time_logged_in'],
            clubId: "", userProfileAsClub: false,

          );
          _hiveService.addUserData(clubMeUserData);
          userDataProvider.setUserData(clubMeUserData);

          context.go("/user_events");
        }
      });
    }else{
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: customStyleClass.backgroundColorMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            "Leeres Passwortfeld",
            style: customStyleClass.getFontStyle1Bold(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Question text
              Text(
                "Bitte gib ein Passwort ein, bevor du weitergehst.",
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


  }



  @override
  Widget build(BuildContext context) {

    customStyleClass = CustomStyleClass(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar:AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: customStyleClass.backgroundColorMain,
        surfaceTintColor: customStyleClass.backgroundColorMain,
        title: Container(
          // color: Colors.red,
            width: screenWidth*0.9,
            height: 100,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  InkWell(
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onTap: () => Navigator.pop(context),
                  ),

                  Container(
                    child: Image.asset(
                      "assets/images/club_me_logo_name_1.png",
                      width: 150,
                    ),
                  )
                ],
              ),
            )
        )
    ),
        body: showSuccessfullySent ?
          Container(
            height: screenHeight,
            width: screenWidth,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth*0.9,
                    child: Text(
                      "Vielen Dank! Die E-Mail mit deinem Zugangspasswort sollte bald bei dir eintreffen!",
                      style: customStyleClass.getFontStyle3(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Row(
                          children: [
                            Text(
                              "Zurück zur Registrierung",
                              style: customStyleClass.getFontStyle3BoldPrimeColor(),
                            ),
                            Icon(
                              Icons.arrow_forward_outlined,
                              color: customStyleClass.primeColor,
                            )
                          ],
                        ),
                        onTap: () => context.go("/register"),
                      )
                    ],
                  )
                ],
              ),
            ),
          ) :
        Container(
            height: screenHeight,
            width: screenWidth,
            color: customStyleClass.backgroundColorMain,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                  children: [

                    // Question headline
                    Container(
                      width: screenWidth*0.9,
                      padding: EdgeInsets.only(
                          top: screenHeight*0.04,
                      ),
                      child: Text(
                        "Account zurücksetzen",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle2Bold(),
                      ),
                    ),

                    // Text: Title
                    Container(
                      width: screenWidth*0.9,
                      padding: EdgeInsets.only(
                        top: 15,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Du kommst nicht mehr in deinen Account ?",
                        style: customStyleClass.getFontStyle5(),
                      ),
                    ),
                    Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Lass dir ein Zugangspasswort schicken.",
                        style: customStyleClass.getFontStyle5(),
                      ),
                    ),

                    // Textfield email
                    Container(
                      // height: screenHeight*0.12,
                      width: screenWidth*0.9,
                      padding:  EdgeInsets.only(
                          top: 20
                      ),
                      child: TextField(
                        controller: _forgotPasswordNameController,
                        cursorColor: customStyleClass.primeColor,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: customStyleClass.primeColor
                              )
                          ),
                          hintText: "z.B. Max Moritz",
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.only(
                              left: 20,
                              top:20,
                              bottom:20
                          ),
                          label: Text(
                            "Dein Name",
                            style: customStyleClass.getFontStyle4Grey2(),
                          ),
                        ),
                        style: customStyleClass.getFontStyle4(),
                      ),
                    ),

                    // Textfield email
                    Container(
                      // height: screenHeight*0.12,
                      width: screenWidth*0.9,
                      padding:  EdgeInsets.only(
                          top: 20
                      ),
                      child: TextField(
                        controller: _forgotPasswordEMailController,
                        cursorColor: customStyleClass.primeColor,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: customStyleClass.primeColor
                              )
                          ),
                          hintText: "z.B. max@moritz.de",
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.only(
                              left: 20,
                              top:20,
                              bottom:20
                          ),
                          label: Text(
                            "Deine E-Mail-Adresse",
                            style: customStyleClass.getFontStyle4Grey2(),
                          ),
                        ),
                        style: customStyleClass.getFontStyle4(),
                      ),
                    ),

                    Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(
                        top: 10
                      ),
                      child: InkWell(
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10
                          ),
                          decoration: BoxDecoration(
                              color: customStyleClass.primeColor,
                              borderRadius: BorderRadius.circular(15)
                          ),
                          child: Center(
                            child: Text(
                              "Abschicken",
                              style: customStyleClass.getFontStyle4Bold(),
                            ),
                          ),
                        ),
                        onTap: () => clickEventSendEMailForAccountRecovery(),
                      ),
                    ),


                    const SizedBox(
                      height: 20,
                    ),

                    // Question headline
                    Container(
                      width: screenWidth*0.9,
                      padding: EdgeInsets.only(
                        top: screenHeight*0.04,
                      ),
                      child: Text(
                        "Erneut anmelden",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle2Bold(),
                      ),
                    ),

                    // Text: Title
                    Container(
                      width: screenWidth*0.9,
                      padding: EdgeInsets.only(
                        top: 15,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Du hast ein Zugangspasswort erhalten?",
                        style: customStyleClass.getFontStyle5(),
                      ),
                    ),
                    Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Melde dich erneut in deinem Accoutn an.",
                        style: customStyleClass.getFontStyle5(),
                      ),
                    ),

                    // Textfield last name
                    Container(
                      // height: screenHeight*0.12,
                      width: screenWidth*0.9,
                      padding:  EdgeInsets.only(
                          top: distanceBetweenTitleAndTextField
                      ),
                      child: TextField(
                        controller: _oneTimePasswordCOntroller,
                        cursorColor: customStyleClass.primeColor,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: customStyleClass.primeColor
                              )
                          ),
                          hintText: "z.B. 1234",
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.only(
                              left: 20,
                              top:20,
                              bottom:20
                          ),
                          label: Text(
                            "Deine Passwort",
                            style: customStyleClass.getFontStyle4Grey2(),
                          ),
                        ),
                        style: customStyleClass.getFontStyle4(),
                      ),
                    ),

                    Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(
                          top: 10
                      ),
                      child: InkWell(
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10
                          ),
                          decoration: BoxDecoration(
                              color: customStyleClass.primeColor,
                              borderRadius: BorderRadius.circular(15)
                          ),
                          child: Center(
                            child: Text(
                              "Anmelden",
                              style: customStyleClass.getFontStyle4Bold(),
                            ),
                          ),
                        ),
                        onTap: () => clickEventCheckPasswordForAccountRecovery(),
                      ),
                    ),

                  ]
              ),
            )
        ),
      bottomNavigationBar: Container(
        // color: Colors.red,
        width: screenWidth,
        decoration: BoxDecoration(
            color: customStyleClass.backgroundColorMain,
            border: Border(
              top: BorderSide(color: Colors.grey, width: 1.0),
            )
        ),
        height: 70,
        alignment: Alignment.bottomCenter,
        child: Center(
          child: Image.asset(
            "assets/images/runes_footer.PNG",
            width: 100,
          ),
        ),
      ),
    );
  }
}
