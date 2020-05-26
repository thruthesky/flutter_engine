import 'package:clientf/flutter_engine/engine.defines.dart';
import 'package:clientf/flutter_engine/engine.forum_list.model.dart';
import 'package:clientf/flutter_engine/engine.globals.dart';
import 'package:clientf/flutter_engine/engine.post.model.dart';
import 'package:clientf/flutter_engine/widgets/forum/engine.post_edit_form.dart';
import 'package:flutter/material.dart';

class EnginePostCreateActionButton extends StatelessWidget {
  EnginePostCreateActionButton({
    this.id,
    this.forum,
  });

  // final Function onTap;
  final String id;
  final EngineForumListModel forum;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(Icons.add),
      onTap: () async {
        EnginePost _post = await openDialog(
          EnginePostEditForm(id: id),
        );
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
