import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../services/hive_service.dart';
import '../../../shared/custom_text_style.dart';

class FaqUserView extends StatefulWidget {
  const FaqUserView({super.key});

  @override
  State<FaqUserView> createState() => _FaqUserViewState();
}

class _FaqUserViewState extends State<FaqUserView> {

  String headLine = "FAQ";

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late double screenHeight, screenWidth;

  late CustomStyleClass customStyleClass;


  List<String> questions = [
    "1.	Wie kann ich meine Kontaktdaten ändern?",
    "2.	Wie kann ich mich aus der App abmelden?",
    "3.	Wie kann ich meinen Account löschen?",
    "4.	Wie aktiviere ich die Push-Benachrichtigung und was bringt mir das?",
    "5. Kann ich die Events oder Coupons als Favoriten speichern?",
    "6. Warum ist es sinnvoll, dass ich meinen aktuellen Standort aktiviere?",
    "7.	Wie öffne ich die Detail-Ansicht der Clubs?",
    "8.	Wie kann ich den Routenplaner zu einem Club öffnen?",
    "9.	Gibt es sonstige Angebote der Clubs, außer der verfügbaren Coupons?",
    "10.	Komme ich mit der ClubMe-App automatisch in jeden Club?",
    "11.	Wie alt muss ich sein, um die ClubMe-App benutzen zu dürfen?",
    "12.	Können Bilder von mir in der ClubMe-App auftauchen?",
    "13.	Wie kann ich ein Bild aus der ClubMe-App löschen lassen?",
    "14.	Wie kann ich nach bestimmten Musikrichtungen schauen?",
    "15.	Gibt es noch mehr Informationen über ein Event?",
    "16.	Wie kann ich Bilder oder Videos abspielen, die der Club mit dem Event hochgeladen hat?",
    "17.	Gibt es eine Liste oder ähnliches mit allen Clubs?",
    "18.	Wie kann ich die Live-Stories der Clubs ansehen?",
    "19.	Wie kann ich einen Coupon einlösen?",
    "20.	Welche unterschiedlichen Coupons gibt es in der ClubMe-App?",
    "21.	Gibt es zeitliche Beschränkungen oder mehrmalige Verwendungen für Coupons?"
  ];
  List<String> answers = [
    "Du hast die Möglichkeit, unter dem Reiter Profil deine Kontaktdaten jederzeit zu ändern. Klicke hier auf „Bearbeiten“, gib deine neuen Daten ein und speichere diese.",
    "Gehe dazu in die Einstellungen, die du unter dem Reiter Profil rechts oben öffnen kannst. Du kannst dich dann über den Button „Abmelden“ auch ausloggen. ",
    "Du kannst deinen Account löschen, indem du unter dem Reiter Profil auf „Bearbeiten“ gehst. Unten findest du den Button „Account löschen“.",
    "In die Einstellungen unter dem Reiter Benachrichtigungen kannst du die Push-Benachrichtigungen aktivieren. Damit verpasst du keine Events, Coupons und Live-Stories der Clubs. Es ist möglich, dass Clubs auch am Abend noch etwas hochladen, sodass du auch bereits in Partylaune deine Vorteile noch sichern kannst.",
    "Ja, du kannst sowohl Events, Coupons, als auch Clubs als Favoriten speichern, indem du auf den jeweiligen Ansichten auf den Stern klickst. Falls du nur deine Favoriten anzeigen willst, hast du oben rechts die Möglichkeit, indem du dort wieder auf den Stern klickst. Das bietet dir die Möglichkeit, bereits vor dem Club auf deine Events und Coupons  schnell zugreifen zu können.",
    "Wenn die App deinen Standort weiß, siehst du deine Entfernung und kannst den Routenplaner zu den verschiedenen Clubs öffnen. Zudem hast du den Vorteil, dass du auch noch am Abend über exklusive Vorteile erfährst, die ganz in deiner Nähe sind.",
    "Du kannst du Detail-Ansicht der Clubs öffnen, indem du unter dem Reiter Clubs das Logo eines bestimmten Clubs anklickst. Daraufhin öffnet sich die Detail-Ansicht.",
    "Wenn du zu einem bestimmten Club möchtest, hast du die Möglichkeit, die Detail-Ansicht mit allen Informationen über diesen Club anzusehen. Links neben dem Logo kannst du dann auf Karte klicken, dann öffnet sich Google Maps mit dem Standort des Clubs. Starte dann die Route und du gelangst dann dort hin.",
    "In der Detail-Ansicht kannst du rechts neben dem Logo auf Angebote klicken. Es erscheint eine Übersicht von verschiedenen Angeboten und Bundles (wenn die Clubs so etwas anbieten wollen), die in den jeweiligen Clubs gekauft werden können. ",
    "Jeder Club hat seine eigenen Einlassregeln, die du beachten musst. Die ClubMe-App haftet nicht, wenn du nicht in den Club darfst.",
    "Das Mindestalter für die Nutzung der ClubMe-App beträgt 16 Jahre. Vergewissere ich jedoch davor, ab welchem Alter du in die jeweiligen Clubs darfst (Regelungen oder Besonderheiten kannst du auf den Homepages der Clubs entnehmen).",
    "Die Clubs können, soweit mit deren Datenschutzerklärungen konform, Bilder oder Videos von dir in der ClubMe-App hochladen. Jeder Club hat dafür Sorge zu tragen, dass das hochgeladene Material mit ihren Datenschutzbestimmungen übereinstimmen. Die ClubMe-App haftet nicht für Verstöße von den Clubs.",
    "Wenn du ein Bild oder Video aus der ClubMe-App löschen lassen möchtest, wende dich bitte an die Verantwortlichen der App mit dem jeweiligen Clubnamen, der das Bild oder Video hochgeladen hat, und einer kurzen Begründung, warum du das Bild oder Video löschen lassen möchtest. Kontaktieren kannst du uns über E-Mail oder Instagram.",
    "Du hast die Möglichkeit, Musikrichtungen bei den Events und den Clubs zu filtern. Klicke dabei oben rechts auf das Symbol Filter und suche dir deine bestimmte Musikrichtung aus. Er erscheinen nur noch diese Events und Clubs, die deinen Geschmack treffen.",
    "Wenn du auf das jeweilige Event klickst, kommst du zur Detail-Ansicht mit einer detaillierten Beschreibung und den jeweiligen Musikrichtungen. Es können auch ein Bilder oder Video abgespielt werden, wenn der Club etwas für ein Event hochlädt.",
    "Du findest bei jedem Event (falls der Club ein Bild oder Video hochgeladen hat) das ClubMe-Symbol. Wenn du auf dieses Logo klickst, erscheint automatisch das Bild oder das Video, das der Club hochgeladen hat.",
    "Es gibt unter dem Reiter Karte eine übersichtliche Liste mit allen Clubs und deren wichtigsten Informationen in deiner Stadt. Du findest sie, indem du rechts oben auf das Symbol Liste klickst.",
    "Du hast zwei Möglichkeiten, die Live-Stories anzusehen. Falls du einen bestimmten Club ansehen möchtest, öffnest du die Detail-Ansicht und kannst auf das Logo des Clubs klicken. Falls ein Club eine Live-Story hochgeladen hat, erscheint vor dem Logo ein Play-Button. Die zweite Möglichkeit ist über die Listenansicht unter dem Reiter Karte. Hier sind alle Clubs mit allen Live-Stories aufgelistet, die du nacheinander anschauen kannst.",
    "Du kannst unter dem Reiter Coupons alle zur Verfügung stehende Coupons ansehen. Klicke auf das Feld „Einlösen“, um den Coupon einzulösen. Es erscheint eine Übersicht mit einem Countdown, der 10 Sekunden herunterzählt. Bitte beachte, dass der Barkeeper oder Türsteher diese Übersicht sehen muss, damit du das Angebot auch erhalten kannst.",
    "Das ist sehr unterschiedlich, je nachdem welche Coupons die einzelnen Clubs hochladen möchten. Die ClubMe-App hat keinen Einfluss darauf, welche und wie viele Coupons zur Verfügung stehen. Es können reduzierte oder kostenfreie Eintritte, Welcome-Drinks, 2 Getränke für 1 Preis oder ähnliches sein, die dir zur Verfügung stehen. Sei täglich gespannt auf neue und einzigartige Angebote, die du mit der Aktivierung der Push-Benachrichtigungen nicht verpasst.",
    "Die Clubs können beim Hinzufügen der Coupons angeben, wie lange der Gutschein gültig ist und wie oft man diesen verwenden kann. Falls dies zutrifft, kannst du dies bei den Coupons ablesen.",
  ];

