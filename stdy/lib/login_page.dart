import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STDY'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Login'),
          onPressed: () {
            // Navigate to the second screen when tapped.
            Navigator.pushReplacementNamed(context, '/second');
          },
        ),
      ),
    );
  }
}
