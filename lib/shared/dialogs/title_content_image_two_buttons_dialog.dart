import 'dart:io';

import 'package:flutter/material.dart';

import '../custom_text_style.dart';

class TitleContentImageAndTwoButtonsDialog extends StatelessWidget{

  TitleContentImageAndTwoButtonsDialog({
    super.key,
    required this.titleToDisplay,
    required this.contentToDisplay,
    required this.file,
    required this.firstButtonToDisplay,
    required this.secondButtonToDisplay
  });

  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  Widget firstButtonToDisplay;
  Widget secondButtonToDisplay;
  String titleToDisplay;
  String contentToDisplay;
  File file;


  @override
  Widget build(BuildContext context) {
    customStyleClass = CustomStyleClass(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      backgroundColor: customStyleClass.backgroundColorMain,
      title: Text(
        titleToDisplay,
        style: customStyleClass.getFontStyle3Bold(),
      ),
      content: SizedBox(
        height: screenHeight*0.15,
        child: Column(
            children: [

              Center(
                child: Text(
                  contentToDisplay,
                  style: customStyleClass.getFontStyle5(),
                ),
              ),

              //
              // // Spacer
              SizedBox(
                height: screenHeight*0.01,
              ),

              Image(
                  width: 100,
                  height: 100,
                  image: FileImage(
                    file,
                  )
              ),



            ]
        ),
      ),
      actions: [
        firstButtonToDisplay,
        secondButtonToDisplay
      ],
    );
  }
}
