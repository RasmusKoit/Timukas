import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timukas/models/word.dart';
import 'package:timukas/util/app_bar_title.dart';
import 'package:timukas/util/bool_widget.dart';
import 'package:timukas/util/const.dart';
import 'package:timukas/util/display_word.dart';
import 'package:timukas/util/keyboard.dart';
import 'package:timukas/util/main_menu_button.dart';
import 'package:timukas/util/show_image.dart';
import 'package:http/http.dart' as http;

class PlayPage extends StatefulWidget {
  final String wordsFile;
  const PlayPage({super.key, required this.wordsFile});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  get wordsFile => widget.wordsFile;
  List<Word> words = [];
  TextEditingController guessController = TextEditingController();
  Word word = Word(word: '');
  String guessedLetters = '';
  int wrongGuesses = 1;
  final bImage = Image.asset('lib/images/Hangman_1.png');
  bool gameOver = false;
  String resultMessage = '';
  FirebaseAuth auth = FirebaseAuth.instance;
  DocumentReference docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid);

  @override
  void initState() {
    super.initState();
    initializeWord();
    guessedLetters = '_ ' * word.word.length;
  }

  initializeWord() async {
    await readWords();
    if (words.isNotEmpty) {
      final Word newWord = await chooseWord();
      setState(() {
        word = newWord;
        guessedLetters = '_ ' * newWord.word.length;
      });
    } else {
      if (mounted) {
        showSnackBar(
            context, 'Failed to initialize', const Duration(seconds: 1));
      }
    }
  }

  Future<void> readWords() async {
    final List<Word> readWords = [];
    final String data =
        await DefaultAssetBundle.of(context).loadString(wordsFile);
    final List<String> lines = data.split('\n');
    for (String line in lines) {
      final Word word = Word(word: line);
      readWords.add(word);
    }
    setState(() {
      words = readWords;
    });
  }

  Future<Word> chooseWord({String oldWord = ''}) async {
    Word wordToSearch = Word(word: '');
    bool keepSearching = true;
    // Add a maximum number of attempts to avoid infinite loop
    int maxAttempts = 100;

    for (int attempts = 0;
        attempts < maxAttempts && keepSearching;
        attempts++) {
      final randomIndex = Random().nextInt(words.length);
      final randomWord = words[randomIndex];
      wordToSearch = await fetchWord(randomWord.word);

      if (wordToSearch.meanings != null &&
          wordToSearch.meanings!.isNotEmpty &&
          (oldWord.isEmpty || wordToSearch.word != oldWord)) {
        keepSearching = false;
      }
    }

    if (keepSearching) {
      // Handle the case where no suitable word is found within the maximum attempts
      throw Exception('Failed to find a suitable word');
    }

    return wordToSearch;
  }

  Future<Word> fetchWord(String wordToSearch, {bool showSnack = false}) async {
    final uri = Uri.parse('https://sonapi.koit.dev/v1/$wordToSearch');
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    String message = '';
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Word.fromJson(jsonData);
    }
    if (response.statusCode == 400) message = 'Word not found';
    if (response.statusCode == 429) message = 'Too many requests';
    // Other errors
    if (context.mounted && showSnack) {
      showSnackBar(context, message, const Duration(milliseconds: 500));
    }
    return Word(word: wordToSearch);
  }

  void onKeyboardKeyTap(String letter) {
    String correctWord = word.word.toLowerCase();
    letter = letter.toLowerCase();
    // Check if guessController.text
    if (guessController.text.contains(letter)) {
      // If it is, show a snackbar
      showSnackBar(context, 'You already guessed this letter!',
          const Duration(milliseconds: 500));
      return;
    }
    if (correctWord.contains(letter)) {
      showSnackBar(context, 'Correct!', const Duration(milliseconds: 200));
      for (int i = 0; i < correctWord.length; i++) {
        if (correctWord[i] == letter) {
          String newString =
              guessedLetters.replaceRange(i * 2, i * 2 + 1, letter);
          setState(() => guessedLetters = newString);
        }
      }
      if (!guessedLetters.contains('_')) {
        showSnackBar(context, 'You won!', const Duration(milliseconds: 200));
        increaseCounter('levelsCompleted');
        setState(() {
          gameOver = true;
          resultMessage = 'You won!';
        });
        // Update user's levelsCompleted
      }
    }
    // If the letter is not in the word, increase the wrongGuesses counter
    else {
      setState(() => wrongGuesses++);
      showSnackBar(context, 'Incorrect!', const Duration(milliseconds: 200));
      if (wrongGuesses == 12) {
        increaseCounter('levelsFailed');
        setState(() {
          gameOver = true;
          resultMessage = 'You lost!';
        });
        // Update user's levelsFailed
      }
    }
    guessController.text += letter;
  }

  Future<void> increaseCounter(String fieldName) async {
    // Update either levelsCompleted or levelsFailed
    await docRef.collection('public').doc('publicData').update({
      fieldName: FieldValue.increment(1),
    });
    // Update levelsPlayed
    await docRef.collection('private').doc('privateData').update({
      'levelsPlayed': FieldValue.increment(1),
    });
  }

  Future<void> levelFinished() async {
    // first time executing this function, we will show some info,
    // second time we will navigate to the next level
    if (gameOver && resultMessage == 'Play again?') {
      final Word newWord = await chooseWord(oldWord: word.word);

      // if (mounted) {
      setState(() {
        word = newWord;
        gameOver = false;
        resultMessage = '';
        guessedLetters = '_ ' * newWord.word.length;
        wrongGuesses = 1;
        guessController.clear();
      });
      // }
    } else {
      setState(() {
        resultMessage = 'Play again?';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (word.word == '') {
      return Scaffold(
        appBar: AppBar(title: const MyAppBarTitle(title: Text('Play'))),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const MyAppBarTitle(title: Text('Play'))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 16),
                  BoolWidget(
                    primary: Text(
                      guessedLetters,
                      style: const TextStyle(fontSize: 16),
                    ),
                    secondary: Text(
                      word.word,
                      style: const TextStyle(fontSize: 16),
                    ),
                    value: !gameOver,
                  ),
                  Text(
                    word.getDefinitions()[0],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BoolWidget(
                    primary: Container(
                      color: Colors.grey[100],
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DisplayWord(word: word)),
                    ),
                    secondary: ShowImage(
                      width: bImage.width,
                      height: bImage.height,
                      image: AssetImage('lib/images/Hangman_$wrongGuesses.png'),
                    ),
                    value: gameOver && resultMessage == 'Play again?'),
              ),
              // Show keyboard or action buttons
              BoolWidget(
                primary: Column(
                  children: [
                    MainMenuButton(
                      onPressed: levelFinished,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(resultMessage),
                          const Text('Continue'),
                        ],
                      ),
                    ),
                  ],
                ),
                secondary: EstonianKeyboard(onLetterTap: onKeyboardKeyTap),
                value: gameOver,
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    guessController.dispose();
    super.dispose();
  }
}

void showSnackBar(BuildContext context, String message, Duration duration) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
    ),
  );
}
