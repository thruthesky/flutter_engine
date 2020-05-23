import '../engine.defines.dart';
import './engine.comment_list.dart';

import '../engine.globals.dart';
import './engine.post_item_content.dart';

import '../../flutter_engine/engine.post.model.dart';
import '../engine.post.model.dart';

import 'package:flutter/material.dart';

import 'engine.text.dart';

/// 글을 보여주고 수정/삭제/코멘트 등의 작업을 할 수 있다.
///
/// 다만, 새글을 추가하지는 않는다. 따라서 글 목록 자체는 필요 없이 글 하나의 정보만 필요하다.
class EnginePostItem extends StatefulWidget {
  EnginePostItem(
    this.post, {
    this.showContentByDefault = true,
    @required this.onUpdate,
    @required this.onReply,
    @required this.onDelete,
    @required this.onError,
    @required this.onCommentReply,
    @required this.onCommentUpdate,
    @required this.onCommentDelete,
    @required this.onCommentError,
    Key key,
  }) : super(key: key);

  final bool showContentByDefault;
  final EnginePost post;
  final Function onUpdate;
  final Function onReply;
  final Function onDelete;
  final Function onError;

  final Function onCommentReply;
  final Function onCommentUpdate;
  final Function onCommentDelete;
  final Function onCommentError;

  @override
  _EnginePostItemState createState() =>
      _EnginePostItemState(showContentByDefault);
}

class _EnginePostItemState extends State<EnginePostItem> {
  _EnginePostItemState(this.showContent);

  bool showContent;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EnginePost post = widget.post;
    if (showContent) {
      return Column(
        children: <Widget>[
          EnginePostItemContent(post), // 글 제목 & 내용 & 사진 & 기타 정보
          Row(
            children: <Widget>[
              FlatButton(
                child: T('Reply'),
                onPressed: () => widget.onReply(widget.post),
              ),
              FlatButton(
                child: T('Edit'),
                onPressed: () => widget.onUpdate(widget.post),
              ),
              FlatButton(
                onPressed: () async {
                  confirm(
                    title: t(CONFIRM_POST_DELETE_TITLE),
                    content: t(CONFIRM_POST_DELETE_CONTENT),
                    onYes: () async {
                      try {
                        final re = await ef.postDelete(post.id);
                        setState(() {
                          post.title = re.title;
                          post.content = re.content;
                        });
                        if (re.deletedAt is int) {
                          widget.onDelete();
                        }
                      } catch (e) {
                        widget.onError(e);
                      }
                    },
                    onNo: () {},
                  );
                },
                child: T('Delete'),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    showContent = false;
                  });
                },
                child: T('Close'),
              ),
            ],
          ),
          EngineCommentList(
            post,
            key: ValueKey('ColumnList${post.id}'),
            onCommentReply: widget.onCommentReply,
            onCommentUpdate: widget.onCommentUpdate,
            onCommentDelete: widget.onCommentDelete,
            onCommentError: widget.onCommentError,
          ),
          SizedBox(height: 48,),
        ],
      );
    } else {
      return ListTile(
        title: Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Text(post.title ?? 'No title'),
        ),
        trailing: Icon(Icons.keyboard_arrow_down),
        onTap: () {
          setState(() {
            showContent = true;
          });
        },
      );
    }
  }
}
