import 'package:clientf/flutter_engine/engine.firestore_forum_list.model.dart';
import 'package:clientf/flutter_engine/widgets/engine.text_button.dart';

import './engine.comment_edit_form.dart';
import './engine.comment_view_content.dart';
import 'package:provider/provider.dart';

import '../../engine.defines.dart';

import '../../engine.globals.dart';

import '../../engine.comment.helper.dart';
import '../../engine.post.helper.dart';
import 'package:flutter/material.dart';

class EngineCommentView extends StatelessWidget {
  EngineCommentView(
    this.post,
    this.comment, {
    Key key,
  }) : super(key: key);
  final EnginePost post;
  final EngineComment comment;

  @override
  Widget build(BuildContext context) {
    if (comment == null) return SizedBox.shrink();

    EngineFirestoreForumModel forum =
        Provider.of<EngineFirestoreForumModel>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      color: Colors.black12,
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              EngineCommentViewContent(comment: comment),
              EngineCommentButtons(
                post: post,
                forum: forum,
                comment: comment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EngineCommentButtons extends StatefulWidget {
  EngineCommentButtons({
    this.post,
    this.forum,
    this.comment,
    // this.onReply,
    // this.onUpdate,
    // this.onDelete,
  });
  // final Function onReply;
  // final Function onUpdate;
  // final Function onDelete;
  final EnginePost post;
  final EngineFirestoreForumModel forum;
  final EngineComment comment;

  @override
  _EngineCommentButtonsState createState() => _EngineCommentButtonsState();
}

class _EngineCommentButtonsState extends State<EngineCommentButtons> {
  bool inDelete = false;
  bool inLike = false;
  bool inDisike = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        EngineTextButton(
          onTap: () async {
            /// 코멘트 보기에서 Reply 버튼을 클릭한 경우, 코멘트 수정 창을 열고, 결과를 리턴 받음.
            EngineComment _comment = await openDialog(
              EngineCommentEditForm(
                widget.post,
                currentComment: EngineComment(),
                parentComment: widget.comment,
              ),
            );

            /// 결과를 목록에 집어 넣는다.
            widget.forum.addComment(_comment, widget.post, widget.comment.id);
          },
          text: t('reply'),
        ),
        EngineTextButton(
          onTap: () async {
            /// 삭제되면 수정 불가
            if (ef.isDeleted(widget.comment)) return alert(t(ALREADY_DELETED));

            /// 자신의 글이 아니면, 에러
            if (!ef.isMine(widget.comment)) return alert(t(NOT_MINE));

            EngineComment _comment = await openDialog(
              EngineCommentEditForm(
                widget.post,
                currentComment: widget.comment,
              ),
            );
            widget.forum.updateComment(_comment, widget.post);
            // model.notify();
          },
          text: t('edit'),
        ),
        EngineTextButton(
          loader: inLike,
          text: t('Like') + ' ' + widget.comment.likes.toString(),
          onTap: () async {
            /// 이미 vote 중이면 불가
            if (inLike || inDisike) return;

            /// 글이 삭제되면  불가
            if (ef.isDeleted(widget.comment)) return alert(t(ALREADY_DELETED));

            /// 본인의 글이면 불가
            if (ef.isMine(widget.comment)) return alert(t(CANNOT_VOTE_ON_MINE));
            setState(() => inLike = true);
            final re =
                await ef.commentLike({'id': widget.comment.id, 'vote': 'like'});
            setState(() {
              inLike = false;
              widget.comment.likes = re['likes'];
              widget.comment.dislikes = re['dislikes'];
            });
            print(re);
          },
        ),
        EngineTextButton(
          loader: inDisike,
          text: t('dislike') + ' ' + widget.comment.dislikes.toString(),
          onTap: () async {
            /// 이미 vote 중이면 불가
            if (inLike || inDisike) return;

            /// 글이 삭제되면  불가
            if (ef.isDeleted(widget.comment)) return alert(t(ALREADY_DELETED));

            /// 본인의 글이면 불가
            if (ef.isMine(widget.comment)) return alert(t(CANNOT_VOTE_ON_MINE));
            setState(() => inDisike = true);
            final re = await ef
                .commentLike({'id': widget.comment.id, 'vote': 'dislike'});
            setState(() {
              inDisike = false;
              widget.comment.likes = re['likes'];
              widget.comment.dislikes = re['dislikes'];
            });
            print(re);
          },
        ),
        EngineTextButton(
          loader: inDelete,
          onTap: () async {
            /// 코멘트 삭제
            ///
            /// 삭제되면 재 삭제 불가
            if (ef.isDeleted(widget.comment)) return alert(t(ALREADY_DELETED));

            /// 자신의 글이 아니면, 에러
            if (!ef.isMine(widget.comment)) return alert(t(NOT_MINE));

            confirm(
              title: t(CONFIRM_COMMENT_DELETE_TITLE),
              content: t(CONFIRM_COMMENT_DELETE_CONTENT),
              onYes: () async {
                setState(() => inDelete = true);
                try {
                  var re = await ef.commentDelete(widget.comment.id);
                  widget.comment.content = re['content'];
                  widget.forum.notify();
                } catch (e) {
                  alert(e);
                }
                setState(() => inDelete = false);
              },
              onNo: () {
                // print('no');
              },
            );
          },
          text: t('delete'),
        ),
      ],
    );
  }
}
