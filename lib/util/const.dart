import "package:flutter/material.dart";

const myColorScheme = ColorScheme(
  primary: Color(0xFF0072CE),
  secondary: Color(0xFF000000),
  surface: Color(0xFFFFFFFF),
  background: Color(0xFFFFFFFF),
  error: Color(0xFFB00020),
  onPrimary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFFFFFFFF),
  onSurface: Color(0xFF000000),
  onBackground: Color(0xFF000000),
  onError: Color(0xFFFFFFFF),
  brightness: Brightness.light,
);

const String lemmad2013File = 'lib/assets/lemmad2013.txt';
const String soned2013File = 'lib/assets/soned2013.txt';

const Color estBlue = Color(0xFF0072CE);

ButtonStyle myButtonStyle = ButtonStyle(
  padding: MaterialStateProperty.all<EdgeInsets>(
    // const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
    const EdgeInsets.all(8),
  ),
  textStyle: MaterialStateProperty.all<TextStyle>(
    const TextStyle(fontSize: 24),
  ),
  fixedSize: MaterialStateProperty.all<Size>(
    const Size(300, 100),
  ),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);

enum Language { english, estonian }

extension LanguageExtension on Language {
  String get string {
    switch (this) {
      case Language.english:
        return 'en';
      case Language.estonian:
        return 'et';
      default:
        return '';
    }
  }
}
