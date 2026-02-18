// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_section_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacySectionItem _$PrivacySectionItemFromJson(Map<String, dynamic> json) =>
    PrivacySectionItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      position: (json['position'] as num).toInt(),
    );

Map<String, dynamic> _$PrivacySectionItemToJson(PrivacySectionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'position': instance.position,
    };
