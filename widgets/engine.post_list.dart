
import '../engine.globals.dart';
import 'package:flutter_community_app/flutter_engine/engine.globals.dart';

import './engine.post_item.dart';
import '../engine.forum.dart';
import 'package:flutter/material.dart';


class EnginePostList extends StatefulWidget {
  EnginePostList(
    this.forum, {
      @required this.onEdit,
      @required this.onReply,
    Key key,
  }) : super(key: key);

  final EngineForum forum;
  final Function onEdit;
  final Function onReply;

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
          onEdit: () => widget.onEdit(widget.forum.posts[i]),
          onReply: (post) {
//
          },
          onDelete: () => engineAlert(t('post deleted')),
          onError: (e) => engineAlert(t(e)),
        );
      },
    );
  }
}
