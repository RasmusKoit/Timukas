import 'package:flutter/material.dart';
import 'package:timukas/util/app_bar_title.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  final List<String> subtitleList = [
    'Welcome to Timukas!',
    'Timukas is Awesome:',
    'Who is Timukas For:',
    'Technical Details:',
    'Explore the world of Estonian words with Timukas!'
  ];

  final List<String> contentList = [
    'Timukas is a project created by Rasmus Koit, developed with passion and creativity. It\'s not just an ordinary app; it\'s your gateway to mastering Estonian words in a fun and interactive way through the classic game of Hangman!',
    '🎮 Gamified Learning: Learning a new language has never been this enjoyable. Timukas turns the language learning process into an engaging game of Hangman.',
    '🚀 Powered by Technology: Timukas leverages the latest in technology. It\'s built using Flutter for a smooth and responsive user experience.',
    '🌐 Language Insights: With SONAPI integration, you can dive deeper into the Estonian language. Get extra information and insights about the words you\'re learning. Hard to understand hints can be translated with a click of a button using Azure Text Translation!',
    '👩‍🎓 Language Enthusiasts: Whether you\'re a language enthusiast or just starting to explore Estonian, Timukas welcomes everyone on their language-learning journey.',
    '🧒 Educational Fun: It\'s a perfect tool for students looking to expand their vocabulary while having fun.',
    '📦 Backend with Firebase: Timukas relies on Firebase as its robust backend, ensuring a seamless and secure experience.',
    '📚 Word Source: For word generation, Timukas uses the Eesti Keele Instituut word soned2013.txt or lemmad2013.txt file, a trusted resource for Estonian words.',
    'Explore the world of Estonian words with Timukas!'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MyAppBarTitle(title: Text('About Timukas')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < subtitleList.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitleList[i],
                      style: TextStyle(
                        fontSize: i == 0 ? 24 : 20,
                        fontWeight:
                            i == 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contentList[i],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    if (i < subtitleList.length - 1) const SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
