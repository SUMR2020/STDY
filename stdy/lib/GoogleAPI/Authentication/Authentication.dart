import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:googleapis_auth/auth_io.dart" as auth;
import "package:http/http.dart" as http;
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:study/UpdateApp/UI/LoginPage.dart';
import 'package:study/HomePage.dart';

//class for using google and firebase for authentication
class Authentication {
  final scopes = [calendar.CalendarApi.CalendarScope];
  String name;
  bool authCheck = false;
  final FirebaseAuth author = FirebaseAuth.instance;
  auth.AuthClient authClient;
  final GoogleSignIn googleSignIn =
  new GoogleSignIn(scopes: [calendar.CalendarApi.CalendarScope]);

  static final Authentication _singleton = new Authentication._internal();

  factory Authentication() {
    return _singleton;
  }

  Authentication._internal();

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
    final AuthResult authResult = await author.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await author.currentUser();
    assert(user.uid == currentUser.uid);

    print("SUCCESS");

    authCheck = true;

    name = user.displayName;

    if (name.contains(" ")) {
      name = name.substring(0, name.indexOf(" "));
    }

    return true;
  }

  signOut() async {
    await author.signOut();
    await googleSignIn.signOut();
  }
}

//class for checking if user is authenticated
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
    Authentication().signInWithGoogle();
    return Home();
  }
}
