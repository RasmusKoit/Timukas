import 'package:flutter/material.dart';
import 'package:timukas/util/api.dart';
import 'package:timukas/util/Widgets/bool_widget.dart';
import 'package:timukas/util/const.dart';
import 'package:timukas/util/word_manager.dart';

class PlayPageHeader extends StatefulWidget {
  final WordManager wordManager;

  const PlayPageHeader({super.key, required this.wordManager});

  @override
  State<PlayPageHeader> createState() => _PlayPageHeaderState();
}

class _PlayPageHeaderState extends State<PlayPageHeader> {
  get wordManager => widget.wordManager;
  bool showTranslatedDefinition = false;
  String translatedDefinition = '';
  String currentWord = '';

  @override
  void initState() {
    super.initState();
    currentWord = wordManager.word.word;
  }

  @override
  void didUpdateWidget(covariant PlayPageHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wordManager.word.word != currentWord) {
      setState(() {
        translatedDefinition = '';
        showTranslatedDefinition = false;
        currentWord = wordManager.word.word;
      });
    }
  }

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
            wordManager.guessedLetters,
            style: const TextStyle(fontSize: 16),
          ),
          secondary: Text(
            wordManager.word.word,
            style: const TextStyle(fontSize: 16),
          ),
          value: !wordManager.gameOver,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    translateDefinition(wordManager.word.getDefinitions()[0]);
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
                      : wordManager.word.getDefinitions()[0],
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
