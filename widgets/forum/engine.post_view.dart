import '../engine.text_button.dart';

import './engine.comment_edit_form.dart';
import './engine.post_edit_form.dart';

import '../../engine.comment.helper.dart';
import '../../engine.defines.dart';
import '../../engine.forum_list.model.dart';
import '../../engine.globals.dart';
import '../../engine.post.helper.dart';
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

class EnginePostViewButtons extends StatefulWidget {
  const EnginePostViewButtons(
    this.post, {
    Key key,
  }) : super(key: key);

  final EnginePost post;

  @override
  _EnginePostViewButtonsState createState() => _EnginePostViewButtonsState();
}

class _EnginePostViewButtonsState extends State<EnginePostViewButtons> {
  bool inDelete = false;
  bool inLike = false;
  bool inDisike = false;
  @override
  Widget build(BuildContext context) {
    EngineForumListModel forum =
        Provider.of<EngineForumListModel>(context, listen: false);
    return Row(
      children: <Widget>[
        EngineTextButton(
          text: t('Reply'),
          onTap: () async {
            /// 글에서 Reply 버튼을 클릭한 경우
            ///
            /// 글이 삭제되어도 코멘트를 달 수 있다.
            EngineComment comment = await openDialog(
              EngineCommentEditForm(
                widget.post,
                currentComment: EngineComment(),
              ),
            );

            forum.addComment(comment, widget.post, null);

            // forum.notify();
          },
        ),
        EngineTextButton(
          text: t('Edit'),
          onTap: () async {
            /// 글 수정

            /// 글이 삭제되면 수정 불가
            if (ef.isDeleted(widget.post)) return alert(t(ALREADY_DELETED));

            /// 자신의 글이 아니면, 에러
            if (!ef.isMine(widget.post)) return alert(t(NOT_MINE));

            EnginePost _post = await openDialog(
              EnginePostEditForm(post: widget.post),
            );
            if (_post == null) return;
            forum.updatePost(widget.post, _post);

            /// 글 수정 후, 카테고리가 변경되어, 현재 카테고리가 글에 포함되지 않으면, 첫번째 카테고리로 이동한다.
            if (!_post.categories.contains(forum.id)) {
              return redirect(
                EngineRoutes.postList,
                arguments: {'id': _post.categories.first},
              );
            }
          },
        ),
        EngineTextButton(
          loader: inLike,
          text: t('Like') + ' ' + widget.post.likes.toString(),
          onTap: () async {
            /// 이미 vote 중이면 불가
            if (inLike || inDisike) return;

            /// 글이 삭제되면  불가
            if (ef.isDeleted(widget.post)) return alert(t(ALREADY_DELETED));

            /// 본인의 글이면 불가
            if (ef.isMine(widget.post)) return alert(t(CANNOT_VOTE_ON_MINE));
            setState(() => inLike = true);
            final re =
                await ef.postLike({'id': widget.post.id, 'vote': 'like'});
            setState(() {
              inLike = false;
              widget.post.likes = re['likes'];
              widget.post.dislikes = re['dislikes'];
            });
            print(re);
          },
        ),
        EngineTextButton(
          loader: inDisike,
          text: t('dislike') + ' ' + widget.post.dislikes.toString(),
          onTap: () async {
            /// 이미 vote 중이면 불가
            if (inLike || inDisike) return;

            /// 글이 삭제되면  불가
            if (ef.isDeleted(widget.post)) return alert(t(ALREADY_DELETED));

            /// 본인의 글이면 불가
            if (ef.isMine(widget.post)) return alert(t(CANNOT_VOTE_ON_MINE));
            setState(() => inDisike = true);
            final re =
                await ef.postLike({'id': widget.post.id, 'vote': 'dislike'});
            setState(() {
              inDisike = false;
              widget.post.likes = re['likes'];
              widget.post.dislikes = re['dislikes'];
            });
            print(re);
          },
        ),
        EngineTextButton(
          loader: inDelete,
          onTap: () async {
            /// 글이 삭제되면 재 삭제 불가
            if (ef.isDeleted(widget.post)) return alert(t(ALREADY_DELETED));

            /// 자신의 글이 아니면, 에러
            if (!ef.isMine(widget.post)) return alert(t(NOT_MINE));

            confirm(
              title: t(CONFIRM_POST_DELETE_TITLE),
              content: t(CONFIRM_POST_DELETE_CONTENT),
              onYes: () async {
                setState(() => inDelete = true);
                await forum.deletePost(widget.post);
                setState(() => inDelete = false);
              },
              onNo: () {},
            );
          },
          text: t('Delete'),
        ),
      ],
    );
  }
}
