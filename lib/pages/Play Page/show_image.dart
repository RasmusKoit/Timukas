import 'package:flutter/material.dart';

class ShowHangManImages extends StatelessWidget {
  final int numberOfGuesses;
  const ShowHangManImages({
    super.key,
    required this.numberOfGuesses,
  });

  static Image bImage = Image.asset('lib/images/Hangman_1.png');

  @override
  Widget build(BuildContext context) {
    final AssetImage image =
        AssetImage('lib/images/Hangman_$numberOfGuesses.png');
    return Container(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: bImage.width,
          height: bImage.height,
          child: Image(image: image),
        ),
      ),
    );
  }
}
