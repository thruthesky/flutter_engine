class EngineCategory {
  String id;
  String title;
  String description;
  EngineCategory({
    this.id,
    this.title,
    this.description,
  });
  factory EngineCategory.fromEngineData(Map<dynamic, dynamic> data) {
    return EngineCategory(
      id: data['id'],
      title: data['title'],
      description: data['description'],
    );
  }

  @override
  String toString() {
    return "$id, $title, $description";
  }
}
