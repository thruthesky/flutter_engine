import 'package:clientf/flutter_engine/enginf.defines.dart';
import './enginf.model.dart';

EngineModel ft = EngineModel();

int failure = 0;
String uid;
equal(a, b, msg) {
  if (a == b) {
    trace('===> [$msg] OK');
  } else {
    failure++;
    trace("===> ERROR [$msg] '$a' is not equal to '$b'");
  }
}

failed(String message) {
  failure++;
  trace('===> Failed: $message');
}

trace(dynamic obj) {
  print(obj);
}

testError() async {
  // final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
  //   functionName: 'throwHttpsError',
  // );
  // try {
  //   HttpsCallableResult callableResult = await callable.call();
  //   print(callableResult);
  // } on PlatformException catch (e) {
  //   print('PlatformException=======>');
  //   print(e.code);
  //   print(e.message);
  //   print(e.details['message']); // 실제 메시지
  //   print(e.details['code']); // 실제 데이터
  // } catch (e) {
  //   print('=========> error');
  //   print(e);
  // }
}

testRouter() async {
  EngineModel engin = EngineModel();
  try {
    await engin.callFunction({'route': 'wrong-class'});
  } catch (e) {
    equal(e.code, WRONG_CLASS_NAME, 'Wrong class name test');
  }

  try {
    await engin.callFunction({'route': 'user.wrong-method'});
  } catch (e) {
    equal(e.code, WRONG_METHOD_NAME, 'Wrong method name test');
  }
}

testEngineUser() async {
  var now = new DateTime.now();

  var id = 'userid' +
      now.day.toString() +
      now.minute.toString() +
      now.second.toString();

  failure = 0;
  trace('user test ok');
  trace(ft.user);
  try {
    await ft.register({});
    failed('Expect email is not provided');
  } catch (e) {
    equal(e.code, EMAIL_IS_NOT_PROVIDED, 'Register without email');
  }

  try {
    await ft.register({'email': 'abc'});
    failed('Expect password is not provided');
  } catch (e) {
    equal(e.code, PASSWORD_IS_NOT_PROVIDED, 'Register without password');
  }

  try {
    await ft.register({'email': 'abc', 'password': '12345a'});
    failed('Expect invalid email');
  } catch (e) {
    /// TODO - Functions and Auth returns difference error code on same error.
    equal(e.code == ERROR_INVALID_EMAIL || e.code == AUTH_INVALID_EMAIL, true,
        'Register with invalid email address.');
  }

  try {
    String email = '$id@myemail.com';
    trace('email: $email');
    var user = await ft.register({'email': email, 'password': '12345a'});
    uid = user.uid;
    equal(user.email, email, 'Register. Expect success.');
  } catch (e) {
    failed('Expect success. but Exception on register: $e');
  }



  trace('');
  trace('===> Failure: $failure\n');
}
