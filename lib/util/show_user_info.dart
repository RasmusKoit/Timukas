import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timukas/util/const.dart';

class ShowUserInfo extends StatefulWidget {
  final User? user;
  final VoidCallback onPressed;

  const ShowUserInfo({Key? key, required this.user, required this.onPressed})
      : super(key: key);

  @override
  State<ShowUserInfo> createState() => _ShowUserInfoState();
}

class _ShowUserInfoState extends State<ShowUserInfo> {
  late Future<List<DocumentSnapshot<Map<String, dynamic>>>> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = getUserDetails();
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getUserDetails() async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(widget.user?.uid);
    final docPublicSnapshot =
        await userDocRef.collection('public').doc('publicData').get();
    final docPrivateSnapshot =
        await userDocRef.collection('private').doc('privateData').get();

    return [docPublicSnapshot, docPrivateSnapshot];
  }

  Future<void> deleteUser() async {
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
      // Delete user data
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(widget.user?.uid);
      await userDocRef.collection('public').doc('publicData').delete();
      await userDocRef.collection('private').doc('privateData').delete();
      await userDocRef.delete();

      // Delete user account
      await widget.user?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The user must reauthenticate before this operation can be executed.',
            ),
          ),
        );
      }
    }
  }

  void showEditDialog(DocumentSnapshot<Map<String, dynamic>>? docPublic) {
    String newName = docPublic?.data()?['nickName'] ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    .doc(widget.user?.uid)
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
    return FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('User data not found.'));
        } else {
          final docPublicData = snapshot.data![0].data();
          final docPrivateData = snapshot.data![1].data();
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
                        backgroundImage: widget.user?.photoURL != null
                            ? NetworkImage(widget.user!.photoURL!)
                            : const AssetImage('lib/images/default_avatar.png')
                                as ImageProvider<Object>?,
                      ),
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
                              showEditDialog(snapshot.data?[0]);
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
                          widget.onPressed();
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
                        onPressed: deleteUser,
                        child: const Text('Delete Account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
