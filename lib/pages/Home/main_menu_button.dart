import 'package:flutter/material.dart';
import 'package:timukas/util/const.dart';

class MainMenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const MainMenuButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: myButtonStyle,
        child: child,
      ),
    );
  }
}
