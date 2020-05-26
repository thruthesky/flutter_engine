class EngineCategory {
  String id;
  String title;
  String description;
  int createdAt;
  EngineCategory({
    this.id,
    this.title,
    this.description,
    this.createdAt,
  });
  factory EngineCategory.fromEngineData(Map<dynamic, dynamic> data) {
    var re = EngineCategory(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      createdAt: data['createdAt'],
    );
    return re;
  }

  @override
  String toString() {
    return "id: $id, title: $title, description: $description";
  }
}
