import '../../engine.forum_list.model.dart';
import './engine.comment_edit_form.dart';
import './engine.comment_view_content.dart';
import 'package:provider/provider.dart';

import '../../engine.defines.dart';
import './../engine.text.dart';

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

    EngineForumListModel forum =
        Provider.of<EngineForumListModel>(context, listen: false);
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
                onReply: () async {
                  /// 코멘트 보기에서 Reply 버튼을 클릭한 경우, 코멘트 수정 창을 열고, 결과를 리턴 받음.
                  EngineComment _comment = await openDialog(
                    EngineCommentEditForm(
                      post,
                      currentComment: EngineComment(),
                      parentComment: comment,
                    ),
                  );
                  /// 결과를 목록에 집어 넣는다.
                  forum.addComment(_comment, post, comment.id);
                },
                onUpdate: () async {
                  /// 삭제되면 수정 불가
                  if (ef.isDeleted(comment)) return alert(t(ALREADY_DELETED));

                  /// 자신의 글이 아니면, 에러
                  if (!ef.isMine(comment)) return alert(t(NOT_MINE));

                  EngineComment _comment = await openDialog(
                    EngineCommentEditForm(
                      post,
                      currentComment: comment,
                    ),
                  );
                  forum.updateComment(_comment, post);
                  // model.notify();
                },
                onDelete: () async {
                  /// 코멘트 삭제
                  ///
                  /// 삭제되면 재 삭제 불가
                  if (ef.isDeleted(comment)) return alert(t(ALREADY_DELETED));

                  /// 자신의 글이 아니면, 에러
                  if (!ef.isMine(comment)) return alert(t(NOT_MINE));

                  confirm(
                    title: t(CONFIRM_COMMENT_DELETE_TITLE),
                    content: t(CONFIRM_COMMENT_DELETE_CONTENT),
                    onYes: () async {
                      try {
                        var re = await ef.commentDelete(comment.id);
                        comment.content = re['content'];
                        forum.notify();
                      } catch (e) {
                        alert(e);
                      }
                    },
                    onNo: () {
                      // print('no');
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EngineCommentButtons extends StatelessWidget {
  EngineCommentButtons({
    this.onReply,
    this.onUpdate,
    this.onDelete,
  });
  final Function onReply;
  final Function onUpdate;
  final Function onDelete;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          onPressed: onReply,
          child: T('reply'),
        ),
        FlatButton(
          onPressed: onUpdate,
          child: T('edit'),
        ),
        FlatButton(
          onPressed: onDelete,
          child: T('delete'),
        ),
      ],
    );
  }
}
