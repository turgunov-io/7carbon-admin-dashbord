// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsultationItem _$ConsultationItemFromJson(Map<String, dynamic> json) =>
    ConsultationItem(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      serviceType: json['service_type'] as String,
      carModel: json['car_model'] as String?,
      preferredCallTime: json['preferred_call_time'] as String?,
      comments: json['comments'] as String?,
      status: consultationStatusFromApi(json['status'] as String),
      createdAt: ConsultationItem._dateFromJson(json['created_at']),
    );

Map<String, dynamic> _$ConsultationItemToJson(ConsultationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'service_type': instance.serviceType,
      'car_model': instance.carModel,
      'preferred_call_time': instance.preferredCallTime,
      'comments': instance.comments,
      'status': consultationStatusToApi(instance.status),
      'created_at': ConsultationItem._dateToJson(instance.createdAt),
    };
