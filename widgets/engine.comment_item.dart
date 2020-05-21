
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
      padding: EdgeInsets.all(AppSpace.space),
      color: AppColor.scaffoldBackgroundColor,
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              EngineCommentContent(comment: widget.comment),
              EngineCommentButtons(
                onReply: () =>
                    widget.onCommentReply(widget.post, widget.comment),
                onUpdate: () {
                  // print('update button clicked: ');
                  // print(widget.comment);
                  widget.onCommentUpdate(widget.post, widget.comment);
                },
                // async {

                //   /// Comment Edit
                //   final re = await AppService.openCommentBox(
                //       widget.post, null, widget.comment);
                //   EngineForum().updateComment(re, widget.post);
                //   setState(() {
                //     /** 코멘트 수정 반영 */
                //   });
                // },
                onDelete: () async {
                  /// Comment Delte
                  var re = await ef.commentDelete(widget.comment.id);
                  setState(() {
                    /** 코멘트 삭제 반영 */
                    widget.comment.content = re['content'];
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EngineCommentContent extends StatelessWidget {
  const EngineCommentContent({
    Key key,
    @required this.comment,
  }) : super(key: key);

  final EngineComment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Container(
        color: AppColor.light,
        margin: EdgeInsets.only(left: AppSpace.space * comment.depth),
        padding: EdgeInsets.all(AppSpace.space),
        child: Column(
          children: <Widget>[
            EngineDisplayUploadedImages(
              comment,
            ),
            Text('[${comment.depth}] ${comment.content}'),
          ],
        ),
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
      children: <Widget>[
        RaisedButton(
          onPressed: onReply,
          child: T('reply'),
        ),
        RaisedButton(
          onPressed: onUpdate,
          child: T('edit'),
        ),
        RaisedButton(
          onPressed: onDelete,
          child: T('delete'),
        ),
      ],
    );
  }
}
