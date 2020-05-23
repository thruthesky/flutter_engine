
import './engine.button.dart';

import '../widgets/engine.space.dart';
import '../engine.globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EngineLoginForm extends StatefulWidget {
  EngineLoginForm({
    this.hintEmail = 'Email',
    this.hintPassword = 'Password',
    this.textSubmit = 'Submit',
    this.hintGoogleSignIn = 'Google Sign In',
    @required this.onLogin,
    @required this.onError,
  });

  final String hintEmail;
  final String hintPassword;
  final String textSubmit;
  final String hintGoogleSignIn;
  final Function onLogin;
  final Function onError;

  @override
  _EngineLoginFormState createState() => _EngineLoginFormState();
}

class _EngineLoginFormState extends State<EngineLoginForm> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool inSubmit = false;

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
      widget.onError(e);
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
            hintText: widget.hintEmail,
          ),
        ),
        EngineSpace(),
        TextField(
          controller: _passwordController,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: widget.hintPassword,
          ),
        ),
        EngineSpace(),
        EngineButton(
          loader: inSubmit,
          text: widget.textSubmit,
          onPressed: () async {
            if ( inSubmit ) return;
            setState(() {
              inSubmit = true;
            });
            final data = getFormData();
            try {
              final user = await ef.login(data['email'], data['password']);
              widget.onLogin(user);
            } catch (e) {
              widget.onError(e);
            }
            setState(() {
              inSubmit = false;
            });
          },
        ),
        RaisedButton(
          onPressed: () async {
            try {
              final user = await _handleSignIn();
            } catch (e) {
              widget.onError(e);
            }
          },
          child: Text(widget.hintGoogleSignIn),
        ),
      ],
    );
  }
}
