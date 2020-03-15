import 'package:flutter/material.dart';
import 'UpdateApp/Subject/SettingsData.dart';
import 'package:flutter/services.dart';
import 'GoogleAPI/CloudMessaging/PushNotifications.dart' as notifs;
import 'UpdateApp/Observer/MyApp.dart';
import 'package:dcdg/dcdg.dart';

//main fucntion of our app
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);//Removes the navigation bar
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])//Locks app to portrait mode
      .then((_) {
      SaveFontScale().loadScale();//gets font scale
    runApp(MyApp());
  });
}

