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

  List<dynamic> startAfter;

  void _scrollListener() {
    if (noMorePosts) {
      print(
          'EngineFirestoreForumModel::_scrollListener():: no more posts on $id. just return!');
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
      print(
          '---------> EngineFirestoreForumModel::_loadPage() - No more posts on $id ! just return!');
      return this.posts;
    }
    inLoading = true;
    notify();
    // var req = {
    //   'categories': [id],
    //   'limit': limit,
    //   'includeComments': true,
    // };

    // print('_cache: $_cache');
    if (cache) {
      final docs = Hive.box(hiveCacheBox).get(cacheKey);
      if (docs != null) {
        posts = [];
        for (final doc in docs) {
          posts.add(EnginePost.fromEngineData(doc));
        }
        // posts = ef.sanitizePosts(re);
        // print('Got cache: cache id: $_cacheKey, $posts');
        // print('posts from cache');
        // print(posts);
        if (onLoad != null) onLoad(posts);
        notify();
      }
    }

    // dynamic startAfter = 0;
    // if (posts.length > 0) {
    //   startAfter = posts[posts.length - 1].createdAt;
    // }
    final watch = Stopwatch()..start();
    var q = Firestore.instance.collection('post');

    q.where('categories', arrayContains: id);
    q.orderBy('createdAt');
    if (startAfter != null) q.startAfter(startAfter);
    q.limit(limit);

    /// TODO: 에러 핸들링을 해야 한다.
    q.snapshots().listen(
      (data) {
        print('time passed by Firestore connection: in ${watch.elapsed}');

        List<EnginePost> _posts = [];
        List _docs = [];
        data.documents.forEach(
          (doc) {
            var _re = EnginePost.fromEngineData(doc.data);
            _docs.add(doc);
            _posts.add(_re);
          },
        );
        if (cache) {
          Hive.box(hiveCacheBox).put(cacheKey, _docs);
        }
        posts.addAll(_posts);
        print('posts from firestore: $posts');
        if (onLoad != null) onLoad(posts);
        if (_posts.length < limit) {
          noMorePosts = true;
        }
        pageNo++;
      },
    ).onError((e) {
      print('------>  EngineFirestoreForumModel::_loadPage() ERROR: $e');
      alert(e);
    });

    inLoading = false;
    notify();
    if (onLoad != null) onLoad(this.posts);

    // try {
    //   final res = await ef.postDocuments(req);

    //   /// 캐시 저장
    //   if (_cache) {
    //     Hive.box(hiveCacheBox).put(_cacheKey, res);
    //     // print('put cache: $_cacheKey');
    //   }
    //   final _posts = ef.sanitizePosts(res);

    //   /// 더 이상 글이 없는 경우
    //   if (_posts.length < _limit) {
    //     _noMorePosts = true;
    //   }

    //   /// 캐시를 하는 경우, 첫 페이지 글은 덮어 쓴다.
    //   if (_cache) {
    //     posts = _posts;
    //   } else {
    //     posts.addAll(_posts);
    //   }

    //   // print('posts from backend');
    //   // print(posts);

    //   pageNo++;
    // } catch (e) {
    //   if (_onError == null)
    //     alert(t(e));
    //   else
    //     _onError(e);
    // }

    // _inLoading = false;

    // if (_onLoad != null) _onLoad(this.posts);
    // notify();
    // return this.posts;
  }
}
