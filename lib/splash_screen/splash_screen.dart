import 'package:club_me/services/hive_service.dart';
import 'package:flutter/cupertino.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late double screenHeight, screenWidth;


  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenWidth,
      child: Center(
        child: Image.asset(
          "assets/images/ClubMe_Logo_weiß.png",
          width: 50,
          height: 50,
        )
      )
    );
  }
}
