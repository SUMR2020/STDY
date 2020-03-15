import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:googleapis_auth/auth_io.dart" as auth;
import "package:http/http.dart" as http;
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:study/UpdateApp/UI/LoginPage.dart';
import 'package:study/HomePage.dart';
import '../CloudMessaging/PushNotifications.dart' as notifs;

//class for using google and firebase for authentication
class Authentication {
  static final _scopes = [calendar.CalendarApi.CalendarScope];
  String name;
  bool authCheck = false;
  final FirebaseAuth _author = FirebaseAuth.instance;
  auth.AuthClient authClient;
  final GoogleSignIn _googleSignIn =
  new GoogleSignIn(scopes: _scopes);

  static final Authentication _singleton = new Authentication._internal();

  factory Authentication() {
    return _singleton;
  }

  Authentication._internal();

  Future<bool> signInWithGoogle() async {
    final GoogleSignInAccount _googleSignInAccount = await _googleSignIn.signIn();
    if (_googleSignInAccount == null) authCheck = false;
    final GoogleSignInAuthentication _googleSignInAuthentication =
        await _googleSignInAccount.authentication;

    final AuthCredential _credential = GoogleAuthProvider.getCredential(
      accessToken: _googleSignInAuthentication.accessToken,
      idToken: _googleSignInAuthentication.idToken,
    );

    auth.AccessToken _token = auth.AccessToken(
        "Bearer",
        _googleSignInAuthentication.accessToken,
        DateTime.now().add(Duration(days: 1)).toUtc());
    auth.AccessCredentials(_token, _googleSignInAccount.id, _scopes);
    http.BaseClient _client = http.Client();
    authClient = auth.authenticatedClient(
        _client, auth.AccessCredentials(_token, _googleSignInAccount.id, _scopes));
    final AuthResult _authResult = await _author.signInWithCredential(_credential);
    final FirebaseUser _user = _authResult.user;

    assert(!_user.isAnonymous);
    assert(await _user.getIdToken() != null);

    final FirebaseUser _currentUser = await _author.currentUser();
    assert(_user.uid == _currentUser.uid);

    print("SUCCESS");

    authCheck = true;

    name = _user.displayName;

    if (name.contains(" ")) {
      name = name.substring(0, name.indexOf(" "));
    }

    notifs.PushNotificationsManager().init();//inititalizes cloud messaging

    return true;
  }

  signOut() async {
    await _author.signOut();
    await _googleSignIn.signOut();
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
