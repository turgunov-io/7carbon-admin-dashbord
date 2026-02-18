import 'package:json_annotation/json_annotation.dart';

part 'service_offering_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ServiceOfferingItem {
  const ServiceOfferingItem({
    required this.id,
    this.serviceType,
    this.title,
    this.detailedDescription,
    this.galleryImages = const <String>[],
    this.priceText,
    this.position = 0,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? serviceType;
  final String? title;
  final String? detailedDescription;
  final List<String> galleryImages;
  final String? priceText;

  @JsonKey(fromJson: _intFromJson)
  final int position;

  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? createdAt;

  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? updatedAt;

  factory ServiceOfferingItem.fromJson(Map<String, dynamic> json) =>
      _$ServiceOfferingItemFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceOfferingItemToJson(this);

  static int _intFromJson(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String? _dateToJson(DateTime? value) => value?.toIso8601String();
}
