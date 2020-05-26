import 'dart:async';

import '../../engine.defines.dart';
import '../../engine.forum_list.model.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../../engine.post.helper.dart';
import '../../widgets/engine.post_title.dart';

import 'package:flutter/material.dart';

/// 최근 글 목록
///
/// * 최근 글 목록의 글 수가 많아지면 overflow 에러가 발생 할 수 있는데, 상단 위젯에서 처리해야한다.
///   이 처럼, 글 목록만 한다.
class EngineLatestPosts extends StatefulWidget {
  EngineLatestPosts(
    this.categories, {
    this.limit = 10,
    this.onError,
    this.onTap,
    Key key,
  }) : super(key: key);

  final int limit;
  final List<String> categories;
  final Function onError;
  final Function onTap;

  @override
  _EngineLatestPostsState createState() => _EngineLatestPostsState();
}

class _EngineLatestPostsState extends State<EngineLatestPosts> {
  final EngineForumListModel forum = EngineForumListModel();

  @override
  void initState() {
    Timer(
      Duration(milliseconds: 100),
      () async {
        await forum.init(
          categories: widget.categories,
          cacheKey: EngineCacheKey.frontPage(''),
          limit: 15,
          onLoad: (posts) {
            if (mounted) setState(() => null);
          },
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (forum.posts.length == 0)
      return Center(child: PlatformCircularProgressIndicator());
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
