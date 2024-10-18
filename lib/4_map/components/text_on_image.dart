import 'package:flutter/material.dart';

class TextOnImage extends StatelessWidget {
  const TextOnImage({
    super.key,
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Image(
          image: AssetImage(
            "assets/images/1_standort_blau_weiss.png",
          ),
          height: 150,
          width: 150,
        ),
        Text(
          text,
          style: const TextStyle(color: Colors.black),
        )
      ],
    );
  }
}