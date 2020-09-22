import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_tutorial/auth/confirm.dart';
import 'package:amplify_tutorial/storage/bucketView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isSignedUp = false;
  bool _isConfirmed = false;
  bool _isSignedin = false;

  String _userName;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> _registerUser(LoginData data) async {
  }

  Future<String> _signIn(LoginData data) async {
  }

  void _enter() async {
    if (_isSignedin) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (_) => BucketViewer()));
    } else if (_isSignedUp && !_isConfirmed) {
      // push confirm ui
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Confirm(
                    username: _userName,
                  )));
    } else {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FlutterLogin(
            logo: 'images/trash_can.png',
            onLogin: _signIn,
            onSignup: _registerUser,
            onRecoverPassword: (_) => null,
            onSubmitAnimationCompleted: _enter,
            title: 'Doogle Grive'),
      ),
    );
  }
}
