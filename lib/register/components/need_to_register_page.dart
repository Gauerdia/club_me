import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/custom_text_style.dart';

class NeedToRegisterPage extends StatefulWidget {
  const NeedToRegisterPage({super.key});

  @override
  State<NeedToRegisterPage> createState() => _NeedToRegisterPageState();
}

class _NeedToRegisterPageState extends State<NeedToRegisterPage> {
  @override
  Widget build(BuildContext context) {

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var customStyleClass = CustomStyleClass(context: context);

    return Scaffold(
      body: Stack(
        children: [

          SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Image.asset(
                "assets/images/registrierung_coupons_ohne.png"
            ),
          ),

          Container(
            padding: EdgeInsets.only(
              top: screenHeight*0.08,
              right: screenWidth*0.05
            ),
            alignment: Alignment.topRight,
            child: InkWell(
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),

          Container(
            padding: EdgeInsets.only(
              bottom: screenHeight*0.1
            ),
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff00D7D7),
                borderRadius: BorderRadius.circular(10)
              ),
              width: screenWidth*0.4,
              height: screenHeight*0.05,
              child: Center(
                child: InkWell(
                  child: Text(
                    "Registrieren",
                    style: customStyleClass.getFontStyle3Bold(),
                  ),
                  onTap: () => context.go("/register"),
                ),
              ),
            )
          )

        ],
      ),
    );
  }
}
