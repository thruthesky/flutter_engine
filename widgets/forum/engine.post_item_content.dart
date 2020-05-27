import '../../engine.globals.dart';
import '../../widgets/engine.user_photo.dart';
import 'package:flutter/material.dart';
import 'package:time_formatter/time_formatter.dart';
import './engine.display_uploaded_images.dart';
import '../../engine.post.helper.dart';

class EnginePostItemContent extends StatelessWidget {
  const EnginePostItemContent(
    this.post, {
    Key key,
  }) : super(key: key);

  final EnginePost post;

  @override
  Widget build(BuildContext context) {
    // print('EnginepostItem content: $post');
    // String dt = DateTime.fromMillisecondsSinceEpoch(post.createdAt).toLocal().toString();
    String formatted = formatTime(post.createdAt);
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              EngineUserPhoto(
                post.photoUrl,
                onTap: () => alert('tap'),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${post.title}',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text('author: ' + (post.displayName ?? post.uid)),
                    Text('created: $formatted'),
                  ],
                ),
              )
            ],
          ),
          Container(
            width: double.infinity,
            color: Colors.black12,
            padding: EdgeInsets.all(8.0),
            child: Text('${post.content}'),
          ),
          EngineDisplayUploadedImages(
            post,
          ),
        ],
      ),
    );
  }
}
