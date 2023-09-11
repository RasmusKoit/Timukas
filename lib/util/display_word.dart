import 'package:flutter/material.dart';
import 'package:timukas/models/word.dart';

class DisplayWord extends StatelessWidget {
  final Word word;
  const DisplayWord({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Sõna',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(word.word, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text(
            'Definitioon',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(word.getDefinitions().first, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text('Tüüp', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: word.getPartOfSpeech().map(
              (part) {
                return Text(part);
              },
            ).toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sõna vormid',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: word.getWordForms().map((line) {
              // check if line contains singular or plural
              if (line[0] == 'singular') line[0] = 'Ainsus';
              if (line[0] == 'plural') line[0] = 'Mitmus';

              String formmatedText = line.join("\n");
              return Text(formmatedText, textAlign: TextAlign.center);
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Näited',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: word.getExamples().map((example) {
              return Text(example, textAlign: TextAlign.center);
            }).toList(),
          ),
        ],
      ),
    );
  }
}
