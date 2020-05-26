import 'package:flutter/material.dart';

import '../../engine.comment.helper.dart';
import 'engine.display_uploaded_images.dart';

class EngineCommentViewContent extends StatelessWidget {
  const EngineCommentViewContent({
    Key key,
    @required this.comment,
  }) : super(key: key);

  final EngineComment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Container(
        color: Colors.white70,
        margin: EdgeInsets.only(left: 32.0 * comment.depth),
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            EngineDisplayUploadedImages(
              comment,
            ),
            Text('author: ' + (comment.displayName ?? comment.uid) ),
            Text(comment.content),
          ],
        ),
      ),
    );
  }
}