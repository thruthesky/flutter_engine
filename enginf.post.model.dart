import 'package:clientf/enginf_clientf_service/enginf.comment.model.dart';

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
  });
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
    );
  }

  @override
  String toString() {
    return "id: $id, uid: $uid, categories: $categories, title: $title, content: $content, createdAt: $createdAt, updated: $updatedAt, deleted: $deletedAt, comments: $comments";
  }
}
