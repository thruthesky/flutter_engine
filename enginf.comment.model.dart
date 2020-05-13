class EngineComment {
  String content;
  int createdAt;
  int updatedAt;
  int deletedAt;
  String uid;
  String id;
  String postId;
  String parentId;
  EngineComment({
    this.id,
    this.uid,
    this.postId,
    this.parentId,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
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
    );
  }

  @override
  String toString() {
    return "id: $id, uid: $uid, postId: $postId, parentId: $parentId, content: $content, createdAt: $createdAt, updated: $updatedAt, deleted: $deletedAt";
  }
}
