import 'dart:async';

import '../engine.space.dart';

import '../../widgets/forum/engine.display_uploaded_images.dart';

import '../../engine.defines.dart';
import '../../widgets/engine.button.dart';

import '../../engine.globals.dart';
import '../../widgets/engine.text.dart';
import '../../widgets/engine.upload_icon.dart';
import '../../widgets/upload_progress_bar.dart';
import '../../../globals.dart';

import '../../engine.post.model.dart';

import 'package:flutter/material.dart';

class EnginePostEditForm extends StatefulWidget {
  EnginePostEditForm({this.id, this.post});
  final String id;
  final EnginePost post;
  @override
  _EnginePostEditFormState createState() => _EnginePostEditFormState();
}

class _EnginePostEditFormState extends State<EnginePostEditForm> {
  EnginePost post = EnginePost();
  String postId;
  int progress = 0;
  bool inSubmit = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Timer(Duration(milliseconds: 10), () {
      setState(() {
        /// 글 생성시, post.id (카테고리)
        postId = widget.id;

        /// 글 수정시, post document.
        var _post = widget.post;
        if (_post != null) {
          post = _post;
          _titleController.text = post.title;
          _contentController.text = post.content;
        }
      });
    });
  }

  /// TODO - form validation
  getFormData() {
    final String title = _titleController.text;
    final String content = _contentController.text;

    /// TODO: 카테고리는 사용자가 선택 할 수 있도록 옵션 처리 할 것.
    final data = {
      'categories': isCreate ? [postId] : post.categories,
      'title': title,
      'content': content,
      'urls': post.urls,
    };

    if (isUpdate) {
      data['id'] = post.id;
    }
    return data;
  }

  bool get isCreate => postId != null;
  bool get isUpdate => !isCreate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: T(postId ?? post.title ?? ''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _titleController,
              onSubmitted: (text) {},
              decoration: InputDecoration(
                hintText: t('input title'),
              ),
            ),
            EngineSpace(),
            TextField(
              controller: _contentController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onSubmitted: (text) {},
              decoration: InputDecoration(
                hintText: t('input content'),
              ),
            ),
            EngineSpace(),
            EngineProgressBar(0),
            EngineDisplayUploadedImages(
              post,
              editable: true,
            ),
            EngineSpace(),
            EngineProgressBar(progress),
            EngineSpace(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                EngineUploadIcon(
                  post,
                  onProgress: (p) {
                    setState(() {
                      progress = p;
                    });
                  },
                  onUploadComplete: (String url) {
                    setState(() {});
                  },
                  onError: (e) => alert(t(e)),
                ),
                EngineButton(
                  loader: inSubmit,
                  text: isCreate ? CREATE_POST : UPDATE_POST,
                  onPressed: () async {
                    if (inSubmit) return;
                    setState(() => inSubmit = true);
                    try {
                      var re;
                      if (isCreate) {
                        re = await ef.postCreate(getFormData());
                      } else {
                        re = await ef.postUpdate(getFormData());
                      }

                      back(arguments: re);
                    } catch (e) {
                      alert(e);
                      setState(() => inSubmit = false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
