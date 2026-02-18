// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuning_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TuningItem _$TuningItemFromJson(Map<String, dynamic> json) => TuningItem(
  id: (json['id'] as num).toInt(),
  brand: json['brand'] as String?,
  carModel: json['model'] as String?,
  title: json['title'] as String?,
  cardImageUrl: json['card_image_url'] as String?,
  fullImageUrl:
      (json['full_image_url'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  price: json['price'],
  description: json['description'] as String?,
  cardDescription: json['card_description'] as String?,
  fullDescription: json['full_description'] as String?,
  videoImageUrl: json['video_image_url'] as String?,
  videoLink: json['video_link'] as String?,
  createdAt: TuningItem._dateFromJson(json['created_at']),
  updatedAt: TuningItem._dateFromJson(json['updated_at']),
);

Map<String, dynamic> _$TuningItemToJson(TuningItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'model': instance.carModel,
      'title': instance.title,
      'card_image_url': instance.cardImageUrl,
      'full_image_url': instance.fullImageUrl,
      'price': instance.price,
      'description': instance.description,
      'card_description': instance.cardDescription,
      'full_description': instance.fullDescription,
      'video_image_url': instance.videoImageUrl,
      'video_link': instance.videoLink,
      'created_at': TuningItem._dateToJson(instance.createdAt),
      'updated_at': TuningItem._dateToJson(instance.updatedAt),
    };
