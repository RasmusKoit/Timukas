import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timukas/models/word.dart';
import 'package:timukas/pages/about_page.dart';
import 'package:timukas/pages/login_page.dart';
import 'package:timukas/pages/play_page.dart';
import 'package:timukas/pages/score_page.dart';
import 'package:timukas/pages/search_page.dart';
import 'package:timukas/util/app_bar_title.dart';
import 'package:timukas/util/const.dart';
import 'package:http/http.dart' as http;
import 'package:timukas/util/main_menu_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Word> words = [];
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        this.user = user;
      });
    });
    readWords();
  }

  Future<void> readWords() async {
    final String data =
        await DefaultAssetBundle.of(context).loadString(lemmad2013File);
    final List<String> lines = data.split('\n');
    for (String line in lines) {
      final Word word = Word(word: line);
      words.add(word);
    }
  }

  void showSnackBar(BuildContext context, String message, {int duration = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MyAppBarTitle(
          title: Text('Timukas'),
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _auth.currentUser == null
                ? const Text('Welcome!')
                : Text("Welcome ${user?.displayName ?? user?.email}!"),
            MainMenuButton(
              onPressed: () async {
                // Go to the PlayPage
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayPage(words: words),
                    ),
                  );
                }
              },
              child: const Text('Play'),
            ),
            MainMenuButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              child: const Text('Search'),
            ),
            MainMenuButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScorePage()),
                );
              },
              child: const Text('Scoreboard'),
            ),
            MainMenuButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
              child: const Text('About'),
            ),
            MainMenuButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('User'),
            ),
          ],
        ),
      ),
    );
  }
}
