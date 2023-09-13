import 'package:flutter/material.dart';
import 'package:timukas/models/word.dart';
import 'package:timukas/util/api.dart';
import 'package:timukas/util/Widgets/bool_widget.dart';
import 'package:timukas/util/const.dart';

class PlayPageHeader extends StatefulWidget {
  final String guessedLetters;
  final bool gameOver;
  final Word word;

  const PlayPageHeader({
    super.key,
    required this.guessedLetters,
    required this.gameOver,
    required this.word,
  });

  @override
  State<PlayPageHeader> createState() => _PlayPageHeaderState();
}

class _PlayPageHeaderState extends State<PlayPageHeader> {
  bool showTranslatedDefinition = false;
  String translatedDefinition = '';

  Future<void> translateDefinition(String text) async {
    if (text == translatedDefinition || translatedDefinition != '') {
      setState(() {
        showTranslatedDefinition = !showTranslatedDefinition;
      });
      return;
    }
    final String definition = await translateText(text, 'et', 'en');
    setState(() {
      translatedDefinition = definition;
      showTranslatedDefinition = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        BoolWidget(
          primary: Text(
            widget.guessedLetters,
            style: const TextStyle(fontSize: 16),
          ),
          secondary: Text(
            widget.word.word,
            style: const TextStyle(fontSize: 16),
          ),
          value: !widget.gameOver,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    translateDefinition(widget.word.getDefinitions()[0]);
                  },
                  icon: const Icon(
                    Icons.language,
                    color: estBlue,
                  )),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  translatedDefinition != '' && showTranslatedDefinition
                      ? translatedDefinition
                      : widget.word.getDefinitions()[0],
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
