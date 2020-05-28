import 'package:clientf/flutter_engine/engine.comment.helper.dart';
import 'package:clientf/flutter_engine/engine.globals.dart';
import 'package:clientf/flutter_engine/engine.post.helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// `Firestore` 에 직접 접속해서  목록을 가져오기 위해서 사용.
///
/// 문제: `Engine`으로 접속을 하면 속도가 매우 느리게 나온다.
///   - 게시글 20개 가지고 오는데, 평균 10초에서 13초 걸린다.
///   - 하지만 `Firestorea`로 직접 접속하면 평균 0.3초에서 0.4초 걸린다.
///
/// 글 쓰기, 수정 등은 `Engine` 으로 해야 한다. 그 이유는 대부분의 작업이 한 번의 쿼리로 되는 것이 아니라, 여러번의 작업이 필요하기 때문이다.
///   - 예를 들어, 추천, 비추천 테스를 할 때만 해도 추천을 하기 위해서 `like` collection 을 수정해야하고, 해당 글/코멘트 도큐먼트의 `likes`, `dislikes`를 수정해야 한다.
///     이 처럼, `Firestore`로 모든 것을 다 하기에는 여러가지 번거로운 점이 있으므로,
///     게시판 목록만 사용을 한다.
///
///   - 게시판 록록 외에는 조금 느려도 괜찮다.
///
///
class EngineFirestoreForumModel extends ChangeNotifier {
  EngineFirestoreForumModel();

  /// 하나의 게시판을 목록
  String id;
  int limit;

  /// 에러가 있을 때, `onError` 로 전달한다. 만약, `onError` 가 지정되지 않으면, 기본 `alert`로 에러 표시를 한다.
  Function onError;

  /// 글 목록이 로드 될 때 마다 (첫 페이지에서 캐시를 하는 경우 두번 호출) 호출
  Function onLoad;

  /// 첫 번째 목록을 캐시.
  ///
  /// 인터넷이 안되거나 느린 경우, 첫 페이지를 볼 수 있음.
  String cacheKey;

  /// 첫 페이지인 경우만 캐시를 하도록 조건 검사
  bool get cache {
    return cacheKey != null && pageNo == 1;
  }

  bool noMorePosts = false;
  bool inLoading = false;

  int pageNo = 1;

  List<EnginePost> posts = [];

  /// 스크롤을 감지해서, 다음 페이지 로드
  /// 만약, 첫 페이지만 로드하는 경우, scrollController 를 그냥 무시하면 된다.
  final scrollController =
      ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);

  /// 위젯이 dispose 되었으면, notify 를 하지 않는다.
  /// 이 기능을 활요하기 위해서는 위젯의 dispose 에서 이 변수의 값을 true 로 지정한다.
  bool disposed = false;

  dynamic startAfter;

  void _scrollListener() {
    if (noMorePosts) {
      print('_scrollListener():: no more posts on $id');
      return;
    }

    bool isBottom = scrollController.offset >=
        scrollController.position.maxScrollExtent - 200;

    if (!isBottom) return;
    if (inLoading) return;

    /// @warning `mount` check is needed here?

    // print('_scrollListener() going to load on $_id');
    _loadPage();
  }

  /// notifyListener 를 담당하는 메소드
  ///
  /// disposed 이면, notify 를 하지 않는다.
  notify() {
    if (disposed) return;
    // print('notify(): notifyListeners');
    notifyListeners();
  }

  init({
    String id,
    int limit = 20,
    Function onError,
    Function onLoad,
    String cacheKey,
  }) async {
    this.id = id;
    this.limit = limit;
    this.onError = onError;
    this.onLoad = onLoad;
    this.cacheKey = cacheKey;
    scrollController.addListener(_scrollListener);
    _loadPage();
  }

  /// 글 목록을 한다.
  ///
  /// Model 객체를 생성하면 바로 실행된다. 그리고 ListView 등에 scroll controller 를 연결하고, 스크롤읋 할 때마다 자동으로 다음 페이지를 로드한다.
  ///
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
  _loadPage() async {
    if (noMorePosts) {
      // print('--> _loadPage() - No more posts on $id !');
      return this.posts;
    }
    if (inLoading) {
      print('already in loading. just return');
      return;
    } else
      inLoading = true;
    notify();
    if (cache) {
      final docs = Hive.box(hiveCacheBox).get(cacheKey);
      if (docs != null) {
        posts = [];
        for (final doc in docs) {
          posts.add(EnginePost.fromEngineData(doc));
        }
        if (onLoad != null) onLoad(posts);
        notify();
      }
    }

    Query q = Firestore.instance.collection('post');
    q = q.where('categories', arrayContains: id);
    q = q.orderBy('createdAt', descending: true);
    if (startAfter != null) q = q.startAfter([startAfter]);

    /// 주의: 배열로 넘겨주어야 한다.
    q = q.limit(limit);
    q.snapshots().listen(
      (data) {
        if (isEmpty(data?.documents?.length)) {
          noMorePosts = true;
          inLoading = false;
          notify();
          return;
        }
        startAfter = data.documents.last.data['createdAt'];
        List<EnginePost> _posts = [];
        List _docs = [];
        data.documents.forEach(
          (doc) {
            final docData = doc.data;
            docData['id'] = doc.documentID;
            var _re = EnginePost.fromEngineData(docData);
            // print('_re: ');
            // print(_re);
            _docs.add(docData);
            _posts.add(_re);
            print('title: ${_re.title}');
          },
        );
        if (cache) {
          Hive.box(hiveCacheBox).put(cacheKey, _docs);
        }

        /// 캐시를 하는 경우, 첫 페이지 글은 덮어 쓴다.
        if (cache) {
          posts = _posts;
        } else {
          posts.addAll(_posts);
        }

        // print('posts from firestore: limit: $limit length: ${_posts.length}');
        if (onLoad != null) onLoad(posts);
        if (_posts.length < limit) {
          noMorePosts = true;
        }
        pageNo++;
        inLoading = false;
        print('notify: $pageNo');
        notify();
      },
    ).onError((e) {
      print('------>  EngineFirestoreForumModel::_loadPage() ERROR: $e');
      alert(e);
      inLoading = false;
    });
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
      onError(e);
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
