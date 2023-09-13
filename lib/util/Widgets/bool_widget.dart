import 'package:flutter/material.dart';

class BoolWidget extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final bool value;
  const BoolWidget(
      {super.key,
      required this.primary,
      required this.secondary,
      required this.value});

  @override
  Widget build(BuildContext context) {
    if (value) {
      return primary;
    } else {
      return secondary;
    }
  }
}
