import 'package:clientf/flutter_engine/engine.forum_list.model.dart';
import 'package:clientf/flutter_engine/widgets/forum/engine.comment_box.dart';
import 'package:clientf/flutter_engine/widgets/forum/engine.comment_view_content.dart';
import 'package:provider/provider.dart';

import '../../engine.defines.dart';
import './../engine.text.dart';

import '../../engine.globals.dart';

import '../../engine.comment.model.dart';
import '../../engine.post.model.dart';
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
                  /// 코멘트에서 Reply 버튼을 클릭한 경우,
                  EngineComment _comment = await openDialog(
                    EngineCommentBox(
                      post,
                      currentComment: EngineComment(),
                      parentComment: comment,
                    ),
                  );
                  forum.addComment(_comment, post, comment.id);
                  // forum.notify();
                },
                onUpdate: () async {
                  EngineComment _comment = await openDialog(
                    EngineCommentBox(
                      post,
                      currentComment: comment,
                    ),
                  );
                  forum.updateComment(_comment, post);
                  // model.notify();
                },
                onDelete: () async {
                  /// 코멘트 삭제
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
