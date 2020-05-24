import 'dart:async';

import 'package:clientf/flutter_engine/engine.forum_list.model.dart';
import 'package:clientf/flutter_engine/engine.post.model.dart';
import 'package:clientf/flutter_engine/widgets/engine.post_title.dart';

import 'package:flutter/material.dart';

/// 최근 글 목록
///
/// * 최근 글 목록의 글 수가 많아지면 overflow 에러가 발생 할 수 있는데, 상단 위젯에서 처리해야한다.
///   이 처럼, 글 목록만 한다.
class EngineLatestPosts extends StatefulWidget {
  EngineLatestPosts(
    this.id, {
    this.limit = 10,
    this.onError,
    this.onTap,
    Key key,
  }) : super(key: key);

  final int limit;
  final String id;
  final Function onError;
  final Function onTap;

  @override
  _EngineLatestPostsState createState() => _EngineLatestPostsState();
}

class _EngineLatestPostsState extends State<EngineLatestPosts> {
  final EngineForumListModel forum = EngineForumListModel();

  @override
  void initState() {
    Timer(Duration(milliseconds: 100), () {
      forum.init(
        id: widget.id,
        cacheKey: 'front-page',
        limit: 15,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (forum.posts == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (EnginePost p in forum.posts) ...[
          EnginePostTitle(
            post: p,
            onTap: widget.onTap,
          ),
          Divider(
            color: Colors.black38,
          ),
        ]
      ],
    );
  }
}
