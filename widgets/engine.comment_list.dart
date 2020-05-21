import '../engine.globals.dart';
import '../engine.post.model.dart';
<<<<<<< HEAD
import './comment_item.dart';
=======
import './engine.comment_item.dart';

>>>>>>> 9b2cee297ca8547a1698446551b4dd810aefe158
import 'package:flutter/material.dart';

class EngineCommentList extends StatefulWidget {
  EngineCommentList(
    this.post, {
    Key key,
  }) : super(key: key);

  final EnginePost post;
  @override
  _EngineCommentListState createState() => _EngineCommentListState();
}

class _EngineCommentListState extends State<EngineCommentList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// 글 하나에 달려있는 코멘트 목록을 표시한다.
    return Column(
      children: <Widget>[
        if (widget.post.comments != null)
          for (var c in widget.post.comments)
            EngineCommentItem(
              widget.post,
              c,
              key: ValueKey(c.id ?? randomString()),
              onStateChanged: () => setState(() => {}),
            ),
      ],
    );
  }
}
