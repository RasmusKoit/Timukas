import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timukas/pages/Play/play_page.dart';
import 'package:timukas/util/Widgets/app_bar_title.dart';
import 'package:timukas/util/const.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  Future getAllLevelsCompleted() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('public')
          .orderBy('levelsCompleted', descending: true)
          .where('levelsCompleted', isGreaterThan: 0)
          .get();

      final List<Map<String, dynamic>> levelsCompletedList = [];
      for (var doc in querySnapshot.docs) {
        levelsCompletedList.add({
          'name': doc['nickName'],
          'levelsCompleted': doc['levelsCompleted'],
        });
      }

      return levelsCompletedList;
    } catch (e) {
      if (mounted) {
        showSnackBar(
            context, 'Failed to pull data', const Duration(seconds: 1));
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MyAppBarTitle(title: Text('Scoreboard')),
      ),
      body: FutureBuilder(
        future: getAllLevelsCompleted(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final name = snapshot.data![index]['name'];
                final levelsCompleted =
                    snapshot.data![index]['levelsCompleted'];
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: estBlue,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text("$levelsCompleted completed levels"),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
