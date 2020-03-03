import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study/bloc/theme.dart';
import 'package:study/main.dart';
import 'home_widget.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import "package:googleapis_auth/auth_io.dart" as auth;
import "package:http/http.dart" as http;

bool authCheck = false;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
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
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
        splashColor: Theme.of(context).accentColor,
        onPressed: () {
          signInWithGoogle().whenComplete(() {
            if (authCheck) {
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

final FirebaseAuth _auth = FirebaseAuth.instance;
auth.AuthClient authClient;
final GoogleSignIn googleSignIn =
    new GoogleSignIn(scopes: [calendar.CalendarApi.CalendarScope]);

Future<bool> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount == null) authCheck = false;
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  auth.AccessToken token = auth.AccessToken(
      "Bearer",
      googleSignInAuthentication.accessToken,
      DateTime.now().add(Duration(days: 1)).toUtc());
  auth.AccessCredentials(token, googleSignInAccount.id, scopes);
  http.BaseClient _client = http.Client();
  authClient = auth.authenticatedClient(
      _client, auth.AccessCredentials(token, googleSignInAccount.id, scopes));
  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  print("SUCCESS");

  authCheck = true;

  name = user.displayName;

  if (name.contains(" ")) {
    name = name.substring(0, name.indexOf(" "));
  }

  return true;
}

void signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Sign Out");
}

class Auth {
  FirebaseAuth _firebaseAuth;
  FirebaseUser _user;

  Auth() {
    this._firebaseAuth = FirebaseAuth.instance;
  }

  Future<Widget> isLoggedIn() async {
    this._user = await _firebaseAuth.currentUser();
    if (this._user == null) {
      return LoginScreen();
    }
    signInWithGoogle();
    return Home();
  }
}
