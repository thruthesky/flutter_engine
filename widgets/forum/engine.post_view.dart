import './engine.comment_edit_form.dart';
import './engine.post_edit_form.dart';

import '../../engine.comment.helper.dart';
import '../../engine.defines.dart';
import '../../engine.forum_list.model.dart';
import '../../engine.globals.dart';
import '../../engine.post.helper.dart';
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
            ///
            /// 글이 삭제되어도 코멘트를 달 수 있다.
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

            /// 글이 삭제되면 수정 불가
            if (ef.isDeleted(post)) return alert(t(ALREADY_DELETED));

            /// 자신의 글이 아니면, 에러
            if (!ef.isMine(post)) return alert(t(NOT_MINE));

            EnginePost _post = await openDialog(
              EnginePostEditForm(post: post),
            );
            if (_post == null) return;
            forum.updatePost(post, _post);

            /// 글 수정 후, 카테고리가 변경되어, 현재 카테고리가 글에 포함되지 않으면, 첫번째 카테고리로 이동한다.
            if (!_post.categories.contains(forum.id)) {
              return redirect(
                EngineRoutes.postList,
                arguments: {'id': _post.categories.first},
              );
            }
          },
        ),
        FlatButton(
          onPressed: () async {
            /// 글이 삭제되면 재 삭제 불가
            if (ef.isDeleted(post)) return alert(t(ALREADY_DELETED));

            /// 자신의 글이 아니면, 에러
            if (!ef.isMine(post)) return alert(t(NOT_MINE));

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
