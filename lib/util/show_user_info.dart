import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timukas/util/const.dart';

class ShowUserInfo extends StatefulWidget {
  final User? user;
  final VoidCallback onPressed;
  const ShowUserInfo({super.key, required this.user, required this.onPressed});

  @override
  State<ShowUserInfo> createState() => _ShowUserInfoState();
}

class _ShowUserInfoState extends State<ShowUserInfo> {
  get user => widget.user;
  DocumentSnapshot<Map<String, dynamic>>? userDoc;

  Future<void> getUserDetails() async {
    userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    if (mounted) {
      setState(() {
        userDoc = userDoc;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
              child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                    radius: 60.0,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : const AssetImage('lib/images/default_avatar.png')
                            as ImageProvider<Object>?),
                const SizedBox(height: 16.0),
                Text(
                  user.displayName ?? 'Welcome!',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  user.email ?? '',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Completed levels: ${userDoc?.get('levelsCompleted') ?? 0}',
                ),
                Text(
                  'Failed levels: ${userDoc?.get('levelsFailed') ?? 0}',
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        widget.onPressed();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: estBlue, // Button color
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
