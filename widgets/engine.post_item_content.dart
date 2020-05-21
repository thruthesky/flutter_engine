
import 'package:clientf/flutter_engine/engine.post.model.dart';
import 'package:clientf/flutter_engine/widgets/engine.display_uploaded_images.dart';
import 'package:flutter/material.dart';

class EnginePostItemContent extends StatelessWidget {
  const EnginePostItemContent(
    this.post, {
    Key key,
  }) : super(key: key);

  final EnginePost post;

  @override
  Widget build(BuildContext context) {
    // print('EnginepostItem content: $post');
    return Column(
      children: <Widget>[
        Text(
          'title: ${post.title}',
          style: TextStyle(fontSize: 32),
        ),
        Text('author: ${post.uid}'),
        Text('created: ${post.createdAt}'),
        Text('content: ${post.content}'),
        EngineDisplayUploadedImages(
          post,
        ),
      ],
    );
  }
}

