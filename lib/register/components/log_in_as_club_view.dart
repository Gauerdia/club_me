import 'package:club_me/provider/fetched_content_provider.dart';
import 'package:club_me/provider/state_provider.dart';
import 'package:club_me/shared/dialogs/TitleAndContentDialog.dart';
import 'package:club_me/shared/dialogs/title_content_and_button_dialog.dart';
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

              Container(
                height: 50,
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: InkWell(
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),

            ],
          ),
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

    if(!agbAccepted || !privacyAccepted){
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
                      // height: screenHeight*0.15,
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
                      height: screenHeight*0.05,
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
                      child: isLoading ?
                      Center(child: CircularProgressIndicator(color: customStyleClass.primeColor)):
                      InkWell(
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
                        onTap: () => checkPassWord(),
                      ),
                    )

                  ]
              )
          )
      ),
    );
  }
}
