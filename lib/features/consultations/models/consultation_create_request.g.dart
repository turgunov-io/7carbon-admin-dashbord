// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsultationCreateRequest _$ConsultationCreateRequestFromJson(
  Map<String, dynamic> json,
) => ConsultationCreateRequest(
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  phone: json['phone'] as String,
  serviceType: json['service_type'] as String,
  carModel: json['car_model'] as String?,
  preferredCallTime: json['preferred_call_time'] as String?,
  comments: json['comments'] as String?,
);

Map<String, dynamic> _$ConsultationCreateRequestToJson(
  ConsultationCreateRequest instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'phone': instance.phone,
  'service_type': instance.serviceType,
  'car_model': ?instance.carModel,
  'preferred_call_time': ?instance.preferredCallTime,
  'comments': ?instance.comments,
};
