// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsultationListResponse _$ConsultationListResponseFromJson(
  Map<String, dynamic> json,
) => ConsultationListResponse(
  status: json['status'] as String,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => ConsultationItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ConsultationItem>[],
);

Map<String, dynamic> _$ConsultationListResponseToJson(
  ConsultationListResponse instance,
) => <String, dynamic>{'status': instance.status, 'data': instance.data};
