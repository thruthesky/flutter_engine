import '../engine.globals.dart';
import '../engine.post.model.dart';
import './engine.comment_item.dart';

import 'package:flutter/material.dart';

class EngineCommentList extends StatefulWidget {
  EngineCommentList(
    this.post, {
    @required this.onCommentReply,
    @required this.onCommentUpdate,
    @required this.onCommentDelete,
    @required this.onCommentError,
    Key key,
  }) : super(key: key);

  final Function onCommentReply;
  final Function onCommentUpdate;
  final Function onCommentDelete;
  final Function onCommentError;

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
              onCommentReply: widget.onCommentReply,
              onCommentUpdate: widget.onCommentUpdate,
              onCommentDelete: widget.onCommentDelete,
              onCommentError: widget.onCommentError,
            ),
      ],
    );
  }
}
