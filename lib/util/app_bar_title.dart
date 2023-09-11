import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyAppBarTitle extends StatelessWidget {
  final Widget title;
  final MainAxisAlignment? mainAxisAlignment;
  const MyAppBarTitle({super.key, required this.title, this.mainAxisAlignment});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      children: [
        const FaIcon(
          FontAwesomeIcons.skull,
          color: Color.fromARGB(255, 0, 114, 206),
        ),
        const SizedBox(width: 12),
        title
      ],
    );
  }
}
