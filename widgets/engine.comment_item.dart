import 'package:clientf/flutter_engine/widgets/engine.comment_content.dart';

import '../engine.defines.dart';
import './engine.text.dart';

import '../engine.globals.dart';

import '../engine.comment.model.dart';
import '../engine.post.model.dart';
import 'package:flutter/material.dart';

class EngineCommentItem extends StatefulWidget {
  EngineCommentItem(
    this.post,
    this.comment, {
    Key key,
    @required this.onCommentReply,
    @required this.onCommentUpdate,
    @required this.onCommentDelete,
    @required this.onCommentError,
  }) : super(key: key);
  final EnginePost post;
  final EngineComment comment;

  final Function onCommentReply;
  final Function onCommentUpdate;
  final Function onCommentDelete;
  final Function onCommentError;

  @override
  _EngineCommentItemState createState() => _EngineCommentItemState();
}

class _EngineCommentItemState extends State<EngineCommentItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.comment == null) return SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      color: Colors.black12,
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              EngineCommentContent(comment: widget.comment),
              EngineCommentButtons(
                onReply: () =>
                    widget.onCommentReply(widget.post, widget.comment),
                onUpdate: () {
                  widget.onCommentUpdate(widget.post, widget.comment);
                },
                onDelete: () async {
                  /// 코멘트 삭제
                  confirm(
                    title: t(CONFIRM_COMMENT_DELETE_TITLE),
                    content: t(CONFIRM_COMMENT_DELETE_CONTENT),
                    onYes: () async {
                      try {
                        var re = await ef.commentDelete(widget.comment.id);
                        setState(() {
                          /** 코멘트 삭제 반영 */
                          widget.comment.content = re['content'];
                        });
                      } catch (e) {
                        widget.onCommentError(e);
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
