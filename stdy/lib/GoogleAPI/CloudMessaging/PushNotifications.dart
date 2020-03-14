import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study/GoogleAPI/Firestore/GradesFirestore.dart';

//Class for initializing the notifications
class PushNotificationsManager {
  GradesFirestore db = new GradesFirestore();
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      String token = await _firebaseMessaging.getToken();
      db.addingTokenData(token); //add token to databse for notifications
      print("FirebaseMessaging token: $token");
      _initialized = true;
    }
  }
}