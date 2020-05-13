import 'package:clientf/enginf_clientf_service/enginf.category.model.dart';
import 'package:clientf/enginf_clientf_service/enginf.category_list.model.dart';
import 'package:clientf/enginf_clientf_service/enginf.comment.model.dart';
import 'package:clientf/enginf_clientf_service/enginf.defines.dart';
import 'package:clientf/enginf_clientf_service/enginf.error.model.dart';
import 'package:clientf/enginf_clientf_service/enginf.post.model.dart';
import 'package:clientf/enginf_clientf_service/enginf.user.model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EngineModel extends ChangeNotifier {
  /// If user is null when no user is logged in.
  FirebaseUser user;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  EngineModel() {
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
      /// Error happened when calling Callable funtions. This should never happens.
      throw 'Error at allableResult.data EngineModel::callFunctions()';
    }

    /// The return value from callable function is always an object(Map or List). Not a String or Number.
    /// When there is error on callable funtion, the returned object has `error` property with `true`.
    if (result is Map && result['error'] == true) {
      throw EngineError.fromMap(result);
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
  Future<EngineUser> update(data) async {
    data['uid'] = user.uid;
    var update = await callFunction(
      {'route': 'user.update', 'data': data},
    );
    await user.reload();
    user = await _auth.currentUser();
    notifyListeners();
    return EngineUser.fromMap(update);
  }

  /// Gets user profile data from Firestore  & return user data as `EngineUser` helper class.
  /// @warning It does `NOT notifyListeners()` and does `NOT update user`.
  Future<EngineUser> profile() async {
    if (notLoggedIn || user?.uid == null) throw LOGIN_FIRST;
    // print(user.uid);
    final profile =
        await callFunction({'route': 'user.data', 'data': user.uid});
    print('profile: ');
    print(profile);
    return EngineUser.fromMap(profile);
  }

  Future categoryCreate(data) {
    return callFunction({'route': 'category.create', 'data': data});
  }

  Future categoryUpdate(data) {
    return callFunction({'route': 'category.update', 'data': data});
  }

  Future<EngineCategory> categoryData(String id) async {
    var re = await callFunction({'route': 'category.data', 'data': id});
    return EngineCategory.fromEnginData(re);
  }

  Future<EngineCategoryList> categoryList() async {
    return EngineCategoryList.fromEnginData(
        await callFunction({'route': 'category.list'}));
  }

  Future<EnginePost> postCreate(data) async {
    final post = await callFunction({'route': 'post.create', 'data': data});
    return EnginePost.fromEnginData(post);
  }

  Future<EnginePost> postUpdate(data) async {
    final post = await callFunction({'route': 'post.update', 'data': data});
    return EnginePost.fromEnginData(post);
  }

  Future<EnginePost> postDelete(String id) async {
    final post = await callFunction({'route': 'post.delete', 'data': id});
    return EnginePost.fromEnginData(post);
  }

  /// @return List<EnginePost> of posts
  ///   If there is no posts, then empty array will be returned.
  Future<List<EnginePost>> postList(data) async {
    final List posts = await callFunction({'route': 'post.list', 'data': data});

    List<EnginePost> ret = [];
    for (var e in posts) {
      ret.add(EnginePost.fromEnginData(e));
    }
    return ret;
  }

  /// @중요 postCreate(), postUpdate() 와는 달리 자동으로 EngineComment 로 변환하지 않는다.
  Future<Map<dynamic, dynamic>> commentCreate(data) async {
    final comment =
        await callFunction({'route': 'comment.create', 'data': data});
    return comment;
    // return EngineComment.fromEnginData(comment);
  }
}
