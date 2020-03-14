import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study/GoogleAPI/Firestore/InitFirestore.dart';

//Class for initializing the notifications
class PushNotificationsManager {
  InitFireStore _db = new InitFireStore();

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      String token = await _firebaseMessaging.getToken();
      _db.addingTokenData(token); //add token to databse for notifications
      print("FirebaseMessaging token: $token");
      _initialized = true;
    }
  }
}