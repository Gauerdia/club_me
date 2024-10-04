import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComingSoonView extends StatefulWidget {
  const ComingSoonView({super.key});

  @override
  State<ComingSoonView> createState() => _ComingSoonViewState();
}

class _ComingSoonViewState extends State<ComingSoonView>
  with TickerProviderStateMixin{

  late AnimationController motionController;
  late Animation motionAnimation;

  double size = 20;

  late double screenHeight, screenWidth;

  void initState() {
    super.initState();

    motionController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
      lowerBound: 0.9,
    );

    motionAnimation = CurvedAnimation(
        parent: motionController,
        curve: Curves.ease
    );

    motionController.forward();

    motionController.addStatusListener((status) {
      setState(() {
        if(status == AnimationStatus.completed){
          motionController.reverse();
        } else if(status == AnimationStatus.dismissed){
          motionController.forward();
        }
      });
    });

    motionController.addListener(() {
      setState(() {
        size = motionController.value * 150;
      });
    });
  }

  @override
  void dispose() {
    motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          Center(
            child: Container(
              child: Image.asset('assets/images/premium_advantages.png'),
              height: size,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight*0.2
            ),
          child: Center(
            child: Text(
              "Coming soon",
              style: GoogleFonts.yaldevi(
                  textStyle:const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none
                  ),
              )
            ),
          ),)
        ],
      )
    );
  }
}
