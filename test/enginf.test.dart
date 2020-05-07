import 'package:clientf/enginf_clientf_service/enginf.defines.dart';
import 'package:clientf/enginf_clientf_service/enginf.model.dart';

EnginfModel f = EnginfModel();

int failure = 0;
equal(a, b) {
  if (a == b) {
    trace('===> OK');
  } else {
    failure++;
    trace("===> ERROR '$a' is not equal to '$b'");
  }
}

failed(String message) {
  failure++;
  trace('===> Failed: $message');
}

trace(dynamic obj) {
  print(obj);
}

testEnginfUser() async {
  var now = new DateTime.now();

  var id = 'userid' +
      now.day.toString() +
      now.minute.toString() +
      now.second.toString();

  failure = 0;
  trace('user test ok');
  trace(f.user);
  try {
    await f.register({});
    failed('Expect email is not provided');
  } catch (e) {
    equal(e, EMAIL_IS_NOT_PROVIDED);
  }

  try {
    await f.register({'email': 'abc'});
    failed('Expect password is not provided');
  } catch (e) {
    equal(e, PASSWORD_IS_NOT_PROVIDED);
  }

  try {
    await f.register({'email': 'abc', 'password': '12345a'});
    failed('Expect invalid email');
  } catch (e) {
    /// TODO - Functions and Auth returns difference error code on same error.
    equal(e == ERROR_INVALID_EMAIL || e == AUTH_INVALID_EMAIL, true);
  }

  try {
    String email = '$id@myemail.com';
    trace('email: $email');
    var user = await f.register({'email': email, 'password': '12345a'});
    equal(user.email, email);
  } catch (e) {
    failed('Expect success. but Exception on register: $e');
  }

  trace('');
  trace('===> Failure: $failure\n');
}
