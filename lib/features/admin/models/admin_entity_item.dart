import 'package:json_annotation/json_annotation.dart';

part 'admin_entity_item.g.dart';

@JsonSerializable()
class AdminEntityItem {
  const AdminEntityItem({required this.id, required this.values});

  final dynamic id;
  @JsonKey(fromJson: _mapFromJson, toJson: _mapToJson)
  final Map<String, dynamic> values;

  factory AdminEntityItem.fromJson(Map<String, dynamic> json) =>
      _$AdminEntityItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminEntityItemToJson(this);

  factory AdminEntityItem.fromBackend(Map<String, dynamic> json) {
    return AdminEntityItem(
      id: json['id'],
      values: Map<String, dynamic>.from(json),
    );
  }

  static Map<String, dynamic> _mapFromJson(Map<String, dynamic>? json) {
    return json ?? <String, dynamic>{};
  }

  static Map<String, dynamic> _mapToJson(Map<String, dynamic> json) => json;
}
