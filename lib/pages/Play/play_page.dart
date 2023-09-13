import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timukas/util/Widgets/bool_widget.dart';
import 'package:timukas/util/Widgets/display_word.dart';
import 'package:timukas/util/Widgets/keyboard.dart';
import 'package:timukas/pages/Home/main_menu_button.dart';
import 'package:timukas/pages/Play/play_page_header.dart';
import 'package:timukas/pages/Play/show_image.dart';
import 'package:timukas/util/word_manager.dart';
import 'package:provider/provider.dart';

class PlayPage extends StatelessWidget {
  final String wordsFile;
  const PlayPage({Key? key, required this.wordsFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WordManager(wordsFile: wordsFile),
      child: _PlayPageContent(),
    );
  }
}

class _PlayPageContent extends StatefulWidget {
  @override
  _PlayPageContentState createState() => _PlayPageContentState();
}

class _PlayPageContentState extends State<_PlayPageContent> {
  @override
  void initState() {
    super.initState();
    final wordManager = Provider.of<WordManager>(context, listen: false);
    wordManager.initializeWord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Play')),
      body: Consumer<WordManager>(
        builder: (context, wordManager, child) {
          return wordManager.word.word == ''
              ? const Center(child: CircularProgressIndicator())
              : _buildGameView(context, wordManager);
        },
      ),
    );
  }

  Widget _buildGameView(BuildContext context, WordManager wordManager) {
    Future<void> incrementCounter() async {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid);

      if (wordManager.resultMessage == 'You won!') {
        await userDocRef.collection('public').doc('publicData').update({
          'levelsCompleted': FieldValue.increment(1),
        });
      } else {
        await userDocRef.collection('public').doc('publicData').update({
          'levelsFailed': FieldValue.increment(1),
        });
      }
      await userDocRef.collection('private').doc('privateData').update({
        'levelsPlayed': FieldValue.increment(1),
      });
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PlayPageHeader(
            guessedLetters: wordManager.guessedLetters,
            gameOver: wordManager.gameOver,
            word: wordManager.word,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BoolWidget(
              primary: Container(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DisplayWord(word: wordManager.word),
                ),
              ),
              secondary: ShowHangManImages(
                numberOfGuesses: wordManager.wrongGuesses,
              ),
              value: wordManager.gameOver &&
                  wordManager.resultMessage == 'Play again?',
            ),
          ),
          // Show keyboard or action buttons
          BoolWidget(
            primary: Column(
              children: [
                MainMenuButton(
                  onPressed: () {
                    if (wordManager.gameOver) {
                      if (wordManager.resultMessage == 'Play again?') {
                        wordManager.newGame();
                      } else {
                        incrementCounter();
                        wordManager.resultMessage = 'Play again?';
                      }
                      setState(() {});
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(wordManager.resultMessage),
                      const Text('Continue'),
                    ],
                  ),
                ),
              ],
            ),
            secondary: EstonianKeyboard(
              onLetterTap: (letter) {
                wordManager.guessLetter(letter);
              },
            ),
            value: wordManager.gameOver,
          )
        ],
      ),
    );
  }
}
