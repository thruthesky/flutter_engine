import 'package:clientf/flutter_engine/engine.comment.helper.dart';
import 'package:clientf/flutter_engine/engine.defines.dart';
import 'package:clientf/flutter_engine/engine.forum_list.model.dart';
import 'package:clientf/flutter_engine/engine.globals.dart';
import 'package:clientf/flutter_engine/engine.post.model.dart';
import 'package:clientf/flutter_engine/widgets/engine.text.dart';
import 'package:clientf/flutter_engine/widgets/forum/engine.comment_box.dart';
import 'package:clientf/flutter_engine/widgets/forum/engine.comment_view.dart';
import 'package:clientf/flutter_engine/widgets/forum/engine.post_item_content.dart';
import 'package:clientf/globals.dart';
import 'package:clientf/services/app.defines.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnginePostView extends StatelessWidget {
  EnginePostView(this.post);
  final EnginePost post;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnginePostItemContent(post),
        EnginePostViewButtons(post),
        if (post.comments != null)
          for (var c in post.comments)
            EngineCommentView(
              post,
              c,
              key: ValueKey(c.id ?? randomString()),
            ),
      ],
    );
  }
}

class EnginePostViewButtons extends StatelessWidget {
  const EnginePostViewButtons(
    this.post, {
    Key key,
  }) : super(key: key);

  final EnginePost post;
  @override
  Widget build(BuildContext context) {
    EngineForumListModel forum =
        Provider.of<EngineForumListModel>(context, listen: false);
    return Row(
      children: <Widget>[
        FlatButton(
          child: T('Reply'),
          onPressed: () async {
            /// 글에서 Reply 버튼을 클릭한 경우
            EngineComment comment = await openDialog(
              EngineCommentBox(
                post,
                currentComment: EngineComment(),
              ),
            );

            forum.addComment(comment, post, null);

            // forum.notify();
          },
        ),
        FlatButton(
          child: T('Edit'),
          onPressed: () async {
            /// 글 수정
            var updatedPost =
                await open(Routes.postUpdate, arguments: {'post': post});

            /// TODO: 이 코드를 post update 페이지로 집어 넣을 것.
            forum.updatePost(post, updatedPost);
          },
        ),
        FlatButton(
          onPressed: () async {
            confirm(
              title: t(CONFIRM_POST_DELETE_TITLE),
              content: t(CONFIRM_POST_DELETE_CONTENT),
              onYes: () => forum.deletePost(post),
              onNo: () {},
            );
          },
          child: T('Delete'),
        ),
      ],
    );
  }
}
