import 'package:json_annotation/json_annotation.dart';

part 'api_envelope.g.dart';

@JsonSerializable()
class ApiEnvelope {
  const ApiEnvelope({required this.status, this.data, this.message});

  final String status;
  final dynamic data;
  final String? message;

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) =>
      _$ApiEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$ApiEnvelopeToJson(this);
}
