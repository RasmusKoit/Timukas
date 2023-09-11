import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:timukas/models/word.dart';
import 'package:timukas/util/app_bar_title.dart';
import 'package:timukas/util/bool_widget.dart';
import 'package:timukas/util/display_word.dart';
import 'package:timukas/util/keyboard.dart';
import 'package:http/http.dart' as http;
import 'package:timukas/util/search_box.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<String?> translateWord(String wordToTranslate) async {
    final apiKey = dotenv.env['AZ_API_KEY'];
    if (apiKey == null) {
      return null;
    }
    const String endPoint =
        'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=en&to=et';
    final Map<String, String> headers = {
      'Ocp-Apim-Subscription-Key': apiKey,
      'Ocp-Apim-Subscription-Region': 'germanywestcentral',
      'Content-type': 'application/json',
    };
    final requestBody = jsonEncode([
      {'Text': wordToTranslate}
    ]);
    final response = await http.post(
      Uri.parse(endPoint),
      headers: headers,
      body: requestBody,
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final String translatedText = jsonResponse[0]['translations'][0]['text'];
      return translatedText.toLowerCase();
    } else {
      return null;
    }
  }

  Future<Word> fetchWord(String wordToSearch) async {
    final uri = Uri.parse('https://sonapi.koit.dev/v1/$wordToSearch');
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return Word.fromJson(jsonData);
    } else {
      return Word(word: '');
    }
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
      final result = await translateWord(searchWord);
      if (result == null) {
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
                        CountryFlags.flag('EE', width: 40, borderRadius: 4),
                        CountryFlags.flag('US', width: 40, borderRadius: 4),
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
