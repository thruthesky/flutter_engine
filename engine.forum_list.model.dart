import './engine.comment.helper.dart';
import './engine.globals.dart';
import './engine.post.helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// 게시판 및 게시글의 State 를 관리한다.
///
/// 게시글 목록을 관리 할 때 사용 할 수 있는 것으로 각 개시판 별로 `EngineForumListModel` 객체를 하나씩 생성해서 `Provide` 해야 한다.
///
/// `init()`을 호출하면 첫 페이지를 로드하고, 스크롤 할 때 마다 다음 페이지를 로드한다.
///
/// 게시글 읽기 페이지에서도 재 활용하여 사용 할 수 있다.
/// * 게시글 읽기 페이지에는 글이 1개 밖에 없다. 따라서 `posts` 변수에 1개의 글만 지정하면 된다.
/// * 게시글 읽기 페이지에서는 `init()`을 호출 할 필요가 없다.
///
class EngineForumListModel extends ChangeNotifier {
  EngineForumListModel();

  /// 하나의 게시판을 목록
  String _id;

  /// 여러 게시판 카테고리를 목록. 주의: 여러개 카테고리를 리스트하는 것은 아직 미완이다.
  List<String> _categories;
  int _limit;

  /// 에러가 있을 때, `onError` 로 전달한다. 만약, `onError` 가 지정되지 않으면, 기본 `alert`로 에러 표시를 한다.
  Function _onError;

  /// 글 목록이 로드 될 때 마다 (첫 페이지에서 캐시를 하는 경우 두번 호출) 호출
  Function _onLoad;

  String _cacheKey;

  bool _noMorePosts = false;
  bool _inLoading = false;

  int pageNo = 1;

  List<EnginePost> posts = [];

  String get id => _id;
  bool get inLoading => _inLoading;
  bool get noMorePosts => _noMorePosts;
  bool get _cache {
    return _cacheKey != null && pageNo == 1;
  }

  bool _disposed = false;
  final scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  /// 게시판 목록을 위한 설정을 초기화 하고, 현재 글 목록을 리턴한다.
  ///
  /// 참고로 리턴 값을 기다렸다가, setState() 로 업데이트를 할 수 있다.
  ///
  /// * Forum List Model 을 초기화 하고,
  /// * loadPage() 를 호출하여 첫번째 페이지를 가져온다.
  ///
  /// @example README 참고
  Future<List<EnginePost>> init({
    String id,
    List<String> categories,
    Function onError,
    Function onLoad,
    String cacheKey,
    limit = 20,
  }) async {
    _id = id;
    _categories = categories;
    _onError = onError;
    _onLoad = onLoad;
    _cacheKey = cacheKey;
    _limit = limit;
    scrollController.addListener(_scrollListener);
    return await _loadPage();
  }

  void _scrollListener() {
    if (_noMorePosts) {
      print('_scrollListener:: no more posts on $_id. just return!');
      return;
    }

    bool isBottom = scrollController.offset >=
        scrollController.position.maxScrollExtent - 200;

    if (!isBottom) return;
    if (_inLoading) return;

    /// @warning `mount` check is needed here?

    // print('_scrollListener() going to load on $_id');
    _loadPage();
  }

  disposed() {
    _disposed = true;
  }

  /// notifyListener 를 담당하는 메소드
  notify() {
    if (_disposed) return;
    notifyListeners();
  }

