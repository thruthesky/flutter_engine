import './engine.globals.dart';

class EngineComment {
  String content;
  int createdAt;
  int updatedAt;
  int deletedAt;
  String uid;
  String id;
  String postId;
  String parentId;
  int depth;

  /// [inLoading] is used only for [post.tempComment] to indiate whether the comment in submission to backend.
  bool inLoading;

  List<dynamic> urls;

  /// 글 쓴이 이름과 photoURL
  ///
  /// `displayName` 과 `photoUrl`은 `Firebase Auth` 에 저장되어져 있는 것을 가져온다.
  String displayName;
  String photoUrl;

  int likes;
  int dislikes;

  EngineComment({
    this.id,
    this.uid,
    this.postId,
    this.parentId,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.depth,
    this.urls,
    this.displayName,
    this.photoUrl,
    this.likes,
    this.dislikes,
  }) {
    if (depth == null) depth = 0;
    if (urls == null) urls = [];
    if (isEmpty(likes)) likes = 0;
    if (isEmpty(dislikes)) dislikes = 0;
  }
  factory EngineComment.fromEngineData(Map<dynamic, dynamic> data) {
    return EngineComment(
      id: data['id'],
      postId: data['postId'],
      parentId: data['parentId'],
      content: data['content'],
      uid: data['uid'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      deletedAt: data['deletedAt'],
      depth: data['depth'],
      urls: data['urls'] != null
          ? List<dynamic>.from(data['urls'])
          : [], // To preved 'fixed-length' error.

      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      likes: data['likes'],
      dislikes: data['dislikes'],
    );
  }

  @override
  String toString() {
    return "id: $id, uid: $uid, postId: $postId, parentId: $parentId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, dpeth: $depth, urls: $urls";
  }
}
