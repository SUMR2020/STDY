import 'package:flutter/material.dart';
import '../../HomePage.dart';
import '../../GoogleAPI/Authentication/Authentication.dart';

//This class creates the login page

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
              _signInButton(),
            ],
          ),
        ),
        Expanded(child: Container()),
        Align(
          alignment: Alignment.bottomCenter,
          child: Text("Made by SUMR", style: TextStyle(fontFamily:'Bebas',
              fontSize: 23,
              color: Theme.of(context).primaryColor)),
        )
      ]),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
        splashColor: Theme.of(context).accentColor,
        onPressed: () {
          Authentication().signInWithGoogle().whenComplete(() {
            //get authentication
            if (Authentication().authCheck) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return Home();
                  },
                ),
              );
            }
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage('assets/googleLogo.png'), height: 35.0),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
