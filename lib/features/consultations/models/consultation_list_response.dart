import 'package:json_annotation/json_annotation.dart';

import 'consultation_item.dart';

part 'consultation_list_response.g.dart';

@JsonSerializable()
class ConsultationListResponse {
  const ConsultationListResponse({
    required this.status,
    this.data = const <ConsultationItem>[],
  });

  final String status;
  final List<ConsultationItem> data;

  factory ConsultationListResponse.fromJson(Map<String, dynamic> json) =>
      _$ConsultationListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConsultationListResponseToJson(this);
}
