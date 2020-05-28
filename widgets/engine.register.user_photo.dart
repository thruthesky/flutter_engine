import './engine.button.dart';
import './engine.image.dart';

import '../engine.storage.dart';
import './engine.space.dart';
import './engine.text.dart';
// import 'package:flutter_image/network.dart';

import '../engine.defines.dart';

import '../engine.globals.dart';

import '../engine.user.helper.dart';
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
  _EngineRegisterUserPhotoState createState() =>
      _EngineRegisterUserPhotoState();
}

class _EngineRegisterUserPhotoState extends State<EngineRegisterUserPhoto> {
  bool inDelete = false;
  @override
  Widget build(BuildContext context) {
    /// `Firebase Auth` 의 `photoUrl` 을 바로 보여준다.
    String url = ef.user?.photoUrl;
    bool hasPhoto = url != null && url != DELETED_PHOTO;

    // print('hasPhoto: $hasPhoto, $url');
    return Column(
      children: <Widget>[
        hasPhoto
            ? ClipOval(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: EngineImage(url),
                ),
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
          EngineButton(
            loader: inDelete,
            onPressed: () async {
              /// 사진 삭제
              if (inDelete) return;
              setState(() => inDelete = true);
              try {
                await EngineStorage(widget.user).delete(url);
                await ef.userUpdate({'photoURL': DELETED_PHOTO}); // @see README
                setState(() {});
              } catch (e) {
                widget.onError(e);
                // AppService.alert(null, t(e));
              }

              setState(() => inDelete = false);
            },
            text: t('Delete Photo'),
          ),
        ],
      ],
    );
  }
}
