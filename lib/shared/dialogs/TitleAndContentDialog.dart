import 'package:club_me/shared/custom_text_style.dart';
import 'package:flutter/material.dart';

class TitleAndContentDialog extends StatelessWidget {
  TitleAndContentDialog({super.key, required this.titleToDisplay, required this.contentToDisplay});

  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  String titleToDisplay;
  String contentToDisplay;

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
          height: screenHeight*0.12,
          child: Center(
            child: Text(
              contentToDisplay,
              style: customStyleClass.getFontStyle5(),
            ),
          )
      ),
    );
  }
}
