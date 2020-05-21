import 'package:flutter_community_app/flutter_engine/engine.forum.dart';

import '../engine.post.model.dart';
import './engine.post_title.dart';
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
    Key key,
  }) : super(key: key);

  final int limit;
  final String id;
  final Function onError;

  @override
  _EngineLatestPostsState createState() => _EngineLatestPostsState();
}

class _EngineLatestPostsState extends State<EngineLatestPosts> {
  EngineForum forum = EngineForum();

  @override
  void initState() {
    loadPosts();
    super.initState();
  }

  loadPosts() {
    forum.loadPage(
      id: widget.id,
      limit: widget.limit,
      onLoad: () => setState(() => {}),
      onError: (e) => widget.onError(e),
      cacheKey: 'front-page',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (forum.posts == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (EnginePost p in forum.posts) ...[
          EnginePostTitle(post: p),
          Divider(
            color: Colors.black38,
          ),
        ]
      ],
    );
  }
}
