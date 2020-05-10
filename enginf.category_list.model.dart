class EnginCategoryList {
  List<dynamic> ids;
  Map<dynamic, dynamic> data;
  EnginCategoryList({
    this.ids,
    this.data,
  });
  factory EnginCategoryList.fromEnginData(Map<dynamic, dynamic> data) {
    // data.keys;

    return EnginCategoryList(
      ids: data.keys.toList(),
      data: data,
    );
  }

  @override
  String toString() {
    return "$ids $data";
  }
}
