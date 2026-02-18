// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_post_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkPostItem _$WorkPostItemFromJson(Map<String, dynamic> json) => WorkPostItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  fullDescription: json['fullDescription'] as String,
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  performedWorks:
      (json['performedWorks'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  galleryImages:
      (json['galleryImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$WorkPostItemToJson(WorkPostItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'fullDescription': instance.fullDescription,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'performedWorks': instance.performedWorks,
      'galleryImages': instance.galleryImages,
    };
