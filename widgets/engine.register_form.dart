
import '../engine.globals.dart';
import '../engine.user.model.dart';
import './engine.register.user_photo.dart';
import './engine.space.dart';
import './engine.text.dart';
import './engine.upload_icon.dart';
import './upload_progress_bar.dart';
import 'package:flutter/material.dart';

class EngineRegisterFrom extends StatefulWidget {
  EngineRegisterFrom({
    @required this.onError,
    @required this.onRegisterSuccess,
    @required this.onUpdateSuccess,
  });

  final Function onError;
  final Function onRegisterSuccess;
  final Function onUpdateSuccess;
  @override
  _EngineRegisterFromState createState() => _EngineRegisterFromState();
}

class _EngineRegisterFromState extends State<EngineRegisterFrom> {
  EngineUser user = EngineUser();
  int progress = 0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  /// Gets user registration data from the form
  /// TODO - form validation
  getFormData() {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String nickname = _nicknameController.text;
    final String phoneNumber = _phoneNumberController.text;
    final String birthday = _birthdayController.text;

    /// 여기서 부터. 회원 정보에서 displayName, phoneNumber, photoURL 이... Auth 에 저장되고, Firestore 에 저장되지 않는지 확인.
    /// 회원 정보 수정. Auth 에 있는 값과 Firestore 에 있는 값을 모두 잘 수정하는지 확인.
    ///
    final data = {
      'displayName': nickname,
      'phoneNumber': phoneNumber,
      'birthday': birthday,
    };

    /// 회원 가입
    if (ef.notLoggedIn) {
      /// 회원 가입시에만 이메일과 비빌번호를 지정
      data['email'] = email;
      data['password'] = password;

      /// 회원 가입을 할 때에는 사진이 `Anonymous` 로 업로드 되어져있는데,
      ///   - 그 사진의 URL 을 `Enginef`로 전달하고
      ///   - `Enginef`에서 해당 사용자의 `Firebase Auth` 에 기록을 한다.
      if (user.urls != null && user.urls.length > 0) {
        data['photoURL'] = user.urls[0];
      }
    }
    return data;
  }

  @override
  void initState() {
    if (ef.loggedIn) {
      loadProfile();
    }
    super.initState();
  }

  loadProfile() async {
    try {
      var _user = await ef.userProfile();
      setState(() {
        user = _user;
        _nicknameController.text = user.displayName;
        _phoneNumberController.text = user.phoneNumber;
        _birthdayController.text = user.birthday;
      });
    } catch (e) {
      widget.onError(e);
      // AppService.alert(null, t(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        EngineUploadIcon(
          user,
          onProgress: (p) {
            /// 업로드 Percentage 표시
            setState(() {
              progress = p;
            });
          },
          onUploadComplete: (String url) async {
            /// 사진 업로드
            try {
              /// 사진을 업로드하면, `Enginef` 에 바로 저장을 해 버린다. 즉, 전송 버튼을 누르지 않아도 이미 업데이트가 되어져 버린다.
              await ef.userUpdate({'photoURL': url});
              setState(() {});
            } catch (e) {
              widget.onError(e);
              // AppService.alert(null, t(e));
            }
          },
          onError: (e) => widget.onError(e),
          icon: EngineRegisterUserPhoto(
            user,
            onError: (e) => widget.onError(e),
          ),
        ),
        EngineProgressBar(progress),
        EnginePageSpace(),
        ef.notLoggedIn
            ? TextField(
                controller: _emailController,
                onSubmitted: (text) {},
                decoration: InputDecoration(
                  hintText: t('input email'),
                ),
              )
            : Text(user?.email ?? ''),
        EngineSpace(),
        if (ef.notLoggedIn)
          TextField(
            controller: _passwordController,
            onSubmitted: (text) {},
            decoration: InputDecoration(
              hintText: t('input password'),
            ),
          ),
        EngineSpace(),
        TextField(
          controller: _nicknameController,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: t('input nickname'),
          ),
        ),
        EngineSpace(),
        TextField(
          controller: _phoneNumberController,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: t('input phone number'),
          ),
        ),
        EngineSpace(),
        TextField(
          controller: _birthdayController,
          onSubmitted: (text) {},
          decoration: InputDecoration(
            hintText: t('input birthday'),
          ),
        ),
        RaisedButton(
          onPressed: () async {
            /// 전송 버튼
            final data = getFormData();
            try {
              if (ef.notLoggedIn) {
                await ef.register(data);
                widget.onRegisterSuccess();
              } else {
                await ef.userUpdate(data);
                widget.onUpdateSuccess();
              }
            } catch (e) {
              widget.onError(e);
            }
          },
          child: ef.notLoggedIn ? T('register submit') : T('update submit'),
        ),
      ],
    );
  }
}
