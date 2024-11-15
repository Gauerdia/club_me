import 'package:flutter/material.dart';

class TextOnImage extends StatelessWidget {
  TextOnImage({
    super.key,
    required this.text,
    required this.index
  });

  final int index;
  final String text;

  List<String> imagePaths = [
    "assets/images/standort_weiss_blau_2.png",
    "assets/images/clubme_100x100.png",
    "assets/images/beispiel_100x100.png",
  ];


  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image(
          image: AssetImage(
            imagePaths[index],
          ),
          height: 150,
          width: 150,
        ),
        // Text(
        //   text,
        //   style: const TextStyle(color: Colors.black),
        // )
      ],
    );
  }
}