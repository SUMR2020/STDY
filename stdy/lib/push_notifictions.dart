import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:study/grades/grades_data.dart';

class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");
      GradeData().addingTokenData(token);
      _initialized = true;
    }
  }
}