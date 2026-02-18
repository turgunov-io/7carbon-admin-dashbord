import 'package:json_annotation/json_annotation.dart';

part 'privacy_section_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PrivacySectionItem {
  const PrivacySectionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
  });

  final int id;
  final String title;
  final String description;
  final int position;

  factory PrivacySectionItem.fromJson(Map<String, dynamic> json) =>
      _$PrivacySectionItemFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacySectionItemToJson(this);
}
