import 'package:club_me/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/fetched_content_provider.dart';
import '../../provider/state_provider.dart';
import '../../services/hive_service.dart';
import '../../shared/custom_text_style.dart';
import '../../shared/dialogs/TitleAndContentDialog.dart';
import '../../shared/dialogs/title_content_and_button_dialog.dart';
import '../../shared/dialogs/title_content_and_two_buttons_dialog.dart';

class SettingsClubView extends StatefulWidget {
  const SettingsClubView({super.key});

  @override
  State<SettingsClubView> createState() => _SettingsClubViewState();
}

class _SettingsClubViewState extends State<SettingsClubView> {

  String headLine = "Einstellungen";

  late StateProvider stateProvider;
  late UserDataProvider userDataProvider;
  late FetchedContentProvider fetchedContentProvider;
  late double screenHeight, screenWidth;

  final HiveService _hiveService = HiveService();

  late CustomStyleClass customStyleClass;


  void clickEventFAQ(){
    context.push("/club_faq");
  }
  void clickEventContact() async{

    var result = await OpenMailApp.openMailApp();

    if (!result.didOpen && !result.canOpen) {
      showNoMailAppsDialog(context);

      // iOS: if multiple mail apps found, show dialog to select.
      // There is no native intent/default app system in iOS so
      // you have to do it yourself.
    } else if (!result.didOpen && result.canOpen) {
      showDialog(
        context: context,
        builder: (_) {
          return MailAppPickerDialog(
            mailApps: result.options,
            title: "Anfrage aus ClubMe-App",
            emailContent: EmailContent(
                to: ["info@club-me.de"],
                subject: "Anfrage aus ClubMe-App"
            ),
          );
        },
      );
    }
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("Es wurde keine Mailing-App gefunden."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void clickEventRateUs(){

    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleAndContentDialog(
              titleToDisplay: "Bewertungen",
              contentToDisplay: "Diese Funktion ist derzeit noch nicht möglich. Wir bitten um Entschuldigung.");
        }
    );
  }
  void clickEventShare(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleAndContentDialog(
              titleToDisplay: "Teilen",
              contentToDisplay: "Diese Funktion ist derzeit noch nicht möglich. Wir bitten um Entschuldigung.");
        }
    );
  }
  void clickEventNotifications(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleAndContentDialog(
              titleToDisplay: "Benachrichtigungen",
              contentToDisplay: "Diese Funktion ist derzeit noch nicht möglich. Wir bitten um Entschuldigung.");
        }
    );
  }
  void clickEventImpressum(){


    showDialog(
        context: context,
        builder: (BuildContext context){
          return TitleContentAndButtonDialog(
              titleToDisplay: "Impressum",
              contentToDisplay: "Dieser Link führt zu unserer Website. Möchten Sie fortfahren?",
              buttonToDisplay: TextButton(onPressed: () async {
                final Uri url = Uri.parse("https://club-me-web-interface.pages.dev/impressum");
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              }, child: Text("Ja", style: customStyleClass.getFontStyle3BoldPrimeColor(),)));

        }
    );
  }
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
  void clickEventSponsors(){
    context.push("/user_sponsors");
  }



  void clickEventSwitchToUserView(){
    if(userDataProvider.getUserData().getUserProfileAsClub()){
      _hiveService.toggleUserDataProfileType(userDataProvider.getUserData()).then(
          (response){
            context.go("/user_events");
          }
      );
    }else{
      context.push('/register_for_user_as_club');
    }
  }

  void clickEventLogOut(){
    showDialog(
      context: context,
      builder: (_) {
        return TitleContentAndTwoButtonsDialog(
            titleToDisplay: "Ausloggen",
            contentToDisplay: "Bist du sicher, dass du dich ausloggen möchtest?",
            firstButtonToDisplay: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Zurück",
                  style: customStyleClass.getFontStyle3BoldPrimeColor(),
                )),
            secondButtonToDisplay: TextButton(onPressed: () => processLogOut(), child: Text(
              "Ja",
              style: customStyleClass.getFontStyle3BoldPrimeColor(),
            ))
        );
      },
    );
  }

  void processLogOut(){
    fetchedContentProvider.setFetchedEvents([]);
    fetchedContentProvider.setFetchedDiscounts([]);
    fetchedContentProvider.setFetchedClubs([]);
    stateProvider.setClubUiActive(false);
    stateProvider.setPageIndex(0);
    stateProvider.activeLogOut = false;
    _hiveService.resetUserData().then((value) => context.go("/register"));
  }

  @override
  Widget build(BuildContext context) {


    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);
    userDataProvider = Provider.of<UserDataProvider>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(

        extendBody: true,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: customStyleClass.backgroundColorMain,
            surfaceTintColor: customStyleClass.backgroundColorMain,
            title: SizedBox(
              width: screenWidth,
              child: Stack(
                children: [
                  // HEADLINE
                  SizedBox(
                      width: screenWidth,
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(headLine,
                            textAlign: TextAlign.center,
                            style: customStyleClass.getFontStyleHeadline1Bold(),
                          ),
                        ],
                      )
                  ),

                  // back icon
                  Container(
                      width: screenWidth,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                // size: 20,
                              )
                          )
                        ],
                      )
                  ),

                ],
              ),
            )
        ),
        body: Container(
            width: screenWidth,
            height: screenHeight,
            color: customStyleClass.backgroundColorMain,
            child: SingleChildScrollView(

                child: Column(
                  children: [

                    InkWell(
                      child: Container(
                        width: screenWidth*0.9,
                        padding: const EdgeInsets.only(
                            top: 20
                        ),
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventFAQ(), icon: Icon(
                              Icons.question_mark,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "FAQ",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventFAQ(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () => clickEventContact(),
                                icon: Icon(
                                  Icons.mail,
                                  color: customStyleClass.primeColor,
                                  size: 25,
                                )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Kontakt",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventContact(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventRateUs(), icon: Icon(
                              Icons.star,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Bewerten",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventRateUs(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventShare(), icon: Icon(
                              Icons.share,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Teilen",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventShare(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventNotifications(), icon: Icon(
                              Icons.notification_important_rounded,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Benachrichtigungen",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventNotifications(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventImpressum(), icon: Icon(
                              Icons.people,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Impressum",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventImpressum(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventAGB(), icon: Icon(
                              Icons.file_copy,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "AGB",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventAGB(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () =>clickEventPrivacy(), icon: Icon(
                              Icons.remove_red_eye_outlined,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Datenschutz",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () =>clickEventPrivacy(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventSponsors(), icon: Icon(
                              Icons.add_shopping_cart,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Kooperationspartner",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventSponsors(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventLogOut(), icon: Icon(
                              Icons.logout,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Zur Nutzeransicht wechseln",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventSwitchToUserView(),
                    ),

                    InkWell(
                      child: SizedBox(
                        width: screenWidth*0.9,
                        child: Row(
                          children: [
                            IconButton(onPressed: () => clickEventLogOut(), icon: Icon(
                              Icons.logout,
                              color: customStyleClass.primeColor,
                              size: 25,
                            )),
                            SizedBox(
                              width: screenWidth*0.02,
                            ),
                            Text(
                              "Abmelden",
                              style: customStyleClass.getFontStyle1(),
                            )
                          ],
                        ),
                      ),
                      onTap: () => clickEventLogOut(),
                    ),


                  ],
                )
            )
        )
    );
  }
}
