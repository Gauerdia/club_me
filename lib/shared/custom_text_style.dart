import 'dart:ui';
import 'package:club_me/provider/state_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomStyleClass{

  CustomStyleClass({
   required this.context

  }){
    stateProvider = Provider.of<StateProvider>(context);
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  late StateProvider stateProvider;
  late BuildContext context;
  late double screenWidth, screenHeight;

  Color backgroundColorMain = const Color(0xff121111);
  Color backgroundColorEventTile = const Color(0xff222222);

  Color primeColorDark = Colors.teal;
  Color primeColor = Color(0xFF249e9f);  //Colors.tealAccent.shade400;

  double fontSizeHeadline1 = 24;

  double fontSize1 = 20;
  double fontSize2 = 18;
  double fontSize3 = 16;
  double fontSize4 = 14;
  double fontSize5 = 12;
  double fontSize6 = 10;


  double getIconSize1(){
    return 26;
  }

  double getNavIconTextSize(){
    return 8;
  }


  TextStyle getFontStyleVIPGold(){
    return GoogleFonts.inter(
        textStyle: TextStyle(
            color: Color(0xffd4af37),
            fontSize: fontSize6,
            fontWeight: FontWeight.bold
        )
    );
  }

  TextStyle getFontStyleHeadline1Bold(){
    return GoogleFonts.inter(
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSizeHeadline1,
            fontWeight: FontWeight.bold
        )
    );
  }

  double getFontSize1(){
    return fontSize1;
  }
  TextStyle getFontStyle1(){
    return GoogleFonts.inter(
        textStyle: TextStyle(
            color: Colors.white,
            fontSize: fontSize1,
        )
    );
  }
  TextStyle getFontStyle1Bold(){
    return GoogleFonts.inter(
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSize1,
          fontWeight: FontWeight.bold
        )
    );
  }

  double getFontSize2(){
    return fontSize2;
  }
  TextStyle getFontStyle2(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.white,
          fontSize: fontSize2,
        )
    );
  }
  TextStyle getFontStyle2Bold(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.white,
          fontSize: fontSize2,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle2BoldLightWhite(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: const Color(0xffc0c0c0),
          fontSize: fontSize2,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle2BoldGrey(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.grey[400],
          fontSize: fontSize2,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle2BoldLightGrey(){
    return GoogleFonts.inter(
        textStyle: TextStyle(
            color: Colors.white70,
            fontSize: fontSize2,
            fontWeight: FontWeight.bold
        )
    );
  }

  double getFontSize3(){
    return fontSize3;
  }
  TextStyle getFontStyle3(){
    return GoogleFonts.inter(
        textStyle: TextStyle(
            fontSize: fontSize3,
          color: Colors.white
        )
    );
  }
  TextStyle getFontStyle3Red(){
    return GoogleFonts.inter(
        textStyle: TextStyle(
            fontSize: fontSize3,
            color: Colors.red
        )
    );
  }
  TextStyle getFontStyle3Bold(){
    return GoogleFonts.inter(
        textStyle: TextStyle(
          fontSize: fontSize3,
          color: Colors.white,
          fontWeight: FontWeight.bold
        )
    );
  }
  TextStyle getFontStyle3BoldGrey(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.grey[400],
          fontSize: fontSize3,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle3BoldPrimeColor(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: primeColor,
          fontSize: fontSize3,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle3BoldLightWhite(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: const Color(0xffc0c0c0),
          fontSize: fontSize3,
          fontWeight: FontWeight.bold,
        )
    );
  }

  double getFontSize4(){
    return fontSize4;
  }
  TextStyle getFontStyle4(){
    return GoogleFonts.inter(

        textStyle:TextStyle(
          color: Colors.white,
          fontSize: fontSize4,
        )

    );
  }
  TextStyle getFontStyle4Bold(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.white,
          fontSize: fontSize4,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle4BoldGrey(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.grey[400],
          fontSize: fontSize4,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle4Grey2(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.grey[500],
          fontSize: fontSize4,
        )
    );
  }
  TextStyle getFontStyle4BoldGrey2(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.grey[500],
          fontSize: fontSize4,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle4BoldPrimeColor(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: primeColor,
          fontSize: fontSize4,
          fontWeight: FontWeight.bold,
        )
    );
  }

  double getFontSize5(){
    return fontSize5;
  }
  TextStyle getFontStyle5(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.white,
          fontSize: fontSize5,
        )
    );
  }
  TextStyle getFontStyle5Bold(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.white,
          fontSize:fontSize5,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle5BoldGrey(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.grey[400],
          fontSize: fontSize5,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle5BoldDarkGrey(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.grey[500],
          fontSize: fontSize5,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle5BoldLightGrey(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.grey[300],
          fontSize: fontSize5,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle5BoldPrimeColor(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: primeColor,
          fontSize: fontSize5,
          fontWeight: FontWeight.bold,
        )
    );
  }


  double getFontSize6(){
    return fontSize6;
  }
  TextStyle getFontStyle6(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.white,
          fontSize: fontSize6,
        )
    );
  }
  TextStyle getFontStyle6Red(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.red,
          fontSize: fontSize6,
        )
    );
  }
  TextStyle getFontStyle6Bold(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.white,
          fontSize: fontSize6,
          fontWeight: FontWeight.bold,
        )
    );
  }
  TextStyle getFontStyle6BoldGrey(){
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: Colors.grey[400],
          fontSize: fontSize6,
          fontWeight: FontWeight.bold,
        )
    );
  }


  // double screenUtilFactor1 = 22.w;
  // double screenUtilFactor2 = 18.sp; //19.w;
  // double screenUtilFactor3 = 17.w;
  // double screenUtilFactor4 = 15.w;
  // double screenUtilFactor5 = 13.w;
  // double screenUtilFactor6 = 11.w;
  //
  double iconSizeFactor = 0.035;
  double iconSizeFactor2 = 0.0275;
  double iconSizeFactor3 = 0.02;
  double iconSizeFactor4 = 0.012;

  // double numberFieldFontSizeFactor = 0.05;
  // double dropDownItemHeightFactor = 0.08;



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
    return GoogleFonts.inter(
        textStyle:TextStyle(
          color: primeColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize1
        )
    );
  }

  TextStyle sizeDropDownItem(){
    return TextStyle(
        fontSize: fontSize3
    );
  }
  TextStyle sizeNumberFieldItem(){
    return TextStyle(
        fontSize: fontSize3
    );
  }

}