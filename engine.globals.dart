import './widgets/engine.text.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import './engine.app.localization.dart';
import './engine.error.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// `Engine` 에서 사용하는 글로벌 변수 몽므

import './engine.model.dart';

/// `Engine` `state model` 을 여기서 한번만 생성하여 글로벌 변수로 사용한다.
/// 글로벌 변수 명은 `ef` 이며, 이 값을 Provider 에 등록하면 되고, 필요하면 이 객체를 바로 사용하면 된다.
///
/// * 객체 생성은 main.dart 에서 하면 된다.
EngineModel _ef;

set ef(value) => _ef = value;
EngineModel get ef {
  assert(_ef != null, '===> Engine error! [ef] is not set.');
  assert(_ef.navigatorKey != null,
      '[GlobalKey<NavigatorState> navigatorKey] is not set. So, you cannot use context in Engine. Please set it on main.dart');
  return _ef;
}

const String hiveCacheBox = 'cache';


/// Returns translated string from the text code.
/// If [code] is [EngineError], then it takes [EngineError.code] as [code] and translate it.
String t(code, {info}) {
  // print(code);
  if (code is EngineError) {
    code = code.code;
    // if (info == null) info = code.message;
  }
  if (code is FlutterError) code = code.message;
  if (code is PlatformException) {
    code = code.details;
  }
  return AppLocalizations.of(ef.context).t(code, info: info);
}

/// App language code
/// @return two letter string
///   'ko' - Korean
///   'en' - English
///   'zh' - Chinese
///   'ja' - Japanese.
String appLanguageCode() {
  return AppLocalizations.of(ef.context).locale.languageCode;
}

bottomSheet(List<Map<String, dynamic>> items) {
  showModalBottomSheet(
    context: ef.context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Container(
          child: new Wrap(
            children: <Widget>[
              for (var item in items)
                new ListTile(
                  leading: new Icon(item['icon']),
                  title: new Text(item['text']),
                  onTap: item['onTap'],
                  // new ListTile(
                  //   leading: new Icon(Icons.videocam),
                  //   title: new Text('Video'),
                  //   onTap: () => {},
                ),
            ],
          ),
        ),
      );
    },
  );
}



void _back({arguments}) {
  Navigator.pop(ef.context, arguments);
}



/// Show alert box
/// @example AppService.alert(null, e.message);
engineAlert(String title, { String content}) {
  if ( content == null ) {
    content = title;
    title = null;
  }
  showPlatformDialog(
    context: ef.context,
    builder: (_) => PlatformAlertDialog(
      title: title != null ? Text(title) : null,
      content: Text(content),
      actions: <Widget>[
        PlatformDialogAction(
          child: PlatformText(t('Ok')),
          onPressed: () => Navigator.pop(ef.context),
        ),
      ],
    ),
  );
}


  /// Can it be synchronous by using async/await? So, it does not need to use callback functions.
  engineConfirm(
      {String title, String content, Function onNo, Function onYes}) {
    return showPlatformDialog<void>(
      context: ef.context,
      builder: (context) {
        return AlertDialog(
          title: title != null ? Text(title) : null,
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: T('no'),
              onPressed: () {
                onNo();
                _back();
              },
            ),
            FlatButton(
              child: T('yes'),
              onPressed: () {
                onYes();
                _back();
              },
            )
          ],
        );
      },
    );
  }

