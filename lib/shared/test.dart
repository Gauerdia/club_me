import 'package:flutter/material.dart';
import 'custom_text_style.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

  late double screenHeight, screenWidth;
  late CustomStyleClass customStyleClass;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    customStyleClass = CustomStyleClass(context: context);

    return Scaffold(

      appBar: AppBar(
          title: const Text('Vorschau')
      ),

      body: Container(
        width: screenWidth,
        height: screenHeight,
        child: Center(
          child: Text(
            "test",
            style: customStyleClass.getFontStyle3(),
          ),
        ),

      )
      // Container(
      //   width: screenWidth,
      //   height: screenHeight,
      //   child: Center(
      //     child: InkWell(
      //       child: const Text(
      //           "test",
      //         style: TextStyle(
      //           color: Colors.red
      //         ),
      //       ),
      //       onTap: () => showViewIndex == 0 ? showRecordingScreen() :
      //       showViewIndex == 1 ? showReviewScreen() : showChewieScreen(),
      //     ),
      //   ),
      // )
    );
  }
}
