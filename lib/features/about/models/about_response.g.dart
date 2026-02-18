// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'about_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AboutResponse _$AboutResponseFromJson(Map<String, dynamic> json) =>
    AboutResponse(
      page: json['page'] == null
          ? null
          : AboutPage.fromJson(json['page'] as Map<String, dynamic>),
      metrics:
          (json['metrics'] as List<dynamic>?)
              ?.map((e) => AboutMetric.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AboutMetric>[],
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => AboutSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AboutSection>[],
    );

Map<String, dynamic> _$AboutResponseToJson(AboutResponse instance) =>
    <String, dynamic>{
      'page': instance.page,
      'metrics': instance.metrics,
      'sections': instance.sections,
    };

AboutPage _$AboutPageFromJson(Map<String, dynamic> json) => AboutPage(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String?,
  bannerImageUrl: json['banner_image_url'] as String?,
  introDescription: json['intro_description'] as String?,
  missionDescription: json['mission_description'] as String?,
  videoUrl: json['video_url'] as String?,
  missionImageUrl: json['mission_image_url'] as String?,
);

Map<String, dynamic> _$AboutPageToJson(AboutPage instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'banner_image_url': instance.bannerImageUrl,
  'intro_description': instance.introDescription,
  'mission_description': instance.missionDescription,
  'video_url': instance.videoUrl,
  'mission_image_url': instance.missionImageUrl,
};

AboutMetric _$AboutMetricFromJson(Map<String, dynamic> json) => AboutMetric(
  id: (json['id'] as num).toInt(),
  key: json['key'] as String,
  value: json['value'],
  label: json['label'] as String,
  position: (json['position'] as num).toInt(),
);

Map<String, dynamic> _$AboutMetricToJson(AboutMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'label': instance.label,
      'position': instance.position,
    };

AboutSection _$AboutSectionFromJson(Map<String, dynamic> json) => AboutSection(
  id: (json['id'] as num).toInt(),
  key: json['key'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  position: (json['position'] as num).toInt(),
);

Map<String, dynamic> _$AboutSectionToJson(AboutSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'title': instance.title,
      'description': instance.description,
      'position': instance.position,
    };
