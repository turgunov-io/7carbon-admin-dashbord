import 'package:json_annotation/json_annotation.dart';

part 'portfolio_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PortfolioItem {
  const PortfolioItem({
    required this.id,
    this.brand,
    required this.title,
    required this.imageUrl,
    this.description,
    this.youtubeLink,
    this.createdAt,
  });

  final int id;
  final String? brand;
  final String title;
  final String imageUrl;
  final String? description;
  final String? youtubeLink;

  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? createdAt;

  factory PortfolioItem.fromJson(Map<String, dynamic> json) =>
      _$PortfolioItemFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioItemToJson(this);

  static DateTime? _dateFromJson(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String? _dateToJson(DateTime? value) => value?.toIso8601String();
}
