import 'package:flutter/material.dart';

import '../custom_text_style.dart';

class TitleContentAndTwoButtonsDialog extends StatelessWidget{

  TitleContentAndTwoButtonsDialog({
    super.key,
    required this.titleToDisplay,
    required this.contentToDisplay,
    required this.firstButtonToDisplay,
    required this.secondButtonToDisplay
  });

  late CustomStyleClass customStyleClass;
  late double screenHeight, screenWidth;
  Widget firstButtonToDisplay;
  Widget secondButtonToDisplay;
  String titleToDisplay;
  String contentToDisplay;

  @override
  Widget build(BuildContext context) {
    customStyleClass = CustomStyleClass(context: context);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      backgroundColor: customStyleClass.backgroundColorMain,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white)
      ),
      title: Text(
        titleToDisplay,
        style: customStyleClass.getFontStyle3Bold(),
      ),
      content: Text(
        contentToDisplay,
        style: customStyleClass.getFontStyle5(),
      ),
      actions: [
        firstButtonToDisplay,
        secondButtonToDisplay
      ],
    );
  }
}
