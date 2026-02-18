import 'package:json_annotation/json_annotation.dart';

part 'banner_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BannerItem {
  const BannerItem({
    required this.id,
    required this.section,
    required this.title,
    required this.imageUrl,
    required this.priority,
  });

  final int id;
  final String section;
  final String title;
  final String imageUrl;
  final int priority;

  factory BannerItem.fromJson(Map<String, dynamic> json) =>
      _$BannerItemFromJson(json);

  Map<String, dynamic> toJson() => _$BannerItemToJson(this);
}
