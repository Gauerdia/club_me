import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/custom_text_style.dart';
import '../../shared/dialogs/title_content_and_button_dialog.dart';

class AcceptAgbAndPrivacyView extends StatefulWidget {
  const AcceptAgbAndPrivacyView({super.key});

  @override
  State<AcceptAgbAndPrivacyView> createState() => _AcceptAgbAndPrivacyViewState();
}

class _AcceptAgbAndPrivacyViewState extends State<AcceptAgbAndPrivacyView> {

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  bool agbAccepted = false;
  bool privacyAccepted = false;

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

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: customStyleClass.backgroundColorMain,
          surfaceTintColor: customStyleClass.backgroundColorMain,
          title: SizedBox(
            width: screenWidth,
            child: Stack(
              children: [

                // Headline
                Container(
                    alignment: Alignment.bottomCenter,
                    height: screenHeight*0.2,
                    width: screenWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Text(
                                    "AGB und Datenschutz",
                                    textAlign: TextAlign.center,
                                    style: customStyleClass.getFontStyleHeadline1Bold()
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                ),


                Container(
                    alignment: Alignment.centerLeft,
                    width: screenWidth,
                    height: screenHeight*0.2,
                    child: IconButton(
                        onPressed: () => context.go("/register"),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          // size: 20,
                        )
                    )
                ),
              ],
            ),
          )
      ),
      body:Container(
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
                // onTap: () => processContinue(),
              ),
            )
          ],
        ),
      )
    );
  }
}
