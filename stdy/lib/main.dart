import 'package:flutter/material.dart';
import 'GoogleAPI/Authentication/Authentication.dart';
import 'package:provider/provider.dart';
import 'UpdateApp/Subject/Theme.dart';
import 'package:flutter/services.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'GoogleAPI/CloudMessaging/PushNotifications.dart' as notifs;
import 'UpdateApp/Observer/MyApp.dart';



int fontScale = 0;
String name = "";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);//Removes the navigation bar
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])//Locks app to portrait mode
      .then((_) {
    notifs.PushNotificationsManager().init();
    SaveFontScale().loadScale();
    runApp(MyApp());
  });
}

