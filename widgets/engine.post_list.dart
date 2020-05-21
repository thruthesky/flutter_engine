
import 'package:clientf/flutter_engine/engine.globals.dart';
import 'package:clientf/services/app.service.dart';

import './engine.post_item.dart';
import '../engine.forum.dart';
import 'package:flutter/material.dart';

class EnginePostList extends StatefulWidget {
  EnginePostList(
    this.forum, {
    @required this.onEdit,
    @required this.onReply,
    @required this.onDelete,
    @required this.onError,
    Key key,
  }) : super(key: key);

  final EngineForum forum;
  final Function onEdit;
  final Function onReply;
  final Function onDelete;
  final Function onError;

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
          onEdit: widget.onEdit,
          onReply: widget.onReply,
          onDelete: () => widget.onDelete,
          onError: widget.onError,
        );
      },
    );
  }
}
