
import '../engine.post.model.dart';
import './engine.post_title.dart';
import 'package:flutter/material.dart';

class EngineLatestPosts extends StatelessWidget {
  EngineLatestPosts(
    this.posts, {
    Key key,
  }) : super(key: key);

  final List<EnginePost> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (EnginePost p in posts) ...[
          EnginePostTitle(post: p),
          Divider(
            color: Colors.black38,
          ),
        ]
      ],
    );
  }
}

