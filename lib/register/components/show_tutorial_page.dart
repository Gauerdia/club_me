import 'package:club_me/provider/state_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/hive_service.dart';
import '../../shared/custom_text_style.dart';

class ShowTutorialPage extends StatefulWidget {
  const ShowTutorialPage({super.key});

  @override
  State<ShowTutorialPage> createState() => _ShowTutorialPageState();
}

class _ShowTutorialPageState extends State<ShowTutorialPage>
    with SingleTickerProviderStateMixin {

  late double screenWidth, screenHeight;
  int tutorialIndex = 0;
  late CustomStyleClass customStyleClass;
  final HiveService _hiveService = HiveService();

  late Animation animation;
  late AnimationController animationController;

  late StateProvider stateProvider;

  @override
  void initState(){
    animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    animationController.forward();
    super.initState();
  }

  Widget _buildFirstScreen(){
    return FadeTransition(
      opacity: animationController.drive(CurveTween(curve: Curves.easeOut)),
      child: Stack(
        children: [

          Image.asset("assets/images/1_willkommen_ohne.png"),

          Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40
              ),
              alignment: Alignment.bottomCenter,
              width: screenWidth,
              height: screenHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Text(
                      "Später",
                      style: customStyleClass.getFontStyle3Bold(),
                    ),
                    onTap: () => skipOrFinish(),
                  ),
                  InkWell(
                    child: Text(
                      "Anleitung starten",
                      style: customStyleClass.getFontStyle3BoldPrimeColor(),
                    ),
                    onTap: () =>iterateIndex(),
                  )

                ],
              )
          )
        ],
      ),
    );
  }

  Widget _buildSecondScreen(){
    return FadeTransition(
        opacity: animationController.drive(CurveTween(curve: Curves.easeOut)),
      child: Stack(
      children: [

        Image.asset("assets/images/2_event-detailansicht_ohne.png"),

        Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 40
            ),
            alignment: Alignment.bottomCenter,
            width: screenWidth,
            height: screenHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Text(
                    "Später",
                    style: customStyleClass.getFontStyle3Bold(),
                  ),
                  onTap: () => skipOrFinish(),
                ),
                InkWell(
                  child: Text(
                    "Weiter",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onTap: () =>iterateIndex(),
                )

              ],
            )
        )
      ],
    )
      );
  }

  Widget _buildThirdScreen(){
    return
      AnimatedOpacity(
        opacity: tutorialIndex == 2 ? 1.0: 0.0,
        duration: const Duration(milliseconds: 500),
    child:
    Stack(
      children: [

        Image.asset("assets/images/3_externe_ticketlinks_ohne.png"),

        Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 40
            ),
            alignment: Alignment.bottomCenter,
            width: screenWidth,
            height: screenHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Text(
                    "Später",
                    style: customStyleClass.getFontStyle3Bold(),
                  ),
                  onTap: () => skipOrFinish(),
                ),
                InkWell(
                  child: Text(
                    "Weiter",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onTap: () =>iterateIndex(),
                )

              ],
            )
        )
      ],
    ));
  }

  Widget _buildFourthScreen(){
    return
      AnimatedOpacity(
        opacity: tutorialIndex == 3 ? 1.0: 0.0,
        duration: const Duration(milliseconds: 500),
    child: Stack(
      children: [

        Image.asset("assets/images/4_angehaengte_bilder_ohne.png"),

        Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 40
            ),
            alignment: Alignment.bottomCenter,
            width: screenWidth,
            height: screenHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Text(
                    "Später",
                    style: customStyleClass.getFontStyle3Bold(),
                  ),
                  onTap: () => skipOrFinish(),
                ),
                InkWell(
                  child: Text(
                    "Weiter",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onTap: () =>iterateIndex(),
                )

              ],
            )
        )
      ],
    ));
  }

  Widget _buildFifthScreen(){
    return Stack(
      children: [

        Image.asset("assets/images/5_club-detailansicht_ohne.png"),

        Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 40
            ),
            alignment: Alignment.bottomCenter,
            width: screenWidth,
            height: screenHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Text(
                    "Später",
                    style: customStyleClass.getFontStyle3Bold(),
                  ),
                  onTap: () => skipOrFinish(),
                ),
                InkWell(
                  child: Text(
                    "Weiter",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onTap: () =>iterateIndex(),
                )

              ],
            )
        )
      ],
    );
  }

  Widget _buildSixthScreen(){
    return Stack(
      children: [

        Image.asset("assets/images/6_live-story_clubs_ohne.png"),

        Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 40
            ),
            alignment: Alignment.bottomCenter,
            width: screenWidth,
            height: screenHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Text(
                    "Später",
                    style: customStyleClass.getFontStyle3Bold(),
                  ),
                  onTap: () => skipOrFinish(),
                ),
                InkWell(
                  child: Text(
                    "Weiter",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onTap: () =>iterateIndex(),
                )

              ],
            )
        )
      ],
    );
  }

  Widget _buildSeventhScreen(){
    return Stack(
      children: [

        Image.asset("assets/images/7_club-liste_ohne.png"),

        Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 40
            ),
            alignment: Alignment.bottomCenter,
            width: screenWidth,
            height: screenHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Text(
                    "Später",
                    style: customStyleClass.getFontStyle3Bold(),
                  ),
                  onTap: () => skipOrFinish(),
                ),
                InkWell(
                  child: Text(
                    "Weiter",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onTap: () =>iterateIndex(),
                )

              ],
            )
        )
      ],
    );
  }

  Widget _buildEighthScreen(){
    return Stack(
      children: [

        Image.asset("assets/images/8_live-story_clubs_ohne.png"),

        Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 40
            ),
            alignment: Alignment.bottomCenter,
            width: screenWidth,
            height: screenHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Text(
                    "Später",
                    style: customStyleClass.getFontStyle3Bold(),
                  ),
                  onTap: () => skipOrFinish(),
                ),
                InkWell(
                  child: Text(
                    "Weiter",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onTap: () =>iterateIndex(),
                )

              ],
            )
        )
      ],
    );
  }

  Widget _buildNinthScreen(){
    return Stack(
      children: [

        Image.asset("assets/images/9_coupons_einloesen_ohne.png"),

        Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 40
            ),
            alignment: Alignment.bottomCenter,
            width: screenWidth,
            height: screenHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "",
                  style: customStyleClass.getFontStyle3Bold(),
                ),
                InkWell(
                  child: Text(
                    "Schließen",
                    style: customStyleClass.getFontStyle3BoldPrimeColor(),
                  ),
                  onTap: () => skipOrFinish(),
                )

              ],
            )
        )
      ],
    );
  }


  void iterateIndex(){

    setState(() {
      tutorialIndex++;
    });

    late Widget widgetToPush;

    switch(tutorialIndex){
      case 0: widgetToPush = _buildFirstScreen();
      case 1: widgetToPush = _buildSecondScreen();
      case 2: widgetToPush = _buildThirdScreen();
      case 3: widgetToPush = _buildFourthScreen();
      case 4: widgetToPush = _buildFifthScreen();
      case 5: widgetToPush = _buildSixthScreen();
      case 6: widgetToPush = _buildSeventhScreen();
      case 7: widgetToPush = _buildEighthScreen();
      case 8: widgetToPush = _buildNinthScreen();
      default: widgetToPush = Image.asset("assets/images/1_willkommen_ohne.png");
    }

    Navigator.push(
      context,
      PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) =>
          Scaffold(
            body: SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: widgetToPush,
            ),
          ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
    )
    );
  
  }

  void skipOrFinish(){
    if(stateProvider.accessedTutorialFromSettings){
      context.go("/user_settings");
    }else{
      _hiveService.setTutorialSeen().then((response) => context.go("/register"));
    }

  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    customStyleClass = CustomStyleClass(context: context);

    stateProvider = Provider.of<StateProvider>(context);

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        child: _buildFirstScreen()
      ),
    );
  }
}
