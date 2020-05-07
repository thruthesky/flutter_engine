import 'package:clientf/enginf_clientf_service/enginf.defines.dart';
import 'package:clientf/enginf_clientf_service/enginf.user.model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnginfModel extends ChangeNotifier {
  /// If user is null when no user is logged in.
  FirebaseUser user;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  EnginfModel() {
    /// User login/logout change listener initialization.
    /// Whenever auth changes, it will notify listens.

    (() async {
      _auth.onAuthStateChanged.listen((_user) {
        user = _user;
        notifyListeners();
      });
    })();
  }

  /// Returns result from `Cloud Functions` call.
  /// If there is error on protocol, then it throws the error message.
  Future<dynamic> callFunction(Map<String, dynamic> request) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'router',
    );
    HttpsCallableResult callableResult = await callable.call(request);

    var result;

    try {
      result = callableResult.data;
    } catch (e) {
      throw 'error on allableResult.data in callFunctions()';
    }

    // print('=====> callableResult.data: <${result.runtimeType}> $result');
    if (result is String) {
      throw result;
    } else {
      return result;
    }
  }

  bool get loggedIn {
    return user != null;
  }

  bool get notLoggedIn {
    return loggedIn == false;
  }

  /// Let user log through the Firebase Auth
  /// It notifies listeners & returns user object.
  /// When there is an Error, it will throw the error code. Only the code of the error.
  /// @example see README
  Future<FirebaseUser> login(String email, String password) async {
    if (email == null || email == '') {
      throw INPUT_EMAIL;
    }
    if (password == null || password == '') {
      throw INPUT_PASSWORD;
    }
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user != null) {
        /// success
        notifyListeners();
        return result.user;
      } else {
        throw ERROR_USER_IS_NULL;
      }
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      throw code;
    } catch (e) {
      throw e.message;
    }
  }

  /// Let the user log out & set `user` to null & `notifyListeners()`
  logout() async {
    await _auth.signOut();
    user = null;
    notifyListeners();
  }

  /// If there is an Error, it will throw the error code.
  Future<FirebaseUser> register(data) async {
    var registeredUser = await callFunction(
      {'route': 'user.register', 'data': data},
    );
    final loggedUser = await login(registeredUser['email'], data['password']);
    return loggedUser;
  }

  /// Updates user data
  /// It can update not only `displayName` and `photoUrl` but also `phoneNumber` and all of other things.
  Future<EnginfUser> update(data) async {
    data['uid'] = user.uid;
    var update = await callFunction(
      {'route': 'user.update', 'data': data},
    );
    await user.reload();
    user = await _auth.currentUser();
    return EnginfUser.fromMap(update);
  }

  /// Gets user profile data from Firestore  & return user data as `EnginfUser` helper class.
  /// @warning It does `NOT notifyListeners()` and does `NOT update user`.
  Future<EnginfUser> profile() async {
    if (notLoggedIn || user?.uid == null) throw LOGIN_FIRST;
    // print(user.uid);
    return EnginfUser.fromMap(
      await callFunction({'route': 'user.data', 'data': user.uid}),
    );
  }
}
