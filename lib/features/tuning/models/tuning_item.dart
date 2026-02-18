import 'package:json_annotation/json_annotation.dart';

part 'tuning_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TuningItem {
  const TuningItem({
    required this.id,
    this.brand,
    this.carModel,
    this.title,
    this.cardImageUrl,
    this.fullImageUrl = const <String>[],
    this.price,
    this.description,
    this.cardDescription,
    this.fullDescription,
    this.videoImageUrl,
    this.videoLink,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? brand;

  @JsonKey(name: 'model')
  final String? carModel;

  final String? title;
  final String? cardImageUrl;
  final List<String> fullImageUrl;
  final Object? price;
  final String? description;
  final String? cardDescription;
  final String? fullDescription;
  final String? videoImageUrl;
  final String? videoLink;

  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? createdAt;

  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? updatedAt;

  factory TuningItem.fromJson(Map<String, dynamic> json) =>
      _$TuningItemFromJson(json);

  Map<String, dynamic> toJson() => _$TuningItemToJson(this);

  static DateTime? _dateFromJson(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String? _dateToJson(DateTime? value) => value?.toIso8601String();
}