  List<Widget> widgetsToDisplay = [];

  int selected = 0;

  @override
  void initState(){
    super.initState();
    createWidgetsToDisplay();
  }

  void createWidgetsToDisplay(){
    for(var i=0;i<answers.length;i++){

      widgetsToDisplay.add(
          ExpansionTile(
            iconColor: Color(0xFF249e9f),
            collapsedIconColor: Color(0xFF249e9f),
            title: Text(
              questions[i],
              style:GoogleFonts.inter(
                  textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white
                  )
              )
            ),
            children: [
              ListTile(
                title:Text(
                  answers[i],
                    style:GoogleFonts.inter(
                        textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white
                        )
                    )
                ),
              ),
            ],
            onExpansionChanged: (value){
              if(value){
                setState(() {
                  selected = i;
                });
              }else{
                setState(() {
                  selected = -1;
                });
              }
            },
          )
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    stateProvider = Provider.of<StateProvider>(context);
    fetchedContentProvider = Provider.of<FetchedContentProvider>(context);

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
                                      headLine,
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


                  // back icon
                  Container(
                      width: screenWidth,
                      height: screenHeight*0.2,
                      // color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                          onPressed: () => Navigator.pop(context),
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
        body: Container(
            width: screenWidth,
            height: screenHeight,
            color: customStyleClass.backgroundColorMain,
            child: SingleChildScrollView(

                child: Column(
                  children: [

                    Container(
                      width: screenWidth*0.9,
                      padding: const EdgeInsets.only(
                          top: 20
                      ),
                      child: Text(
                        "Häufig gestellte Fragen",
                        style: customStyleClass.getFontStyle1Bold(),
                      ),
                    ),

                    Container(
                      width: screenWidth*0.9,
                      padding: const EdgeInsets.only(
                          top: 20
                      ),
                      child: Text(
                        "Hier findest du die am häufigsten gestellten Fragen und Ihre Antworten!",
                        style: customStyleClass.getFontStyle2(),
                      ),
                    ),

                    SizedBox(
                      height: screenHeight*0.05,
                    ),

                    for(var element in widgetsToDisplay)
                      element,

                    SizedBox(
                      height: screenHeight*0.05,
                    )


                  ],
                )
            )
        ),
      bottomNavigationBar: Container(
        height: 50,
        decoration: BoxDecoration(
            color: customStyleClass.backgroundColorMain,
          border: Border.all(
            color: customStyleClass.backgroundColorEventTile
          )
        ),
      ),
    );
  }



}
