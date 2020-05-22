class EngineCategoryList {
  List<dynamic> ids;
  Map<dynamic, dynamic> data;
  EngineCategoryList({
    this.ids,
    this.data,
  });
  factory EngineCategoryList.fromEngineData(Map<dynamic, dynamic> data) {
    // data.keys;

    return EngineCategoryList(
      ids: data.keys.toList(),
      data: data,
    );
  }

  @override
  String toString() {
    return "$ids $data";
  }
}
