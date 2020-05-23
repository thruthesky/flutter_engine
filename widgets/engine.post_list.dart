
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
  _EnginePostListState createState() {
    var _state = _EnginePostListState();
    return _state;
    }
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
          // showContentByDefault: false,
          onUpdate: widget.onUpdate,
          onReply: widget.onReply,
          onDelete: () => widget.onDelete,
          onError: widget.onError,
          onCommentReply: widget.onCommentReply,
          onCommentUpdate: widget.onCommentUpdate,
          onCommentDelete: widget.onCommentDelete,
          onCommentError: widget.onCommentError,
        );
      },
    );
  }
}
