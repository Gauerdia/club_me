import 'package:flutter/material.dart';

import '../../../shared/custom_text_style.dart';

class CoverImageCard extends StatelessWidget {
  CoverImageCard({super.key, required this.fileName});

  String fileName;
  late double screenWidth, screenHeight;
  late CustomStyleClass customStyleClass;



  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    customStyleClass = CustomStyleClass(context: context);

    return Container(
      width: screenWidth*0.9,
      height: screenHeight*0.555,
      decoration: BoxDecoration(
          color: customStyleClass.backgroundColorEventTile,
          borderRadius: BorderRadius.circular(
              15
          ),
          border: Border.all(
              color: Colors.grey[900]!,
              width: 2
          )
      ),
      child: Column(
        children: [

          // Image container
          SizedBox(
              height: screenHeight*0.35,
              child: Stack(
                children: [

                  SizedBox(
                    height: screenHeight*0.35,
                    width: screenWidth,
                    child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15)
                        ),
                        child: Image.asset(
                          "assets/images/$fileName",
                          fit: BoxFit.cover,
                        )
                    ),
                  )
                ],
              )
          ),

          // Content container
          Container(
            color: customStyleClass.backgroundColorEventTile,
            height: screenHeight*0.2,
            child: Container(
                height: screenHeight*0.2,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: customStyleClass.backgroundColorEventTile,
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12)
                  ),

                ),
                child: Stack(
                  children: [

                  ],
                )
            ),
          )

        ],
      )
    );
  }
}
