class HadeethListItem {
  final String id;
  final String title;

  HadeethListItem({required this.id, required this.title});

  factory HadeethListItem.fromJson(Map<String, dynamic> json) {
    return HadeethListItem(id: json['id'].toString(), title: json['title']);
  }
}
