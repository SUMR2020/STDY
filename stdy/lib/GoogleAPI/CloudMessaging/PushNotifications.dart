import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study/GoogleAPI/Firestore/InitFirestore.dart';

class PushNotificationsManager {
  InitFireStore c = new InitFireStore();
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      String token = await _firebaseMessaging.getToken();
      c.addingTokenData(token);
      print("FirebaseMessaging token: $token");
      _initialized = true;
    }
  }
}