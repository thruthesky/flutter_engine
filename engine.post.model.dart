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
  }) {
    if (comments == null) comments = [];
    if (urls == null) urls = [];
  }
  factory EnginePost.fromEnginData(Map<dynamic, dynamic> data) {
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
    );
  }

  /// 현재 글 속성을 입력된 글로 변경한다.
  /// 
  /// 글 수정 할 때 유용하게 사용 할 수 있다.
  replaceWith(EnginePost post) {
    id = post.id;
    categories = post.categories;
    title = post.title;
    content = post.content;
    uid = post.uid;
    createdAt = post.createdAt;
    updatedAt = post.updatedAt;
    deletedAt = post.deletedAt;
    comments = post.comments;
    urls = post.urls ?? [];
  }

  @override
  String toString() {
    return "id: $id, uid: $uid, categories: $categories, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, comments: $comments";
  }
}
