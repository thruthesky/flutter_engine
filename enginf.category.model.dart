class EnginCategory {
  String id;
  String title;
  String description;
  EnginCategory({
    this.id,
    this.title,
    this.description,
  });
  factory EnginCategory.fromEnginData(Map<dynamic, dynamic> data) {
    return EnginCategory(
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
