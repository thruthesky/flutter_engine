class EnginPost {
  List<dynamic> categories;
  String title;
  String content;
  int created;
  int updated;
  int deleted;
  String uid;
  String id;
  EnginPost({
    this.id,
    this.uid,
    this.categories,
    this.title,
    this.content,
    this.created,
    this.updated,
    this.deleted,
  });
  factory EnginPost.fromEnginData(Map<dynamic, dynamic> data) {
    return EnginPost(
      id: data['id'],
      categories: data['categories'],
      title: data['title'],
      content: data['content'],
      uid: data['uid'],
      created: data['created'],
      updated: data['updated'],
      deleted: data['deleted'],
    );
  }

  @override
  String toString() {
    return "id: $id, uid: $uid, categories: $categories, title: $title, content: $content, created: $created, updated: $updated, deleted: $deleted";
  }
}
