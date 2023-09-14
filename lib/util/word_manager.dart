import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timukas/models/word.dart';
import 'package:timukas/util/api.dart';

const int kMaxAttempts = 100;
const int kMaxWrongGuesses = 12;

class WordManager extends ChangeNotifier {
  final String wordsFile;
  List<Word> words = [];
  Word word = Word(word: '');
  String guessedLetters = '';
  int wrongGuesses = 1;
  bool gameOver = false;
  String resultMessage = '';
  TextEditingController textController = TextEditingController();

  WordManager({required this.wordsFile});

  Future<void> initializeWord() async {
    await readWords();
    if (words.isNotEmpty) {
      final Word newWord = await chooseWord();
      word = newWord;
      guessedLetters = '_ ' * newWord.word.length;
    } else {
      throw Exception('Failed to initialize');
    }
    notifyListeners();
  }

  Future<void> newGame() async {
    final Word newWord = await chooseWord(oldWord: word.word);
    word = newWord;
    guessedLetters = '_ ' * newWord.word.length;
    wrongGuesses = 1;
    gameOver = false;
    resultMessage = '';
    textController.clear();
    notifyListeners();
  }

  Future<void> readWords() async {
    final List<Word> readWords = [];
    final String data = await rootBundle.loadString(wordsFile);

    final List<String> lines = data.split('\n');
    for (String line in lines) {
      final Word word = Word(word: line);
      readWords.add(word);
    }
    words = readWords;
    notifyListeners();
  }

  Future<Word> chooseWord({String oldWord = ''}) async {
    Word wordToSearch = Word(word: '');
    bool search = true;
    // Add a maximum number of attempts to avoid infinite loop

    for (int attempt = 0; attempt < kMaxAttempts && search; attempt++) {
      final randomIndex = Random().nextInt(words.length);
      final randomWord = words[randomIndex];
      wordToSearch = await fetchWord(randomWord.word);

      if (wordToSearch.meanings != null &&
          wordToSearch.meanings!.isNotEmpty &&
          (oldWord.isEmpty || wordToSearch.word != oldWord)) {
        search = false;
      }
    }

    if (search) {
      // Handle the case where no suitable word is found within the maximum attempts
      throw Exception('Failed to find a suitable word');
    }

    return wordToSearch;
  }

  void guessLetter(BuildContext context, String letter) {
    letter = letter.toLowerCase();
    if (textController.text.contains(letter)) {
      // Show Snackbar notification here with msg: 'Letter already tried'
      final snackBar = SnackBar(
        content: Text('Letter $letter has already been tried.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (word.word.contains(letter)) {
      final List<String> letters = guessedLetters.split(' ');
      for (int i = 0; i < word.word.length; i++) {
        if (word.word[i] == letter) {
          letters[i] = letter;
        }
      }
      guessedLetters = letters.join(' ');
      if (!guessedLetters.contains('_')) {
        gameOver = true;
        resultMessage = 'You won!';
      }
    } else {
      wrongGuesses++;
      if (wrongGuesses >= kMaxWrongGuesses) {
        gameOver = true;
        resultMessage = 'You lost!';
      }
    }
    textController.text += letter;
    notifyListeners();
  }
}
