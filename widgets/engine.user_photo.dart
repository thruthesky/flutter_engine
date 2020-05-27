

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
          child: (url == null || url == '' || url == DELETED_PHOTO)
              ? Image.asset('lib/flutter_engine/assets/images/user-icon.png')
              : EngineImage(url),
        ),
      ),
    );
  }
}