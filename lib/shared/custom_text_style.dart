import 'dart:ui';
import 'package:club_me/provider/state_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextStyle{

  CustomTextStyle({
   required this.context

  }){
    stateProvider = Provider.of<StateProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  late StateProvider stateProvider;
  late BuildContext context;
  late double screenWidth, screenHeight;

  Color primeColorDark = Colors.teal;
  Color primeColor = Colors.tealAccent;

  // Größe 14
  double fontSizeFactorMapHeadline = 0.035;

  // Größe 14
  double fontSizeFactor1 = 0.03;
  // 12
  double fontSizeFactor2 = 0.027;
  // 11
  double fontSizeFactor3 = 0.024;
  // 10
  double fontSizeFactor4 = 0.021;
  // 9
  double fontSizeFactor5 = 0.018;
  // 8
  double fontSizeFactor6 = 0.015;

  double screenUtilFactor1 = 22.w;
  double screenUtilFactor2 = 18.sp; //19.w;
  double screenUtilFactor3 = 17.w;
  double screenUtilFactor4 = 15.w;
  double screenUtilFactor5 = 13.w;
  double screenUtilFactor6 = 11.w;

  double iconSizeFactor = 0.035;
  double iconSizeFactor2 = 0.0275;
  double iconSizeFactor3 = 0.02;
  double iconSizeFactor4 = 0.012;

  double numberFieldFontSizeFactor = 0.05;
  double dropDownItemHeightFactor = 0.08;

  double getIconSize1(){
    return screenHeight*iconSizeFactor;
  }
  double getIconSize2(){
    return screenHeight*iconSizeFactor2;
  }
  double getIconSize3(){
    return screenHeight*iconSizeFactor3;
  }
  double getIconSize4(){
    return screenHeight*iconSizeFactor4;
  }

  TextStyle activeDiscountTimer(){
    return GoogleFonts.yaldevi(
        textStyle:TextStyle(
          color: primeColor,
          fontWeight: FontWeight.bold,
          fontSize: screenHeight*fontSizeFactorMapHeadline,
        )
    );
  }

  TextStyle sizeDropDownItem(){
    return TextStyle(
        fontSize: screenWidth*stateProvider.getDropDownItemHeightFactor()
    );
  }
  TextStyle sizeNumberFieldItem(){
    return TextStyle(
        fontSize: screenWidth*stateProvider.getNumberFieldFontSizeFactor()
    );
  }

  TextStyle size1(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor1,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor1,
        // )
    );
  }
  TextStyle size1Bold(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor1,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor1,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size1MapHeadline(){
    return GoogleFonts.yaldevi(
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenHeight*fontSizeFactorMapHeadline,
          shadows: const <Shadow>[
            Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 5.0,
                color: Colors.grey
            ),
          ],
        )
    );
  }

  TextStyle size2(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor1,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor2,
        // )
    );
  }
  TextStyle size2Bold(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor2,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor2,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size2BoldLightGrey(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white70,
          fontSize:screenUtilFactor2,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.white70,
        //   fontSize: screenHeight*fontSizeFactor2,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size2BoldLightWhite(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: const Color(0xffc0c0c0),
          fontSize: screenUtilFactor2,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: const Color(0xffc0c0c0),
        //   fontSize: screenHeight*fontSizeFactor2,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }

  TextStyle size3(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor3,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor3,
        // )
    );
  }
  TextStyle size3Bold(){
    return GoogleFonts.yaldevi(
        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor3,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor3,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size3BoldGrey(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.grey[400],
          fontSize: screenUtilFactor3,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.grey[400],
        //   fontSize: screenHeight*fontSizeFactor3,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size3BoldPrimeColor(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: primeColor,
          fontSize: screenUtilFactor3,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: primeColor,
        //   fontSize: screenHeight*fontSizeFactor3,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size3BoldLightWhite(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: const Color(0xffc0c0c0),
          fontSize: screenUtilFactor3,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: const Color(0xffc0c0c0),
        //   fontSize: screenHeight*fontSizeFactor3,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }

  TextStyle size4(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor4,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor4,
        // )
    );
  }
  TextStyle size4Bold(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor4,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor4,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size4BoldGrey(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.grey[400],
          fontSize: screenUtilFactor4,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.grey[400],
        //   fontSize: screenHeight*fontSizeFactor4,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size4BoldGrey2(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.grey[500],
          fontSize: screenUtilFactor4,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.grey[500],
        //   fontSize: screenHeight*fontSizeFactor4,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size4BoldPrimeColor(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: primeColor,
          fontSize: screenUtilFactor4,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: primeColor,
        //   fontSize: screenHeight*fontSizeFactor4,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }

  TextStyle size5(){
    return GoogleFonts.yaldevi(
        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor5,
        )
      // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor5,
        // )
    );
  }
  TextStyle size5Bold(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize:screenUtilFactor5,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor5,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size5BoldGrey(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.grey[400],
          fontSize: screenUtilFactor5,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.grey[400],
        //   fontSize: screenHeight*fontSizeFactor5,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size5BoldDarkGrey(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.grey[500],
          fontSize: screenUtilFactor5,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.grey[500],
        //   fontSize: screenHeight*fontSizeFactor5,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }

  TextStyle size6(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor6,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor6,
        // )
    );
  }
  TextStyle size6Red(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.red,
          fontSize: screenUtilFactor6,
        )

        // textStyle:TextStyle(
        //   color: Colors.red,
        //   fontSize: screenHeight*fontSizeFactor6,
        // )
    );
  }
  TextStyle size6Bold(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: screenUtilFactor6,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.white,
        //   fontSize: screenHeight*fontSizeFactor6,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }
  TextStyle size6BoldGrey(){
    return GoogleFonts.yaldevi(

        textStyle:TextStyle(
          color: Colors.grey[400],
          fontSize: screenUtilFactor6,
          fontWeight: FontWeight.bold,
        )

        // textStyle:TextStyle(
        //   color: Colors.grey[400],
        //   fontSize: screenHeight*fontSizeFactor6,
        //   fontWeight: FontWeight.bold,
        // )
    );
  }

}