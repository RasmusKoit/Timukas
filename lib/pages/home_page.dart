import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timukas/pages/about_page.dart';
import 'package:timukas/pages/login_page.dart';
import 'package:timukas/pages/play_page.dart';
import 'package:timukas/pages/score_page.dart';
import 'package:timukas/pages/search_page.dart';
import 'package:timukas/util/app_bar_title.dart';
import 'package:timukas/util/const.dart';
import 'package:timukas/util/main_menu_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<bool> _isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        this.user = user;
      });
    });
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
              onPressed: () {
                // Go to the PlayPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayPage(
                        wordsFile:
                            _isSelected[0] ? soned2013File : lemmad2013File),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Play'),
                  SizedBox(
                    height: 32,
                    child: ToggleButtons(
                      isSelected: _isSelected,
                      onPressed: (index) {
                        setState(() {
                          for (int i = 0; i < _isSelected.length; i++) {
                            _isSelected[i] = i == index;
                          }
                        });
                      },
                      children: const [
                        Text('Easy'),
                        Text('Hard'),
                      ],
                    ),
                  ),
                ],
              ),
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
