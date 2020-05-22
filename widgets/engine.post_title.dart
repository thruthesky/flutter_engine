import '../engine.defines.dart';
import '../engine.globals.dart';

import '../engine.post.model.dart';
// import 'package:clientf/globals.dart';
// import 'package:clientf/services/services/app.defines.dart';

// import 'package:clientf/services/app.space.dart';
import 'package:flutter/material.dart';

class EnginePostTitle extends StatelessWidget {
  const EnginePostTitle({
    Key key,
    @required this.post,
    this.onTap,
  }) : super(key: key);

  final EnginePost post;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    if ( this.post == null ) return SizedBox.shrink();
    String title;
    if (post.title == null || post.title == '')
      title = t(NO_TITLE);
    else if (post.title == POST_TITLE_DELETED)
      title = t(POST_TITLE_DELETED);
    else
      title = post.title;

    return GestureDetector(
      onTap: () => onTap(post),// open(AppRoutes.postView, arguments: {'post': post}),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
