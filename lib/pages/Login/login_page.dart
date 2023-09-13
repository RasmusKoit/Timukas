import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timukas/util/Widgets/app_bar_title.dart';
import 'package:timukas/pages/Login/show_user_info.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> signInWithProvider(provider) async {
    try {
      final UserCredential providerSignIn =
          await auth.signInWithProvider(provider);
      final User? user = providerSignIn.user;
      if (user != null) {
        await addUserDetails();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${user?.email}!'),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error signing with provider!'),
          ),
        );
      }
    }
  }

  Future<void> addUserDetails() async {
    // check if document with user.uid exists, if not, add it
    // Reference to the user's document
    final User? user = auth.currentUser;
    DocumentReference<Map<String, dynamic>> userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);

    // Fetch the user's document
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await userDocRef.get();

    // Check if the document exists
    if (!docSnapshot.exists) {
      // Document does not exist, add collections and data

      // Add 'public' subcollection with 'publicData' document
      await userDocRef.collection('public').doc('publicData').set({
        'levelsCompleted': 0,
        'levelsFailed': 0,
        'nickName': 'Anonymous'
        // Add other fields and values as needed
      });

      // Add 'private' subcollection with 'privateData' document
      await userDocRef.collection('private').doc('privateData').set({
        'email': auth.currentUser?.email ?? 'No email',
        'displayName': auth.currentUser?.displayName ?? 'Anonymous',
        'levelsPlayed': 0,
      });
    } else {
      // Document exists, do nothing
      return;
    }
  }

  Future<void> signInAnonymously() async {
    try {
      final UserCredential anonymousSignIn = await auth.signInAnonymously();
      final User? user = anonymousSignIn.user;
      user?.updateDisplayName('Guest');
      if (user != null) {
        await addUserDetails();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome guest!'),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error signing in anonymously!'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const MyAppBarTitle(title: Text('Login'))),
      body: StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return Center(
              child: ShowUserInfo(
                user: snapshot.data,
                onPressed: () async {
                  await auth.signOut();
                },
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      signInWithProvider(MicrosoftAuthProvider());
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Continue with Microsoft'),
                        SizedBox(width: 8),
                        FaIcon(FontAwesomeIcons.microsoft),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      signInWithProvider(GoogleAuthProvider());
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Continue with Google'),
                        SizedBox(width: 8),
                        FaIcon(FontAwesomeIcons.google),
                      ],
                    ),
                  ),
                  const Divider(),
                  ElevatedButton(
                    onPressed: () {
                      signInAnonymously();
                    },
                    child: const Text('Continue as Guest'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
