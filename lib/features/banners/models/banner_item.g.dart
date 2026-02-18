// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerItem _$BannerItemFromJson(Map<String, dynamic> json) => BannerItem(
  id: (json['id'] as num).toInt(),
  section: json['section'] as String,
  title: json['title'] as String,
  imageUrl: json['image_url'] as String,
  priority: (json['priority'] as num).toInt(),
);

Map<String, dynamic> _$BannerItemToJson(BannerItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'section': instance.section,
      'title': instance.title,
      'image_url': instance.imageUrl,
      'priority': instance.priority,
    };
