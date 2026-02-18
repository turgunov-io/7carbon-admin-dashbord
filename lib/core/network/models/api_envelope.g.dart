// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiEnvelope _$ApiEnvelopeFromJson(Map<String, dynamic> json) => ApiEnvelope(
  status: json['status'] as String,
  data: json['data'],
  message: json['message'] as String?,
);

Map<String, dynamic> _$ApiEnvelopeToJson(ApiEnvelope instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
      'message': instance.message,
    };
