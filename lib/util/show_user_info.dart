import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  DocumentSnapshot<Map<String, dynamic>>? docPublic;
  DocumentSnapshot<Map<String, dynamic>>? docPrivate;

  Future<void> getUserDetails() async {
    DocumentReference<Map<String, dynamic>> userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    final DocumentSnapshot<Map<String, dynamic>> docPublicSnapshot =
        await userDocRef.collection('public').doc('publicData').get();
    final DocumentSnapshot<Map<String, dynamic>> docPrivateSnapshot =
        await userDocRef.collection('private').doc('privateData').get();

    setState(() {
      docPublic = docPublicSnapshot;
      docPrivate = docPrivateSnapshot;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  Future<void> deleteUser() async {
    // Ask user to confirm
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    if (confirm == null || !confirm) {
      return;
    }
    try {
      // Delete public data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('public')
          .doc('publicData')
          .delete();
      // Delete private data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('private')
          .doc('privateData')
          .delete();
      // Delete user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .delete();
      await user?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'The user must reauthenticate before this operation can be executed.'),
            ),
          );
        }
      }
    }
  }

  void showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = docPublic?.data()?['nickName'] ?? '';
        return AlertDialog(
          title: const Text('Edit your nickname'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            controller: TextEditingController(text: newName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the display name in Firestore
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('public')
                    .doc('publicData')
                    .update({'nickName': newName});
                Navigator.of(context).pop();
                getUserDetails();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (docPublic == null || docPrivate == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      final docPrivateData = docPrivate?.data();
      final docPublicData = docPublic?.data();
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                    radius: 60.0,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : const AssetImage('lib/images/default_avatar.png')
                            as ImageProvider<Object>?),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const FaIcon(
                        FontAwesomeIcons.skull,
                        size: 20,
                      ),
                    ),
                    Text(
                      docPublicData?['nickName'] ?? '',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                      onPressed: () {
                        // Open a dialog for editing the display name
                        showEditDialog();
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Text(
                  docPrivateData?['email'] ?? '',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Completed levels: ${docPublicData?['levelsCompleted'] ?? 0}',
                ),
                Text(
                  'Total levels played: ${docPrivateData?['levelsPlayed'] ?? 0}',
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
                const SizedBox(height: 32.0),
                ElevatedButton(
                    onPressed: deleteUser, child: const Text('Delete Account')),
              ],
            ),
          )),
        ),
      );
    }
  }
}
