import 'package:flutter/material.dart';

class ShowImage extends StatelessWidget {
  final double? width;
  final double? height;
  final AssetImage image;
  const ShowImage({
    super.key,
    required this.width,
    required this.height,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: width,
          height: height,
          child: Image(
            image: image,
          ),
        ),
      ),
    );
  }
}
