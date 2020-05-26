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

  /// 글 쓴이 이름.
  ///
  /// `displayName` 은 `Engine` 에서 필수 정보가 아니다. 클라이언트에서 임의로 값을 저장하는 것이다.
  String displayName;

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
  }) {
    if (depth == null) depth = 0;
    if (urls == null) urls = [];
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
    );
  }

  @override
  String toString() {
    return "id: $id, uid: $uid, postId: $postId, parentId: $parentId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, dpeth: $depth, urls: $urls";
  }
}
