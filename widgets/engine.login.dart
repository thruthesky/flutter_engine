import 'package:clientf/flutter_engine/widgets/space.dart';

import '../engine.globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EngineLogin extends StatelessWidget {
  EngineLogin({
    this.hintEmail = 'Email',
    this.hintPassword = 'Password',
    this.hintSubmit = 'Submit',
    this.hintGoogleSignIn = 'Google Sign In',
    @required this.onLogin,
    @required this.onError,
  });

  final String hintEmail;
  final String hintPassword;
  final String hintSubmit;
  final String hintGoogleSignIn;
  final Function onLogin;
  final Function onError;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Gets user registration data from the form
  /// TODO - form validation
  getFormData() {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final data = {
      'email': email,
      'password': password,
    };
    return data;
  }

  Future<FirebaseUser> _handleSignIn() async {
    try {
      await ef.loginWithGoogleAccount();
    } catch (e) {
      print('Got error: ');
      print(e);
      onError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _emailController,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: hintEmail,
          ),
        ),
        EngineSpace(),
        TextField(
          controller: _passwordController,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: hintPassword,
          ),
        ),
        EngineSpace(),
        RaisedButton(
          onPressed: () async {
            final data = getFormData();
            try {
              final user = await ef.login(data['email'], data['password']);
              onLogin(user);
              // AppRouter.open(context, AppRoutes.home);
            } catch (e) {
              onError(e);
              // AppService.alert(null, t(e));
            }
          },
          child: Text(hintSubmit),
        ),
        RaisedButton(
          onPressed: () async {
            try {
              final user = await _handleSignIn();
            } catch (e) {
              onError(e);
            }

            // .then((FirebaseUser user) => print(user))
            // .catchError((e) => print(e));
          },
          child: Text(hintGoogleSignIn),
        ),
      ],
    );
  }
}
