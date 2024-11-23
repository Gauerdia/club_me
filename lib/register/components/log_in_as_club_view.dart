import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/club_password.dart';
import '../../models/hive_models/0_club_me_user_data.dart';
import '../../models/parser/club_me_password_parser.dart';
import '../../provider/user_data_provider.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/custom_text_style.dart';
import '../../shared/logger.util.dart';

class LogInAsClubView extends StatefulWidget {
  const LogInAsClubView({super.key});

  @override
  State<LogInAsClubView> createState() => _LogInAsClubViewState();
}

class _LogInAsClubViewState extends State<LogInAsClubView> {

  bool agbAccepted = false;
  bool privacyAccepted = false;

  final log = getLogger();

  late UserDataProvider userDataProvider;
  late StateProvider stateProvider;

  bool showVIP = false;
  bool isLoading = false;
  String headLine = "ClubMe";
  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;
  final TextEditingController _clubPasswordController = TextEditingController();

  final HiveService _hiveService = HiveService();
  final SupabaseService _supabaseService = SupabaseService();

  late FetchedContentProvider fetchedContentProvider;

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


  AppBar _buildAppBar(){
    return AppBar(
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
                    "assets/images/clubme_logo_1.png",
                    width: 150,
                  ),
                )
              ],
            ),
          )
        )
    );
  }

  // MISC
  void showErrorDialog(){
    showDialog(context: context, builder: (BuildContext context){
      return TitleAndContentDialog(
          titleToDisplay: "Fehlerhafter Log-In",
          contentToDisplay: "Leider war ein Log-In mit diesen Zugangsdaten nicht möglich");

    });
  }

  void checkPassWord() async{

    setState(() {
      isLoading = true;
    });

    if(!privacyAccepted){
      showDialog(context: context, builder: (BuildContext context){
        return TitleAndContentDialog(
            titleToDisplay: "Konditionen akzeptieren",
            contentToDisplay: "Bitte bestätigen Sie unsere AGB und Datenschutzerklärung, um fortzufahren."
        );
      });
      setState(() {
        isLoading = false;
      });
    }else{
      try{
        await _supabaseService.checkIfClubPwIsLegit(_clubPasswordController.text).then((value){
          if(value.isEmpty){
            showErrorDialog();
          }else{

            ClubMePassword clubMePassword = parseClubMePassword(value[0]);

            if(clubMePassword.clubId == "1234"){
              stateProvider.setUsingTheAppAsADeveloper(true);
              context.go("/log_in");
            }else{
              ClubMeUserData newUserData = ClubMeUserData(
                  firstName: "...",
                  lastName: "...",
                  birthDate: DateTime.now(),
                  eMail: "...",
                  gender: 0,
                  userId: clubMePassword.clubId,
                  profileType: 1,
                  lastTimeLoggedIn: DateTime.now(),
                  userProfileAsClub: false,
                  clubId: clubMePassword.clubId
              );
              _hiveService.addUserData(newUserData).then((value){

                fetchedContentProvider.setFetchedEvents([]);
                fetchedContentProvider.setFetchedDiscounts([]);

                stateProvider.setClubUiActive(true);

                userDataProvider.setUserData(newUserData);
                context.go("/club_events");
              });
            }
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

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    stateProvider = Provider.of<StateProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
          height: screenHeight,
          color: customStyleClass.backgroundColorMain,
          child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                  children: [

                    // Question headline
                    Container(
                      width: screenWidth*0.8,
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        "Als Club registrieren",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle1Bold(),
                      ),
                    ),

                    Container(
                      width: screenWidth*0.8,
                      padding: EdgeInsets.only(
                        top: 10
                      ),
                      child: Text(
                        "Hier kannst du dein Club-Passwort eingeben.",
                        textAlign: TextAlign.left,
                        style: customStyleClass.getFontStyle5(),
                      ),
                    ),

                    // Textfield email
                    Container(
                      padding: EdgeInsets.only(
                          top: 10
                      ),
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
                        // maxLength: 35,
                      ),
                    ),

                    // SPACER
                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                    // DATENSCHUTZ
                    Container(
                      padding: EdgeInsets.only(
                          top: 10,
                      ),
                      width: screenWidth,
                      child: Row(
                        children: [
                          SizedBox(
                            width: screenWidth*0.07,
                          ),
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
                            width: screenWidth*0.7,
                            child: RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "Ich habe die",
                                          style: customStyleClass.getFontStyle5()
                                      ),
                                      TextSpan(
                                          text: " allgemeinen Geschäftsbedingungen ",
                                          style: customStyleClass.getFontStyle5BoldPrimeColor(),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => clickEventAGB()
                                      ),
                                      TextSpan(
                                          text: "und die",
                                          style: customStyleClass.getFontStyle5()
                                      ),
                                      TextSpan(
                                          text: " Datenschutzerklärung ",
                                          style: customStyleClass.getFontStyle5BoldPrimeColor(),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => clickEventPrivacy()
                                      ),
                                      TextSpan(
                                          text: "gelesen und akzeptiert.",
                                          style: customStyleClass.getFontStyle5()
                                      )
                                    ]
                                )
                            ),
                          )
                        ],
                      ),
                    ),

                    // SPACER
                    SizedBox(
                      height: screenHeight*0.02,
                    ),

                    Container(
                      padding: const EdgeInsets.only(
                        top: 10
                      ),
                      width: screenWidth*0.9,
                      alignment: Alignment.centerRight,
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
                        child: isLoading ?
                        Center(child: CircularProgressIndicator(color: customStyleClass.primeColor)):
                        InkWell(
                          child: Center(
                            child: Text(
                              "Registrieren",
                              style: customStyleClass.getFontStyle3Bold(),
                            ),
                          ),
                          onTap: () => checkPassWord(),
                        ),
                      )
                    )

                  ]
              )
          )
      ),
    );
  }
}
