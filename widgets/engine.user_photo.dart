import 'package:clientf/flutter_engine/engine.globals.dart';

import '../engine.defines.dart';
import '../widgets/engine.image.dart';
import 'package:flutter/material.dart';

class EngineUserPhoto extends StatelessWidget {
  const EngineUserPhoto(
    this.url, {
    this.onTap,
    Key key,
  }) : super(key: key);

  final String url;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    // print('url: $url');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(),
      child: Material(
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.blueAccent,
        child: SizedBox(
          width: 44,
          height: 44,
          child: (isEmpty(url) ||
                  url == DELETED_PHOTO ||

                  /// 사진이 http 로 시작하는 문자열이 아니면, NetworkCacheImage 에서 부하 에러가 난다.
                  ///
                  url.indexOf('http') != 0)
              ? Image.asset('lib/flutter_engine/assets/images/user-icon.png')
              : EngineImage(url),
        ),
      ),
    );
  }
}
