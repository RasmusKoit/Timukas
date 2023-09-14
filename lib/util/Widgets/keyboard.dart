import 'package:flutter/material.dart';

class EstonianKeyboard extends StatefulWidget {
  final Function(String) onLetterTap;
  final bool highLightKeys;

  const EstonianKeyboard(
      {super.key, required this.onLetterTap, this.highLightKeys = false});

  @override
  State<EstonianKeyboard> createState() => _EstonianKeyboardState();
}

class _EstonianKeyboardState extends State<EstonianKeyboard> {
  bool isExpanded = true;
  final List<List<String>> keyboardLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ü', 'Õ'], // üõ - öä
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ö', 'Ä'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Š', 'Ž'],
  ];

  Map<String, bool> keyTappedState = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      // padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...keyboardLayout.map(
                    (row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: row.map((letter) {
                          return KeyboardKey(
                            letter: letter,
                            onTap: () {
                              widget.onLetterTap(letter);
                              if (widget.highLightKeys) {
                                setState(() {
                                  keyTappedState[letter] = true;
                                });
                              }
                            },
                            isTapped: keyTappedState[letter] ?? false,
                          );
                        }).toList(),
                      );
                    },
                  ).toList(),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              IconButton(
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class KeyboardKey extends StatelessWidget {
  final String letter;
  final Function() onTap;
  final bool isTapped;

  // ignore: use_key_in_widget_constructors
  const KeyboardKey(
      {required this.letter, required this.onTap, required this.isTapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: isTapped ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
      ),
    );
  }
}
