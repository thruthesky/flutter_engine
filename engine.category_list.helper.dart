
import './engine.category.helper.dart';

class EngineCategoryList {
  List<dynamic> ids;
  List<EngineCategory> categories;
  EngineCategoryList({
    this.ids,
    this.categories,
  });
  factory EngineCategoryList.fromEngineData(Map<dynamic, dynamic> data) {
    // data.keys;

    var _ids = data.keys.toList();
    List<EngineCategory> arr = [];
    for (String id in _ids) {
      var _data = Map.from(data[id]);
      _data['id'] = id;
      // print('data: ');
      // print(_data);
      arr.add(EngineCategory.fromEngineData(_data));
    }

    return EngineCategoryList(
      ids: data.keys.toList(),
      categories: arr,
    );
  }

  @override
  String toString() {
    return "$ids $categories";
  }
}
