import 'package:clientf/flutter_engine/engine.comment.model.dart';
import 'package:clientf/flutter_engine/engine.globals.dart';
import 'package:clientf/flutter_engine/engine.post.model.dart';
import 'package:clientf/globals.dart';
import 'package:clientf/services/app.defines.dart';
import 'package:clientf/services/app.service.dart';

import './engine.post_item.dart';
import '../engine.forum.dart';
import 'package:flutter/material.dart';

class EnginePostList extends StatefulWidget {
  EnginePostList(this.forum, {Key key}) : super(key: key);

  final EngineForum forum;

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
          onEdit: (onDone) async => onDone(
            await open(AppRoutes.postUpdate,
                arguments: {'post': widget.forum.posts[i]}),
          ),
          onReply: (onDone) async => onDone(
            await AppService.openCommentBox(
                widget.forum.posts[i], null, EngineComment()),
          ),
          onDelete: () => AppService.alert(null, t('post deleted')),
          onError: (e) => AppService.alert(null, t(e)),
        );
      },
    );
  }
}
