import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../provider/fetched_content_provider.dart';
import '../../../provider/state_provider.dart';
import '../../../services/hive_service.dart';
import '../../../shared/custom_text_style.dart';

class FaqClubView extends StatefulWidget {
  const FaqClubView({super.key});

  @override
  State<FaqClubView> createState() => _FaqClubViewState();
}

class _FaqClubViewState extends State<FaqClubView> {

  String headLine = "FAQ";

  late StateProvider stateProvider;
  late FetchedContentProvider fetchedContentProvider;
  late double screenHeight, screenWidth;

  final HiveService _hiveService = HiveService();

  late CustomStyleClass customStyleClass;

  List<Widget> widgetsToDisplay = [];

  List<String> questions = [
    "1. Wie funktioniert ClubMe für mich als Club?",
    "2. Wie finanziert sich ClubMe?",
    "3.	Wer kann sich dem ClubMe-Netzwerk anschließen?",
    "4.	In welchen Städten ist ClubMe aktuell vertreten?",
    "5.	Warum wird meine Stadt nicht bei ClubMe angezeigt?",
    "6.	Ändert sich etwas im Betrieb mit der Benutzung der App?",
    "7.	Welchen Aufwand habe ich mit der ClubMe-App als Club?",
    "8.	Wie lange dauert es, bis ich als Club in der ClubMe-App angezeigt werde?",
    "9.	Welche Informationen benötigt ClubMe von mir als Club?",
    "10.	Wie kann ich als Club Änderungen meines Profils vornehmen?",
    "11.	Welche Coupons kann ich bei ClubMe anbieten?",
    "12.	Wie oft können die Besucher die Coupons einlösen?",
    "13.	Welche Vorteile habe ich als Club in der ClubMe-App?",
    "14.	Kann ich in der ClubMe-App als Club angezeigt werden, ohne diese zu benutzen?",
    "15.	Kostet ClubMe etwas für mich als Club?",
    "16.	Erhalte ich Geld von ClubMe, wenn ich mich als Club anzeigen lasse?"
  ];
  List<String> answers = [
    "Die ClubMe-App verbindet partyfreudige Besucher mit Deinem Club. So funktioniert es:\n\n"
        "-	Registrierung: Nach der erfolgreichen Anfrage erstellen wir dir einen Account auf unserer Plattform. Du hast die Möglichkeit, deine eigenen Events und Coupons hochzuladen. Im Betrieb ermöglicht dir die App, die Atmosphäre mithilfe von Live-Stories festzuhalten. Du entscheidest dabei selbst, welche Features du benutzt und kannst dabei auf unsere Hilfe zählen.\n\n"
        "-	Coupons einlösen: Die Besucher zeigen deinen Türstehern oder Barkeepern die Coupons und lösen diese für das erhaltene Angebot ein. Mithilfe von technischen Hilfsmitteln ist dabei der Betrug von mehrfachem Einlösen so gut wie ausgeschlossen.",
    "ClubMe bietet Besuchern einen Premium-Account an, der einen kleinen monatlichen Beitrag kostet. Es gibt ebenfalls Werbepartner, die über unsere App ihre eigene Werbung schalten können.",
    "Für die Benutzung der ClubMe-App heißen wir Clubs oder ähnliche Discotheken herzlich Willkommen. Selbst wenn wir derzeit noch nicht in Deiner Stadt vertreten sind, kann sich das schnell ändern. Wir freuen uns auf deine Anfrage!",
    "Alle Städte, in denen ClubMe verfügbar ist, kannst du auf der Startseite unter „Hier findest du uns“ finden.",
    "Wir arbeiten intensiv an der Umsetzung, ClubMe in ganz Deutschland flächendeckend auszuweiten. Wenn wir mit der ClubMe-App noch nicht in deiner Stadt zu finden sind, kannst du dich gerne unter info@club-me.de melden. Eventuell planen wir bereits, in deiner Nähe die App zu launchen.",
    "Für Dich ändert sich während dem Betrieb kaum etwas. Du kannst Deinen Club ganz einfach über die App oder die Website mithilfe von Events, Coupons oder Live-Stories vermarkten. Das Einlösen der Coupons ist ganz einfach über die Smartphones der Besucher zu sehen und wir nach Verwendung automatisch gelöscht.",
    "Wir übernehmen die Erstellung deines eigenen Profils, damit du von Anfang an durchstarten kannst. Du kannst dort weitere Informationen und Bilder einfügen, sodass die Besucher alles über deinen Club erfahren können. Die Erstellung von Events, Coupons und Live-Stories benötigt einen kleinen Aufwand, der sich jedoch im Betrieb direkt auszahlt.",
    "Sobald wir die Informationen über deinen Club sowie ein passendes Logo erhalten haben, wird dein Profil innerhalb von 48 Stunden erstellt. Danach bekommst du deine Zugangsdaten und kannst direkt loslegen.",
    "Wir benötigen folgende Daten, um mit der Erstellung deines Profils zu beginnen: Passendes Logo (Farbe passend für einen dunklen Hintergrund) – Kontaktdaten: Name, Musikrichtung und Öffnungszeiten des Clubs, Standort, Telefonnummer, E-Mail-Adresse, etc.",
    "Du hast die Möglichkeit, in der App oder auf der Website dein Profil unter „Profil“ ganz einfach anpassen. Ob Informationen ändern, Bilder hinzufügen oder löschen, du kannst dein Profil nach deinen Wünschen verwalten. Falls du ein neues Logo oder die Musikrichtung deines Clubs ändern möchtest, schreibe dein Anliegen bitte an info@club-me.de.",
    "Bei ClubMe kannst du verschiedene Coupons anbieten, die deinen individuellen Wünschen entsprechen. Beispiele hierfür sind: Freier Eintritt (nach Geschlecht oder bis zu einer gewissen Öffnungszeit), 2 Getränke zum Preis für 1, Gratis Welcome-Shots etc. Falls du nach weiteren Ideen suchst, die bei anderen Clubs erfolgreich waren, melde dich gerne unter info@club-me.de.",
    "Das entscheidest du selbst bei der Erstellung des Coupons. Du hast die Möglichkeit, das Nutzungslimit individuell anzupassen, wie oft ein Besucher diesen einlösen kann. Nach Ablauf der Limits löscht sich der Coupons bei ihnen automatisch.",
    "Mit ClubMe erhältst du Zugang du den partyfreudigen Menschen, die nur auf Deine Events und Angebote warten. Durch die angebotenen Features kannst du mehr Umsatz generieren, deine Werbekosten über Dritte deutlich verringern und deine Werbung auch gezielt einsetzen. Mit den Auswertungen kannst Du dir einen Überblick über deine Interaktionen mit den Besuchern machen und steuern.",
    "Nein, das ist leider nicht möglich. Wenn Du als Club angezeigt werden willst, musst du dich registrieren. Welche Features du dann in Anspruch nimmst, bleibt dir selbst überlassen.",
    "Nein! ClubMe ist und bleibt für Dich als Club kostenlos! Du wirst auch nicht von versteckten Kosten überrascht während deiner Nutzung. In späteren Updates werden optionale Angebote gelauncht, die kleine und einmalige Beträge kosten. Diese werden aber zusätzlich angeboten und müssen nicht verwendet werden.",
    "Nein. Kein Club bekommt von ClubMe eine Vergütung für die Bereitstellung seiner Informationen."
  ];

  int selected = 0;

  @override
  void initState(){
    super.initState();
    createWidgetsToDisplay();
  }


  void createWidgetsToDisplay(){

    for(var i=0;i<answers.length;i++){

      if(i == 0){
        widgetsToDisplay.add(
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 20
              ),
              child: Text(
                "Allgemeine Informationen",
                style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    )
                )
              ),
            )
        );
      }
      if(i == 5 ){
        widgetsToDisplay.add(
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 20
              ),
              child: Text(
                "Registrierung und Nutzung",
                style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            )
        );
      }
      if(i==10){
        widgetsToDisplay.add(
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 20
              ),
              child: Text(
                "Coupons",
                style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            )
        );
      }
      if(i==12){
        widgetsToDisplay.add(
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 20
              ),
              child: Text(
                "Zusammenarbeit",
                style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            )
        );
      }

      widgetsToDisplay.add(

          ExpansionTile(
            iconColor: const Color(0xFF249e9f),
            collapsedIconColor: const Color(0xFF249e9f),
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

    if(widgetsToDisplay.isEmpty){
      createWidgetsToDisplay();
    }


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
                      height: screenHeight*0.1,
                    ),

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