  /// 글 목록을 한다.
  ///
  /// 글 목록을 할 때, 처음에는 한번 호출을 해 줘야한다. 그 다음 부터는 스크롤읋 할 때마다 자동으로 다음 페이지를 로드한다.
  /// [onLoad] 이 것은 페이지가 로드 될 때 마다 호출 된다. setState() 와 같은 필요한 작업을 하면 된다.
  ///
  /// [cacheKey]이 것이 문자열이면 이면,
  ///
  /// * 첫번째 페이지만 캐시를 한다.
  /// * 게시판을 목록 할 때 마다 `notifyListeners()` 가 되며, callback handler 인 `_onLoad()`가 호출 된다.
  /// * 그리고 첫 페이지에서는 `await ... init()` 를 통해서 페이지 목록을 기다릴 수 있다.
  /// * 첫 페이지를 로드 할 때, `onLoad`가 두번 호출 된다.
  ///
  /// @return async 로 작업하고, 현재 글 목록 전체를 리턴한다.
  Future<List<EnginePost>> _loadPage() async {
    if (_noMorePosts) {
      print('---------> No more posts on $_id ! just return!');
      return this.posts;
    }
    _inLoading = true;
    notify();
    var req = {
      'categories': id == null ? _categories : [_id],
      'limit': _limit,
      'includeComments': true,
    };
    if (posts.length > 0) {
      req['startAfter'] = posts[posts.length - 1].createdAt;
    }

    // print('_cache: $_cache');
    if (_cache) {
      var re = Hive.box(hiveCacheBox).get(_cacheKey);
      if (re != null) {
        posts = ef.sanitizePosts(re);
        // print('Got cache: cache id: $_cacheKey, $posts');
        // print('posts from cache');
        // print(posts);
        if (_onLoad != null) _onLoad(posts);
        notify();
      }
    }

    try {
      final res = await ef.postDocuments(req);

      /// 캐시 저장
      if (_cache) {
        Hive.box(hiveCacheBox).put(_cacheKey, res);
        // print('put cache: $_cacheKey');
      }
      final _posts = ef.sanitizePosts(res);

      /// 더 이상 글이 없는 경우
      if (_posts.length < _limit) {
        _noMorePosts = true;
      }

      /// 캐시를 하는 경우, 첫 페이지 글은 덮어 쓴다.
      if (_cache) {
        posts = _posts;
      } else {
        posts.addAll(_posts);
      }

      // print('posts from backend');
      // print(posts);

      pageNo++;
    } catch (e) {
      if (_onError == null)
        alert(t(e));
      else
        _onError(e);
    }

    _inLoading = false;

    if (_onLoad != null) _onLoad(this.posts);
    notify();
    return this.posts;
  }

  addPost(EnginePost post) {
    if (post == null) return;
    posts.insert(0, post);
    scrollController.jumpTo(0);
    notify();
  }

  /// 글을 수정한다.
  ///
  /// 만약, 글 카테고리가 변경되어, 현재 게시판 카테고리에 더 이상 속하지 않는다면, 글을 목록에서 뺀다.
  updatePost(EnginePost oldPost, EnginePost updatedPost) {
    print('updatePost: updatedPost:');

    /// @see `README 캐시를 하는 경우 글/코멘트 수정 삭제` 참고
    oldPost = this.posts.firstWhere((p) => p.id == oldPost.id);
    print(updatedPost);
    if (updatedPost.categories.contains(id)) {
      oldPost.replaceWith(updatedPost);
    } else {
      posts.removeWhere((p) => p.id == updatedPost.id);
    }
    notify();
  }

  deletePost(EnginePost post) async {
    try {
      final re = await ef.postDelete(post.id);
      post.title = re.title;
      post.content = re.content;
      notify();
    } catch (e) {
      _onError(e);
    }
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
  /// @see `README 캐시를 하는 경우 글/코멘트 수정 삭제` 참고
  addComment(EngineComment comment, EnginePost post, String parentId) {
    if (comment == null) return;

    /// 현재 최신 글 목록(캐시를 한다면, 캐시 데이터가 아닌 실 데이터)의 코멘트 목록을 가져와서 업데이트 한다.
    /// @see `README 캐시를 하는 경우 글/코멘트 수정 삭제` 참고
    post = this.posts.firstWhere((p) => p.id == post.id);

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
    notify();
  }

  /// 코멘트를 수정하고, 기존의 코멘트와 바꿔치기 한다.
  ///
  /// [comment] 업데이트된 코멘트
  updateComment(EngineComment comment, EnginePost post) {
    if (comment == null) return;

    /// @see `README 캐시를 하는 경우 글/코멘트 수정 삭제` 참고
    post = this.posts.firstWhere((p) => p.id == post.id);

    int i = post.comments.indexWhere((element) => element.id == comment.id);
    post.comments.removeAt(i);
    post.comments.insert(i, comment);
    notify();
  }
}
