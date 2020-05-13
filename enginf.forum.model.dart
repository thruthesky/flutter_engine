

import 'package:clientf/enginf_clientf_service/enginf.model.dart';
import 'package:flutter/material.dart';

/// 게시판 기능 (게시글 목록, 생성, 코멘트 생성 등)과 관련된 모델이다.
/// 따라서 게시판 목록에서 게시판마다 별도로 ChangeNotifer 를 해야 한다.
class EngineForumModel extends ChangeNotifier {

  String id;
  EngineModel f = EngineModel();
  EngineForumModel(this.id) {
    print('forum id: $id');
  }

  loadPage() {

  }
}

