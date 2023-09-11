import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timukas/util/app_bar_title.dart';
import 'package:timukas/util/show_user_info.dart';

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

  Future addUserDetails() async {
    // check if document with user.uid exists, if not, add it
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser?.uid)
            .get();
    if (!userDoc.exists) {
      // add document with id user.uid
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid)
          .set({
        'id': auth.currentUser?.uid,
        'levelsCompleted': 0,
        'lg': "et",
      });
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
