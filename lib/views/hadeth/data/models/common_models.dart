class Metadata {
  final int? length;
  final int? currentPageCount;
  final int? page;
  final bool? hasNextPage;
  final bool? hasPrevPage;
  final int? totalPages;
  final bool? removeHTML;
  final bool? isCached;

  Metadata({
    this.length,
    this.currentPageCount,
    this.page,
    this.hasNextPage,
    this.hasPrevPage,
    this.totalPages,
    this.removeHTML,
    this.isCached,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      length: json['length'],
      currentPageCount: json['currentPageCount'],
      page: json['page'],
      hasNextPage: json['hasNextPage'],
      hasPrevPage: json['hasPrevPage'],
      totalPages: json['totalPages'],
      removeHTML: json['removeHTML'],
      isCached: json['isCached'],
    );
  }

  Map<String, dynamic> toJson() => {
    'length': length,
    'currentPageCount': currentPageCount,
    'page': page,
    'hasNextPage': hasNextPage,
    'hasPrevPage': hasPrevPage,
    'totalPages': totalPages,
    'removeHTML': removeHTML,
    'isCached': isCached,
  };
}

class SuccessWrapper<T> {
  final String status;
  final Metadata? metadata;
  final T data;

  SuccessWrapper({
    required this.status,
    this.metadata,
    required this.data,
  });

  factory SuccessWrapper.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return SuccessWrapper(
      status: json['status'] ?? 'error',
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      data: fromJsonT(json['data']),
    );
  }
}
