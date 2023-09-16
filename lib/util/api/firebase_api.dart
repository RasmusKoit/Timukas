import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseAPI {
  final _firebaseMessagin = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // request permission
    await _firebaseMessagin.requestPermission();
    final fCMToken = await _firebaseMessagin.getToken();
  }
}
