import 'package:flutter/material.dart';
import 'package:timukas/util/app_bar_title.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const MyAppBarTitle(title: Text('Scoreboard'))),
        body: Center());
  }
}
