import './engine.comment.model.dart';
import './engine.model.dart';
import './engine.post.model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
class EngineForum {
  String _id;
  String _cacheKey;
  String _cacheBox = 'cache';

  /// 한 페이지(글 목록)의 글 수. 직접 수정을 하면 된다.
  int _limit;

  /// 페이지(글 목록)을 가져오면 호출
  Function _onLoad;

  /// 글 목록을 가져 올 때, 에러가 있으면 호출
  Function _onError;

  EngineModel f = EngineModel();

  List<EnginePost> posts = [];

  int pageNo = 1;
  bool loading = false;
  bool noMorePosts = false;

  final scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  /// 생성자. 초기화를 한다.
  EngineForum() {
    initScrollListener();
  }

  /// 
  initScrollListener() {
    scrollController.addListener(_scrollListener);
  }

  String get id => _id;
  bool get cache {
    return _cacheKey != null && pageNo == 1;
  }

  /// 글 목록을 한다.
  ///
  /// 글 목록을 할 때, 처음에는 한번 호출을 해 줘야한다. 그 다음 부터는 스크롤읋 할 때마다 자동으로 다음 페이지를 로드한다.
  /// [onLoad] 이 것은 페이지가 로드 될 때 마다 호출 된다. setState() 와 같은 필요한 작업을 하면 된다.
  ///
  /// [cacheKey]이 것이 문자열이면 이면,
  ///
  /// * 첫번째 페이지만 캐시를 한다.
  /// * 첫 페이지를 로드 할 때, `onLoad`가 두번 호출 된다.
  ///
  loadPage({
    String id,
    int limit = 20,
    String cacheKey,
    Function onLoad,
    Function onError,
  }) async {
    _id ??= id;
    _limit ??= limit;
    _cacheKey ??= cacheKey;
    _onLoad ??= onLoad;
    _onError ??= onError;

    if (noMorePosts) {
      print('---------> No more posts on $id ! just return!');
      return;
    }
    loading = true;
    var req = {
      'categories': [id],
      'limit': _limit,
      'includeComments': true,
    };
    if (posts.length > 0) {
      req['startAfter'] = posts[posts.length - 1].createdAt;
    }

    if (cache) {
      var re = Hive.box(_cacheBox).get(cacheKey);
      if (re != null) {
        print('Got cache: cache id: $cacheKey');
        posts = f.sanitizePosts(re);
        _onLoad();
      }
    }

    try {
      final res = await f.postDocuments(req);

      /// 캐시 저장
      if (cache) {
        print('Save cache: cache id: $cacheKey');
        Hive.box(_cacheBox).put(cacheKey, res);
      }
      final _posts = f.sanitizePosts(res);

      loading = false;

      /// 더 이상 글이 없는 경우
      if (_posts.length < _limit) {
        noMorePosts = true;
      }

      /// 캐시를 하는 경우, 첫 페이지 글은 덮어 쓴다.
      if (cache) {
        posts = _posts;
      } else {
        posts.addAll(_posts);
      }

      pageNo++;
      _onLoad();
    } catch (e) {
      print(e);
      if ( _onError != null ) {
        _onError(e);
      }
      ///
      // AppService.alert(null, t(e));
    }
  }

  void _scrollListener() {
    if (noMorePosts) {
      print('_scrollListener:: no more posts on $_id. just return!');
      return;
    }

    bool isBottom = scrollController.offset >=
        scrollController.position.maxScrollExtent - 200;

    if (!isBottom) return;
    if (loading) return;

    /// @warning `mount` check is needed here?

    print('_scrollListener() going to load on $_id');
    loadPage();

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
