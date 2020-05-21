import 'package:clientf/flutter_engine/engine.comment.model.dart';
import 'package:clientf/flutter_engine/engine.globals.dart';
import 'package:clientf/flutter_engine/engine.post.model.dart';
import 'package:clientf/services/app.service.dart';

import './engine.post_item.dart';
import '../engine.forum.dart';
import 'package:flutter/material.dart';

class EnginePostList extends StatefulWidget {
  EnginePostList(
    this.forum, {
    @required this.onEdit,
    Key key,
  }) : super(key: key);

  final EngineForum forum;
  final Function onEdit;

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
          onReply: (EnginePost post) async {
            var reply = await AppService.openCommentBox(post, null, EngineComment());
            widget.forum.addComment(reply, post, null);
            setState(() { /** 댓글 반영 */});
          },
          onDelete: () => AppService.alert(null, t('post deleted')),
          onError: (e) => AppService.alert(null, t(e)),
        );
      },
    );
  }
}
