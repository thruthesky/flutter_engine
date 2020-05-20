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
  }) {
    if (depth == null) depth = 0;
    if (urls == null) urls = [];
  }
  factory EngineComment.fromEnginData(Map<dynamic, dynamic> data) {
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
      urls: data['urls'] != null ? List<dynamic>.from(data['urls']) : [], // To preved 'fixed-length' error.
    );
  }

  @override
  String toString() {
    return "id: $id, uid: $uid, postId: $postId, parentId: $parentId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, dpeth: $depth, urls: $urls";
  }
}
