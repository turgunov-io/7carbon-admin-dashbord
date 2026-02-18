// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_entity_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminEntityItem _$AdminEntityItemFromJson(Map<String, dynamic> json) =>
    AdminEntityItem(
      id: json['id'],
      values: AdminEntityItem._mapFromJson(
        json['values'] as Map<String, dynamic>?,
      ),
    );

Map<String, dynamic> _$AdminEntityItemToJson(AdminEntityItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'values': AdminEntityItem._mapToJson(instance.values),
    };
