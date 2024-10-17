import 'package:club_me/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  final TextEditingController _forgotPasswordEMailController = TextEditingController();
  final TextEditingController _oneTimePasswordCOntroller = TextEditingController();

  final SupabaseService _supabaseService = SupabaseService();
  final HiveService _hiveService = HiveService();

  double distanceBetweenTitleAndTextField = 10;

  bool showSuccessfullySent = false;

  void clickEventSendEMailForAccountRecovery(){
    setState(() {
      _supabaseService.saveForgotPassword(_forgotPasswordEMailController.text);
      showSuccessfullySent = true;
    });
  }
  void clickEventCheckPasswordForAccountRecovery(){

    UserDataProvider userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

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
  }



  @override
  Widget build(BuildContext context) {

    final customStyleClass = CustomStyleClass(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: showSuccessfullySent ?
          Container(
            height: screenHeight,
            width: screenWidth,
            child: Center(
              child: Text(
                "Vielen Dank! Die E-Mail mit deinem Zugangspasswort sollte bald bei dir eintreffen!",
                style: customStyleClass.getFontStyle3BoldPrimeColor(),
                textAlign: TextAlign.center,
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


                    const SizedBox(
                      height: 100,
                    ),

                    // Question headline
                    Container(
                      width: screenWidth*0.9,
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight*0.04,
                          horizontal: screenWidth*0.02
                      ),
                      child: Text(
                        "Kommst du nicht mehr in deinen Account? Lass dir jetzt ein Zugangspasswort schicken!",
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle2Bold(),
                      ),
                    ),

                    // Text: Title
                    Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Deine E-Mail-Adresse",
                        style: customStyleClass.getFontStyle3(),
                      ),
                    ),

                    // Textfield email
                    Container(
                      height: screenHeight*0.12,
                      width: screenWidth*0.9,
                      padding:  EdgeInsets.only(
                          top: distanceBetweenTitleAndTextField
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
                        ),
                        style: customStyleClass.getFontStyle4(),
                        autofocus: true,
                        maxLength: 35,
                      ),
                    ),

                    // ABSCHICKEN
                    Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerRight,
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
                        onTap: () => clickEventSendEMailForAccountRecovery(),
                      ),
                    ),

                    const SizedBox(
                      height: 50,
                    ),

                    // Question headline
                    Container(
                      width: screenWidth*0.9,
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight*0.04,
                          horizontal: screenWidth*0.02
                      ),
                      child: Text(
                        "Du hast bereits ein Passwort erhalten? Logge dich jetzt in deinen Account ein!",
                        textAlign: TextAlign.center,
                        style: customStyleClass.getFontStyle2Bold(),
                      ),
                    ),

                    // Text: Title
                    Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Dein Einmal-Passwort",
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
                        ),
                        style: customStyleClass.getFontStyle4(),
                        maxLength: 35,
                      ),
                    ),

                    // ABSCHICKEN
                    Container(
                      width: screenWidth*0.9,
                      alignment: Alignment.centerRight,
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
        height: 50,
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
