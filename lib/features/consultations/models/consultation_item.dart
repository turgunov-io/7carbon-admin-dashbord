import 'package:json_annotation/json_annotation.dart';

import 'consultation_status.dart';

part 'consultation_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ConsultationItem {
  const ConsultationItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.serviceType,
    this.carModel,
    this.preferredCallTime,
    this.comments,
    required this.status,
    this.createdAt,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String serviceType;
  final String? carModel;
  final String? preferredCallTime;
  final String? comments;

  @JsonKey(fromJson: consultationStatusFromApi, toJson: consultationStatusToApi)
  final ConsultationStatus status;

  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? createdAt;

  factory ConsultationItem.fromJson(Map<String, dynamic> json) =>
      _$ConsultationItemFromJson(json);

  Map<String, dynamic> toJson() => _$ConsultationItemToJson(this);

  static DateTime? _dateFromJson(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String? _dateToJson(DateTime? value) => value?.toIso8601String();
}
