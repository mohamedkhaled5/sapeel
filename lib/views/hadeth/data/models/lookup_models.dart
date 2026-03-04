import 'common_models.dart';

class LookupItem {
  final String id;
  final String value;

  LookupItem({
    required this.id,
    required this.value,
  });

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    return LookupItem(
      id: json['id']?.toString() ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
  };
}

typedef DataResponse = SuccessWrapper<List<LookupItem>>;
