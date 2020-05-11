class EnginPost {
  List<dynamic> categories;
  String title;
  String content;
  int created;
  int updated;
  String uid;
  EnginPost({
    this.uid,
    this.categories,
    this.title,
    this.content,
    this.created,
    this.updated,
  });
  factory EnginPost.fromEnginData(Map<dynamic, dynamic> data) {
    return EnginPost(
      categories: data['categories'],
      title: data['title'],
      content: data['content'],
      uid: data['uid'],
      created: data['created'],
      updated: data['updated'],
    );
  }

  @override
  String toString() {
    return "$categories, $uid, $title, $content $created $updated";
  }
}
