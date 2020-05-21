import 'package:clientf/flutter_engine/engine.globals.dart';
import 'package:clientf/services/app.service.dart';

import './engine.post_item.dart';
import '../engine.forum.dart';
import 'package:flutter/material.dart';

class EnginePostList extends StatefulWidget {
  EnginePostList(
    this.forum, {
    @required this.onUpdate,
    @required this.onReply,
    @required this.onDelete,
    @required this.onError,
    @required this.onCommentError,
    @required this.onCommentReply,
    @required this.onCommentUpdate,
    @required this.onCommentDelete,
    Key key,
  }) : super(key: key);

  final EngineForum forum;
  final Function onUpdate;
  final Function onReply;
  final Function onDelete;
  final Function onError;

  final Function onCommentReply;
  final Function onCommentUpdate;
  final Function onCommentDelete;
  final Function onCommentError;

  @override
  _EnginePostListState createState() => _EnginePostListState();
}

class _EnginePostListState extends State<EnginePostList> {
  @override
  Widget build(BuildContext context) {
    /// 글을 목록한다.
    return ListView.builder(
      itemCount: widget.forum.posts.length,
      controller: widget.forum.scrollController,
      itemBuilder: (context, i) {
        return EnginePostItem(
          widget.forum.posts[i],
          onUpdate: widget.onUpdate,
          onReply: widget.onReply,
          onDelete: () => widget.onDelete,
          onError: widget.onError,
          onCommentReply: widget.onCommentReply,
          onCommentUpdate: widget.onCommentUpdate,
          onCommentDelete: widget.onCommentDelete,
          onCommentError: widget.onCommentError,

          /// TODO: 게시판 목록에서 코멘트 Error Callback 을 걸 필요 있는가? Error Callback 이 약간 복잡하다.
        );
      },
    );
  }
}
