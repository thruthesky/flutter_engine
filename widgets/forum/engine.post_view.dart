import './engine.comment_edit_form.dart';
import './engine.post_edit_form.dart';

import '../../engine.comment.helper.dart';
import '../../engine.defines.dart';
import '../../engine.forum_list.model.dart';
import '../../engine.globals.dart';
import '../../engine.post.model.dart';
import '../engine.text.dart';
import './engine.comment_view.dart';
import './engine.post_item_content.dart';
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
              EngineCommentEditForm(
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
            EnginePost _post = await openDialog(
              EnginePostEditForm(post: post),
            );
            forum.updatePost(post, _post);
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
