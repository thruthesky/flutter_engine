import './engine.comment_list.dart';

import '../engine.globals.dart';
import './engine.post_item_content.dart';

import '../../flutter_engine/engine.forum.dart';
import '../../flutter_engine/engine.post.model.dart';

// import 'package:clientf/services/app.service.dart';
import 'package:flutter/material.dart';

/// 글을 보여주고 수정/삭제/코멘트 등의 작업을 할 수 있다.
///
/// 다만, 새글을 추가하지는 않는다. 따라서 글 목록 자체는 필요 없이 글 하나의 정보만 필요하다.
class EnginePostItem extends StatefulWidget {
  EnginePostItem(
    this.post, {
    @required this.onEdit,
    @required this.onReply,
    @required this.onDelete,
    @required this.onError,
    Key key,
  }) : super(key: key);

  final EnginePost post;
  final Function onEdit;
  final Function onReply;
  final Function onDelete;
  final Function onError;

  @override
  _EnginePostItemState createState() => _EnginePostItemState();
}

class _EnginePostItemState extends State<EnginePostItem> {
  bool showContent = true;
  bool showCommentBox = false;

  @override
  void initState() {
    // print('--> _EnginePostItemState::initState() called for: ${widget.post.id}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EnginePost post = widget.post;
    EngineForum forum = EngineForum();
    if (showContent) {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: EnginePostItemContent(post), // 글 제목 & 내용 & 사진 & 기타 정보
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('Reply'),

                /// README Ping/pong callback 참고
                onPressed: () => widget.onReply((comment) {
                  forum.addComment(comment, post, null);
                  setState(() {
                    /// 코멘트 작성 rendering
                  });
                }),
                // () async {
                //   final re = await AppService.openCommentBox(
                //       post, null, EngineComment());
                //   forum.addComment(re, post, null);
                //   setState(() {
                //     /** 수정 반영 */
                //   });
                // },
              ),
              RaisedButton(
                child: Text('Edit'),

                /// README Ping/pong callback 참고
                onPressed: widget.onEdit,
                // () => widget.onEdit((updatedPost) {
                //   forum.updatePost(post, updatedPost);
                //   setState(() {
                //     /** 수정된 글 rendering */
                //   });
                // }),
              ),
              RaisedButton(
                onPressed: () async {
                  engineConfirm(
                    title: 'confirm',
                    content: 'do you want to delete?',
                    onYes: () async {
                      try {
                        final re = await ef.postDelete(post.id);
                        setState(() {
                          post.title = re.title;
                          post.content = re.content;
                        });
                        // print(re);
                        if (re.deletedAt is int) {
                          // AppService.alert(null, t('post deleted'));
                          widget.onDelete();
                        }
                      } catch (e) {
                        widget.onError(e);
                      }
                    },
                    onNo: () {
                      // print('no');
                    },
                  );
                },
                child: Text('Delete'),
              ),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    showContent = false;
                  });
                },
                child: Text('Close'),
              ),
            ],
          ),
          if (showCommentBox)
            CommentBox(
              post,
              // onCancel: () => setState(() => showCommentBox = false),
              onSubmit: () => setState(() => showCommentBox = false),
              key: ValueKey('EnginePostItem::CommentBox::' + post.id),
            ),
          EngineCommentList(
            post,
            key: ValueKey('ColumnList${post.id}'),
          )
        ],
      );
    } else {
      return ListTile(
        title: Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),

          /// This padding is for testing.
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
