import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:timukas/models/word.dart';
import 'package:timukas/util/api.dart';
import 'package:timukas/util/app_bar_title.dart';
import 'package:timukas/util/bool_widget.dart';
import 'package:timukas/util/display_word.dart';
import 'package:timukas/util/keyboard.dart';
import 'package:timukas/util/search_box.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Word word = Word(word: '');
  List<bool> isSelected = [true, false];
  String message = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onFlagSelect(int index) {
    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = i == index;
      }
    });
  }

  Future<void> searchWord() async {
    String searchWord = searchController.text;
    if (searchWord.isEmpty) {
      return;
    }
    if (searchWord == word.word) {
      return;
    }
    if (isSelected[0]) {
      word = await fetchWord(searchWord);
    } else {
      final result = await translateText(searchWord, 'en', 'et');
      if (result == '') {
        word = Word(word: '');
      } else {
        word = await fetchWord(result);
      }
    }
    if (word.word == '') {
      setState(() {
        message = 'Word not found';
      });
      return;
    }
    setState(() {
      word = word;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const MyAppBarTitle(title: Text('Search'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SearchBox(
                  controller: searchController,
                  msg: message,
                  onSearchTap: searchWord,
                ),
                SizedBox(
                  height: 40,
                  child: ToggleButtons(
                      isSelected: isSelected,
                      onPressed: onFlagSelect,
                      children: [
                        CountryFlag.fromCountryCode('ee',
                            width: 40, borderRadius: 4),
                        CountryFlag.fromCountryCode('us',
                            width: 40, borderRadius: 4),
                      ]),
                ),
              ],
            ),
            Expanded(
              child: BoolWidget(
                  primary: Text(message),
                  secondary: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DisplayWord(
                      word: word,
                    ),
                  ),
                  value: word.word == ''),
            ),
            EstonianKeyboard(onLetterTap: onTapListener),
          ],
        ),
      ),
    );
  }

  void onTapListener(String letter) {
    letter = letter.toLowerCase();
    setState(() {
      searchController.text += letter;
    });
  }
}
