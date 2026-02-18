// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactItem _$ContactItemFromJson(Map<String, dynamic> json) => ContactItem(
  id: (json['id'] as num).toInt(),
  phoneNumber: json['phone_number'] as String?,
  address: json['address'] as String?,
  description: json['description'] as String?,
  email: json['email'] as String?,
  workSchedule: json['work_schedule'] as String?,
);

Map<String, dynamic> _$ContactItemToJson(ContactItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone_number': instance.phoneNumber,
      'address': instance.address,
      'description': instance.description,
      'email': instance.email,
      'work_schedule': instance.workSchedule,
    };
