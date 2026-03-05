class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int totalItems;
  final int perPage;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.totalItems,
    required this.perPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] is String
          ? int.parse(json['current_page'])
          : json['current_page'],

      lastPage: json['last_page'] is String
          ? int.parse(json['last_page'])
          : json['last_page'],

      totalItems: json['total_items'] is String
          ? int.parse(json['total_items'])
          : json['total_items'],

      perPage: json['per_page'] is String
          ? int.parse(json['per_page'])
          : json['per_page'],
    );
  }
}
