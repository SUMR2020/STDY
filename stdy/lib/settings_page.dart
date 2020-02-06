import 'package:study/bloc/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(ThemeData.dark()),
      child: new MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      theme: theme.getTheme(),
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
                child: Text('Dark Theme'),
                onPressed: () => _themeChanger.setTheme(ThemeData.dark())),
            FlatButton(
                child: Text('Light Theme'),
                onPressed: () => _themeChanger.setTheme(ThemeData.light())),
          ],
        ),
      ),
    );
  }
}
