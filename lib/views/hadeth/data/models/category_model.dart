class CategoryModel {
  final String id;
  final String title;
  final int hadeethCount;
  final String? parentId;

  CategoryModel({
    required this.id,
    required this.title,
    required this.hadeethCount,
    this.parentId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      title: json['title'],
      hadeethCount: int.parse(json['hadeeths_count'].toString()),
      parentId: json['parent_id']?.toString(),
    );
  }
}
