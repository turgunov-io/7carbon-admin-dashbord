import 'package:json_annotation/json_annotation.dart';

part 'consultation_create_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ConsultationCreateRequest {
  const ConsultationCreateRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.serviceType,
    this.carModel,
    this.preferredCallTime,
    this.comments,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String serviceType;
  final String? carModel;
  final String? preferredCallTime;
  final String? comments;

  factory ConsultationCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ConsultationCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConsultationCreateRequestToJson(this);
}
