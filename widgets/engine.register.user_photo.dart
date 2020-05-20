
import '../engine.firestore.dart';
import './engine.space.dart';
import './engine.text.dart';
import 'package:flutter_image/network.dart';

import '../engine.defines.dart';

import '../engine.globals.dart';

import '../engine.user.model.dart';
import 'package:flutter/material.dart';

class EngineRegisterUserPhoto extends StatefulWidget {
  EngineRegisterUserPhoto(
    this.user, {
      @required this.onError,
    Key key,
  }) : super(key: key);

  final EngineUser user;
  final Function onError;

  @override
  _EngineRegisterUserPhotoState createState() => _EngineRegisterUserPhotoState();
}

class _EngineRegisterUserPhotoState extends State<EngineRegisterUserPhoto> {
  @override
  Widget build(BuildContext context) {
    /// `Firebase Auth` 의 `photoUrl` 을 바로 보여준다.
    String url = ef.user?.photoUrl;
    bool hasPhoto = url != null && url != DELETED_PHOTO;
    return Column(
      children: <Widget>[
        hasPhoto
            ? ClipOval(
                child: Image(
                    image: NetworkImageWithRetry(url),
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover),
              )
            : Material(
                elevation: 4.0,
                shape: CircleBorder(),
                clipBehavior: Clip.hardEdge,
                color: Colors.blueAccent,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.person,
                      size: 128,
                      color: Colors.white,
                    )),
              ),
        EngineSpace(),
        if (!hasPhoto) T('Upload photo'),
        if (hasPhoto) ...[
          T('Change photo'),
          RaisedButton(
            onPressed: () async {
              /// 사진 삭제
              try {
                await EngineFirestore(widget.user).delete(url);
                await ef.userUpdate({'photoURL': DELETED_PHOTO}); // @see README
                setState(() {});
              } catch (e) {
                widget.onError(e);
                // AppService.alert(null, t(e));
              }
            },
            child: T('Delete Photo'),
          ),
        ],
      ],
    );
  }
}
