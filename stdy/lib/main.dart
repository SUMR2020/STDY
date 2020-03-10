import 'package:flutter/material.dart';
import 'Settings/Authentication.dart';
import 'package:provider/provider.dart';
import 'Settings/theme.dart';
import 'package:flutter/services.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'push_notifictions.dart' as notifs;
import 'MyApp.dart';



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

