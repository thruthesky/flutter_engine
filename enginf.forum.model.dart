import 'package:clientf/enginf_clientf_service/enginf.model.dart';
import 'package:clientf/enginf_clientf_service/enginf.post.model.dart';
import 'package:clientf/services/app.i18n.dart';
import 'package:clientf/services/app.service.dart';
import 'package:flutter/material.dart';

/// 게시판 기능 (게시글 목록, 생성, 코멘트 생성 등)과 관련된 모델이다.
/// 따라서 게시판 목록에서 게시판마다 별도로 ChangeNotifer 를 해야 한다.
class EngineForumModel extends ChangeNotifier {
  String id;
  EngineModel f = EngineModel();

  List<EnginePost> posts = [];
  int limit = 10;

  bool loading = false;
  bool noMorePosts = false;

  final scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  EngineForumModel() {}

  init({String id}) {
    this.id = id;
    print('init() forum id: ${this.id}');

    loadPage();

    scrollController.addListener(_scrollListener);
  }

  loadPage() async {
    if (noMorePosts) {
      print('---------> No more posts on $id ! just return!');
      return;
    }
    loading = true;
    var req = {
      'categories': [id],
      'limit': limit,
      'includeComments': true,
    };
    if (posts.length > 0) {
      req['startAfter'] = posts[posts.length - 1].createdAt;
    }

    try {
      final _re = await f.postList(req);
      loading = false;
      if (_re.length < limit) {
        print('---------> No more posts on $id !');
        noMorePosts = true;
      }
      print('f.postList()');
      print(_re);

      posts.addAll(_re);

      print('notifyListeners();');
      notifyListeners();

      // for (var _p in _re) {
      //   print(_p.title);
      // }
    } catch (e) {
      print(e);
      AppService.alert(null, t(e));
    }
  }

  void _scrollListener() {
    if (noMorePosts) {
      // print('---------> No more posts on $id ! just return!');
      return;
    }

    bool isBottom = scrollController.offset >=
        scrollController.position.maxScrollExtent - 200;

    if (!isBottom) return;
    if (loading) return;

    /// @warning `mount` check is needed here?

    print('_scrollListener() going to load on $id');
    loadPage();

    loading = true;
    notifyListeners();
  }

  addComment(comment, String postId, String parentId) {
    var post =
        posts.firstWhere((post) => post.id == postId, orElse: () => null);
    if (post == null) {
      print('addComment() critical error. This should never happened');
      return;
    }

    var comments = post.comments;

    if (parentId != null) {
      var i = comments.indexWhere((c) => c['id'] == parentId);
      if (i == -1) {
        print(
            'addComment() critical error. finding comment. This should never happened');
        return;
      }
      /// TODO: depth 가 null 인 경우가 있다. 서버에서 depth 값은 무조건 포함되저 전달되는데, 어디선가 누락되었다.
      /// 항상 depth 가 값을 가지도록 서버에서 고칠 수 있도록 한다.
      comment['depth'] = (comments[i]['depth'] ?? 0) + 1;
      comments.insert(i + 1, comment);
    } else {
      comments.insert(0, comment);
      print(comments);
    }

    // for (var c in post.comments) { // test print
    //   print('content: ${c['content']}');
    // }
    notifyListeners();
  }
}
