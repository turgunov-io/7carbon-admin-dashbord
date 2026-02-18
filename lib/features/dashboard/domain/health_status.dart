import 'package:json_annotation/json_annotation.dart';

part 'health_status.g.dart';

@JsonSerializable()
class HealthStatus {
  const HealthStatus({required this.status, required this.db});

  final String status;
  final bool db;

  factory HealthStatus.fromJson(Map<String, dynamic> json) =>
      _$HealthStatusFromJson(json);

  Map<String, dynamic> toJson() => _$HealthStatusToJson(this);
}
