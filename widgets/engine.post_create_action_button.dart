import 'package:clientf/flutter_engine/engine.firestore_forum_list.model.dart';

import '../engine.defines.dart';
import '../engine.globals.dart';
import '../engine.post.helper.dart';
import '../widgets/forum/engine.post_edit_form.dart';
import 'package:flutter/material.dart';

class EnginePostCreateActionButton extends StatelessWidget {
  EnginePostCreateActionButton({
    this.id,
    this.forum,
  });

  // final Function onTap;
  final String id;

  /// forum 모델이 DI 로 호환될 수 있도록 Type 을 주지 않는다.
  final EngineFirestoreForumModel forum;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(Icons.add),
      onTap: () async {
        /// 글 생성
        if (ef.notLoggedIn) return alert(t(LOGIN_FIRST));
        EnginePost _post = await openDialog(
          EnginePostEditForm(id: id),
        );

        /// 글 생성 완료
        if (_post == null) return;

        /// 모델이 있으면 모델에 글 추가
        /// 그런데 어차피
        if (forum != null) forum.addPost(_post);

        /// 글 작성/수정 후, 첫번째 카테고리로 이동
        return redirect(
          EngineRoutes.postList,
          arguments: {'id': _post.categories.first},
        );
      },
    );
  }
}
