import './engine.globals.dart';

/// 글 helper class
///
class EnginePost {
  List<dynamic> categories;
  String title;
  String content;
  int createdAt;
  int updatedAt;
  int deletedAt;
  String uid;
  String id;
  List<dynamic> comments;
  List<dynamic> urls;

  /// 글 쓴이 이름과 photoURL
  ///
  /// `displayName` 과 `photoUrl`은 `Firebase Auth` 에 저장되어져 있는 것을 가져온다.
  String displayName;
  String photoUrl;

  int likes;
  int dislikes;
  EnginePost({
    this.id,
    this.uid,
    this.categories,
    this.title,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.comments,
    this.urls,
    this.displayName,
    this.photoUrl,
    this.likes,
    this.dislikes,
  }) {
    if (comments == null) comments = [];
    if (urls == null) urls = [];
    if (categories != null && categories.length > 0) {
      categories = List.from(categories);
    }
    if (isEmpty(likes)) likes = 0;
    if (isEmpty(dislikes)) dislikes = 0;
  }
  factory EnginePost.fromEngineData(Map<dynamic, dynamic> data) {
    return EnginePost(
      id: data['id'],
      categories: data['categories'],
      title: data['title'],
      content: data['content'],
      uid: data['uid'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      deletedAt: data['deletedAt'],
      comments: data['comments'],
      urls: data['urls'] != null
          ? List<dynamic>.from(data['urls'])
          : [], // To preved 'fixed-length' error.
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      likes: data['likes'],
      dislikes: data['dislikes'],
    );
  }

  /// 현재 글 속성을 입력된 글로 변경한다.
  ///
  /// 글 수정 할 때 유용하게 사용 할 수 있다.
  /// @attention 코멘트는 덮어쓰지 않고 기존의 것을 유지한다.
  replaceWith(EnginePost post) {
    if (post == null) return;
    id = post.id;
    categories = post.categories;
    title = post.title;
    content = post.content;
    uid = post.uid;
    createdAt = post.createdAt;
    updatedAt = post.updatedAt;
    deletedAt = post.deletedAt;
    // comments = post.comments;
    urls = post.urls ?? [];
  }

  @override
  String toString() {
    return "id: $id, uid: $uid, categories: $categories, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, comments: $comments";
  }
}
