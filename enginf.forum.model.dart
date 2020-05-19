import 'package:clientf/enginf_clientf_service/enginf.comment.model.dart';
import 'package:clientf/enginf_clientf_service/enginf.model.dart';
import 'package:clientf/enginf_clientf_service/enginf.post.model.dart';
import 'package:clientf/services/app.i18n.dart';
import 'package:clientf/services/app.service.dart';
import 'package:flutter/material.dart';

/// 게시판 헬퍼 클래스
///
/// 이전에는 `ChangeNotifier`를 extend 하여 `State`를 관리하는 `Model`로 만들어 게시판 목록에서 `Provider`를 해서 사용했다.
/// 그러나 게시판 목록에서만 사용 될 뿐만아니라 보다 범용적으로 사용되는 것이 필요해졌다.
/// 또한 앱의 최 상단에서 `Provider` 하는 것도 무리하게 느껴져,
/// 순수하고 `Future`와 `Callback` 으로만 구현을 하게 되었다.
/// 그 결과 `게시글 목록, 생성, 코멘트 생성 및 기타 기능`을 하나로 묶어 보다 유연하게 사용 할 수 있게 되었다.
///
/// 게시판 목록을 불러 올 때, 이 클래스를 instance 해서 사용하면 된다.
/// * 최근글
/// * 게시판 별 목록 등
///
/// 기능
/// * 캐시
/// * 스크롤이 되면 자동으로 다음 페이지 불러 오기
class EngineForumList {
  String id;
  EngineModel f = EngineModel();

  List<EnginePost> posts = [];

  /// 한 페이지(글 목록)의 글 수. 직접 수정을 하면 된다.
  int noOfPostsPerPage = 10;

  bool loading = false;
  bool noMorePosts = false;
  Function callbackOnLoad;

  final scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  EngineForumList();


  initScrollListener() {
    scrollController.addListener(_scrollListener);
  }


  /// 글 목록을 한다.
  /// 
  /// 글 목록을 할 때, 처음에는 한번 호출을 해 줘야한다. 그 다음 부터는 스크롤읋 할 때마다 자동으로 다음 페이지를 로드한다.
  /// [onLoad] 이 것은 페이지가 로드 될 때 마다 호출 된다. setState() 와 같은 필요한 작업을 하면 된다.
  loadPage({@required Function onLoad}) async {
    if (onLoad != null) callbackOnLoad = onLoad;
    if (noMorePosts) {
      print('---------> No more posts on $id ! just return!');
      return;
    }
    loading = true;
    var req = {
      'categories': [id],
      'limit': noOfPostsPerPage,
      'includeComments': true,
    };
    if (posts.length > 0) {
      req['startAfter'] = posts[posts.length - 1].createdAt;
    }

    try {
      final _re = await f.postList(req);
      loading = false;
      if (_re.length < noOfPostsPerPage) {
        noMorePosts = true;
      }
      posts.addAll(_re);

      callbackOnLoad();
    } catch (e) {
      print(e);

      ///
      AppService.alert(null, t(e));
    }
  }

  void _scrollListener() {
    if (noMorePosts) {
      print('_scrollListener:: no more posts on $id. just return!');
      return;
    }

    bool isBottom = scrollController.offset >=
        scrollController.position.maxScrollExtent - 200;

    if (!isBottom) return;
    if (loading) return;

    /// @warning `mount` check is needed here?

    print('_scrollListener() going to load on $id');
    loadPage(onLoad: null);

    loading = true;
  }

  /// 글을 수정한다.
  updatePost(EnginePost oldPost, EnginePost updatedPost) {
    oldPost.replaceWith(updatedPost);
    // if (post == null) return;

    // int i = posts.indexWhere((p) => p.id == post.id);
    // posts.removeAt(i);
    // posts.insert(i, post);
  }

  /// 글의 코멘트 목록에 코멘트를 하나 끼워 넣는다.
  ///
  /// 코멘트 생성 시에 가짜(임시 코멘트) 정보를 넣을 수도 있다.
  ///
  /// @example
  /// ```dart
  ///   Provider.of<EngineForumModel>(context, listen: false)
  ///     .addComment(
  ///      commentToAdd, post, parentCommentId);
  /// ```
  addComment(EngineComment comment, EnginePost post, String parentId,
      {bool notify: true}) {
    if (comment == null) return;
    var comments = post.comments;

    if (parentId != null) {
      var i = comments.indexWhere((c) => c.id == parentId);
      if (i == -1) {
        print(
            'addComment() critical error. finding comment. This should never happened');
        return;
      }
      comments.insert(i + 1, comment);
    } else {
      comments.insert(0, comment);
    }
  }

  /// 코멘트를 수정하고, 기존의 코멘트와 바꿔치기 한다.
  ///
  /// [comment] 업데이트된 코멘트
  /// TODO: 에러 핸들링. 정상적인 이용에서는 에러가 없지어야 하지만, 혹시라도 ... 코멘트가 없을 수 있다.
  updateComment(EngineComment comment, EnginePost post) {
    int i = post.comments.indexWhere((element) => element.id == comment.id);
    post.comments.removeAt(i);
    post.comments.insert(i, comment);
  }
}
